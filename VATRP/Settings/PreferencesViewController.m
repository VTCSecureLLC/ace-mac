//
//  PreferencesViewController.m
//  ACE
//
//  Created by Norayr Harutyunyan on 1/11/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import "PreferencesViewController.h"
#import "LinphoneManager.h"
#import "SettingsService.h"
#import "AccountsService.h"
#import "SDPNegotiationService.h"
#import "CodecModel.h"
#import "DefaultSettingsManager.h"

@interface PreferencesViewController () <NSTextFieldDelegate, NSComboBoxDelegate> {
    NSMutableArray *audioCodecList;
    NSMutableArray *videoCodecList;
    
    BOOL isChanged;

    NSButton *checkboxEnableVideo;
    NSButton *checkboxEnableRTT;
    NSButton *checkboxAdaptiveRate;
    NSButton *checkboxAlwaysInititate;
    NSButton *checkboxAlwaysAccept;
    NSComboBox *comboBoxVideoPreset;
    NSComboBox *comboBoxPreferredSize;
    NSTextField *textFieldMWIURL;
    NSButton *checkboxStun;
    NSButton *checkboxEnableICE;
    NSButton *checkboxEnableUPNP;
    NSButton *checkboxRandomPorts;
    NSComboBox *comboBoxMediaEncription;
    NSButton *checkboxPushNotifications;
    NSButton *checkboxIPv6;
    NSButton *checkboxDebugMode;
    NSButton *checkboxPersistentNotifier;
    NSButton *checkboxSharingServerURL;
    NSButton *checkboxRemoteProvisioning;
    NSButton *checkboxSendLogs;
    NSButton *checkboxClearLogs;
    
    NSTextField *textFieldPreferredFPS;
    NSTextField *textFieldSTUNURL;
    NSTextField *textFieldSIPPort;
    NSTextField *textFieldAudioPorts;
    NSTextField *textFieldVideoPorts;
    
    NSDictionary *supportedCodecsMap;
}

@property (weak) IBOutlet NSScrollView *scrollView;

@end

@implementation PreferencesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
}

- (NSString*) textFieldValueWithUserDefaultsKey:(NSString*)key {
    if ([key isEqualToString:@"ACE_USERNAME"]) {
        AccountModel *accountModel = [[AccountsService sharedInstance] getDefaultAccount];
        return accountModel.username;
    } else if ([key isEqualToString:@"ACE_AUTH_ID"]) {
        AccountModel *accountModel = [[AccountsService sharedInstance] getDefaultAccount];
        return accountModel.userID;
    } else if ([key isEqualToString:@"ACE_DOMAIN"]) {
        AccountModel *accountModel = [[AccountsService sharedInstance] getDefaultAccount];
        return accountModel.domain;
    } else {
        return [[NSUserDefaults standardUserDefaults] objectForKey:key];
    }
    
    return nil;
}

