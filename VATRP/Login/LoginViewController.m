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
#import "AccountsService.h"
#import "RegistrationService.h"
#import "Utils.h"


@interface LoginViewController () {
    AccountModel *loginAccount;
}

@property (weak) IBOutlet NSTextField *textFieldUsername;
@property (weak) IBOutlet NSTextField *textFieldUserID;
@property (weak) IBOutlet NSTextField *textFieldPassword;
@property (weak) IBOutlet NSTextField *textFieldDomain;
@property (weak) IBOutlet NSTextField *textFieldPort;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)loadView {
    [super loadView];
    
    [AppDelegate sharedInstance].loginViewController = self;

    [[LinphoneManager instance]	startLinphoneCore];
    [[LinphoneManager instance] lpConfigSetBool:FALSE forKey:@"enable_first_login_view_preference"];
}

- (IBAction)onButtonLogin:(id)sender {
    loginAccount = [[AccountModel alloc] init];
    loginAccount.username = self.textFieldUsername.stringValue;
    loginAccount.userID = self.textFieldUserID.stringValue;
    loginAccount.password = self.textFieldPassword.stringValue;
    loginAccount.domain = self.textFieldDomain.stringValue;
    loginAccount.transport = @"TCP";
    loginAccount.port = self.textFieldPort.intValue;
    
    [[RegistrationService sharedInstance] registerWithUsername:loginAccount.username
                                                        UserID:loginAccount.userID
                                                      password:loginAccount.password
                                                        domain:loginAccount.domain
                                                     transport:loginAccount.transport
                                                          port:loginAccount.port];
}

- (void) viewDidDisappear {
    [super viewDidDisappear];

    [AppDelegate sharedInstance].loginViewController = nil;
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
    LinphoneRegistrationState state = [[notif.userInfo objectForKey: @"state"] intValue];
    [self registrationUpdate:state message:message];
    
    if (state == LinphoneRegistrationOk) {
        [[[[AppDelegate sharedInstance].homeWindowController getHomeViewController] getProfileView] registrationUpdateEvent:notif];
    }
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

- (void)registrationUpdate:(LinphoneRegistrationState)state message:(NSString*)message {
    switch (state) {
        case LinphoneRegistrationOk: {
            [[AccountsService sharedInstance] addAccountWithUsername:loginAccount.username
                                                              UserID:loginAccount.userID
                                                            Password:loginAccount.password
                                                              Domain:loginAccount.domain
                                                           Transport:loginAccount.transport
                                                                Port:loginAccount.port
                                                           isDefault:YES];
            
            [[AppDelegate sharedInstance] showTabWindow];
            [[AppDelegate sharedInstance].loginWindowController close];
            [AppDelegate sharedInstance].loginWindowController = nil;
            
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
