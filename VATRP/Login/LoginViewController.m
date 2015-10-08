//
//  LoginViewController.m
//  VATRP
//
//  Created by Norayr Harutyunyan on 9/3/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import "LoginViewController.h"
#import "BFNavigationController.h"
#import "NSViewController+BFNavigationController.h"
#import "AppDelegate.h"
#import "LinphoneManager.h"
#import "AccountsService.h"
#import "RegistrationService.h"
#import "Utils.h"


@interface LoginViewController ()

@property (weak) IBOutlet NSTextField *textFieldUsername;
@property (weak) IBOutlet NSTextField *textFieldPassword;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [AppDelegate sharedInstance].loginViewController = self;
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
    
    NSString *first = [[NSUserDefaults standardUserDefaults] objectForKey:@"ACE_FIRST_OPEN"];
    
    if (!first) {
        MSVideoSize vsize;
        MS_VIDEO_SIZE_ASSIGN(vsize, VGA);
        linphone_core_set_preferred_video_size([LinphoneManager getLc], vsize);
        
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"ACE_FIRST_OPEN"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    AccountModel *accountModel = [[AccountsService sharedInstance] getDefaultAccount];
    
    if (accountModel) {
        self.textFieldUsername.stringValue = accountModel.username;
        self.textFieldPassword.stringValue = accountModel.password;
    }
}

- (IBAction)onButtonLogin:(id)sender {
    [[RegistrationService sharedInstance] registerWithUsername:self.textFieldUsername.stringValue
                                                      password:self.textFieldPassword.stringValue
                                                        domain:@"bc1.vatrp.net"
                                                 withTransport:@"TLS"];

    [[AppDelegate sharedInstance] showTabWindow];
    [[AppDelegate sharedInstance].loginWindowController close];
    [AppDelegate sharedInstance].loginWindowController = nil;
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

#pragma mark -

- (void)registrationUpdate:(LinphoneRegistrationState)state message:(NSString*)message{
    switch (state) {
        case LinphoneRegistrationOk: {
            [[AccountsService sharedInstance] addAccountWithUsername:self.textFieldUsername.stringValue
                                                            Password:self.textFieldPassword.stringValue
                                                              Domain:@"bc1.vatrp.net"
                                                           Transport:@"TCP"
                                                                Port:5060
                                                           isDefault:YES];
            break;
        }
        case LinphoneRegistrationNone:
        case LinphoneRegistrationCleared:  {
            break;
        }
        case LinphoneRegistrationFailed: {
            NSAlert *alert = [[NSAlert alloc]init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:message];
            [alert runModal];

            break;
        }
        case LinphoneRegistrationProgress: {
            break;
        }
        default:
            break;
    }
}

@end
