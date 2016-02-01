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
#import "SettingsService.h"
#import "AppDelegate.h"

@interface TestingViewController () {
    BOOL isChanged;
}

@property (weak) IBOutlet NSButton *buttonAutoAnswer;
@property (weak) IBOutlet NSButton *buttonEnableAVPF;
@property (weak) IBOutlet NSButton *buttonSendDTMF;
@property (weak) IBOutlet NSButton *buttonEnableAdaptiveRateControl;
@property (weak) IBOutlet NSComboBox *comboBoxRTCPFeedBack;

@property (weak) IBOutlet NSTextField *textFieldMaxUpload;
@property (weak) IBOutlet NSTextField *textFieldMaxDownload;

@end

@implementation TestingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.

    NSInteger auto_answer = [[NSUserDefaults standardUserDefaults] boolForKey:@"ACE_AUTO_ANSWER_CALL"];
    self.buttonAutoAnswer.state = auto_answer;
    
    LinphoneProxyConfig* proxyCfg = NULL;
    proxyCfg = linphone_core_get_default_proxy_config([LinphoneManager getLc]);
    
    
    self.buttonEnableAdaptiveRateControl.state = linphone_core_adaptive_rate_control_enabled([LinphoneManager getLc]);
    
    self.textFieldMaxUpload.intValue = linphone_core_get_upload_bandwidth([LinphoneManager getLc]);
    self.textFieldMaxDownload.intValue = linphone_core_get_download_bandwidth([LinphoneManager getLc]);
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterNoStyle];
    [numberFormatter setAllowsFloats:NO];
    [[self.textFieldMaxUpload cell] setFormatter:numberFormatter];
    [[self.textFieldMaxDownload cell] setFormatter:numberFormatter];
    
    [self.textFieldMaxUpload setDelegate:self];
    [self.textFieldMaxDownload setDelegate:self];
    [self.buttonEnableAVPF setEnabled:NO];
    [self.buttonEnableAVPF removeFromSuperview];
    
    int rtcpFBSetting = lp_config_get_int([[LinphoneManager instance] configDb],  "rtp", "rtcp_fb_implicit_rtcp_fb", 0);
    LinphoneAVPFMode mode = linphone_core_get_avpf_mode([LinphoneManager getLc]);
    [self.comboBoxRTCPFeedBack setEditable:NO];
    @try{
        if(rtcpFBSetting == 0 && mode == LinphoneAVPFDisabled){
            [self.comboBoxRTCPFeedBack selectItemWithObjectValue:@"Off"];
        }
        else if(rtcpFBSetting == 1 && mode == LinphoneAVPFDisabled){
            [self.comboBoxRTCPFeedBack selectItemWithObjectValue:@"Implicit"];
        }
        else{
            [self.comboBoxRTCPFeedBack selectItemWithObjectValue:@"Explicit"];
        }
    }
    @catch(NSError *error){
        [self.comboBoxRTCPFeedBack setStringValue:@"Off"];
    }
}

- (void) save {
    if (!isChanged) {
        return;
    }
    
    
    [[NSUserDefaults standardUserDefaults] setBool:self.buttonAutoAnswer.state forKey:@"ACE_AUTO_ANSWER_CALL"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    LinphoneProxyConfig* proxyCfg = NULL;
    proxyCfg = linphone_core_get_default_proxy_config([LinphoneManager getLc]);

//    if (proxyCfg) {
//        linphone_proxy_config_enable_avpf(proxyCfg, self.buttonEnableAVPF.state);
//    }
    
    linphone_core_set_use_info_for_dtmf([LinphoneManager getLc], self.buttonSendDTMF.state);
    linphone_core_enable_adaptive_rate_control([LinphoneManager getLc], self.buttonEnableAdaptiveRateControl.state);
    
    linphone_core_set_upload_bandwidth([LinphoneManager getLc], self.textFieldMaxUpload.intValue);
    linphone_core_set_download_bandwidth([LinphoneManager getLc], self.textFieldMaxDownload.intValue);
}

- (IBAction)onCheckBox:(id)sender {
    isChanged = YES;
}

- (void)controlTextDidChange:(NSNotification *)notification {
    isChanged = YES;
}
- (IBAction)onRTCPFeedbackSelected:(id)sender {
    NSString *rtcpFeedback = ((NSComboBox*)sender).stringValue;
    int rtcpFB;
    LinphoneProxyConfig *cfg = linphone_core_get_default_proxy_config([LinphoneManager getLc]);
        if([rtcpFeedback isEqualToString:@"Implicit"]){
            rtcpFB = 1;
            linphone_core_set_avpf_mode([LinphoneManager getLc], LinphoneAVPFDisabled);
            if(cfg){ linphone_proxy_config_set_avpf_mode(cfg, LinphoneAVPFDisabled); }

            lp_config_set_int([[LinphoneManager instance] configDb],  "rtp", "rtcp_fb_implicit_rtcp_fb", rtcpFB);
            }
        else if([rtcpFeedback isEqualToString:@"Explicit"]){
            rtcpFB = 1;
            linphone_core_set_avpf_mode([LinphoneManager getLc], LinphoneAVPFEnabled);
            
            if(cfg){ linphone_proxy_config_set_avpf_mode(cfg, LinphoneAVPFEnabled); }
            
            lp_config_set_int([[LinphoneManager instance] configDb],  "rtp", "rtcp_fb_implicit_rtcp_fb", rtcpFB);
            }
        else{
            rtcpFB = 0;
            linphone_core_set_avpf_mode([LinphoneManager getLc], LinphoneAVPFDisabled);
            
            if(cfg){ linphone_proxy_config_set_avpf_mode(cfg, LinphoneAVPFDisabled); }
            
            lp_config_set_int([[LinphoneManager instance] configDb],  "rtp", "rtcp_fb_implicit_rtcp_fb", rtcpFB);
            }
}

- (IBAction)onButtonCleareUserData:(id)sender {
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"linphone_chats.db"];
    
    if ([fileManager fileExistsAtPath:filePath]) {
        [fileManager removeItemAtPath:filePath error:nil];
    }
    
    [[AppDelegate sharedInstance] SignOut];
}

@end
