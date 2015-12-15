//
//  SettingsService.h
//  ACE
//
//  Created by Norayr Harutyunyan on 12/11/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SettingsService : NSObject

+ (SettingsService *)sharedInstance;

+ (void) setSIPEncryption:(BOOL)encrypt;
+ (void) setStartAppOnBoot:(BOOL)start;
+ (void) setColorWithKey:(NSString*)key Color:(NSColor*)color;
+ (NSColor*) getColorWithKey:(NSString*)key;
+ (BOOL) getMicMute;
+ (BOOL) getEchoCancel;
+ (BOOL) getShowPreview;

@end
