//
//  SettingsService.m
//  ACE
//
//  Created by Norayr Harutyunyan on 12/11/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "SettingsService.h"
#import "LinphoneManager.h"
#import "AccountsService.h"
#import "RegistrationService.h"
#import "DefaultSettingsManager.h"
#import "SDPNegotiationService.h"
#import "AccountModel.h"
#import "SettingsHeaderModel.h"
#import "SettingsItemModel.h"
#import "CodecModel.h"

static NSMutableArray *settingsList;

extern void linphone_iphone_log_handler(int lev, const char *fmt, va_list args);

@implementation SettingsService

+ (SettingsService *)sharedInstance
{
    static SettingsService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SettingsService alloc] init];
    });
    
    return sharedInstance;
}

+ (void) setSIPEncryption:(BOOL)encrypt {
    AccountModel *accountModel = [[AccountsService sharedInstance] getDefaultAccount];
    
    @try{
        if (accountModel) {
            [[AccountsService sharedInstance] removeAccountWithUsername:accountModel.username];
        }
    }
    @catch(NSException *e){
        NSLog(@"Tried to remove account that does not exist.");
    }
    
    NSString *transport;
    if (encrypt) {
        transport=@"TLS";
    } else {
        transport=@"TCP";
    }
    
    [[AccountsService sharedInstance] addAccountWithUsername:accountModel.username
                                                      UserID:accountModel.userID
                                                    Password:accountModel.password
                                                      Domain:accountModel.domain
                                                   Transport:transport
                                                        Port:accountModel.port
                                                   isDefault:YES];
    
    AccountModel *accountModel_ = [[AccountsService sharedInstance] getDefaultAccount];
    
    if (accountModel_) {
        [[RegistrationService sharedInstance] registerWithAccountModel:accountModel_];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeAccountsViewController" object:nil];
}

+ (void)setStartAppOnBoot:(BOOL)start {
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
    // Create a reference to the shared file list.
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
    if (loginItems) {
        if (start)
            [[SettingsService sharedInstance] enableLoginItemWithLoginItemsReference:loginItems ForPath:appPath];
        else
            [[SettingsService sharedInstance] disableLoginItemWithLoginItemsReference:loginItems ForPath:appPath];
    }
    
    CFRelease(loginItems);
}

+ (void) setColorWithKey:(NSString*)key Color:(NSColor*)color {
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSColor*) getColorWithKey:(NSString*)key {
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    NSColor *color = nil;
    if (colorData)
        color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];

    return color;
}

+ (BOOL) getMicMute {
    BOOL micMute = [[NSUserDefaults standardUserDefaults] boolForKey:@"MICROPHONE_MUTE"];
    
    return micMute;
}

+ (BOOL) getEchoCancel {
    BOOL echoCancel = [[NSUserDefaults standardUserDefaults] boolForKey:@"ECHO_CANCEL"];
    
    return echoCancel;
}

+ (BOOL) getShowPreview {
    BOOL showPreview;
    if ([[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"VIDEO_SHOW_PREVIEW"]){
            showPreview = [[NSUserDefaults standardUserDefaults] boolForKey:@"VIDEO_SHOW_PREVIEW"];
    }
    else{
        return TRUE;
    }
    return showPreview;
}

+ (BOOL) getRTTEnabled {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[[defaults dictionaryRepresentation] allKeys] containsObject:kREAL_TIME_TEXT_ENABLED]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:kREAL_TIME_TEXT_ENABLED];
    } else {
        return TRUE;
    }
}

//
- (void)enableLoginItemWithLoginItemsReference:(LSSharedFileListRef )theLoginItemsRefs ForPath:(NSString *)appPath {
    // We call LSSharedFileListInsertItemURL to insert the item at the bottom of Login Items list.
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];
    LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(theLoginItemsRefs, kLSSharedFileListItemLast, NULL, NULL, url, NULL, NULL);
    if (item)
        CFRelease(item);
}

- (void)disableLoginItemWithLoginItemsReference:(LSSharedFileListRef )theLoginItemsRefs ForPath:(NSString *)appPath {
    UInt32 seedValue;
    CFURLRef thePath = NULL;
    // We're going to grab the contents of the shared file list (LSSharedFileListItemRef objects)
    // and pop it in an array so we can iterate through it to find our item.
    CFArrayRef loginItemsArray = LSSharedFileListCopySnapshot(theLoginItemsRefs, &seedValue);
    for (id item in (__bridge NSArray *)loginItemsArray) {
        LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)item;
        if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &thePath, NULL) == noErr) {
            if ([[(__bridge NSURL *)thePath path] hasPrefix:appPath]) {
                LSSharedFileListItemRemove(theLoginItemsRefs, itemRef); // Deleting the item
            }
            // Docs for LSSharedFileListItemResolve say we're responsible
            // for releasing the CFURLRef that is returned
            if (thePath != NULL) CFRelease(thePath);
        }
    }
    if (loginItemsArray != NULL) CFRelease(loginItemsArray);
}

