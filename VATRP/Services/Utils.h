//
//  Utils.h
//  ACE
//
//  Created by Ruben Semerjyan on 4/26/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include "linphone/linphonecore.h"

@interface Utils : NSObject

+ (int) intValueDict:(NSDictionary*)dict Key:(NSString*)key;
+ (NSString*) stringValueDict:(NSDictionary*)dict Key:(NSString*)key;
+ (NSDictionary*)normalizeServerDictionary:(NSDictionary*)jsonDictionary;

+ (NSString*) resourcePathForFile:(NSString*)fileName Type:(NSString*)type;
+ (void) setButtonTitleColor:(NSColor*)color Button:(NSButton*)button;
+ (void) setUIBorderColor:(NSColor*)color CornerRadius:(CGFloat)cornerRadius Width:(CGFloat)width Control:(NSControl*)control;
+ (NSString*)makeAccountNameFromSipURI:(NSString*)sipURI;
+ (NSString *)getTimeStringFromSeconds:(int)seconds;
+ (BOOL) nsStringIsValidSip:(NSString *)checkString;
+ (NSString*)makeSipURIWithAccountName:(NSString*)accountName andProviderAddress:(NSString*)providerAddress;
+ (NSString*)makeAccountNumberFromSipURI:(NSString*)sipURI;
+ (NSString*)providerNameFromSipURI:(NSString*)fullSipURI;
+ (NSMutableArray*)cdnResources;
+ (NSString *)decodeTextMessage:(const char *)text;
+ (NSString*)callStateStringByIndex:(NSNumber *)enumIndex;

@end
