//
//  AccountsViewController.m
//  vatrp
//
//  Created by Edgar Sukiasyan on 9/22/15.
//  Copyright © 2015 Home. All rights reserved.
//

#import "AccountsViewController.h"
#import "LinphoneManager.h"

@interface AccountsViewController ()

@property (weak) IBOutlet NSTextField *textFieldUsername;
@property (weak) IBOutlet NSSecureTextField *secureTextFieldPassword;
@property (weak) IBOutlet NSTextField *textFieldDomain;
@property (weak) IBOutlet NSTextField *textFieldPort;
@property (weak) IBOutlet NSComboBox *comboBoxTransport;


@end

@implementation AccountsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"%@ - viewWillAppear: %i", self.title, animated);
    
    LinphoneCore *lc = [LinphoneManager getLc];
    LinphoneProxyConfig *cfg=NULL;
    linphone_core_get_default_proxy(lc,&cfg);
    const char *identity=linphone_proxy_config_get_identity(cfg);
    LinphoneAddress *addr=linphone_address_new(identity);
    
    //Get Username
    const char* user = linphone_address_get_username(addr);
    NSString *username = [NSString stringWithUTF8String:user];
    
    //Get Password
    LinphoneAuthInfo *ai;
    NSString *password = @"";
    const MSList *elem=linphone_core_get_auth_info_list(lc);
    if (elem && (ai=(LinphoneAuthInfo*)elem->data)){
        const char* pass = linphone_auth_info_get_passwd(ai);
        password = [NSString stringWithUTF8String:pass];
    }
    
    // Get Domian name
    const char* domain = linphone_address_get_domain(addr);
    NSString *domainname = [NSString stringWithUTF8String:domain];
    
    // Get Port
    int port = linphone_address_get_port(addr);
    NSString *sip_port = [NSString stringWithFormat:@"%d", port];
    
    LinphoneProxyConfig* proxyCfg = linphone_core_create_proxy_config(lc);
    const char* _domain = linphone_proxy_config_get_transport(proxyCfg);

    
    // Get SIP Transport
    LinphoneTransportType transport = linphone_address_get_transport(addr);
    NSString *sip_transport = @"";
    switch (transport) {
        case LinphoneTransportUdp:
            sip_transport = @"UDP";
            break;
        case LinphoneTransportTcp:
            sip_transport = @"TCP";
            break;
        case LinphoneTransportTls:
            sip_transport = @"TLS";
            break;
        case LinphoneTransportDtls:
            sip_transport = @"DTLS";
            break;
            
        default:
            break;
    }
    
    
    self.textFieldUsername.stringValue = username;
    self.secureTextFieldPassword.stringValue = password;
    self.textFieldDomain.stringValue = domainname;
    self.textFieldPort.stringValue = sip_port;
    [self.comboBoxTransport selectItemWithObjectValue:sip_transport];
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

@end