- (BOOL)loginItemExistsWithLoginItemReference:(LSSharedFileListRef)theLoginItemsRefs ForPath:(NSString *)appPath {
    BOOL found = NO;
    UInt32 seedValue;
    CFURLRef thePath = NULL;
    
    // We're going to grab the contents of the shared file list (LSSharedFileListItemRef objects)
    // and pop it in an array so we can iterate through it to find our item.
    CFArrayRef loginItemsArray = LSSharedFileListCopySnapshot(theLoginItemsRefs, &seedValue);
    for (id item in (__bridge NSArray *)loginItemsArray) {
        LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)item;
        if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &thePath, NULL) == noErr) {
            if ([[(__bridge NSURL *)thePath path] hasPrefix:appPath]) {
                found = YES;
                break;
            }
            // Docs for LSSharedFileListItemResolve say we're responsible
            // for releasing the CFURLRef that is returned
            if (thePath != NULL) CFRelease(thePath);
        }
    }
    if (loginItemsArray != NULL) CFRelease(loginItemsArray);
    
    return found;
}

+ (void) setStun:(BOOL)enable {
    LinphoneCore *lc = [LinphoneManager getLc];
    NSString *stun_server = [[NSUserDefaults standardUserDefaults] objectForKey:@"stun_url_preference"];
    
    if ([stun_server length] > 0) {
        linphone_core_set_stun_server(lc, [stun_server UTF8String]);
        BOOL ice_preference = [[NSUserDefaults standardUserDefaults] boolForKey:@"ice_preference"];
        if (ice_preference) {
            linphone_core_set_firewall_policy(lc, LinphonePolicyUseIce);
        }
    } else {
        linphone_core_set_stun_server(lc, NULL);
        linphone_core_set_firewall_policy(lc, LinphonePolicyNoFirewall);
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:@"stun_preference"];
}

+ (void) setICE:(BOOL)enable {
    LinphoneCore *lc = [LinphoneManager getLc];

    if (enable) {
        linphone_core_set_firewall_policy(lc, LinphonePolicyUseIce);
    } else {
        linphone_core_set_firewall_policy(lc, LinphonePolicyNoFirewall);
        [SettingsService setStun:[[NSUserDefaults standardUserDefaults] boolForKey:@"ice_preference"]];
    }
}

+ (void) setUPNP:(BOOL)enable {
    LinphoneCore *lc = [LinphoneManager getLc];
    
    if (enable) {
        linphone_core_set_firewall_policy(lc, LinphonePolicyUseUpnp);
    } else {
        linphone_core_set_firewall_policy(lc, LinphonePolicyNoFirewall);
        [self setICE:[[NSUserDefaults standardUserDefaults] boolForKey:@"upnp_preference"]];
    }
}

+ (void) setRandomPorts:(BOOL)enable {
    LinphoneCore *lc = [LinphoneManager getLc];
    int port_preference = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"port_preference"];
    
    if (enable) {
        port_preference = -1;
    }
    
    LCSipTransports transportValue = {port_preference, port_preference, -1, -1};
    
    // will also update the sip_*_port section of the config
    if (linphone_core_set_sip_transports(lc, &transportValue)) {
        NSLog(@"cannot set transport");
    }
}

+ (BOOL) defaultBoolValueForBoolKey:(NSString*)key {
    NSString *FileDB = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"SettingsAdvancedUI.plist"];
    NSArray *settings = [NSArray arrayWithContentsOfFile:FileDB];
    [settingsList removeAllObjects];
    
    [SettingsService loadSettingsFromArray:settings];
    
    for (int i = 0; i < settingsList.count; i++) {
        SettingsItemModel *object = [settingsList objectAtIndex:i];
        
        if ([object isKindOfClass:[SettingsItemModel class]] &&
            [object.userDefaultsKey isEqualToString:key]) {
            
            return [object.defaultValue boolValue];
        }
    }
    
    return NO;
}

+ (NSString*) defaultStringValueForBoolKey:(NSString*)key {
    NSString *FileDB = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"SettingsAdvancedUI.plist"];
    NSArray *settings = [NSArray arrayWithContentsOfFile:FileDB];
    [settingsList removeAllObjects];
    
    [SettingsService loadSettingsFromArray:settings];
    
    for (int i = 0; i < settingsList.count; i++) {
        SettingsItemModel *object = [settingsList objectAtIndex:i];
        
        if ([object isKindOfClass:[SettingsItemModel class]] &&
            [object.userDefaultsKey isEqualToString:key]) {
            
            return object.defaultValue;
        }
    }

    return nil;
}

