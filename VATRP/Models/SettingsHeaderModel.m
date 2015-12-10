//
//  SettingsHeaderModel.m
//  ACE
//
//  Created by Norayr Harutyunyan on 12/8/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "SettingsHeaderModel.h"

@implementation SettingsHeaderModel

@synthesize title;

- (id) initWithTitle:(NSString*)ttl {
    self = [super init];
    
    if (self) {
        self.title = ttl;
    }
    
    return self;
}

@end
