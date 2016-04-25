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
#import "DefaultSettingsManager.h"
#import "SettingsConstants.h"

@interface AccountsViewController () {
    AccountModel *accountModel;
    BOOL isChanged;
}

@property (weak) IBOutlet NSTextField *textFieldUsername;
@property (weak) IBOutlet NSTextField *textFieldUserID;
@property (weak) IBOutlet NSSecureTextField *secureTextFieldPassword;
@property (weak) IBOutlet NSTextField *textFieldDomain;
@property (weak) IBOutlet NSButton *comboBoxOutboundProxy;
@property (weak) IBOutlet NSTextField *textFieldOutboundProxy;
@property (weak) IBOutlet NSTextField *textFieldPort;
@property (weak) IBOutlet NSComboBox *comboBoxTransport;
@property (weak) IBOutlet NSTextField *settingsFeedbackText;
@property (weak) IBOutlet NSTextField *textFieldMailWaitingIndicatorURI;
@property (weak) IBOutlet NSTextField *textFieldVideoMailUri;

@property (weak) IBOutlet NSTextField *textCardDavServerPath;
@property (weak) IBOutlet NSTextField *textCardDavRealmName;

@end

@implementation AccountsViewController

-(id) init
{
    self = [super initWithNibName:@"AccountsViewController" bundle:nil];
    if (self)
    {
        // init
    }
    return self;
    
}

- (void) awakeFromNib {
    [super awakeFromNib];
    [self initializeData];
}

- (void)initializeData
{
    // Do view setup here.
    self.textFieldUserID.enabled = false;
    self.textFieldUsername.enabled = false;
    self.secureTextFieldPassword.enabled = false;
    self.textFieldDomain.enabled = false;
    self.textFieldPort.enabled = false;
    [self.textFieldMailWaitingIndicatorURI setDelegate:self];
    [self.textFieldVideoMailUri setDelegate:self];
    [self.textFieldOutboundProxy setDelegate:self];
    [self.textCardDavServerPath setDelegate:self];
    [self.textCardDavRealmName setDelegate:self];
    isChanged = NO;
    [self setFields];
}


