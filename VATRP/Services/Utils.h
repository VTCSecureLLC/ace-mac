//
//  Utils.h
//  HappyTaxi
//
//  Created by Ruben Semerjyan on 4/26/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface Utils : NSObject

+ (int) intValueDict:(NSDictionary*)dict Key:(NSString*)key;
+ (NSString*) stringValueDict:(NSDictionary*)dict Key:(NSString*)key;
+ (NSString*) resourcePathForFile:(NSString*)fileName Type:(NSString*)type;
+ (void) setButtonTitleColor:(NSColor*)color Button:(NSButton*)button;
+ (void) setUIBorderColor:(NSColor*)color CornerRadius:(CGFloat)cornerRadius Width:(CGFloat)width Control:(NSControl*)control;
+ (NSString*)makeAccountNameFromSipURI:(NSString*)sipURI;

@end
