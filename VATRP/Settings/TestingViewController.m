//
//  TestingViewController.m
//  ACE
//
//  Created by Ruben Semerjyan on 10/8/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "TestingViewController.h"
#import "LinphoneManager.h"
#import "CallService.h"

@interface TestingViewController () {
    BOOL isChanged;
}

@property (weak) IBOutlet NSButton *buttonAutoAnswer;
@property (weak) IBOutlet NSButton *buttonEnableAVPF;
@property (weak) IBOutlet NSButton *buttonSendDTMF;
@property (weak) IBOutlet NSButton *buttonEnableAdaptiveRateControl;
@property (weak) IBOutlet NSButton *buttonEnableRealTimeText;

@end

@implementation TestingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.

    NSInteger auto_answer = [[NSUserDefaults standardUserDefaults] boolForKey:@"ACE_AUTO_ANSWER_CALL"];
    self.buttonAutoAnswer.state = auto_answer;
    
    LinphoneProxyConfig* proxyCfg = NULL;
    linphone_core_get_default_proxy([LinphoneManager getLc], &proxyCfg);
    
    if (proxyCfg) {
        self.buttonEnableAVPF.state = linphone_proxy_config_avpf_enabled(proxyCfg);
    }
    
    self.buttonEnableAdaptiveRateControl.state = linphone_core_adaptive_rate_control_enabled([LinphoneManager getLc]);
    self.buttonEnableRealTimeText.state = [[NSUserDefaults standardUserDefaults] boolForKey:kREAL_TIME_TEXT_ENABLED];
}

- (void) save {
    if (!isChanged) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:self.buttonEnableRealTimeText.state forKey:kREAL_TIME_TEXT_ENABLED];
    [[NSUserDefaults standardUserDefaults] setBool:self.buttonAutoAnswer.state forKey:@"ACE_AUTO_ANSWER_CALL"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    LinphoneProxyConfig* proxyCfg = NULL;
    linphone_core_get_default_proxy([LinphoneManager getLc], &proxyCfg);

    LinphoneAVPFMode mode;
    if(self.buttonEnableAVPF.state == 1){
        mode = LinphoneAVPFEnabled;
    }
    
    else{
        mode = LinphoneAVPFDisabled;
    }
    linphone_core_set_avpf_mode([LinphoneManager getLc], mode);
    if (proxyCfg) {
        linphone_proxy_config_enable_avpf(proxyCfg, self.buttonEnableAVPF.state);
    }
    
    linphone_core_set_use_info_for_dtmf([LinphoneManager getLc], self.buttonSendDTMF.state);
    linphone_core_enable_adaptive_rate_control([LinphoneManager getLc], self.buttonEnableAdaptiveRateControl.state);
}

- (IBAction)onCheckBox:(id)sender {
    isChanged = YES;
}

@end
