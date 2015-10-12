//
//  Utils.h
//  HappyTaxi
//
//  Created by Ruben Semerjyan on 4/26/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (int) intValueDict:(NSDictionary*)dict Key:(NSString*)key;
+ (NSString*) stringValueDict:(NSDictionary*)dict Key:(NSString*)key;
+ (NSString*) resourcePathForFile:(NSString*)fileName Type:(NSString*)type;

@end
