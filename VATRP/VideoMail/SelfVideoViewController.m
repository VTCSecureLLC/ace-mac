//
//  SelfVideoViewController.m
//  ACE
//
//  Created by Zack Matthews on 10/2/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "SelfVideoViewController.h"
#import "LinphoneManager.h"
#import "AppDelegate.h"

@interface SelfVideoViewController ()

@end

@implementation SelfVideoViewController

-(id) init
{
    self = [super initWithNibName:@"SelfVideoViewController" bundle:nil];
    if (self)
    {
        // init
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
        linphone_core_enable_video_preview([LinphoneManager getLc], TRUE);
        linphone_core_use_preview_window([LinphoneManager getLc], YES);
        linphone_core_set_native_preview_window_id([LinphoneManager getLc], (__bridge void *)(self.view));
        linphone_core_enable_self_view([LinphoneManager getLc], TRUE);
}

@end