+ (void) loadSettingsFromArray:(NSArray*)array_  {
    static int position = 0;
    SettingsHeaderModel *settingsHeaderModel;
    
    if (!settingsList)
        settingsList = [[NSMutableArray alloc] init];

    for (NSDictionary *dict in array_) {
        if ([dict isKindOfClass:[NSString class]]) {
            settingsHeaderModel = [[SettingsHeaderModel alloc] initWithTitle:(NSString *)dict];
            settingsHeaderModel.position = position;
            [settingsList addObject:settingsHeaderModel];
        } else if ([dict isKindOfClass:[NSDictionary class]]) {
            SettingsItemModel *settingsItemModel = [[SettingsItemModel alloc] initWithDictionary:dict];
            settingsItemModel.position = settingsHeaderModel.position;
            [settingsList addObject:settingsItemModel];
        } else if ([dict isKindOfClass:[NSArray class]]) {
            position++;
            [self loadSettingsFromArray:(NSArray *)dict];
            position--;
        }
    }
}

- (void)setConfigurationSettingsInitialValues {
    LinphoneManager *lm = [LinphoneManager instance];
    LinphoneCore *lc = [LinphoneManager getLc];
    
    // version - ?
    
    // expiration_time - set
    
    LinphoneProxyConfig* proxyCfg = linphone_core_create_proxy_config(lc);
    linphone_proxy_config_set_expires (proxyCfg, [DefaultSettingsManager sharedInstance].exparitionTime); // expiration time by default is 280

    // configuration_auth_password - ?
    
    // configuration_auth_expiration - ?
    
    // sip_registration_maximum_threshold - ?
    
    // sip_register_usernames - ?
    
    // sip_auth_username - will be later
    
    // sip_auth_password - will be later
    
    // sip_register_domain - will be later
    
    // sip_register_port - will be later
    
    // sip_register_transport - will be later
    
    // enable_echo_cancellation
    linphone_core_enable_echo_cancellation(lc, [DefaultSettingsManager sharedInstance].enableEchoCancellation);
    
    // enable_video - set
    linphone_core_enable_video_capture(lc, [DefaultSettingsManager sharedInstance].enableVideo);
    linphone_core_enable_video_display(lc, [DefaultSettingsManager sharedInstance].enableVideo);

    // enable_rtt
    [lm lpConfigSetBool:[DefaultSettingsManager sharedInstance].enableRtt forKey:@"rtt"];
    
    // enable_adaptive_rate
    linphone_core_enable_adaptive_rate_control(lc, [DefaultSettingsManager sharedInstance].enableAdaptiveRate);
    
    // enabled_codecs
    [self enableVideoCodecs];
    [self enableAudioCodecs];
    
    // bwLimit - ? the name bwlimit is confusing
    //linphone_core_set_video_preset(lc, [DefaultSettingsManager sharedInstance].bwLimit.UTF8String);
    
    // upload_bandwidth
    linphone_core_set_upload_bandwidth(lc, [DefaultSettingsManager sharedInstance].uploadBandwidth);
    
    // download_bandwidth
    linphone_core_set_download_bandwidth(lc, [DefaultSettingsManager sharedInstance].downloadBandwidth);
    
    // enable_stun
    if ([DefaultSettingsManager sharedInstance].enableStun) {
        linphone_core_set_firewall_policy(lc, LinphonePolicyUseStun);
    }
    
    //stun_server
    linphone_core_set_stun_server(lc, [DefaultSettingsManager sharedInstance].stunServer.UTF8String);
    
    // enable_ice
    if ([DefaultSettingsManager sharedInstance].enableIce) {
        linphone_core_set_firewall_policy(lc, LinphonePolicyUseIce);
    }
    
    // logging
    linphone_core_set_log_level([self logLevel:[DefaultSettingsManager sharedInstance].logging]);
    linphone_core_set_log_handler((OrtpLogFunc)linphone_iphone_log_handler);
    
    // sip_mwi_uri - set
    
    // sip_videomail_uri - ?
    
    // video_resolution_maximum - set
}

