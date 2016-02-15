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
#import "SettingsHandler.h"
@interface TestingViewController () {
    BOOL isChanged;
}

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
    
    LinphoneProxyConfig* proxyCfg = linphone_core_get_default_proxy_config([LinphoneManager getLc]);

    if (proxyCfg) {
        self.buttonEnableAVPF.state = linphone_proxy_config_avpf_enabled(proxyCfg);
    }
    
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
    
    [self.comboBoxRTCPFeedBack setEditable:NO];
    NSString *rtcpFbMode = [SettingsHandler.settingsHandler getRtcpFbMode];
   [self.comboBoxRTCPFeedBack setStringValue:rtcpFbMode];
}

- (void) save {
    if (!isChanged) {
        return;
    }
    
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
        if(cfg){
            linphone_proxy_config_set_avpf_mode(cfg, LinphoneAVPFDisabled);
            linphone_proxy_config_enable_avpf(cfg, FALSE);
            linphone_proxy_config_set_avpf_rr_interval(cfg, 3);
        }
        linphone_core_set_avpf_mode([LinphoneManager getLc], LinphoneAVPFDisabled);
        linphone_core_set_avpf_rr_interval([LinphoneManager getLc], 3);
        [[LinphoneManager instance] lpConfigSetInt:rtcpFB forKey:@"rtp" forSection:@"rtcp_fb_implicit_rtcp_fb"];
    }
    else if([rtcpFeedback isEqualToString:@"Explicit"]){
        rtcpFB = 1;
        if(cfg){
            linphone_proxy_config_set_avpf_mode(cfg, LinphoneAVPFEnabled);
            linphone_proxy_config_enable_avpf(cfg, TRUE);
            linphone_proxy_config_set_avpf_rr_interval(cfg, 3);
        }
        linphone_core_set_avpf_mode([LinphoneManager getLc], LinphoneAVPFEnabled);
        linphone_core_set_avpf_rr_interval([LinphoneManager getLc], 3);
        [[LinphoneManager instance] lpConfigSetInt:rtcpFB forKey:@"rtp" forSection:@"rtcp_fb_implicit_rtcp_fb"];
    }
    else{
        rtcpFB = 0;
        if(cfg){
            linphone_proxy_config_set_avpf_mode(cfg, LinphoneAVPFDisabled);
            linphone_proxy_config_enable_avpf(cfg, FALSE);
            linphone_proxy_config_set_avpf_rr_interval(cfg, 3);
        }
        linphone_core_set_avpf_mode([LinphoneManager getLc], LinphoneAVPFDisabled);
        linphone_core_set_avpf_rr_interval([LinphoneManager getLc], 3);
        [[LinphoneManager instance] lpConfigSetInt:rtcpFB forKey:@"rtp" forSection:@"rtcp_fb_implicit_rtcp_fb"];
    }
    
    [[SettingsHandler settingsHandler] setRtcpFbMode:rtcpFeedback];
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
