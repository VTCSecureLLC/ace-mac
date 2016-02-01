//
//  Utils.m
//  ACE
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

+ (NSString *)getTimeStringFromSeconds:(int)seconds {
    NSDateComponentsFormatter *dcFormatter = [[NSDateComponentsFormatter alloc] init];
    dcFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    dcFormatter.allowedUnits = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    dcFormatter.unitsStyle = NSDateComponentsFormatterUnitsStylePositional;
    return [dcFormatter stringFromTimeInterval:seconds];
}

+ (BOOL) nsStringIsValidSip:(NSString *)checkString {
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

+ (NSString*)makeSipURIWithAccountName:(NSString*)accountName andProviderAddress:(NSString*)providerAddress {
    return  [[[@"sip:" stringByAppendingString:accountName] stringByAppendingString:@"@"] stringByAppendingString:providerAddress];
}

+(NSString*)makeAccountNumberFromSipURI:(NSString*)sipURI {
    NSString *str = [sipURI substringFromIndex:4];
    NSArray *subStrings = [str componentsSeparatedByString:@"@"];
    return [subStrings objectAtIndex:0];
}

+ (NSMutableArray*)cdnResources {
    NSMutableArray *resources = [NSMutableArray new];
    int cdnResourcesCount = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"cdnResourcesCapacity"];
    
    for(int i = 0; i < cdnResourcesCount; ++i) {
        NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"provider%d", i]];
        NSString *domain = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"provider%d_domain", i]];
        NSString *providerLogoURL = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"provider%d_logo", i]];
        NSDictionary *dict = @{@"name" : name,
                               @"domain" : domain,
                               @"providerLogo" : providerLogoURL
                               };
        [resources addObject:dict];
    }
    return resources;
}

@end
