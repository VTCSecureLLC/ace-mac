//
//  AccountsViewController.m
//  vatrp
//
//  Created by Ruben Semerjyan on 9/22/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//
#import "AppDelegate.h"
#import "AccountsViewController.h"
#import "LinphoneManager.h"
#import "AccountsService.h"
#import "RegistrationService.h"
#import "Utils.h"

@interface AccountsViewController () {
    AccountModel *accountModel;
    BOOL isChanged;
}

@property (weak) IBOutlet NSTextField *textFieldUsername;
@property (weak) IBOutlet NSSecureTextField *secureTextFieldPassword;
@property (weak) IBOutlet NSTextField *textFieldDomain;
@property (weak) IBOutlet NSTextField *textFieldPort;
@property (weak) IBOutlet NSComboBox *comboBoxTransport;
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
    
    if(accountModel){
        if(accountModel.username != NULL) { self.textFieldUsername.stringValue = accountModel.username; }
        if(accountModel.password != NULL) { self.secureTextFieldPassword.stringValue = accountModel.password; }
        if(accountModel.domain != NULL) { self.textFieldDomain.stringValue = accountModel.domain; }
        self.textFieldPort.stringValue = [NSString stringWithFormat:@"%d", accountModel.port];
        if(accountModel.transport != NULL) { [self.comboBoxTransport selectItemWithObjectValue:accountModel.transport]; }
    }
    
    else{
        self.textFieldDomain.stringValue = @"bc1.vatrp.net";
        self.textFieldPort.stringValue = @"5060";
        [self.comboBoxTransport selectItemWithObjectValue:@"Unencrypted (TCP)"];
    }
}

- (IBAction)onButtonAutoAnswer:(id)sender {
}

- (void) save {
    if (!isChanged) {
        return;
    }

    @try{
        [[AccountsService sharedInstance] removeAccountWithUsername:accountModel.username];
    }
    @catch(NSException *e){
        NSLog(@"Tried to remove account that does not exist");
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];

    [[AccountsService sharedInstance] addAccountWithUsername:self.textFieldUsername.stringValue
                                                    Password:self.secureTextFieldPassword.stringValue
                                                      Domain:self.textFieldDomain.stringValue
                                                   Transport:self.comboBoxTransport.stringValue
                                                        Port:self.textFieldPort.intValue
                                                   isDefault:YES];

    AccountModel *accountModel_ = [[AccountsService sharedInstance] getDefaultAccount];
    
    LoginWindowController *loginWindowController = [AppDelegate sharedInstance].loginWindowController;
    LoginViewController *loginViewController = [AppDelegate sharedInstance].loginViewController;

    if (accountModel_) {
        loginViewController.loginAccount = accountModel_;
        [[RegistrationService sharedInstance] registerWithAccountModel:accountModel_];
    }

    self.settingsFeedbackText.stringValue = @"Settings saved";
    
   
    if(loginWindowController){
        [[AppDelegate sharedInstance] showTabWindow];
    }
    
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
