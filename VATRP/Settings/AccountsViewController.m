//
//  AccountsViewController.m
//  vatrp
//
//  Created by Ruben Semerjyan on 9/22/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "AccountsViewController.h"
#import "LinphoneManager.h"
#import "AccountsService.h"

@interface AccountsViewController () {
    AccountModel *accountModel;
    BOOL isChanged;
}

@property (weak) IBOutlet NSTextField *textFieldUsername;
@property (weak) IBOutlet NSSecureTextField *secureTextFieldPassword;
@property (weak) IBOutlet NSTextField *textFieldDomain;
@property (weak) IBOutlet NSTextField *textFieldPort;
@property (weak) IBOutlet NSComboBox *comboBoxTransport;
@property (weak) IBOutlet NSButton *buttonAutoAnswer;
@property (weak) IBOutlet NSTextField *settingsFeedbackText;

@end

@implementation AccountsViewController

- (void) awakeFromNib {
    [super awakeFromNib];
    
    isChanged = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    LinphoneCore *lc = [LinphoneManager getLc];
    LinphoneProxyConfig *cfg=NULL;
    linphone_core_get_default_proxy(lc,&cfg);
    
    if (cfg) {
        const char *identity=linphone_proxy_config_get_identity(cfg);
        LinphoneAddress *addr=linphone_address_new(identity);
        
        // Get SIP Transport
        LinphoneTransportType transport = linphone_address_get_transport(addr);
        
        if(transport == LinphoneTransportUdp){
            linphone_address_set_transport(addr, LinphoneTransportTcp);
            transport = linphone_address_get_transport(addr);
        }
        
        NSString *sip_transport = @"";
        switch (transport) {
            case LinphoneTransportTcp:
                sip_transport = @"Unencrypted (TCP)";
                break;
            case LinphoneTransportTls:
                sip_transport = @"Encrypted (TLS)";
                break;
                
            default:
                break;
        }
    }
    
    accountModel = [[AccountsService sharedInstance] getDefaultAccount];
    
    if(accountModel.username != NULL) { self.textFieldUsername.stringValue = accountModel.username; }
    if(accountModel.password != NULL) { self.secureTextFieldPassword.stringValue = accountModel.password; }
    if(accountModel.domain != NULL) { self.textFieldDomain.stringValue = accountModel.domain; }
    self.textFieldPort.stringValue = [NSString stringWithFormat:@"%d", accountModel.port];
    if(accountModel.transport != NULL) { [self.comboBoxTransport selectItemWithObjectValue:accountModel.transport]; }
    NSInteger auto_answer = [[NSUserDefaults standardUserDefaults] boolForKey:@"ACE_AUTO_ANSWER_CALL"];
    self.buttonAutoAnswer.state = auto_answer;
    
}

- (IBAction)onButtonAutoAnswer:(id)sender {
}

- (void) save {
    if (!isChanged) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:self.buttonAutoAnswer.state forKey:@"ACE_AUTO_ANSWER_CALL"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[AccountsService sharedInstance] removeAccountWithUsername:accountModel.username];
    [[AccountsService sharedInstance] addAccountWithUsername:self.textFieldUsername.stringValue
                                                    Password:self.secureTextFieldPassword.stringValue
                                                      Domain:self.textFieldDomain.stringValue
                                                   Transport:self.comboBoxTransport.stringValue
                                                        Port:self.textFieldPort.intValue
                                                   isDefault:YES];
    
    [self verificationSignInWithUsername:self.textFieldUsername.stringValue
                                password:self.secureTextFieldPassword.stringValue
                                  domain:@"bc1.vatrp.net"
                           withTransport:self.comboBoxTransport.stringValue];
    
    self.settingsFeedbackText.stringValue = @"Settings saved";
    
}

- (void) verificationSignInWithUsername:(NSString*)username password:(NSString*)password domain:(NSString*)domain withTransport:(NSString*)transport {
    
    if([transport isEqualToString:@"Unencrypted (TCP)"]){
        transport = @"TCP";
    }

    else if([transport isEqualToString:@"Encrypted (TLS)"]){
        transport = @"TLS";
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
            //                [self addProxyConfig:username password:password domain:domain withTransport:transport];
            //                [[PhoneMainView instance] changeCurrentView:[DialerViewController compositeViewDescription]];
            //            }];
            //            [alert show];
        } else {
            BOOL success = [self addProxyConfig:username password:password domain:domain withTransport:transport];
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

- (BOOL)addProxyConfig:(NSString*)username password:(NSString*)password domain:(NSString*)domain withTransport:(NSString*)transport {
    LinphoneCore* lc = [LinphoneManager getLc];
    LinphoneProxyConfig* proxyCfg = linphone_core_create_proxy_config(lc);
    NSString* server_address = domain;
    
    char normalizedUserName[256];
    linphone_proxy_config_normalize_number(proxyCfg, [username cStringUsingEncoding:[NSString defaultCStringEncoding]], normalizedUserName, sizeof(normalizedUserName));
    
    const char* identity = linphone_proxy_config_get_identity(proxyCfg);
    if( !identity || !*identity ) identity = "sip:user@example.com";
    
    LinphoneAddress* linphoneAddress = linphone_address_new(identity);
    linphone_address_set_username(linphoneAddress, normalizedUserName);
    
    if( domain && [domain length] != 0) {
        if( transport != nil ){
            server_address = [NSString stringWithFormat:@"%@;transport=%@", server_address, [transport lowercaseString]];
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
    
//    NSString *serverAddress = [NSString stringWithFormat:@"sip:%@:%@", domain, self.textFieldPort.stringValue];
    linphone_proxy_config_enable_register(proxyCfg, true);
//    linphone_proxy_config_set_server_addr(proxyCfg, [serverAddress UTF8String]);
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

- (void)controlTextDidChange:(NSNotification *)notification {
    isChanged = YES;
}

- (IBAction)onComboboxTransport:(id)sender {
    isChanged = YES;
}

- (IBAction)onCheckBoxAutoAnswerCall:(id)sender {
    isChanged = YES;
}

@end
