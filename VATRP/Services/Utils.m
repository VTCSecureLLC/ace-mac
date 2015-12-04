//
//  Utils.m
//  HappyTaxi
//
//  Created by Ruben Semerjyan on 4/26/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (int) intValueDict:(NSDictionary*)dict Key:(NSString*)key {
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return 0;
    }
    
    NSString *value = [dict objectForKey:key];
    
    if (![value isKindOfClass:[NSNull class]]) {
        return [value intValue];
    }
    
    return 0;
}

+ (NSString*) stringValueDict:(NSDictionary*)dict Key:(NSString*)key {
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return @"";
    }

    NSString *value = [dict objectForKey:key];
    
    if (![value isKindOfClass:[NSNull class]]) {
        return value;
    }
    
    return @"";
}

+ (NSString*) resourcePathForFile:(NSString*)fileName Type:(NSString*)type {
    NSBundle* myBundle = [NSBundle mainBundle];
    NSString* myFile = [myBundle pathForResource:fileName ofType:type];
    
    return myFile;
}

+ (void) setButtonTitleColor:(NSColor*)color Button:(NSButton*)button {
    NSMutableAttributedString *colorTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[button attributedTitle]];
    NSRange titleRange = NSMakeRange(0, [colorTitle length]);
    [colorTitle addAttribute:NSForegroundColorAttributeName value:color range:titleRange];
    [button setAttributedTitle:colorTitle];
}

+ (void) setUIBorderColor:(NSColor*)color CornerRadius:(CGFloat)cornerRadius Width:(CGFloat)width Control:(NSControl*)control {
    [control setWantsLayer:YES];
    [control.layer setBorderColor:color.CGColor];
    [control.layer setBorderWidth:width];
    [control.layer setCornerRadius:cornerRadius];
}

+ (NSString*)makeAccountNameFromSipURI:(NSString*)sipURI {
    NSString *str = [sipURI substringFromIndex:4];
    NSArray *subStrings = [str componentsSeparatedByString:@"@"];
    return [subStrings objectAtIndex:0];
}

@end
