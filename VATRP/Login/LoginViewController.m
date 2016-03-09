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
    bool loginClicked;
}
@property (weak) IBOutlet NSProgressIndicator *prog_Signin;

@property (weak) IBOutlet NSTextField *textFieldUsername;
@property (weak) IBOutlet NSTextField *textFieldUserID;
@property (weak) IBOutlet NSTextField *textFieldPassword;
@property (weak) IBOutlet NSTextField *textFieldDomain;
@property (weak) IBOutlet NSTextField *textFieldPort;
@property (weak) IBOutlet NSComboBox *comboBoxTransport;
@property (weak) IBOutlet NSButton *loginButton;

@property (weak) IBOutlet NSButton *buttonToggleAutoLogin;
@property (weak) IBOutlet NSComboBox *comboBoxProviderSelect;
@property (weak) NSURLSession *urlSession;
@property NSMutableArray *cdnResources;
@property (strong, nonatomic) IBOutlet CustomComboBox *customComboBox;
@property (weak) IBOutlet NSTextField *tmpTextField;
@property (weak) IBOutlet NSProgressIndicator *tmpProgressIndicator;
@end

#define CDN_PROVIDER_LIST_URL @"http://cdn.vatrp.net/domains.json"

@implementation LoginViewController

-(id) init
{
    self = [super initWithNibName:@"LoginView" bundle:nil];
    if (self)
    {
        // init
    }
    return self;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.prog_Signin setHidden:YES];
    [self.loginButton setEnabled:YES];
    [self checkProvidersInfo];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear];
    [self checkProvidersInfo];
    
}

- (void)loadView {
    [super loadView];
    loginClicked = false;

//    [[LinphoneManager instance]	startLinphoneCore];
//    [[LinphoneManager instance] lpConfigSetBool:FALSE forKey:@"enable_first_login_view_preference"];

    [AppDelegate sharedInstance].loginViewController = self;

    AccountModel *accountModel = [[AccountsService sharedInstance] getDefaultAccount];

    if (accountModel) {
        self.textFieldUsername.stringValue = accountModel.username;
        self.textFieldUserID.stringValue = accountModel.userID;
        self.textFieldDomain.stringValue = accountModel.domain;
        self.textFieldPort.stringValue = [NSString stringWithFormat:@"%d", accountModel.port];
        
        if (accountModel.transport && [accountModel.transport isEqualToString:@"TCP"]) {
            self.comboBoxTransport.stringValue = @"Unencrypted (TCP)";
        } else {
            self.comboBoxTransport.stringValue = @"Encrypted (TLS)";
        }
    }
    
    BOOL shouldAutoLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"auto_login"];
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"auto_login"]){
        shouldAutoLogin = NO;
    }
    [self.buttonToggleAutoLogin setState:shouldAutoLogin];
    [self.comboBoxProviderSelect removeAllItems];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(globalStateChangedNotificationHandler:) name:kLinphoneGlobalStateUpdate object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kLinphoneGlobalStateUpdate
                                                  object:nil];
    

}

#pragma mark - Login methods
-(void)handleAutoLogin:(AccountModel *)accountModel
{
    if (accountModel != nil)
    {
        self.textFieldUsername.stringValue = accountModel.username;
        self.textFieldUserID.stringValue = accountModel.userID;
        self.textFieldPassword.stringValue = accountModel.password;
        self.textFieldPort.stringValue = [NSString stringWithFormat:@"%d", accountModel.port];
        self.textFieldDomain.stringValue = accountModel.domain;

        loginClicked = true;
        [AppDelegate sharedInstance].account = [NSString stringWithFormat:@"%@_%@", self.textFieldUsername.stringValue, self.textFieldDomain.stringValue];
        if ([[LinphoneManager instance] coreIsRunning]) {
            [[LinphoneManager instance] destroyLinphoneCore];
            [LinphoneManager instanceRelease];
        }
        
        if (![[LinphoneManager instance] coreIsRunning]) {
            [[LinphoneManager instance]	startLinphoneCore];
            [[LinphoneManager instance] lpConfigSetBool:FALSE forKey:@"enable_first_login_view_preference"];
        } else {
            NSString *dnsSRVName = [@"_rueconfig._tls." stringByAppendingString:accountModel.domain];
            [[DefaultSettingsManager sharedInstance] parseDefaultConfigSettings:dnsSRVName
                                                                   withUsername:accountModel.username
                                                                    andPassword:accountModel.password];
            [DefaultSettingsManager sharedInstance].delegate = self;
        }
        
        [self.prog_Signin setHidden:NO];
        [self.prog_Signin startAnimation:self];
        [self.loginButton setEnabled:NO];
    }
}

