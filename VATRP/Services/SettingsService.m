//
//  SettingsService.m
//  ACE
//
//  Created by Norayr Harutyunyan on 12/11/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "SettingsService.h"
#import "AccountsService.h"
#import "RegistrationService.h"
#import "AccountModel.h"

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
    BOOL showPreview = [[NSUserDefaults standardUserDefaults] boolForKey:@"VIDEO_SHOW_PREVIEW"];
    
    return showPreview;
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

@end
