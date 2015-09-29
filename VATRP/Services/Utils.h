//
//  Utils.h
//  HappyTaxi
//
//  Created by Edgar Sukiasyan on 4/26/15.
//  Copyright (c) 2015 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (int) intValueDict:(NSDictionary*)dict Key:(NSString*)key;
+ (NSString*) stringValueDict:(NSDictionary*)dict Key:(NSString*)key;

@end
