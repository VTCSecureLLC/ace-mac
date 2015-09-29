//
//  Utils.m
//  HappyTaxi
//
//  Created by Edgar Sukiasyan on 4/26/15.
//  Copyright (c) 2015 Home. All rights reserved.
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

@end
