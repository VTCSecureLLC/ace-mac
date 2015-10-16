//
//  RegistrationService.m
//  ACE
//
//  Created by Edgar Sukiasyan on 10/7/15.
//  Copyright © 2015 Home. All rights reserved.
//

#import "RegistrationService.h"
#import "LinphoneManager.h"
#import "Utils.h"

@implementation RegistrationService

+ (RegistrationService *)sharedInstance
{
    static RegistrationService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RegistrationService alloc] init];
    });
    
    return sharedInstance;
}

- (id) init {
    self = [super init];
    
    if (self) {
        [[LinphoneManager instance]	startLinphoneCore];
        [[LinphoneManager instance] lpConfigSetBool:FALSE forKey:@"enable_first_login_view_preference"];
    }
    
    return self;
}

- (void) registerWithAccountModel:(AccountModel*)accountModel {
    [self verificationSignInWithUsername:accountModel.username
                                password:accountModel.password
                                  domain:accountModel.domain
                           withTransport:accountModel.transport
                                    port:accountModel.port];
}

- (void) registerWithUsername:(NSString*)username
                     password:(NSString*)password
                       domain:(NSString*)domain
                    transport:(NSString*)transport
                         port:(int)port {
    [self verificationSignInWithUsername:username
                                password:password
                                  domain:domain
                           withTransport:transport
                                    port:port];
}

- (void) asyncRegisterWithAccountModel:(AccountModel*)accountModel {
    [NSThread detachNewThreadSelector:@selector(registerThread:) toTarget:self withObject:accountModel];
}

- (void) registerThread:(AccountModel*)accountModel {
    @autoreleasepool {
        
        while ([LinphoneManager instance].connectivity == none) {
            [NSThread sleepForTimeInterval:0.1];
        }
        
        [[RegistrationService sharedInstance] registerWithAccountModel:accountModel];
    }
}

- (void) verificationSignInWithUsername:(NSString*)username password:(NSString*)password domain:(NSString*)domain withTransport:(NSString*)transport port:(int)port {
    
    if([transport isEqualToString:@"Unencrypted (TCP)"]){
        transport = @"TCP";
    }
    else if([transport isEqualToString:@"Encrypted (TLS)"]){
        transport = @"TLS";
    } else {
        transport = @"TCP";
    }

    if ([self verificationWithUsername:username password:password domain:domain withTransport:transport]) {
        if ([LinphoneManager instance].connectivity == none) {
            NSAlert *alert = [[NSAlert alloc]init];
            [alert addButtonWithTitle:NSLocalizedString(@"Stay here", nil)];
            [alert addButtonWithTitle:NSLocalizedString(@"Continue", nil)];
            [alert setMessageText:NSLocalizedString(@"You can either skip verification or connect to the Internet first.", nil)];
            [alert runModal];
            
            //            [alert addButtonWithTitle:NSLocalizedString(@"Continue", nil) block:^{
            //                [waitView setHidden:true];
            [self addProxyConfig:username password:password domain:domain withTransport:transport port:port];
            //                [[PhoneMainView instance] changeCurrentView:[DialerViewController compositeViewDescription]];
            //            }];
            //            [alert show];
        } else {
            BOOL success = [self addProxyConfig:username password:password domain:domain withTransport:transport port:port];
            //            if( !success ){
            //                waitView.hidden = true;
            //            }
        }
    }
}

- (BOOL) verificationWithUsername:(NSString*)username password:(NSString*)password domain:(NSString*)domain withTransport:(NSString*)transport {
    NSMutableString *errors = [NSMutableString string];
    if ([username length] == 0) {
        [errors appendString:[NSString stringWithFormat:NSLocalizedString(@"Please enter a valid username.\n", nil)]];
    }
    
    if (domain != nil && [domain length] == 0) {
        [errors appendString:[NSString stringWithFormat:NSLocalizedString(@"Please enter a valid domain.\n", nil)]];
    }
    
    if([errors length]) {
        // run a modal alert
        NSAlert *alert = [[NSAlert alloc]init];
        [alert addButtonWithTitle:NSLocalizedString(@"Continue",nil)];
        [alert setMessageText:[errors substringWithRange:NSMakeRange(0, [errors length] - 1)]];
        [alert runModal];
        
        //        UIAlertView* errorView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Check error(s)",nil)
        //                                                            message:[errors substringWithRange:NSMakeRange(0, [errors length] - 1)]
        //                                                           delegate:nil
        //                                                  cancelButtonTitle:NSLocalizedString(@"Continue",nil)
        //                                                  otherButtonTitles:nil,nil];
        //        [errorView show];
        return FALSE;
    }
    return TRUE;
}