- (void)enableVideoCodecs {
    
    LinphoneCore *lc = [LinphoneManager getLc];
    const MSList *codecs = linphone_core_get_video_codecs(lc);
    
    PayloadType *pt;
    const MSList *elem;
    
    NSMutableDictionary *mdictForSave = [[NSMutableDictionary alloc] init];
    
    for (elem = codecs; elem != NULL; elem = elem->next) {
        pt = (PayloadType *)elem->data;
        NSString *pref = [SDPNegotiationService getPreferenceForCodec:pt->mime_type withRate:pt->clock_rate];
        
        if (pref) {
            CodecModel *codecModel = [self getVideoCodecWithName:[NSString stringWithUTF8String:pt->mime_type]
                                                            Rate:pt->clock_rate
                                                        Channels:pt->channels];
            NSArray* enabledCodecs = [DefaultSettingsManager sharedInstance].enabledCodecs;
            BOOL enableVideoCodec = [[DefaultSettingsManager sharedInstance].enabledCodecs containsObject:[NSString stringWithUTF8String:pt->mime_type]];
            
            [mdictForSave setObject:[NSNumber numberWithBool:enableVideoCodec] forKey:codecModel.preference];
            linphone_core_enable_payload_type(lc, pt, enableVideoCodec);
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:mdictForSave forKey:@"kUSER_DEFAULTS_VIDEO_CODECS_MAP"];
}

-(void)enableAudioCodecs
{
    LinphoneCore *lc = [LinphoneManager getLc];
    const MSList *codecs = linphone_core_get_audio_codecs(lc);
    
    PayloadType *pt;
    const MSList *elem;
    
    NSMutableDictionary *mdictForSave = [[NSMutableDictionary alloc] init];
    
    for (elem = codecs; elem != NULL; elem = elem->next) {
        pt = (PayloadType *)elem->data;
        NSString *pref = [SDPNegotiationService getPreferenceForCodec:pt->mime_type withRate:pt->clock_rate];
        
        if (pref) {
            CodecModel *codecModel = [self getAudioCodecWithName:[NSString stringWithUTF8String:pt->mime_type]
                                                            Rate:pt->clock_rate
                                                        Channels:pt->channels];
            NSArray* enabledCodecs = [DefaultSettingsManager sharedInstance].enabledCodecs;
            BOOL enableAudioCodec = [[DefaultSettingsManager sharedInstance].enabledCodecs containsObject:[NSString stringWithUTF8String:pt->mime_type]];
            
            [mdictForSave setObject:[NSNumber numberWithBool:enableAudioCodec] forKey:codecModel.preference];
            linphone_core_enable_payload_type(lc, pt, enableAudioCodec);
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:mdictForSave forKey:@"kUSER_DEFAULTS_AUDIO_CODECS_MAP"];

}

- (CodecModel*) getVideoCodecWithName:(NSString*)name Rate:(int)rate Channels:(int)channels {
    PayloadType *pt;
    const MSList *elem;
    NSMutableArray *videoCodecList = [[NSMutableArray alloc] init];
    LinphoneCore *lc = [LinphoneManager getLc];
    const MSList *videoCodecs = linphone_core_get_video_codecs(lc);
    
    NSDictionary *dictVideoCodec = [[NSUserDefaults standardUserDefaults] objectForKey:@"kUSER_DEFAULTS_VIDEO_CODECS_MAP"];
    
    for (elem = videoCodecs; elem != NULL; elem = elem->next) {
        pt = (PayloadType *)elem->data;
        NSString *pref = [SDPNegotiationService getPreferenceForCodec:pt->mime_type withRate:pt->clock_rate];
        
        if (pref) {
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
    
    for (CodecModel *codecModel in videoCodecList) {
        if ([codecModel.name isEqualToString:name] &&
            codecModel.rate == rate &&
            codecModel.channels == channels) {
            return codecModel;
        }
    }
    
    return nil;
}

- (CodecModel*) getAudioCodecWithName:(NSString*)name Rate:(int)rate Channels:(int)channels {
    PayloadType *pt;
    const MSList *elem;
    NSMutableArray *audioCodecList = [[NSMutableArray alloc] init];
    LinphoneCore *lc = [LinphoneManager getLc];
    const MSList *audioCodecs = linphone_core_get_audio_codecs(lc);
    
    NSDictionary *dictAudioCodec = [[NSUserDefaults standardUserDefaults] objectForKey:@"kUSER_DEFAULTS_AUDIO_CODECS_MAP"];
    
    for (elem = audioCodecs; elem != NULL; elem = elem->next) {
        pt = (PayloadType *)elem->data;
        NSString *pref = [SDPNegotiationService getPreferenceForCodec:pt->mime_type withRate:pt->clock_rate];
        
        if (pref) {
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
    
    for (CodecModel *codecModel in audioCodecList) {
        if ([codecModel.name isEqualToString:name] &&
            codecModel.rate == rate &&
            codecModel.channels == channels) {
            return codecModel;
        }
    }
    
    return nil;
}

- (OrtpLogLevel)logLevel:(NSString*)logInfo {
    
    if ([logInfo isEqualToString:@"info"]) {
        return ORTP_MESSAGE;
    }
    
    if ([logInfo isEqualToString:@"debug"]) {
        [[LinphoneManager instance] lpConfigSetInt:1 forKey:@"debugenable_preference"];
        return ORTP_DEBUG;
    }
    
    if ([logInfo isEqualToString:@"all"]) {
        return ORTP_TRACE;
    }
    
    
    return ORTP_DEBUG;
}

@end
