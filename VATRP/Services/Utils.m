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
    NSString* value = [dcFormatter stringFromTimeInterval:seconds];
    if (value != nil)
    {
        return value;
    }
    else
    {
        NSMutableString* selfConstructedValue = [[NSMutableString alloc] init];
        int hours = seconds / 3600;
        int minutes = (seconds - (hours * 3600)) / 60;
        int remainingSeconds = seconds % 60;
        if (hours > 0)
        {
            [selfConstructedValue appendString:[NSMutableString stringWithFormat:@"%d:", hours]];
        }
        if (minutes < 10)
        {
            [selfConstructedValue appendString:[NSMutableString stringWithFormat:@"0%d:", minutes]];
        }
        else
        {
            [selfConstructedValue appendString:[NSMutableString stringWithFormat:@"%d:", minutes]];
        }
        if (remainingSeconds < 10)
        {
            [selfConstructedValue appendString:[NSMutableString stringWithFormat:@"0%d", remainingSeconds]];
        }
        else
        {
            [selfConstructedValue appendString:[NSMutableString stringWithFormat:@"%d", remainingSeconds]];
        }
        return selfConstructedValue;
    }
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

+ (NSString*)providerNameFromSipURI:(NSString*)fullSipURI {
    
    NSArray *tmpArray = [fullSipURI componentsSeparatedByString:@"@"];
    NSString *providerNamae = [tmpArray lastObject];
    
    return providerNamae;
}

+ (NSMutableArray*)cdnResources {
    NSMutableArray *resources = [NSMutableArray new];
    int cdnResourcesCount = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"cdnResourcesCapacity"];
    
    for(int i = 0; i < cdnResourcesCount; ++i) {
        NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"provider%d", i]];
        NSString *domain = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"provider%d_domain", i]];
        NSString *providerLogoURL = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"provider%d_logo.png", i]];
        if ((name != nil) && (domain != nil))
        {
            if (providerLogoURL == nil)
            {
                providerLogoURL = @"";
            }
            NSDictionary *dict = @{@"name" : name,
                                   @"domain" : domain,
                                   @"providerLogo" : providerLogoURL
                                   };
            [resources addObject:dict];
        }
    }
    return resources;
}

@end