- (BOOL)addProxyConfig:(NSString*)username password:(NSString*)password domain:(NSString*)domain withTransport:(NSString*)transport port:(int)port {
    transport = [transport lowercaseString];
    LinphoneCore* lc = [LinphoneManager getLc];
    LinphoneProxyConfig* proxyCfg = linphone_core_create_proxy_config(lc);
    NSString* server_address = domain;
    
    NSLog(@"addProxyConfig transport=%@",transport);
    
    char normalizedUserName[256];
    linphone_proxy_config_normalize_number(proxyCfg, [username cStringUsingEncoding:[NSString defaultCStringEncoding]], normalizedUserName, sizeof(normalizedUserName));
    
    const char* identity = linphone_proxy_config_get_identity(proxyCfg);
    
    if( !identity || !*identity ) identity = "sip:user@example.com";
    
    LinphoneAddress* linphoneAddress = linphone_address_new(identity);
    linphone_address_set_username(linphoneAddress, normalizedUserName);
    
    if( domain && [domain length] != 0) {
        if( transport != nil ){
            server_address = [NSString stringWithFormat:@"%@;transport=%@", server_address, [transport lowercaseString]];
            
            if ([transport isEqualToString:@"tls"]) {
                
                NSString *cer_file = [Utils resourcePathForFile:@"cafile" Type:@"pem"];
                
                if (cer_file) {
                    linphone_core_set_root_ca(lc, [cer_file UTF8String]);
                }
            }
        }
        // when the domain is specified (for external login), take it as the server address
        linphone_proxy_config_set_server_addr(proxyCfg, [server_address UTF8String]);
        linphone_address_set_domain(linphoneAddress, [domain UTF8String]);
    }
    
    char* extractedAddres = linphone_address_as_string_uri_only(linphoneAddress);
    
    LinphoneAddress* parsedAddress = linphone_address_new(extractedAddres);
    ms_free(extractedAddres);
    
    if( parsedAddress == NULL || !linphone_address_is_sip(parsedAddress) ){
        if( parsedAddress ) linphone_address_destroy(parsedAddress);
        
        NSAlert *alert = [[NSAlert alloc]init];
        [alert addButtonWithTitle:NSLocalizedString(@"Continue",nil)];
        [alert setMessageText:NSLocalizedString(@"Please enter a valid username", nil)];
        [alert runModal];
        
        return FALSE;
    }
    
    char *c_parsedAddress = linphone_address_as_string_uri_only(parsedAddress);
    
    linphone_proxy_config_set_identity(proxyCfg, c_parsedAddress);
    
    linphone_address_destroy(parsedAddress);
    ms_free(c_parsedAddress);
    
    LinphoneAuthInfo* info = linphone_auth_info_new([username UTF8String]
                                                    , NULL, [password UTF8String]
                                                    , NULL
                                                    , NULL
                                                    ,linphone_proxy_config_get_domain(proxyCfg));
    
    [self setDefaultSettings:proxyCfg];
    
    [self clearProxyConfig];
    
    NSString *serverAddress = [NSString stringWithFormat:@"sip:%@:%d;transport=%@", domain, port, transport];
    linphone_proxy_config_enable_register(proxyCfg, true);
    linphone_proxy_config_set_server_addr(proxyCfg, [serverAddress UTF8String]);
    linphone_core_add_auth_info(lc, info);
    linphone_core_add_proxy_config(lc, proxyCfg);
    linphone_core_set_default_proxy_config(lc, proxyCfg);
    
    return TRUE;
}

- (void)setDefaultSettings:(LinphoneProxyConfig*)proxyCfg {
    LinphoneManager* lm = [LinphoneManager instance];
    
    [lm configurePushTokenForProxyConfig:proxyCfg];
    
}

- (void)clearProxyConfig {
    linphone_core_clear_proxy_config([LinphoneManager getLc]);
    linphone_core_clear_all_auth_info([LinphoneManager getLc]);
}

@end
