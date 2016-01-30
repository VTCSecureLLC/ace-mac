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
#import "SettingsService.h"
#import "RegistrationService.h"
#import "Utils.h"
#import "DefaultSettingsManager.h"
#import "CustomComboBox.h"


@interface LoginViewController ()<DefaultSettingsManagerDelegate, CustomComboBoxDelegate> {
    AccountModel *loginAccount;
}
@property (weak) IBOutlet NSProgressIndicator *prog_Signin;

@property (weak) IBOutlet NSTextField *textFieldUsername;
@property (weak) IBOutlet NSTextField *textFieldUserID;
@property (weak) IBOutlet NSTextField *textFieldPassword;
@property (weak) IBOutlet NSTextField *textFieldDomain;
@property (weak) IBOutlet NSTextField *textFieldPort;
@property (weak) IBOutlet NSButton *loginButton;

@property (weak) IBOutlet NSButton *buttonToggleAutoLogin;
@property (weak) IBOutlet NSComboBox *comboBoxProviderSelect;
@property (weak) NSURLSession *urlSession;
@property NSMutableArray *cdnResources;
@property (strong, nonatomic) IBOutlet CustomComboBox *customComboBox;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self.prog_Signin setHidden:YES];
    [self.loginButton setEnabled:YES];
    _customComboBox.delegate = self;
}

- (void)loadView {
    [super loadView];
    
    [AppDelegate sharedInstance].loginViewController = self;

    [[LinphoneManager instance]	startLinphoneCore];
    [[LinphoneManager instance] lpConfigSetBool:FALSE forKey:@"enable_first_login_view_preference"];
    
    AccountModel *accountModel = [[AccountsService sharedInstance] getDefaultAccount];

    if (accountModel) {
        self.textFieldUsername.stringValue = accountModel.username;
        self.textFieldUserID.stringValue = accountModel.userID;
        self.textFieldDomain.stringValue = accountModel.domain;
        self.textFieldPort.stringValue = [NSString stringWithFormat:@"%d", accountModel.port];
    }
    
    BOOL shouldAutoLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"auto_login"];
    [self.buttonToggleAutoLogin setState:shouldAutoLogin];
                    [self.comboBoxProviderSelect removeAllItems];
    [self reloadProviderDomains];
}

const NSString *cdnProviderList = @"http://cdn.vatrp.net/domains.json";
-(void) reloadProviderDomains{
    _urlSession = [NSURLSession sharedSession];
    [[_urlSession dataTaskWithURL:[NSURL URLWithString:(NSString*)cdnProviderList] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *jsonParsingError = nil;
        if(data){
            NSArray *resources = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:0 error:&jsonParsingError];
            if(!jsonParsingError){
                NSDictionary *resource;
                _cdnResources = [[NSMutableArray alloc] init];
                [[NSUserDefaults standardUserDefaults] setInteger:[resources count] forKey:@"cdnResourcesCapacity"];
                for(int i=0; i < [resources count];i++){
                    resource= [resources objectAtIndex:i];
                    [_cdnResources addObject:[resource objectForKey:@"name"]];
                    NSLog(@"Loaded CDN Resource: %@", [resource objectForKey:@"name"]);
                    [[NSUserDefaults standardUserDefaults] setObject:[resource objectForKey:@"name"] forKey:[NSString stringWithFormat:@"provider%d", i]];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:[resource objectForKey:@"domain"] forKey:[NSString stringWithFormat:@"provider%d_domain", i]];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:[resource objectForKey:@"icon2x"] forKey:[NSString stringWithFormat:@"provider%d_logo", i]];
                    
                }
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                self.customComboBox.dataSource = [[Utils cdnResources] mutableCopy];
                [self.customComboBox selectItemAtIndex:0];
                
                [self.comboBoxProviderSelect addItemsWithObjectValues:_cdnResources];
                [self.comboBoxProviderSelect selectItemAtIndex:0];
            }
        }
    }] resume];
}

-(void) loadProviderDomainsFromCache{
    NSString *name;
    _cdnResources = [[NSMutableArray alloc] init];
    name = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"provder%d", 1]];
    
    for(int i = 1; name; i++){
        [_cdnResources addObject:name];
        name = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"provder%d", i]];
    }
}

- (IBAction)onComboBoxProviderSelect:(id)sender {
    NSComboBox *comboBox = (NSComboBox*)sender;
    if(comboBox){
        NSInteger indexSelected = [comboBox indexOfSelectedItem];
        NSString *domain = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"provider%ld_domain", (long)indexSelected]];
        self.textFieldDomain.stringValue = domain;
    }
    
}

- (void)customComboBox:(CustomComboBox *)sender didSelectedItem:(NSDictionary *)selectedItem {
    self.textFieldDomain.stringValue = [selectedItem objectForKey:@"domain"];
}

//-(void)dealloc{
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:kLinphoneRegistrationUpdate
//                                                  object:nil];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:kLinphoneConfiguringStateUpdate
//                                                  object:nil];
//}

- (IBAction)onButtonLogin:(id)sender {
    
    [self.prog_Signin setHidden:NO];
    [self.prog_Signin startAnimation:self];
    [self.loginButton setEnabled:NO];
    NSString *dnsSRVName = [@"_rueconfig._tcp." stringByAppendingString:self.textFieldDomain.stringValue];
    [[DefaultSettingsManager sharedInstance] parseDefaultConfigSettings:dnsSRVName
                                                           withUsername:self.textFieldUsername.stringValue
                                                            andPassword:self.textFieldPassword.stringValue];
    [DefaultSettingsManager sharedInstance].delegate = self;
}

- (void)didFinishLoadingConfigData {
    [[SettingsService sharedInstance] setConfigurationSettingsInitialValues];
    // Later - need to set username, userID, password, domain transport and port.
    [self userLogin];
}

- (void)didFinishWithError {
    NSLog(@"Error loading config data");
    [self userLogin];
    [self.prog_Signin setHidden:YES];
    [self.prog_Signin stopAnimation:self];
    [self.loginButton setEnabled:YES];
}

- (void)userLogin {
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
    [self.prog_Signin setHidden:YES];
    [self.prog_Signin stopAnimation:self];
    [self.loginButton setEnabled:YES];
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
- (IBAction)onCheckAutoLogin:(id)sender {
    BOOL shouldAutoLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"auto_login"];
    [[NSUserDefaults standardUserDefaults] setBool:!shouldAutoLogin forKey:@"auto_login"];
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
            [self.loginButton setEnabled:YES];
            [self.prog_Signin setHidden:YES];
            [self.prog_Signin stopAnimation:self];
            NSAlert *alert = [[NSAlert alloc]init];
            [alert addButtonWithTitle:@"OK"];
            if ([message isEqualToString:@"Forbidden"] || [message isEqualToString:@"Unauthorized"])
            {
                [alert setMessageText:@"Either the user name or the password is incorrect. Please enter a valid user name and password."];
            }
            else
            {
                [alert setMessageText:message];
            }
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
