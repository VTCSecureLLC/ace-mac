//
//  SettingsItemModel.m
//  ACE
//
//  Created by Norayr Harutyunyan on 12/8/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "SettingsItemModel.h"

@implementation SettingsItemModel

@synthesize controller_Type;
@synthesize title;
@synthesize defaultValue;

- (id) initWithDictionary:(NSDictionary*)dict {
    self = [super init];
    
    if (self) {
        self.controller_Type = [[dict objectForKey:@"controllerType"] intValue];
        self.title = [dict objectForKey:@"title"];
        self.defaultValue = [dict objectForKey:@"defaultValue"];
    }
    
    return self;
}

@end