- (IBAction)onButtonLogin:(id)sender
{
    loginClicked = true;
    if (!self.textFieldUsername.stringValue || !self.textFieldUsername.stringValue.length ||
        !   self.textFieldDomain.stringValue || !self.textFieldDomain.stringValue.length) {
        
        NSAlert *alert = [[NSAlert alloc]init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Please fill the all fields."];
        [alert runModal];
        
        return;
    }
    
    [AppDelegate sharedInstance].account = [NSString stringWithFormat:@"%@_%@", self.textFieldUsername.stringValue, self.textFieldDomain.stringValue];
    if ([[LinphoneManager instance] coreIsRunning]) {
        [[LinphoneManager instance] destroyLinphoneCore];
        [LinphoneManager instanceRelease];
    }
    
    if (![[LinphoneManager instance] coreIsRunning]) {
        [[LinphoneManager instance]	startLinphoneCore];
        [[LinphoneManager instance] lpConfigSetBool:FALSE forKey:@"enable_first_login_view_preference"];
    } else {
        NSString *dnsSRVName = [@"_rueconfig._tls." stringByAppendingString:self.textFieldDomain.stringValue];
        [[DefaultSettingsManager sharedInstance] parseDefaultConfigSettings:dnsSRVName
                                                               withUsername:self.textFieldUsername.stringValue
                                                                andPassword:self.textFieldPassword.stringValue];
        [DefaultSettingsManager sharedInstance].delegate = self;
    }
    
    [self.prog_Signin setHidden:NO];
    [self.prog_Signin startAnimation:self];
    [self.loginButton setEnabled:NO];
}

#pragma mark - connection

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSError *jsonParsingError = nil;
    if(data){
        NSArray *resources = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0 error:&jsonParsingError];
        if(!jsonParsingError){
            NSDictionary *resource;
            _cdnResources = [[NSMutableArray alloc] init];
            NSMutableArray *logosPaths = [NSMutableArray new];
            [[NSUserDefaults standardUserDefaults] setInteger:[resources count] forKey:@"cdnResourcesCapacity"];
            for(int i=0; i < [resources count];i++){
                resource= [resources objectAtIndex:i];
                [_cdnResources addObject:[resource objectForKey:@"name"]];
                NSLog(@"Loaded CDN Resource: %@", [resource objectForKey:@"name"]);
                [[NSUserDefaults standardUserDefaults] setObject:[resource objectForKey:@"name"] forKey:[NSString stringWithFormat:@"provider%d", i]];
                
                [[NSUserDefaults standardUserDefaults] setObject:[resource objectForKey:@"domain"] forKey:[NSString stringWithFormat:@"provider%d_domain", i]];
                
                [logosPaths addObject:[resource objectForKey:@"icon2x"]];
                
            }
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                [self downloadAndSaveProviderLogos:logosPaths];
                
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [self initCustomComboBox];
                });
            });
            
        }
    }
    
}

