//
//  RegistrationService.m
//  ACE
//
//  Created by Ruben Semerjyan on 10/7/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "RegistrationService.h"
#import "SDPNegotiationService.h"
#import "LinphoneManager.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "DefaultSettingsManager.h"
#import "CodecModel.h"

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
        BOOL shouldAutoLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"auto_login"];
        if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"auto_login"]){
            shouldAutoLogin = NO;
        }

        if (shouldAutoLogin) {
            [[LinphoneManager instance]	startLinphoneCore];
            [[LinphoneManager instance] lpConfigSetBool:FALSE forKey:@"enable_first_login_view_preference"];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(registrationUpdateEvent:)
                                                     name:kLinphoneRegistrationUpdate
                                                   object:nil];
    }
    
    return self;
}

-(void)dealloc{
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:kLinphoneRegistrationUpdate
//                                                  object:nil];
}

- (void) registerWithAccountModel:(AccountModel*)accountModel {
    [self verificationSignInWithUsername:accountModel.username
                                  UserID:accountModel.userID ? accountModel.userID : accountModel.username
                                password:accountModel.password
                                  domain:accountModel.domain
                           withTransport:accountModel.transport
                                    port:accountModel.port];
}

- (void) registerWithUsername:(NSString*)username
                       UserID:(NSString*)userID
                     password:(NSString*)password
                       domain:(NSString*)domain
                    transport:(NSString*)transport
                         port:(int)port {
    [self verificationSignInWithUsername:username
                                  UserID:userID ? userID : username
                                password:password
                                  domain:domain
                           withTransport:transport
                                    port:port];
}

- (void) asyncRegisterWithAccountModel:(AccountModel*)accountModel {
    [NSThread detachNewThreadSelector:@selector(registerThread:) toTarget:self withObject:accountModel];
    
    [self sortAudioCodecs];
    [self sortVideoCodecs];
}

- (void) registerThread:(AccountModel*)accountModel {
    @autoreleasepool {
        
        while ([LinphoneManager instance].connectivity == none) {
            [NSThread sleepForTimeInterval:0.1];
        }
        
        [[RegistrationService sharedInstance] registerWithAccountModel:accountModel];
    }
}

- (void) verificationSignInWithUsername:(NSString*)username UserID:(NSString*)userID password:(NSString*)password domain:(NSString*)domain withTransport:(NSString*)transport port:(int)port {
    
    if([transport isEqualToString:@"Unencrypted (TCP)"]){
        transport = @"TCP";
    }
    else if([transport isEqualToString:@"Encrypted (TLS)"] || [[transport lowercaseString] isEqualToString:@"tls"]){
        transport = @"TLS";
    } else {
        transport = @"TCP";
    }

    if ([self verificationWithUsername:username UserID:userID password:password domain:domain withTransport:transport]) {
        if ([LinphoneManager instance].connectivity == none) {
            NSAlert *alert = [[NSAlert alloc]init];
            [alert addButtonWithTitle:NSLocalizedString(@"Stay here", nil)];
            [alert addButtonWithTitle:NSLocalizedString(@"Continue", nil)];
            [alert setMessageText:NSLocalizedString(@"You can either skip verification or connect to the Internet first.", nil)];
            [alert runModal];
            
            //            [alert addButtonWithTitle:NSLocalizedString(@"Continue", nil) block:^{
            //                [waitView setHidden:true];
            [self addProxyConfig:username UserID:userID password:password domain:domain withTransport:transport port:port];
            //                [[PhoneMainView instance] changeCurrentView:[DialerViewController compositeViewDescription]];
            //            }];
            //            [alert show];
        } else {
            BOOL success = [self addProxyConfig:username UserID:userID password:password domain:domain withTransport:transport port:port];
            //            if( !success ){
            //                waitView.hidden = true;
            //            }
        }
    }
}

