//
//  CodecModel.m
//  ACE
//
//  Created by Edgar Sukiasyan on 9/28/15.
//  Copyright © 2015 Home. All rights reserved.
//

#import "CodecModel.h"

@implementation CodecModel

@synthesize name;
@synthesize rate;
@synthesize channels;
@synthesize status;

- (id) init {
    self = [super init];
    
    if (self) {
        self.name = @"G729";
        self.rate = 8000;
        self.channels = 2;
        self.status = YES;
    }
    
    return self;
}

@end