-(void) reloadProviderDomains{
    _urlSession = [NSURLSession sharedSession];
    [[_urlSession dataTaskWithURL:[NSURL URLWithString:CDN_PROVIDER_LIST_URL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
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

-(void)globalStateChangedNotificationHandler:(NSNotification*)notif {
    if ((LinphoneGlobalState)[[[notif userInfo] valueForKey:@"state"] integerValue] == LinphoneGlobalOn) {
        NSString *dnsSRVName = [@"_rueconfig._tls." stringByAppendingString:self.textFieldDomain.stringValue];
        [[DefaultSettingsManager sharedInstance] parseDefaultConfigSettings:dnsSRVName
                                                               withUsername:self.textFieldUsername.stringValue
                                                                andPassword:self.textFieldPassword.stringValue];
        [DefaultSettingsManager sharedInstance].delegate = self;
    }
}

#pragma mark - CustomComboBox delegate methods

- (void)customComboBox:(CustomComboBox *)sender didSelectedItem:(NSDictionary *)selectedItem {
    self.textFieldDomain.stringValue = [selectedItem objectForKey:@"domain"];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    [[SettingsHandler settingsHandler] initializeUserDefaults:YES];
}

- (void)userLogin
{
    AccountModel *accountModel = [[AccountsService sharedInstance] getDefaultAccount];
    bool shouldAutoLogin = false;
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"auto_login"])
    {
        shouldAutoLogin = NO;
    }
    else
    {
        shouldAutoLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"auto_login"];
    }
    [self.buttonToggleAutoLogin setState:shouldAutoLogin];
    
    if (shouldAutoLogin && accountModel &&
        accountModel.username && accountModel.username.length &&
        accountModel.userID && accountModel.userID.length &&
        accountModel.password && accountModel.password.length &&
        accountModel.domain && accountModel.domain.length &&
        accountModel.transport && accountModel.transport.length &&
        accountModel.port)
    {
        loginAccount = accountModel;
    }
    else
    {
        if (accountModel)
        {
            [[AccountsService sharedInstance] removeAccountWithUsername:accountModel.username];
        }
        [[AccountsService sharedInstance] addAccountWithUsername:self.textFieldUsername.stringValue
                                                          UserID:self.textFieldUserID.stringValue
                                                        Password:self.textFieldPassword.stringValue
                                                          Domain:self.textFieldDomain.stringValue
                                                       Transport:[self.comboBoxTransport.stringValue isEqualToString:@"Encrypted (TLS)"] ? @"TLS" : @"TCP"
                                                            Port:self.textFieldPort.intValue
                                                       isDefault:YES];

    }

    if (loginClicked || shouldAutoLogin)
    {
        if (loginAccount == nil)
        {
            loginAccount = [[AccountModel alloc] init];
            loginAccount.username = self.textFieldUsername.stringValue;
            loginAccount.userID = self.textFieldUserID.stringValue;
            loginAccount.password = self.textFieldPassword.stringValue;
            loginAccount.domain = self.textFieldDomain.stringValue;
            loginAccount.transport = [self.comboBoxTransport.stringValue isEqualToString:@"Encrypted (TLS)"] ? @"TLS" : @"TCP";
            loginAccount.port = self.textFieldPort.intValue;
        }
        else
        {
            self.textFieldUsername.stringValue = accountModel.username;
            self.textFieldUserID.stringValue = accountModel.userID;
            self.textFieldPassword.stringValue = accountModel.password;
            self.textFieldPort.stringValue = [NSString stringWithFormat:@"%d", accountModel.port];
            self.textFieldDomain.stringValue = accountModel.domain;
            if ([loginAccount.transport isEqualToString:@"TLS"])
            {
                [self.comboBoxTransport selectItemWithObjectValue:@"Encrypted (TLS)"];
            }
            else
            {
                [self.comboBoxTransport selectItemWithObjectValue:@"Unencrypted (TCP)"];
            }
        }
  
    
        [[RegistrationService sharedInstance] registerWithUsername:loginAccount.username
                                                            UserID:loginAccount.userID
                                                          password:loginAccount.password
                                                            domain:loginAccount.domain
                                                         transport:loginAccount.transport
                                                              port:loginAccount.port];
        [self.prog_Signin setHidden:YES];
        [self.prog_Signin stopAnimation:self];
        [self.loginButton setEnabled:NO];
    }
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
    current_conf = linphone_core_get_default_proxy_config([LinphoneManager getLc]);
    if(current_conf != NULL){
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
    // be explicit in setting this to the correct value.
    bool shouldAutoLogin = (bool)self.buttonToggleAutoLogin.state;
    [[NSUserDefaults standardUserDefaults] setBool:shouldAutoLogin forKey:@"auto_login"];
}

#pragma mark -

- (void)registrationUpdate:(LinphoneRegistrationState)state message:(NSString*)message {
    switch (state) {
        case LinphoneRegistrationOk: {
//            if (loginAccount == nil)
//            {
                // ToDo - this needs a better fix. On launch, even auto-login is off, the last user is still being registered.
                //   need to figure out where this is happening and prevent it.
                //  for now, if the loginAccount is nil, then we need to figure out what account was just registered.
            // NOTE - deal with this after 2-4 push
//                const char* userName = linphone_core_get_identity([LinphoneManager getLc]);
                
////            }
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
            // VATRP-2202: we do not need to show this message if the user has not yet clicked login.
            if (loginClicked)//![self.loginButton isEnabled])
            {
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
            }
            break;
        }
        case LinphoneRegistrationProgress: {
            break;
        }
        default:
            break;
    }
}

#pragma mark - Providers info checking methods

- (void)checkProvidersInfo {
    [self requestToProvidersInfo];
}

- (BOOL)isProvidersInfoExist {
        //Provider logo
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"provider0_logo.png"] &&
        //Provider name
        [[NSUserDefaults standardUserDefaults] objectForKey:@"provider0"] &&
        //Provider domain
        [[NSUserDefaults standardUserDefaults] objectForKey:@"provider0_domain"]) {
        return YES;
    }
    return NO;
}