- (BOOL) verificationWithUsername:(NSString*)username UserID:(NSString*)userID password:(NSString*)password domain:(NSString*)domain withTransport:(NSString*)transport {
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

- (BOOL)addProxyConfig:(NSString*)username UserID:(NSString*)userID password:(NSString*)password domain:(NSString*)domain withTransport:(NSString*)transport port:(int)port {
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
                                                    ,[userID UTF8String]
                                                    ,[password UTF8String]
                                                    ,NULL
                                                    ,NULL
                                                    ,linphone_proxy_config_get_domain(proxyCfg));
    
    [self setDefaultSettings:proxyCfg];
    
    [self clearProxyConfig];
    
    NSString *serverAddress = [NSString stringWithFormat:@"sip:%@:%d;transport=%@", domain, port, transport];
//    linphone_proxy_config_enable_register(proxyCfg, true);
    linphone_proxy_config_set_server_addr(proxyCfg, [serverAddress UTF8String]);
    linphone_core_add_auth_info(lc, info);
    linphone_core_add_proxy_config(lc, proxyCfg);
    linphone_core_set_default_proxy_config(lc, proxyCfg);
    
    PayloadType *pt;
    const MSList *elem;

    for (elem=linphone_core_get_video_codecs(lc);elem!=NULL;elem=elem->next){
        pt=(PayloadType*)elem->data;
        NSString *pref=[SDPNegotiationService getPreferenceForCodec:pt->mime_type withRate:pt->clock_rate];
        int enable = -1;
        if (pref != nil)
        {
            enable = linphone_core_enable_payload_type(lc,pt,true);
        }
        else
        {
            // explicitly disable or linphone leaves it enabled.
            enable = linphone_core_enable_payload_type(lc, pt, false);
        }

        NSLog(@"enable: %d", enable);
    }

    LpConfig *config = linphone_core_get_config(lc);
    LinphoneVideoPolicy policy;
    policy.automatically_accept = YES;//[self boolForKey:ENABLE_VIDEO_ACCEPT];
    policy.automatically_initiate = YES;//[self boolForKey:ENABLE_VIDEO_START];
    linphone_core_set_video_policy(lc, &policy);
    linphone_core_enable_self_view(lc, YES); // [self boolForKey:VIDEO_SELF_VIEW_ENABLED]
    BOOL preview_preference = YES;//[self boolForKey:@"preview_preference"];
    lp_config_set_int(config, [LINPHONERC_APPLICATION_KEY UTF8String], "preview_preference", preview_preference);

    NSString *first = [[NSUserDefaults standardUserDefaults] objectForKey:@"ACE_FIRST_OPEN"];

    // ToDo: Hardcoded on 2-2 per request - force cif
    if (!first) {
        MSVideoSize vsize;
        MS_VIDEO_SIZE_ASSIGN(vsize, CIF);
        linphone_core_set_preferred_video_size([LinphoneManager getLc], vsize);

        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"ACE_FIRST_OPEN"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

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

- (void)registrationUpdateEvent:(NSNotification*)notif {
    LinphoneRegistrationState state = (LinphoneRegistrationState)[[notif.userInfo objectForKey: @"state"] intValue];
    NSString* message = [notif.userInfo objectForKey:@"message"];

    if (state == LinphoneRegistrationOk) {
        NSDictionary *dictAudioCodec = [[NSUserDefaults standardUserDefaults] objectForKey:@"kUSER_DEFAULTS_AUDIO_CODECS_MAP"];
        NSDictionary *dictVideoCodec = [[NSUserDefaults standardUserDefaults] objectForKey:@"kUSER_DEFAULTS_VIDEO_CODECS_MAP"];
        
        LinphoneCore *lc = [LinphoneManager getLc];
        PayloadType *pt;
        const MSList *elem;
        
        const MSList *audioCodecs = linphone_core_get_audio_codecs(lc);
        
        for (elem = audioCodecs; elem != NULL; elem = elem->next) {
            pt = (PayloadType *)elem->data;
            NSString *pref = [SDPNegotiationService getPreferenceForCodec:pt->mime_type withRate:pt->clock_rate];
        
            if ([dictAudioCodec objectForKey:pref])
            {
                linphone_core_enable_payload_type(lc, pt, [[dictAudioCodec objectForKey:pref] boolValue]);
            }
            else
            {
                linphone_core_enable_payload_type(lc, pt, false);
            }
                
        }
        
        const MSList *videoCodecs = linphone_core_get_video_codecs(lc);
        
        for (elem = videoCodecs; elem != NULL; elem = elem->next) {
            pt = (PayloadType *)elem->data;
            NSString *pref = [SDPNegotiationService getPreferenceForCodec:pt->mime_type withRate:pt->clock_rate];
        
            if ([dictVideoCodec objectForKey:pref])
            {
                linphone_core_enable_payload_type(lc, pt, [[dictVideoCodec objectForKey:pref] boolValue]);
            }
            else
            {
                linphone_core_enable_payload_type(lc, pt, false);
            }
        }
    }

    if ([AppDelegate sharedInstance].loginViewController) {
        [[AppDelegate sharedInstance].loginViewController registrationUpdate:state message:message];
    }
}

- (void) sortAudioCodecs {
    LinphoneCore *lc = [LinphoneManager getLc];
    MSList *audioCodecs = NULL;
    PayloadType *pt = [self findCodec:@"g722_preference"];
    if (pt) {
        audioCodecs = ms_list_append(audioCodecs, pt);
        linphone_core_enable_payload_type(lc, pt, YES);
    }
    
    pt = [self findCodec:@"pcmu_preference"];
    if (pt) {
        audioCodecs = ms_list_append(audioCodecs, pt);
        linphone_core_enable_payload_type(lc, pt, YES);
    }
    
    pt = [self findCodec:@"pcma_preference"];
    if (pt) {
        audioCodecs = ms_list_append(audioCodecs, pt);
        linphone_core_enable_payload_type(lc, pt, YES);
    }

    pt = [self findCodec:@"speex_8k_preference"];
    if (pt) {
        audioCodecs = ms_list_append(audioCodecs, pt);
        linphone_core_enable_payload_type(lc, pt, YES);
    }

    pt = [self findCodec:@"speex_16k_preference"];
    if (pt) {
        audioCodecs = ms_list_append(audioCodecs, pt);
        linphone_core_enable_payload_type(lc, pt, YES);
    }
    
    linphone_core_set_audio_codecs(lc, audioCodecs);
}

- (void) sortVideoCodecs {
    LinphoneCore *lc = [LinphoneManager getLc];
    MSList *videoCodecs = NULL;
    PayloadType *pt = [self findCodec:@"h264_preference"];
    if (pt) {
        videoCodecs = ms_list_append(videoCodecs, pt);
        linphone_core_enable_payload_type(lc, pt, YES);
    }
    
    pt = [self findCodec:@"h263_preference"];
    if (pt) {
        videoCodecs = ms_list_append(videoCodecs, pt);
        linphone_core_enable_payload_type(lc, pt, YES);
    }
    
    pt = [self findCodec:@"vp8_preference"];
    if (pt) {
        videoCodecs = ms_list_append(videoCodecs, pt);
        linphone_core_enable_payload_type(lc, pt, YES);
    }
    
    linphone_core_set_video_codecs(lc, videoCodecs);
}

- (PayloadType*)findCodec:(NSString*)codec {
    LinphoneCore *lc = [LinphoneManager getLc];
    PayloadType *pt;
    const MSList *elem;
    
    const MSList *audioCodecs = linphone_core_get_audio_codecs(lc);
    
    for (elem = audioCodecs; elem != NULL; elem = elem->next) {
        pt = (PayloadType *)elem->data;
        NSString *pref = [SDPNegotiationService getPreferenceForCodec:pt->mime_type withRate:pt->clock_rate];
        
        if ([pref isEqualToString:codec]) {
            return pt;
        }
    }
    
    const MSList *videoCodecs = linphone_core_get_video_codecs(lc);
    
    for (elem = videoCodecs; elem != NULL; elem = elem->next) {
        pt = (PayloadType *)elem->data;
        NSString *pref = [SDPNegotiationService getPreferenceForCodec:pt->mime_type withRate:pt->clock_rate];
        
        if ([pref isEqualToString:codec]) {
            return pt;
        }
    }

    return nil;
}

@end
