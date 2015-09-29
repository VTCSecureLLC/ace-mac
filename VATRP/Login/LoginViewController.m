//
//  LoginViewController.m
//  VATRP
//
//  Created by Norayr Harutyunyan on 9/3/15.
//  Copyright (c) 2015 Home. All rights reserved.
//

#import "LoginViewController.h"
#import "BFNavigationController.h"
#import "NSViewController+BFNavigationController.h"
#import "AppDelegate.h"
#import "LinphoneManager.h"


@interface LoginViewController ()

@property (weak) IBOutlet NSTextField *textFieldUsername;
@property (weak) IBOutlet NSTextField *textFieldPassword;
@property (weak) IBOutlet NSProgressIndicator *progressIndicatorRegister;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)loadView {
    [super loadView];
    
//    self.view.wantsLayer = YES;
//    self.view.layer.backgroundColor = [NSColor redColor].CGColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(configuringUpdate:)
                                                 name:kLinphoneConfiguringStateUpdate
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(registrationUpdateEvent:)
                                                 name:kLinphoneRegistrationUpdate
                                               object:nil];
    
    [[LinphoneManager instance]	startLinphoneCore];
    [[LinphoneManager instance] lpConfigSetBool:FALSE forKey:@"enable_first_login_view_preference"];

    PayloadType *pt;
    const MSList *elem;
    LinphoneCore *lc=[LinphoneManager getLc];

    for (elem=linphone_core_get_video_codecs(lc);elem!=NULL;elem=elem->next){
        pt=(PayloadType*)elem->data;
        NSString *pref=[LinphoneManager getPreferenceForCodec:pt->mime_type withRate:pt->clock_rate];
        int enable = linphone_core_enable_payload_type(lc,pt,1);
        
        NSLog(@"enable: %d", enable);
    }

    linphone_core_enable_video(lc, YES, YES);

    LpConfig *config = linphone_core_get_config(lc);
    LinphoneVideoPolicy policy;
    policy.automatically_accept = YES;//[self boolForKey:@"accept_video_preference"];
    policy.automatically_initiate = YES;//[self boolForKey:@"start_video_preference"];
    linphone_core_set_video_policy(lc, &policy);
    linphone_core_enable_self_view(lc, YES); // [self boolForKey:@"self_video_preference"]
    BOOL preview_preference = YES;//[self boolForKey:@"preview_preference"];
    lp_config_set_int(config, [LINPHONERC_APPLICATION_KEY UTF8String], "preview_preference", preview_preference);
    MSVideoSize vsize;
    int bw;
    switch (1) { // [self integerForKey:@"video_preferred_size_preference"]
        case 0:
            MS_VIDEO_SIZE_ASSIGN(vsize, 720P);
            // 128 = margin for audio, the BW includes both video and audio
            bw = 1024 + 128;
            break;
        case 1:
            MS_VIDEO_SIZE_ASSIGN(vsize, VGA);
            // no margin for VGA or QVGA, because video encoders can encode the
            // target resulution in less than the asked bandwidth
            bw = 512;
            break;
        case 2:
        default:
            MS_VIDEO_SIZE_ASSIGN(vsize, QVGA);
            bw = 380;
            break;
    }

    [self startUp];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"%@ - viewWillAppear: %i", self.title, animated);
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"%@ - viewDidAppear: %i", self.title, animated);
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"%@ - viewWillDisappear: %i", self.title, animated);
}

- (void)viewDidDisappear:(BOOL)animated {
    NSLog(@"%@ - viewDidDisappear: %i", self.title, animated);
}

- (IBAction)onButtonLogin:(id)sender {
    self.progressIndicatorRegister.hidden = NO;
    [self.progressIndicatorRegister startAnimation:nil];
    
    [self verificationSignInWithUsername:self.textFieldUsername.stringValue
                                password:self.textFieldPassword.stringValue
                                  domain:@"bc1.vatrp.net"
                           withTransport:@"TCP"];
}

- (void)startUp {
    LinphoneCore* core = nil;
    @try {
        core = [LinphoneManager getLc];
        LinphoneManager* lm = [LinphoneManager instance];
        LinphoneGlobalState linphoneGlobalState = linphone_core_get_global_state(core);
        if( linphone_core_get_global_state(core) != LinphoneGlobalOn ){
            //            [self changeCurrentView: [DialerViewController compositeViewDescription]];
        } else if ([[LinphoneManager instance] lpConfigBoolForKey:@"enable_first_login_view_preference"]  == true) {
            // Change to fist login view
            //            [self changeCurrentView: [FirstLoginViewController compositeViewDescription]];
        } else {
            // always start to dialer when testing
            // Change to default view
            const MSList *list = linphone_core_get_proxy_config_list(core);
            if(list != NULL || ([lm lpConfigBoolForKey:@"hide_wizard_preference"]  == true) || lm.isTesting) {
                //                [self changeCurrentView: [DialerViewController compositeViewDescription]];
            } else {
                //                WizardViewController *controller = DYNAMIC_CAST([[PhoneMainView instance] changeCurrentView:[WizardViewController compositeViewDescription]], WizardViewController);
                //                if(controller != nil) {
                //                    [controller reset];
                //                }
            }
        }
        //        [self updateApplicationBadgeNumber]; // Update Badge at startup
    }
    @catch (NSException *exception) {
        // we'll wait until the app transitions correctly
    }
}

