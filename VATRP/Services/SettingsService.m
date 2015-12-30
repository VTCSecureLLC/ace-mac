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
#import "AccountModel.h"
#import "SettingsHeaderModel.h"
#import "SettingsItemModel.h"

static NSMutableArray *settingsList;

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
        } else {
            linphone_core_set_firewall_policy(lc, LinphonePolicyUseStun);
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
        [SettingsService setStun:[[NSUserDefaults standardUserDefaults] boolForKey:@"stun_preference"]];
    }
}

+ (void) setUPNP:(BOOL)enable {
    LinphoneCore *lc = [LinphoneManager getLc];
    
    if (enable) {
        linphone_core_set_firewall_policy(lc, LinphonePolicyUseUpnp);
    } else {
        [self setICE:[[NSUserDefaults standardUserDefaults] boolForKey:@"ice_preference"]];
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

@end
