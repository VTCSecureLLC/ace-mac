//
//  SettingsService.h
//  ACE
//
//  Created by Norayr Harutyunyan on 12/11/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define kUSER_DEFAULTS_AUDIO_CODECS_MAP @"kUSER_DEFAULTS_AUDIO_CODECS_MAP"
#define kUSER_DEFAULTS_VIDEO_CODECS_MAP @"kUSER_DEFAULTS_VIDEO_CODECS_MAP"

@interface SettingsService : NSObject

+ (SettingsService *)sharedInstance;

+ (void) setSIPEncryption:(BOOL)encrypt;
+ (void) setStartAppOnBoot:(BOOL)start;
+ (void) setColorWithKey:(NSString*)key Color:(NSColor*)color;
+ (NSColor*) getColorWithKey:(NSString*)key;
+ (BOOL) getMicMute;
+ (BOOL) getEchoCancel;
+ (BOOL) getShowPreview;
+ (BOOL) getRTTEnabled;
+ (void) setStun:(BOOL)enable;
+ (void) setICE:(BOOL)enable;
+ (void) setUPNP:(BOOL)enable;
+ (void) setRandomPorts:(BOOL)enable;
- (void)setConfigurationSettingsInitialValues;

@end
