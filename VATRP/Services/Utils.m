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

+ (NSDictionary*)normalizeServerDictionary:(NSDictionary*)jsonDictionary
{
    NSMutableDictionary* newDictionary = [[NSMutableDictionary alloc] init];
    for (id key in jsonDictionary)
    {
        //        NSLog(@"key=%@ value=%@", key, [myDict objectForKey:key]);
        NSObject* object = [jsonDictionary objectForKey:key];
        if ([object isKindOfClass:[NSString class]])
        {
            NSString* value = [Utils normalizeServerString:[[NSMutableString alloc] initWithString:(NSString*)object]];
            [newDictionary setValue:value forKey:key];
        }
        else if ([object isKindOfClass:[NSArray class]])
        {
            [newDictionary setValue:[Utils normalizeServerArray:(NSArray*)object] forKey:key];
        }
        else if ([object isKindOfClass:[NSDictionary class]])
        {
            [newDictionary setValue:[Utils normalizeServerDictionary:(NSDictionary*)object] forKey:key];
        }
        else
        {
            [newDictionary setValue:object forKey:key];
        }
    }
    return [newDictionary copy];
}

+ (NSArray*)normalizeServerArray:(NSArray*)arrayOfObjects
{
    NSMutableArray* newArray = [[NSMutableArray alloc] init];
    for (NSObject* object in arrayOfObjects)
    {
        //        NSLog(@"key=%@ value=%@", key, [myDict objectForKey:key]);
        if ([object isKindOfClass:[NSString class]])
        {
            [newArray addObject:[Utils normalizeServerString:[[NSMutableString alloc] initWithString:(NSString*)object]]];
        }
        else if ([object isKindOfClass:[NSArray class]])
        {
            [newArray addObject:[Utils normalizeServerArray:(NSArray*)object]];
        }
        else if ([object isKindOfClass:[NSDictionary class]])
        {
            [newArray addObject:[Utils normalizeServerDictionary:(NSDictionary*)object]];
        }
        else
        {
            [newArray addObject:object];
        }
    }
    return [newArray copy];
    
}

// if null or empty (including single of double quotes only) return empty string.
// if starts and ends with quotes, remove them.
+(NSString*) normalizeServerString:(NSString*)value
{
    if ((value == nil) || ([value length] == 0) || [value isEqualToString:@"\""] || [value isEqualToString:@"\"\""])
    {
        return @"";
    }
    
    NSMutableString* valueOut = [[NSMutableString alloc] initWithString:value];
    if ([value hasPrefix:@"\""])
    {
        valueOut = [[NSMutableString alloc] initWithString:[valueOut substringFromIndex:1]];
    }
    if ([valueOut hasSuffix:@"\""])
    {
        valueOut = [[NSMutableString alloc] initWithString:[valueOut substringToIndex:([valueOut length] - 1)]];
    }
    return valueOut;
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

+ (NSString *)decodeTextMessage:(const char *)text {
    if (text == nil)
    {
        return @"";
    }
    NSString *decoded = [NSString stringWithUTF8String:text];
    if (decoded == nil) {
        // couldn't decode the string as UTF8, do a lossy conversion
        decoded = [NSString stringWithCString:text encoding:NSASCIIStringEncoding];
        if (decoded == nil) {
            decoded = @"(invalid string)";
        }
    }
    return decoded;
}

+ (NSString *)failedMessageFromCall:(LinphoneCall*)aCall {
    NSString *failedMessage = @"";
    switch (linphone_call_get_reason(aCall)) {
        case LinphoneReasonNoResponse: {
            failedMessage = NSLocalizedString(@"The called terminal was not reachable becaus of technical reasons (sip: 408).", nil);
        }
            break;
        case LinphoneReasonAddressIncomplete: {
            failedMessage = NSLocalizedString(@"The address was incomplete. Please try again (sip: 484).", nil);
        }
            break;
        case LinphoneReasonForbidden: {
            failedMessage = NSLocalizedString(@"The call did not go through because of access rights failure.", nil);
        }
            break;
        case LinphoneReasonBadGateway: {
            failedMessage = NSLocalizedString(@"Call failed because of error in the communication service (sip: 502).", nil);
        }
            break;
        case LinphoneReasonBusy: {
            failedMessage = NSLocalizedString(@"The number or address you are trying to reach is busy (sip: 486)", nil);
        }
            break;
        case LinphoneReasonDeclined: {
            failedMessage = NSLocalizedString(@"The call has been declined (sip: 603)", nil);
        }
            break;
        case LinphoneReasonDoNotDisturb: {
            failedMessage = NSLocalizedString(@"The call failed becuse of communication problems.", nil);
        }
            break;
        case LinphoneReasonGone: {
            failedMessage = NSLocalizedString(@"The number/address you are trying to reach is no longer available (sip: 604).", nil);
        }
            break;
        case LinphoneReasonIOError: {
            failedMessage = NSLocalizedString(@"Communication error: Bad network connection.", nil);
        }
            break;
        case LinphoneReasonMovedPermanently: {
            failedMessage = NSLocalizedString(@"The called person or organization has changed their number or call address (sip: 301).", nil);
        }
            break;
        case LinphoneReasonNoMatch: {
            failedMessage = NSLocalizedString(@"Call failed because called terminal detected and error (sip: 400).", nil);
        }
            break;
        case LinphoneReasonNotAcceptable: {
            failedMessage =NSLocalizedString( @"The call was not accepted of technical reasons by the called terminal (sip: 406).", nil);
        }
            break;
        case LinphoneReasonNotAnswered: {
            failedMessage = NSLocalizedString(@"No answer.", nil);
        }
            break;
        case LinphoneReasonNotFound: {
            failedMessage = NSLocalizedString(@"The number or address could not be found (sip: 404).", nil);
        }
            break;
        case LinphoneReasonNotImplemented: {
            failedMessage = NSLocalizedString(@"The call failed because of a service error (sip: 501).", nil);
        }
            break;
        case LinphoneReasonServerTimeout: {
            failedMessage = NSLocalizedString(@"The call failed because of a service timeout error (sip: 504).", nil);
        }
            break;
        case LinphoneReasonTemporarilyUnavailable: {
            failedMessage = NSLocalizedString(@"The person or organization you are trying to reach is not available at this time. Check the number or address or try again later (sip: 480).", nil);
        }
            break;
        case LinphoneReasonUnauthorized: {
            failedMessage = NSLocalizedString(@"The call failed because it requires authorization (sip: 494).", nil);
        }
            break;
        case LinphoneReasonUnknown: {
            failedMessage = NSLocalizedString(@"The call failed of an unknown error.", nil);
        }
            break;
        case LinphoneReasonUnsupportedContent: {
            failedMessage = NSLocalizedString(@"The called terminal has no media in common with yours (sip: 488)", nil);
        }
            break;
        default: {
            failedMessage = @"";
        }
            break;
    }
    
    return failedMessage;
}

@end