- (void)configuringUpdate:(NSNotification *)notif {
    LinphoneConfiguringState status = (LinphoneConfiguringState)[[notif.userInfo valueForKey:@"state"] integerValue];
    
    //    [waitView setHidden:true];
    
    switch (status) {
        case LinphoneConfiguringSuccessful:
            //            if( nextView == nil ){
            [self fillDefaultValues];
            //            } else {
            //                [self changeView:nextView back:false animation:TRUE];
            //                nextView = nil;
            //            }
            break;
        case LinphoneConfiguringFailed:
        {
            //            NSString* error_message = [notif.userInfo valueForKey:@"message"];
            //            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Provisioning Load error", nil)
            //                                                            message:error_message
            //                                                           delegate:nil
            //                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
            //                                                  otherButtonTitles: nil];
            //            [alert show];
            break;
        }
            
        case LinphoneConfiguringSkipped:
        default:
            break;
    }
}

#pragma mark - Event Functions

- (void)registrationUpdateEvent:(NSNotification*)notif {
    NSString* message = [notif.userInfo objectForKey:@"message"];
    [self registrationUpdate:[[notif.userInfo objectForKey: @"state"] intValue] message:message];
}

- (void)fillDefaultValues {
    
    LinphoneCore* lc = [LinphoneManager getLc];
    //    [self resetTextFields];
    
    LinphoneProxyConfig* current_conf = NULL;
    linphone_core_get_default_proxy([LinphoneManager getLc], &current_conf);
    if( current_conf != NULL ){
        const char* proxy_addr = linphone_proxy_config_get_identity(current_conf);
        if( proxy_addr ){
            LinphoneAddress *addr = linphone_address_new( proxy_addr );
            if( addr ){
                const LinphoneAuthInfo *auth = linphone_core_find_auth_info(lc, NULL, linphone_address_get_username(addr), linphone_proxy_config_get_domain(current_conf));
                linphone_address_destroy(addr);
                if( auth ){
                    NSLog(@"A proxy config was set up with the remote provisioning, skip wizard");
                    //                    [self onCancelClick:nil];
                }
            }
        }
    }
    
    LinphoneProxyConfig* default_conf = linphone_core_create_proxy_config([LinphoneManager getLc]);
    const char* identity = linphone_proxy_config_get_identity(default_conf);
    if( identity ){
        LinphoneAddress* default_addr = linphone_address_new(identity);
        if( default_addr ){
            const char* domain = linphone_address_get_domain(default_addr);
            const char* username = linphone_address_get_username(default_addr);
            if( domain && strlen(domain) > 0){
                //UITextField* domainfield = [WizardViewController findTextField:ViewElement_Domain view:externalAccountView];
                //                [provisionedDomain setText:[NSString stringWithUTF8String:domain]];
            }
            
            if( username && strlen(username) > 0 && username[0] != '?' ){
                //UITextField* userField = [WizardViewController findTextField:ViewElement_Username view:externalAccountView];
                //                [provisionedUsername setText:[NSString stringWithUTF8String:username]];
            }
        }
    }
    
    //    [self changeView:provisionedAccountView back:FALSE animation:TRUE];
    
    linphone_proxy_config_destroy(default_conf);
}

- (void) verificationSignInWithUsername:(NSString*)username password:(NSString*)password domain:(NSString*)domain withTransport:(NSString*)transport {
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
    
//    [self setDefaultSettings:proxyCfg];
    
    [self clearProxyConfig];
    
    //    NSString *serverAddress = [NSString stringWithFormat:@"sip:%@:%@", self.textFieldDomain.text, self.textFieldPort.text];
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

#pragma mark -

- (void)registrationUpdate:(LinphoneRegistrationState)state message:(NSString*)message{
    switch (state) {
        case LinphoneRegistrationOk: {
            [self.progressIndicatorRegister stopAnimation:nil];

            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:kLinphoneConfiguringStateUpdate
                                                          object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:kLinphoneRegistrationUpdate
                                                          object:nil];
            
            [[AppDelegate sharedInstance] showTabWindow];
            [[AppDelegate sharedInstance].loginWindowController close];
            break;
        }
        case LinphoneRegistrationNone:
        case LinphoneRegistrationCleared:  {
//            [waitView setHidden:true];
            break;
        }
        case LinphoneRegistrationFailed: {
//            [waitView setHidden:true];
            NSAlert *alert = [[NSAlert alloc]init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:message];
            [alert runModal];

            break;
        }
        case LinphoneRegistrationProgress: {
//            [waitView setHidden:false];
            break;
        }
        default:
            break;
    }
}

@end