-(void) viewDidAppear{
    // Do view setup here.
    
    supportedCodecsMap = [[NSDictionary alloc] initWithObjectsAndKeys:@"1", @"g722_preference",
                          @"1", @"pcmu_preference",
                          @"1", @"pcma_preference",
                          @"1", @"speex_8k_preference",
                          @"1", @"speex_16k_preference",
                          @"1", @"h264_preference",
                          @"1", @"h263_preference",
                          @"1", @"vp8_preference",  nil];
    isChanged = NO;
    
    LinphoneCore *lc = [LinphoneManager getLc];
    
    const char *preset = linphone_core_get_video_preset(lc);
    
    PayloadType *pt;
    const MSList *elem;
    
    audioCodecList = [[NSMutableArray alloc] init];
    videoCodecList = [[NSMutableArray alloc] init];
    
    NSDictionary *dictAudioCodec = [[NSUserDefaults standardUserDefaults] objectForKey:kUSER_DEFAULTS_AUDIO_CODECS_MAP];
    NSDictionary *dictVideoCodec = [[NSUserDefaults standardUserDefaults] objectForKey:kUSER_DEFAULTS_VIDEO_CODECS_MAP];
    
    const MSList *audioCodecs = linphone_core_get_audio_codecs(lc);
    
    for (elem = audioCodecs; elem != NULL; elem = elem->next) {
        pt = (PayloadType *)elem->data;
        NSString *pref = [SDPNegotiationService getPreferenceForCodec:pt->mime_type withRate:pt->clock_rate];
        
        if (pref && [self isCodecSupported:pref]) {
            bool_t value = linphone_core_payload_type_enabled(lc, pt);
            
            CodecModel *codecModel = [[CodecModel alloc] init];
            
            codecModel.name = [NSString stringWithUTF8String:pt->mime_type];
            codecModel.preference = pref;
            codecModel.rate = pt->clock_rate;
            codecModel.channels = pt->channels;
            
            if ([dictAudioCodec objectForKey:pref]) {
                codecModel.status = [[dictAudioCodec objectForKey:pref] boolValue];
            } else {
                codecModel.status = value;
            }
            
            [audioCodecList addObject:codecModel];
        }
    }
    
    const MSList *videoCodecs = linphone_core_get_video_codecs(lc);
    
    for (elem = videoCodecs; elem != NULL; elem = elem->next) {
        pt = (PayloadType *)elem->data;
        NSString *pref = [SDPNegotiationService getPreferenceForCodec:pt->mime_type withRate:pt->clock_rate];
        
        if (pref && [self isCodecSupported:pref]) {
            bool_t value = linphone_core_payload_type_enabled(lc, pt);
            
            CodecModel *codecModel = [[CodecModel alloc] init];
            
            codecModel.name = [NSString stringWithUTF8String:pt->mime_type];
            codecModel.preference = pref;
            codecModel.rate = pt->clock_rate;
            codecModel.channels = pt->channels;
            
            if ([dictVideoCodec objectForKey:pref]) {
                codecModel.status = [[dictVideoCodec objectForKey:pref] boolValue];
            } else {
                codecModel.status = value;
            }
            
            [videoCodecList addObject:codecModel];
        }
    }
    
    int scrollContentHeight = 1340;
    int originY = scrollContentHeight - 30;
    
    NSView *docView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 425, scrollContentHeight)];
    [self.scrollView setDocumentView:docView];
    
    
    checkboxEnableVideo = [[NSButton alloc] initWithFrame:NSMakeRect(10, originY, 200, 20)]; // YES
    [checkboxEnableVideo setButtonType:NSSwitchButton];
    [checkboxEnableVideo setBezelStyle:0];
    [checkboxEnableVideo setTitle:@"Enable Video"];
    
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"start_video_preference"]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"start_video_preference"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"enable_video_preference"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"accept_video_preference"];
    }
    [checkboxEnableVideo setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"start_video_preference"]];
    [checkboxEnableVideo setAction:@selector(onCheckBoxHandler:)];
    [checkboxEnableVideo setTarget:self];
    [self.scrollView.documentView addSubview:checkboxEnableVideo];
    
    originY -= 30;
    checkboxEnableRTT = [[NSButton alloc] initWithFrame:NSMakeRect(10, originY, 200, 20)]; // YES
    [checkboxEnableRTT setButtonType:NSSwitchButton];
    [checkboxEnableRTT setBezelStyle:0];
    [checkboxEnableRTT setTitle:@"Enable RTT"];
    [checkboxEnableRTT setState:[SettingsService getRTTEnabled]];
    [checkboxEnableRTT setAction:@selector(onCheckBoxHandler:)];
    [checkboxEnableRTT setTarget:self];
    [self.scrollView.documentView addSubview:checkboxEnableRTT];
    
    originY -= 25;
    NSTextField *labelTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(10, originY, 100, 20)];
    labelTitle.editable = NO;
    labelTitle.stringValue = @"Audio";
    [labelTitle.cell setBordered:NO];
    [labelTitle setBackgroundColor:[NSColor clearColor]];
    [self.scrollView.documentView addSubview:labelTitle];
    
    originY -= 25;
    checkboxAdaptiveRate = [[NSButton alloc] initWithFrame:NSMakeRect(20, originY, 200, 20)]; // YES
    [checkboxAdaptiveRate setButtonType:NSSwitchButton];
    [checkboxAdaptiveRate setBezelStyle:0];
    [checkboxAdaptiveRate setTitle:@"Adaptive Rate"];
    [checkboxAdaptiveRate setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"enable_adaptive_rate_control"]];
    [checkboxAdaptiveRate setAction:@selector(onCheckBoxHandler:)];
    [checkboxAdaptiveRate setTarget:self];
    [self.scrollView.documentView addSubview:checkboxAdaptiveRate];
    
    originY -= 25;
    labelTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(20, originY, 100, 20)]; // YES
    labelTitle.editable = NO;
    labelTitle.stringValue = @"Audio Codecs";
    [labelTitle.cell setBordered:NO];
    [labelTitle setBackgroundColor:[NSColor clearColor]];
    [self.scrollView.documentView addSubview:labelTitle];
    
    for (int i = 0; i <audioCodecList.count; i++) {
        CodecModel *codecModel = [audioCodecList objectAtIndex:i];
        
        originY -= 30;
        NSButton *checkboxACodec = [[NSButton alloc] initWithFrame:NSMakeRect(30, originY, 200, 20)];
        checkboxACodec.tag = i;
        [checkboxACodec setButtonType:NSSwitchButton];
        [checkboxACodec setBezelStyle:0];
        [checkboxACodec setTitle:codecModel.name];
        [checkboxACodec setState:codecModel.status];
        [checkboxACodec setAction:@selector(onCheckboxAudioStatus:)];
        [checkboxACodec setTarget:self];
        [self.scrollView.documentView addSubview:checkboxACodec];
    }
    
    originY -= 30;
    labelTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(10, originY, 100, 20)];
    labelTitle.editable = NO;
    labelTitle.stringValue = @"Video";
    [labelTitle.cell setBordered:NO];
    [labelTitle setBackgroundColor:[NSColor clearColor]];
    [self.scrollView.documentView addSubview:labelTitle];
    
    originY -= 30;
    checkboxAlwaysInititate = [[NSButton alloc] initWithFrame:NSMakeRect(20, originY, 200, 20)]; // YES
    [checkboxAlwaysInititate setButtonType:NSSwitchButton];
    [checkboxAlwaysInititate setBezelStyle:0];
    [checkboxAlwaysInititate setTitle:@"Always Inititate"];
    [checkboxAlwaysInititate setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"enable_video_preference"]];
    [checkboxAlwaysInititate setAction:@selector(onCheckBoxHandler:)];
    [checkboxAlwaysInititate setTarget:self];
    [self.scrollView.documentView addSubview:checkboxAlwaysInititate];
    
    originY -= 30;
    checkboxAlwaysAccept = [[NSButton alloc] initWithFrame:NSMakeRect(20, originY, 200, 20)]; // YES
    [checkboxAlwaysAccept setButtonType:NSSwitchButton];
    [checkboxAlwaysAccept setBezelStyle:0];
    [checkboxAlwaysAccept setTitle:@"Always accept"];
    [checkboxAlwaysAccept setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"accept_video_preference"]];
    [checkboxAlwaysAccept setAction:@selector(onCheckBoxHandler:)];
    [checkboxAlwaysAccept setTarget:self];
    [self.scrollView.documentView addSubview:checkboxAlwaysAccept];
    
    originY -= 30;
    comboBoxVideoPreset = [[NSComboBox alloc] initWithFrame:NSMakeRect(20, originY, 200, 26)]; // YES
    [comboBoxVideoPreset addItemsWithObjectValues:@[@"default", @"high-fps", @"custom"]];
    [comboBoxVideoPreset setDelegate:self];
    
    const char *video_preset = linphone_core_get_video_preset([LinphoneManager getLc]);
    if (!video_preset || strcmp(video_preset, "default") == 0) {
        comboBoxVideoPreset.stringValue = @"default";
    } else if (strcmp(video_preset, "high-fps") == 0) {
        comboBoxVideoPreset.stringValue = @"high-fps";
    } else if (strcmp(video_preset, "custom") == 0) {
        comboBoxVideoPreset.stringValue = @"custom";
    }
    [self.scrollView.documentView addSubview:comboBoxVideoPreset];
    
    originY -= 30;
    
    comboBoxPreferredSize = [[NSComboBox alloc] initWithFrame:NSMakeRect(20, originY, 200, 26)]; // YES
    [comboBoxPreferredSize addItemsWithObjectValues:@[@"1080p (1920x1080)", @"720p (1280x720)", @"svga (800x600)", @"4cif (704x576)", @"vga (640x480)", @"cif (352x288)", @"qcif (176x144)"]];
    
    NSString *video_resolution = [[NSUserDefaults standardUserDefaults] objectForKey:@"video_preferred_size_preference"];
    
    if (video_resolution) {
        comboBoxPreferredSize.stringValue = video_resolution;
    } else {
        MSVideoSize vsize = linphone_core_get_preferred_video_size([LinphoneManager getLc]);
        
        if ((vsize.width == MS_VIDEO_SIZE_1080P_W) && (vsize.height == MS_VIDEO_SIZE_1080P_H)) {
            comboBoxPreferredSize.stringValue = @"1080p (1920x1080)";
        } else if ((vsize.width == MS_VIDEO_SIZE_720P_W) && (vsize.height == MS_VIDEO_SIZE_720P_H)) {
            comboBoxPreferredSize.stringValue = @"720p (1280x720)";
        } else if ((vsize.width == MS_VIDEO_SIZE_SVGA_W) && (vsize.height == MS_VIDEO_SIZE_SVGA_H)) {
            comboBoxPreferredSize.stringValue = @"svga (800x600)";
        } else if ((vsize.width == MS_VIDEO_SIZE_4CIF_W) && (vsize.height == MS_VIDEO_SIZE_4CIF_H)) {
            comboBoxPreferredSize.stringValue = @"4cif (704x576)";
        } else if ((vsize.width == MS_VIDEO_SIZE_VGA_W) && (vsize.height == MS_VIDEO_SIZE_VGA_H)) {
            comboBoxPreferredSize.stringValue = @"vga (640x480)";
        } else if ((vsize.width == MS_VIDEO_SIZE_CIF_W) && (vsize.height == MS_VIDEO_SIZE_CIF_H)) {
            comboBoxPreferredSize.stringValue = @"cif (352x288)";
        } else if ((vsize.width == MS_VIDEO_SIZE_QCIF_W) && (vsize.height == MS_VIDEO_SIZE_QCIF_H)) {
            comboBoxPreferredSize.stringValue = @"qcif (176x144)";
        }  else {
            comboBoxPreferredSize.stringValue = @"None";
        }
    }
    
    [self.scrollView.documentView addSubview:comboBoxPreferredSize];
    
    originY -= 30;
    labelTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(20, originY, 100, 20)]; // YES
    labelTitle.editable = NO;
    labelTitle.stringValue = @"Preferred FPS";
    [labelTitle.cell setBordered:NO];
    [labelTitle setBackgroundColor:[NSColor clearColor]];
    [self.scrollView.documentView addSubview:labelTitle];
    
    NSString *textfieldValue = [self textFieldValueWithUserDefaultsKey:@"video_preferred_fps_preference"];
    
    float fps = linphone_core_get_preferred_framerate([LinphoneManager getLc]);
    
    textFieldPreferredFPS = [[NSTextField alloc] initWithFrame:NSMakeRect(130, originY, 100, 20)];
    textFieldPreferredFPS.delegate = self;
    textFieldPreferredFPS.floatValue = fps ? fps : 30.0;
    textFieldPreferredFPS.editable = YES;
    [self.scrollView.documentView addSubview:textFieldPreferredFPS];
    
    originY -= 25;
    labelTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(20, originY, 100, 20)]; // YES
    labelTitle.editable = NO;
    labelTitle.stringValue = @"Video Codecs";
    [labelTitle.cell setBordered:NO];
    [labelTitle setBackgroundColor:[NSColor clearColor]];
    [self.scrollView.documentView addSubview:labelTitle];
    
    for (int i = 0; i <videoCodecList.count; i++) {
        CodecModel *codecModel = [videoCodecList objectAtIndex:i];
        
        originY -= 30;
        NSButton *checkboxVCodec = [[NSButton alloc] initWithFrame:NSMakeRect(30, originY, 200, 20)];
        checkboxVCodec.tag = i;
        [checkboxVCodec setButtonType:NSSwitchButton];
        [checkboxVCodec setBezelStyle:0];
        [checkboxVCodec setTitle:codecModel.name];
        [checkboxVCodec setState:codecModel.status];
        [checkboxVCodec setAction:@selector(onCheckboxVideoStatus:)];
        [checkboxVCodec setTarget:self];
        [self.scrollView.documentView addSubview:checkboxVCodec];
    }
    
    originY -= 25;
    labelTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(20, originY, 100, 20)];
    labelTitle.editable = NO;
    labelTitle.stringValue = @"Call Control";
    [labelTitle.cell setBordered:NO];
    [labelTitle setBackgroundColor:[NSColor clearColor]];
    [self.scrollView.documentView addSubview:labelTitle];
    
    originY -= 25;
    labelTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(30, originY, 100, 20)]; // YES
    labelTitle.editable = NO;
    labelTitle.stringValue = @"MWI URL";
    [labelTitle.cell setBordered:NO];
    [labelTitle setBackgroundColor:[NSColor clearColor]];
    [self.scrollView.documentView addSubview:labelTitle];
    
    textfieldValue = [DefaultSettingsManager sharedInstance].sipMwiUri;
    
    textFieldMWIURL = [[NSTextField alloc] initWithFrame:NSMakeRect(130, originY, 170, 20)];
    textFieldMWIURL.delegate = self;
    textFieldMWIURL.stringValue = textfieldValue ? textfieldValue : @"mwi.linphone.org";
    textFieldMWIURL.editable = YES;
    [self.scrollView.documentView addSubview:textFieldMWIURL];
    
    originY -= 25;
    labelTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(20, originY, 100, 20)];
    labelTitle.editable = NO;
    labelTitle.stringValue = @"Network";
    [labelTitle.cell setBordered:NO];
    [labelTitle setBackgroundColor:[NSColor clearColor]];
    [self.scrollView.documentView addSubview:labelTitle];
    
    originY -= 25;
    checkboxStun = [[NSButton alloc] initWithFrame:NSMakeRect(30, originY, 200, 20)]; // YES
    [checkboxStun setButtonType:NSSwitchButton];
    [checkboxStun setBezelStyle:0];
    [checkboxStun setTitle:@"STUN"];
    [checkboxStun setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"stun_preference"]];
    [checkboxStun setAction:@selector(onCheckBoxHandler:)];
    [checkboxStun setTarget:self];
    [self.scrollView.documentView addSubview:checkboxStun];
    
    originY -= 30;
    labelTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(30, originY, 100, 20)]; // YES
    labelTitle.editable = NO;
    labelTitle.stringValue = @"STUN URL";
    [labelTitle.cell setBordered:NO];
    [labelTitle setBackgroundColor:[NSColor clearColor]];
    [self.scrollView.documentView addSubview:labelTitle];
    
    textfieldValue = [DefaultSettingsManager sharedInstance].stunServer;
    
    textFieldSTUNURL = [[NSTextField alloc] initWithFrame:NSMakeRect(130, originY, 170, 20)];
    textFieldSTUNURL.delegate = self;
    textFieldSTUNURL.stringValue = textfieldValue ? textfieldValue : @"stun.linphone.org";
    textFieldSTUNURL.editable = YES;
    [self.scrollView.documentView addSubview:textFieldSTUNURL];
    
    originY -= 30;
    checkboxEnableICE = [[NSButton alloc] initWithFrame:NSMakeRect(30, originY, 200, 20)]; // YES
    [checkboxEnableICE setButtonType:NSSwitchButton];
    [checkboxEnableICE setBezelStyle:0];
    [checkboxEnableICE setTitle:@"Enable ICE"];
    [checkboxEnableICE setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"ice_preference"]];
    [checkboxEnableICE setAction:@selector(onCheckBoxHandler:)];
    [checkboxEnableICE setTarget:self];
    [self.scrollView.documentView addSubview:checkboxEnableICE];
    
    originY -= 30;
    checkboxEnableUPNP = [[NSButton alloc] initWithFrame:NSMakeRect(30, originY, 200, 20)]; // YES
    [checkboxEnableUPNP setButtonType:NSSwitchButton];
    [checkboxEnableUPNP setBezelStyle:0];
    [checkboxEnableUPNP setTitle:@"Enable UPNP"];
    [checkboxEnableUPNP setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"ACE_ENABLE_UPNP"]];
    [checkboxEnableUPNP setAction:@selector(onCheckBoxHandler:)];
    [checkboxEnableUPNP setTarget:self];
    [checkboxEnableUPNP setEnabled:linphone_core_upnp_available()];
    [self.scrollView.documentView addSubview:checkboxEnableUPNP];
    
    originY -= 30;
    checkboxRandomPorts = [[NSButton alloc] initWithFrame:NSMakeRect(30, originY, 200, 20)];
    [checkboxRandomPorts setButtonType:NSSwitchButton];
    [checkboxRandomPorts setBezelStyle:0];
    [checkboxRandomPorts setTitle:@"Random Ports"];
    [checkboxRandomPorts setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"random_port_preference"]];
    [checkboxRandomPorts setAction:@selector(onCheckBoxHandler:)];
    [checkboxRandomPorts setTarget:self];
    [self.scrollView.documentView addSubview:checkboxRandomPorts];
    
    originY -= 30;
    labelTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(30, originY, 100, 20)];
    labelTitle.editable = NO;
    labelTitle.stringValue = @"SIP Port";
    [labelTitle.cell setBordered:NO];
    [labelTitle setBackgroundColor:[NSColor clearColor]];
    [self.scrollView.documentView addSubview:labelTitle];
    
    textfieldValue = [NSString stringWithFormat:@"%d", [DefaultSettingsManager sharedInstance].sipRegisterPort];
    
    textFieldSIPPort = [[NSTextField alloc] initWithFrame:NSMakeRect(130, originY, 170, 20)];
    textFieldSIPPort.delegate = self;
    textFieldSIPPort.stringValue = textfieldValue ? textfieldValue : @"5060";
    textFieldSIPPort.editable = YES;
    [self.scrollView.documentView addSubview:textFieldSIPPort];
    
    originY -= 30;
    labelTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(30, originY, 100, 20)];
    labelTitle.editable = NO;
    labelTitle.stringValue = @"Audio ports";
    [labelTitle.cell setBordered:NO];
    [labelTitle setBackgroundColor:[NSColor clearColor]];
    [self.scrollView.documentView addSubview:labelTitle];
    
    textfieldValue = [self textFieldValueWithUserDefaultsKey:@"AVE_AUDIO_PORTS"];
    
    textFieldAudioPorts = [[NSTextField alloc] initWithFrame:NSMakeRect(130, originY, 170, 20)];
    textFieldAudioPorts.delegate = self;
    textFieldAudioPorts.stringValue = textfieldValue ? textfieldValue : @"7200-7299";
    textFieldAudioPorts.editable = YES;
    [self.scrollView.documentView addSubview:textFieldAudioPorts];
    
    originY -= 30;
    labelTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(30, originY, 100, 20)];
    labelTitle.editable = NO;
    labelTitle.stringValue = @"Video ports";
    [labelTitle.cell setBordered:NO];
    [labelTitle setBackgroundColor:[NSColor clearColor]];
    [self.scrollView.documentView addSubview:labelTitle];
    
    textfieldValue = [self textFieldValueWithUserDefaultsKey:@"AVE_AUDIO_PORTS"];
    
    textFieldVideoPorts = [[NSTextField alloc] initWithFrame:NSMakeRect(130, originY, 170, 20)];
    textFieldVideoPorts.delegate = self;
    textFieldVideoPorts.stringValue = textfieldValue ? textfieldValue : @"9200-9299";
    textFieldVideoPorts.editable = YES;
    [self.scrollView.documentView addSubview:textFieldVideoPorts];
    
    originY -= 30;
    labelTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(30, originY, 100, 20)]; // YES
    labelTitle.editable = NO;
    labelTitle.stringValue = @"Media Encrypt.";
    [labelTitle.cell setBordered:NO];
    [labelTitle setBackgroundColor:[NSColor clearColor]];
    [self.scrollView.documentView addSubview:labelTitle];
    
    comboBoxMediaEncription = [[NSComboBox alloc] initWithFrame:NSMakeRect(130, originY, 170, 26)];
    [comboBoxMediaEncription addItemsWithObjectValues:@[@"Encrypted (SRTP)", @"Encrypted (ZRTP)", @"Encrypted (DTLS)", @"Unencrypted"]];
    [self.scrollView.documentView addSubview:comboBoxMediaEncription];
    
    LinphoneMediaEncryption menc = linphone_core_get_media_encryption([LinphoneManager getLc]);
    
    switch (menc) {
        case LinphoneMediaEncryptionSRTP:
            comboBoxMediaEncription.stringValue = @"Encrypted (SRTP)";
            break;
        case LinphoneMediaEncryptionZRTP:
            comboBoxMediaEncription.stringValue = @"Encrypted (ZRTP)";
            break;
        case LinphoneMediaEncryptionDTLS:
            comboBoxMediaEncription.stringValue = @"Encrypted (DTLS)";
            break;
        case LinphoneMediaEncryptionNone:
            comboBoxMediaEncription.stringValue = @"Unencrypted";
            break;
    }
    
    originY -= 30;
    checkboxPushNotifications = [[NSButton alloc] initWithFrame:NSMakeRect(30, originY, 200, 20)]; // NO
    [checkboxPushNotifications setButtonType:NSSwitchButton];
    [checkboxPushNotifications setBezelStyle:0];
    [checkboxPushNotifications setTitle:@"Push Notifications"];
    [checkboxPushNotifications setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"ACE_PUSH_NOTIFICATIONS"]];
    [checkboxPushNotifications setAction:@selector(onCheckBoxHandler:)];
    [checkboxPushNotifications setTarget:self];
    [self.scrollView.documentView addSubview:checkboxPushNotifications];
    
    originY -= 30;
    checkboxIPv6 = [[NSButton alloc] initWithFrame:NSMakeRect(30, originY, 200, 20)]; // YES
    [checkboxIPv6 setButtonType:NSSwitchButton];
    [checkboxIPv6 setBezelStyle:0];
    [checkboxIPv6 setTitle:@"IPv6"];
    [checkboxIPv6 setState:linphone_core_ipv6_enabled([LinphoneManager getLc])];
    [checkboxIPv6 setAction:@selector(onCheckBoxHandler:)];
    [checkboxIPv6 setTarget:self];
    [self.scrollView.documentView addSubview:checkboxIPv6];
    
    originY -= 25;
    labelTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(20, originY, 100, 20)];
    labelTitle.editable = NO;
    labelTitle.stringValue = @"Advanced";
    [labelTitle.cell setBordered:NO];
    [labelTitle setBackgroundColor:[NSColor clearColor]];
    [self.scrollView.documentView addSubview:labelTitle];
    
    originY -= 30;
    checkboxDebugMode = [[NSButton alloc] initWithFrame:NSMakeRect(30, originY, 200, 20)]; // NO
    [checkboxDebugMode setButtonType:NSSwitchButton];
    [checkboxDebugMode setBezelStyle:0];
    [checkboxDebugMode setTitle:@"Debug Mode"];
    [checkboxDebugMode setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"ACE_DEBUG_MODE"]];
    [checkboxDebugMode setAction:@selector(onCheckBoxHandler:)];
    [checkboxDebugMode setTarget:self];
    [self.scrollView.documentView addSubview:checkboxDebugMode];
    
    originY -= 30;
    checkboxPersistentNotifier = [[NSButton alloc] initWithFrame:NSMakeRect(30, originY, 200, 20)]; // NO
    [checkboxPersistentNotifier setButtonType:NSSwitchButton];
    [checkboxPersistentNotifier setBezelStyle:0];
    [checkboxPersistentNotifier setTitle:@"Persistent Notifier"];
    [checkboxPersistentNotifier setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"ACE_PERSISTENT_NOTIFIER"]];
    [checkboxPersistentNotifier setAction:@selector(onCheckBoxHandler:)];
    [checkboxPersistentNotifier setTarget:self];
    [self.scrollView.documentView addSubview:checkboxPersistentNotifier];
    
    originY -= 30;
    checkboxSharingServerURL = [[NSButton alloc] initWithFrame:NSMakeRect(30, originY, 200, 20)]; // NO
    [checkboxSharingServerURL setButtonType:NSSwitchButton];
    [checkboxSharingServerURL setBezelStyle:0];
    [checkboxSharingServerURL setTitle:@"Sharing Server URL"];
    [checkboxSharingServerURL setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"ACE_SHARING_SERVER_URL"]];
    [checkboxSharingServerURL setAction:@selector(onCheckBoxHandler:)];
    [checkboxSharingServerURL setTarget:self];
    [self.scrollView.documentView addSubview:checkboxSharingServerURL];
    
    originY -= 30;
    checkboxRemoteProvisioning = [[NSButton alloc] initWithFrame:NSMakeRect(30, originY, 200, 20)]; // NO
    [checkboxRemoteProvisioning setButtonType:NSSwitchButton];
    [checkboxRemoteProvisioning setBezelStyle:0];
    [checkboxRemoteProvisioning setTitle:@"Remote Provisioning"];
    [checkboxRemoteProvisioning setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"Remote Provisioning"]];
    [checkboxRemoteProvisioning setAction:@selector(onCheckBoxHandler:)];
    [checkboxRemoteProvisioning setTarget:self];
    [self.scrollView.documentView addSubview:checkboxRemoteProvisioning];
    
    originY -= 30;
    checkboxSendLogs = [[NSButton alloc] initWithFrame:NSMakeRect(30, originY, 200, 20)]; // NO
    [checkboxSendLogs setButtonType:NSSwitchButton];
    [checkboxSendLogs setBezelStyle:0];
    [checkboxSendLogs setTitle:@"Send Logs"];
    [checkboxSendLogs setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"ACE_SEND_LOGS"]];
    [checkboxSendLogs setAction:@selector(onCheckBoxHandler:)];
    [checkboxSendLogs setTarget:self];
    [self.scrollView.documentView addSubview:checkboxSendLogs];
    
    originY -= 30;
    checkboxClearLogs = [[NSButton alloc] initWithFrame:NSMakeRect(30, originY, 200, 20)]; // NO
    [checkboxClearLogs setButtonType:NSSwitchButton];
    [checkboxClearLogs setBezelStyle:0];
    [checkboxClearLogs setTitle:@"Clear Logs"];
    [checkboxClearLogs setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"ACE_CLEAR_LOGS"]];
    [checkboxClearLogs setAction:@selector(onCheckBoxHandler:)];
    [checkboxClearLogs setTarget:self];
    [self.scrollView.documentView addSubview:checkboxClearLogs];
    
    NSPoint newOrigin = NSMakePoint(0, NSMaxY(((NSView*)self.scrollView.documentView).frame) - 400);
    [self.scrollView.contentView scrollToPoint:newOrigin];
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
    NSLog(@"comboBoxSelectionDidChange");
    
    NSComboBox *comboBox = (NSComboBox *)[notification object];
    
    if (comboBox == comboBoxMediaEncription || comboBox == comboBoxPreferredSize || comboBox == comboBoxVideoPreset) {
        isChanged = YES;
    }
}

