//
//  CallLogService.m
//  ACE
//
//  Created by Ruben Semerjyan on 9/30/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "CallLogService.h"
#import "LinphoneManager.h"

@implementation CallLogService

+ (CallLogService *)sharedInstance
{
    static CallLogService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CallLogService alloc] init];
    });
    
    return sharedInstance;
}

- (id) init {
    self = [super init];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(coreUpdateEvent:)
                                                     name:kLinphoneCoreUpdate
                                                   object:nil];
    }
    
    return self;
}

- (void)coreUpdateEvent:(NSNotification *)notif {
    NSLog(@"coreUpdateEvent");
}

@end