- (void)initCustomComboBox {
    _customComboBox.delegate = self;
    if([Utils cdnResources] && [Utils cdnResources].count > 0){
        self.customComboBox.dataSource = [[Utils cdnResources] mutableCopy];
        [self.customComboBox selectItemAtIndex:0];
        NSDictionary *dict = [[Utils cdnResources] objectAtIndex:[_customComboBox indexOfSelectedItem]];
        self.textFieldDomain.stringValue = [dict objectForKey:@"domain"];
        [_tmpTextField removeFromSuperview];
        [_tmpProgressIndicator removeFromSuperview];

        // use this opportunity to initialize port if it is not already.
        NSString* port = self.textFieldPort.stringValue;
        if ((port == nil) || (port.length == 0))
        {
            self.textFieldPort.stringValue = @"25060";
        }
    }
}

- (void)requestToProvidersInfo {
    [_tmpProgressIndicator startAnimation:self];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:CDN_PROVIDER_LIST_URL]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    #pragma unused(connection)
}

- (void)downloadAndSaveProviderLogos:(NSMutableArray*)logosPaths {
    int i = 0;
    for (NSString *path in logosPaths) {
        NSURL *imageURL = [NSURL URLWithString:path];
        NSError *downloadError = nil;
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL
                                                  options:kNilOptions
                                                    error:&downloadError];
        
        if (downloadError) {
            NSLog(@"%@",[downloadError localizedDescription]);
        } else {
            
            NSString *filename = [NSString stringWithFormat:@"provider%d_logo.png", i];
            NSString *filePath = [self applicationDirectoryFile:filename];
            NSURL *url = [NSURL fileURLWithPath:filePath];
            
            NSError *saveError = nil;
            BOOL writeWasSuccessful = [imageData writeToURL:url
                                                    options:kNilOptions
                                                      error:&saveError];
            if (!writeWasSuccessful) {
                NSLog(@"%@",[saveError localizedDescription]);
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:filePath forKey:[NSString stringWithFormat:@"provider%d_logo.png", i]];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }

        }
        ++i;
    }
}

- (NSString*)applicationDirectoryFile:(NSString*)file {
    NSString* bundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *makePath = [[[[documentsPath stringByAppendingString:@"/"] stringByAppendingString:bundleID] stringByAppendingString:@"/"] stringByAppendingString:file];
    return makePath;
}

- (void)changeEditBoxesStates:(BOOL)state {
    [self.textFieldUsername setEnabled:!state];
    [self.textFieldUserID setEnabled:!state];
    [self.textFieldPassword setEnabled:!state];
    [self.textFieldDomain setEnabled:!state];
}

#pragma mark - CustomComboBox delegate methods

- (void)customComboBox:(CustomComboBox*)sender didOpenedComboTable:(BOOL)isOpened {
    [self changeEditBoxesStates:isOpened];
}

- (IBAction)onComboboxTransport:(id)sender {
    if([self.comboBoxTransport.stringValue isEqualToString:@"Encrypted (TLS)"]) {
        if(self.textFieldPort.intValue == 25060) {
            self.textFieldPort.stringValue = @"25061";
        }
    } else {
        if(self.textFieldPort.intValue == 25061) {
            self.textFieldPort.stringValue = @"25060";
        }
    }
}

@end
