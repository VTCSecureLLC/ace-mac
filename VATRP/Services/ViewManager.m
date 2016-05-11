//
//  ViewManager.m
//  ACE
//
//  Created by Norayr Harutyunyan on 11/11/15.
//  Developed pursuant to contract FCC15C0008 as open source software under GNU General Public License version 2.. All rights reserved.
//

#import "ViewManager.h"

@implementation ViewManager

@synthesize dockView;
@synthesize dialPadView;
@synthesize profileView;
@synthesize recentsView;
@synthesize callView;
@synthesize rttView;
@synthesize callControllersView_delegate;

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
