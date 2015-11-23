//
//  ViewManager.m
//  ACE
//
//  Created by Norayr Harutyunyan on 11/11/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import "ViewManager.h"

@implementation ViewManager

@synthesize dockView;
@synthesize dialPadView;
@synthesize profileView;
@synthesize recentsView;

+ (ViewManager *)sharedInstance
{
    static ViewManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ViewManager alloc] init];
    });
    
    return sharedInstance;
}

@end