- (void)setFields {
    LinphoneCore *lc = [LinphoneManager getLc];
    LinphoneProxyConfig *cfg = linphone_core_get_default_proxy_config(lc);
    if (cfg) {
        const char *identity=linphone_proxy_config_get_identity(cfg);
        LinphoneAddress *addr=linphone_address_new(identity);
        
        // Get SIP Transport
        LinphoneTransportType transport = linphone_address_get_transport(addr);
        
        if(transport == LinphoneTransportUdp){
            linphone_address_set_transport(addr, LinphoneTransportTcp);
            transport = linphone_address_get_transport(addr);
        }
        
        NSString *sip_transport;
        switch (transport) {
            case LinphoneTransportTcp:
                sip_transport = @"Unencrypted (TCP)";
                break;
            case LinphoneTransportTls:
                sip_transport = @"Encrypted (TLS)";
                break;
            default:
                sip_transport = @"Unencrypted (TCP)";
                break;
        }
        [self.comboBoxTransport selectItemWithObjectValue:sip_transport];
    }
    
    accountModel = [[AccountsService sharedInstance] getDefaultAccount];
    
    if(accountModel){
        if(accountModel.username != NULL) { self.textFieldUsername.stringValue = accountModel.username; }
        if(accountModel.userID != NULL) { self.textFieldUserID.stringValue = accountModel.userID; }
        if(accountModel.password != NULL) { self.secureTextFieldPassword.stringValue = accountModel.password; }
        if(accountModel.domain != NULL) { self.textFieldDomain.stringValue = accountModel.domain; }
        if(accountModel.transport != NULL) {
            [self.comboBoxTransport selectItemWithObjectValue:[[SettingsHandler settingsHandler] getUITransportStringForString:accountModel.transport]];
        }
        if(cfg) {
            const char* proxy_addr = linphone_proxy_config_get_server_addr(cfg);
            LinphoneAddress *addr = linphone_address_new( proxy_addr );
            if(addr){
                self.textFieldPort.stringValue = [NSString stringWithFormat:@"%d", linphone_address_get_port(addr)];
            }
        }
    }
    else{
        //self.textFieldDomain.stringValue = @"bc1.vatrp.net";
        self.textFieldPort.stringValue = @"25060";
        [self.comboBoxTransport selectItemWithObjectValue:@"Unencrypted (TCP)"];
    }
    if([[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"sip_mwi_uri"]){
        self.textFieldMailWaitingIndicatorURI.stringValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"sip_mwi_uri"];
    }
    
    if([[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:VIDEO_MAIL_URI]){
        self.textFieldVideoMailUri.stringValue = [[NSUserDefaults standardUserDefaults] objectForKey:VIDEO_MAIL_URI];
    }
    
    if ([[SettingsHandler settingsHandler] getCardDavServerPath]) {
        self.textCardDavServerPath.stringValue = [[SettingsHandler settingsHandler] getCardDavServerPath];
    } else {
        self.textCardDavServerPath.stringValue = @"";
    }
    
    if ([[SettingsHandler settingsHandler] getCardDavRealmName]) {
        self.textCardDavRealmName.stringValue = [[SettingsHandler settingsHandler] getCardDavRealmName];
    } else {
        self.textCardDavRealmName.stringValue = @"";
    }

    [self setOutboundProxy];
}

- (void)setOutboundProxy {
    self.textFieldOutboundProxy.stringValue = [[SettingsHandler settingsHandler] getOutpboundProxy];
    bool setOutboundProxyState = [[SettingsHandler settingsHandler] getOutpboundProxyState];
    self.comboBoxOutboundProxy.state = setOutboundProxyState;
}

- (IBAction)onButtonAutoAnswer:(id)sender {
}

- (IBAction)onCheckBoxForOutboundProxy:(id)sender {
    isChanged = YES;
}

- (BOOL) save {
    if (!isChanged) {
        return YES;
    }
    
    if ([self checkFieldsValidness]) {
        return NO;
    }
    
    @try{
        [[AccountsService sharedInstance] removeAccountWithUsername:accountModel.username];
    }
    @catch(NSException *e){
        NSLog(@"Tried to remove account that does not exist.");
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    self.settingsFeedbackText.stringValue = @"Settings saved";
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeAccountsViewController" object:nil];
    
    if(![self.textFieldMailWaitingIndicatorURI.stringValue isEqualToString:@""]){
        [[NSUserDefaults standardUserDefaults] setObject:self.textFieldMailWaitingIndicatorURI.stringValue forKey:@"sip_mwi_uri"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if(![self.textFieldVideoMailUri.stringValue isEqualToString:@""]){
        [[NSUserDefaults standardUserDefaults] setObject:self.textFieldVideoMailUri.stringValue forKey:VIDEO_MAIL_URI];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [[SettingsHandler settingsHandler] setCardDavServerPath:self.textCardDavServerPath.stringValue];
    [[SettingsHandler settingsHandler] setCardDavRealmName:self.textCardDavRealmName.stringValue];
    
    NSString* currentTransportSetting = [[SettingsHandler settingsHandler] getUITransportStringForString:[accountModel transport]];
    if (![self.comboBoxTransport.stringValue isEqualToString:currentTransportSetting])
    {
        // do not try to reregister unless there has been a change that requires a reregister.
        @try{
            [[AccountsService sharedInstance] removeAccountWithUsername:accountModel.username];
        }
        @catch(NSException *e){
            NSLog(@"Tried to remove account that does not exist.");
        }
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSString *transport;
        if([self.comboBoxTransport.stringValue isEqualToString:@"Encrypted (TLS)"]) {
            transport=@"TLS";
        } else {
            transport=@"TCP";
        }
        
        [[AccountsService sharedInstance] addAccountWithUsername:self.textFieldUsername.stringValue
                                                          UserID:self.textFieldUserID.stringValue
                                                        Password:self.secureTextFieldPassword.stringValue
                                                          Domain:self.textFieldDomain.stringValue
                                                       Transport:transport
                                                            Port:self.textFieldPort.intValue
                                                       isDefault:YES];
        
        AccountModel *accountModel_ = [[AccountsService sharedInstance] getDefaultAccount];
        
        if (accountModel_) {
            [[RegistrationService sharedInstance] registerWithAccountModel:accountModel_];
        }
    }
    
    if ([self.textFieldOutboundProxy.stringValue isEqualToString:@""]) {
        self.comboBoxOutboundProxy.state = false;
        [[SettingsHandler settingsHandler] setOutboundProxy:self.textFieldOutboundProxy.stringValue];
    } else {
        if ([Utils checkIfContainsProxyPort:self.textFieldOutboundProxy.stringValue]) {
            [[SettingsHandler settingsHandler] setOutboundProxy:self.textFieldOutboundProxy.stringValue];
        } else {
            NSString *outboundProxy = [[self.textFieldOutboundProxy.stringValue stringByAppendingString:@":"] stringByAppendingString:self.textFieldPort.stringValue];
            [[SettingsHandler settingsHandler] setOutboundProxy:outboundProxy];
        }
    }
    
    bool outboundProxyState = self.comboBoxOutboundProxy.state;
    [[SettingsHandler settingsHandler] setOutboundProxyState:outboundProxyState];
    
    [self configureOutboundProxyServer];
    
    return YES;
}

- (void)configureOutboundProxyServer {
    
    bool isOutboundProxy = [[SettingsHandler settingsHandler] getOutpboundProxyState];
    BOOL isEditing = FALSE;
    NSString *proxyAddress = [[SettingsHandler settingsHandler] getOutpboundProxy];
    const char *route = NULL;

    if (![proxyAddress hasPrefix:@"sip:"] && ![proxyAddress hasPrefix:@"sips:"]) {
        proxyAddress = [NSString stringWithFormat:@"sip:%@", proxyAddress];
    }
    
    char *proxy = ms_strdup(proxyAddress.UTF8String);
    LinphoneAddress *proxy_addr = linphone_address_new(proxy);
    
    if (proxy_addr) {
        // Get SIP Transport
        LinphoneTransportType transport = linphone_address_get_transport(proxy_addr);
        
        if (transport == LinphoneTransportUdp) {
            linphone_address_set_transport(proxy_addr, LinphoneTransportTcp);
        }
        proxy = linphone_address_as_string_uri_only(proxy_addr);
    }
    
    LinphoneProxyConfig * proxyCfg = linphone_core_get_default_proxy_config([LinphoneManager getLc]);
    
    if (proxyCfg == NULL) {
        proxyCfg = linphone_core_create_proxy_config([LinphoneManager getLc]);
    } else {
        isEditing = TRUE;
        linphone_proxy_config_edit(proxyCfg);
    }
    
    route = isOutboundProxy ? proxy : NULL;
    if (linphone_proxy_config_set_server_addr(proxyCfg, proxy) == -1) {
        NSLog(@"Invalid proxy address", nil);
    }
    if (linphone_proxy_config_set_route(proxyCfg, route) == -1) {
        NSLog(@"Invalid route", nil);
    }
    
    // setup new proxycfg
    if (isEditing) {
        linphone_proxy_config_done(proxyCfg);
    } else {
        // was a new proxy config, add it
        linphone_core_add_proxy_config([LinphoneManager getLc], proxyCfg);
        linphone_core_set_default_proxy_config([LinphoneManager getLc], proxyCfg);
    }

}

- (BOOL)checkFieldsValidness {
    
    BOOL error = NO;
    NSString *errorString = nil;
    
    if ([self.textFieldUsername.stringValue isEqual:@""]) {
        error = YES;
        errorString = @"Username field is required";
    }
    
    if ([self.secureTextFieldPassword.stringValue isEqual:@""] && !error) {
        error = YES;
        errorString = @"Password field is required";
    }
    
    if ([self.textFieldDomain.stringValue isEqual:@""] && !error) {
        error = YES;
        errorString = @"Domain field is required";
    }
    
    if ([self.textFieldPort.stringValue isEqual:@""] && !error) {
        error = YES;
        errorString = @"Port field is required";
    }
    
    if ([self.textCardDavRealmName.stringValue isEqual:@""] && !error) {
        error = YES;
        errorString = @"Port field is required";
    }
    
    if ([self.textCardDavServerPath.stringValue isEqual:@""] && !error) {
        error = YES;
        errorString = @"Port field is required";
    }
    
    if (error) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:errorString];
        [alert runModal];
    }
    
    return error;
}

- (void)controlTextDidChange:(NSNotification *)notification {
    isChanged = YES;
}

- (IBAction)onComboboxTransport:(id)sender {
    isChanged = YES;
    
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

- (IBAction)onCheckBoxAutoAnswerCall:(id)sender {
    isChanged = YES;
}

@end