- (void)onCheckBoxHandler:(id)sender {
    isChanged = YES;
}

- (void)onCheckboxAudioStatus:(id)sender {
    NSButton *button = (NSButton*)sender;
    
    CodecModel *codecModel = [audioCodecList objectAtIndex:button.tag];
    codecModel.status = button.state;
    
    isChanged = YES;
}

- (void)onCheckboxVideoStatus:(id)sender {
    NSButton *button = (NSButton*)sender;
    
    CodecModel *codecModel = [videoCodecList objectAtIndex:button.tag];
    codecModel.status = button.state;
    
    
    isChanged = YES;
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
    isChanged = YES;
    
    return YES;
}

- (void) save {
    if (!isChanged) {
        return;
    }
    
    [self saveAudioCodecs];
    [self saveVideoCodecs];

    LinphoneCore *lc = [LinphoneManager getLc];

    [[NSUserDefaults standardUserDefaults] setBool:checkboxEnableRTT.state forKey:kREAL_TIME_TEXT_ENABLED];
    
    linphone_core_enable_adaptive_rate_control(lc, checkboxAdaptiveRate.state);
    
    linphone_core_enable_video_capture(lc, checkboxAlwaysInititate.state);
    linphone_core_enable_video_display(lc, checkboxAlwaysInititate.state);

    LinphoneVideoPolicy policy;
    policy.automatically_initiate = (BOOL)checkboxEnableVideo.state;
    policy.automatically_accept = (BOOL)checkboxAlwaysAccept.state;
    linphone_core_set_video_policy(lc, &policy);

    linphone_core_set_video_preset(lc, [comboBoxVideoPreset.stringValue UTF8String]);
    
    MSVideoSize vsize;
    
    if ([comboBoxPreferredSize.stringValue isEqualToString:@"1080p (1920x1080)"]) {
        MS_VIDEO_SIZE_ASSIGN(vsize, 1080P);
    } else     if ([comboBoxPreferredSize.stringValue isEqualToString:@"720p (1280x720)"]) {
        MS_VIDEO_SIZE_ASSIGN(vsize, 720P);
    } else     if ([comboBoxPreferredSize.stringValue isEqualToString:@"svga (800x600)"]) {
        MS_VIDEO_SIZE_ASSIGN(vsize, SVGA);
    } else     if ([comboBoxPreferredSize.stringValue isEqualToString:@"4cif (704x576)"]) {
        MS_VIDEO_SIZE_ASSIGN(vsize, 4CIF);
    } else     if ([comboBoxPreferredSize.stringValue isEqualToString:@"vga (640x480)"]) {
        MS_VIDEO_SIZE_ASSIGN(vsize, VGA);
    } else     if ([comboBoxPreferredSize.stringValue isEqualToString:@"cif (352x288)"]) {
        MS_VIDEO_SIZE_ASSIGN(vsize, CIF);
    } else     if ([comboBoxPreferredSize.stringValue isEqualToString:@"qcif (176x144)"]) {
        MS_VIDEO_SIZE_ASSIGN(vsize, QCIF);
    }
    
    linphone_core_set_preferred_video_size(lc, vsize);
    [[NSUserDefaults standardUserDefaults] setObject:comboBoxPreferredSize.stringValue forKey:@"video_preferred_size_preference"];

    linphone_core_set_preferred_framerate(lc, textFieldPreferredFPS.floatValue);
    
    [[NSUserDefaults standardUserDefaults] setObject:textFieldSTUNURL.stringValue forKey:@"stun_url_preference"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [SettingsService setStun:checkboxStun.state];
    [SettingsService setICE:checkboxEnableICE.state];
    [[NSUserDefaults standardUserDefaults] setBool:checkboxEnableICE.state forKey:@"ice_preference"];

    if (comboBoxMediaEncription.stringValue && [comboBoxMediaEncription.stringValue compare:@"Encrypted (SRTP)"] == NSOrderedSame)
        linphone_core_set_media_encryption(lc, LinphoneMediaEncryptionSRTP);
    else if (comboBoxMediaEncription.stringValue && [comboBoxMediaEncription.stringValue compare:@"Encrypted (ZRTP)"] == NSOrderedSame)
        linphone_core_set_media_encryption(lc, LinphoneMediaEncryptionZRTP);
    else if (comboBoxMediaEncription.stringValue && [comboBoxMediaEncription.stringValue compare:@"Encrypted (DTLS)"] == NSOrderedSame)
        linphone_core_set_media_encryption(lc, LinphoneMediaEncryptionDTLS);
    else
        linphone_core_set_media_encryption(lc, LinphoneMediaEncryptionNone);

    linphone_core_enable_ipv6(lc, checkboxIPv6.state);
}

- (void) saveAudioCodecs {
    LinphoneCore *lc = [LinphoneManager getLc];
    PayloadType *pt;
    const MSList *elem;
    const MSList *audioCodecs = linphone_core_get_audio_codecs(lc);
    NSMutableDictionary *mdictForSave = [[NSMutableDictionary alloc] init];
    
    for (elem = audioCodecs; elem != NULL; elem = elem->next) {
        pt = (PayloadType *)elem->data;
        NSString *pref = [SDPNegotiationService getPreferenceForCodec:pt->mime_type withRate:pt->clock_rate];
        
        if (pref) {
            CodecModel *codecModel = [self getAudioCodecWithName:[NSString stringWithUTF8String:pt->mime_type]
                                                            Rate:pt->clock_rate
                                                        Channels:pt->channels];
            
            if (codecModel) {
                linphone_core_enable_payload_type(lc, pt, codecModel.status);
                
                [mdictForSave setObject:[NSNumber numberWithBool:codecModel.status] forKey:codecModel.preference];
            }
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:mdictForSave forKey:kUSER_DEFAULTS_AUDIO_CODECS_MAP];
}

- (void) saveVideoCodecs {
    LinphoneCore *lc = [LinphoneManager getLc];
    PayloadType *pt;
    const MSList *elem;
    const MSList *videoCodecs = linphone_core_get_video_codecs(lc);
    NSMutableDictionary *mdictForSave = [[NSMutableDictionary alloc] init];
    
    for (elem = videoCodecs; elem != NULL; elem = elem->next) {
        pt = (PayloadType *)elem->data;
        NSString *pref = [SDPNegotiationService getPreferenceForCodec:pt->mime_type withRate:pt->clock_rate];
        
        if (pref) {
            CodecModel *codecModel = [self getVideoCodecWithName:[NSString stringWithUTF8String:pt->mime_type]
                                                            Rate:pt->clock_rate
                                                        Channels:pt->channels];
            
            if (codecModel) {
                linphone_core_enable_payload_type(lc, pt, codecModel.status);
                
                [mdictForSave setObject:[NSNumber numberWithBool:codecModel.status] forKey:codecModel.preference];
            }
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:mdictForSave forKey:kUSER_DEFAULTS_VIDEO_CODECS_MAP];
}

- (CodecModel*) getAudioCodecWithName:(NSString*)name Rate:(int)rate Channels:(int)channels {
    for (CodecModel *codecModel in audioCodecList) {
        if ([codecModel.name isEqualToString:name] &&
            codecModel.rate == rate &&
            codecModel.channels == channels) {
            return codecModel;
        }
    }
    
    return nil;
}

- (CodecModel*) getVideoCodecWithName:(NSString*)name Rate:(int)rate Channels:(int)channels {
    for (CodecModel *codecModel in videoCodecList) {
        if ([codecModel.name isEqualToString:name] &&
            codecModel.rate == rate &&
            codecModel.channels == channels) {
            return codecModel;
        }
    }
    
    return nil;
}

- (BOOL) isCodecSupported:(NSString*)codec {
    return [[supportedCodecsMap objectForKey:codec] boolValue];
}

@end
