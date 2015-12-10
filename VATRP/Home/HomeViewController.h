//
//  HomeViewController.h
//  ACE
//
//  Created by Norayr Harutyunyan on 11/10/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VideoView.h"
#import "ProfileView.h"

@interface HomeViewController : NSViewController

@property (weak) IBOutlet VideoView *videoView;
@property (weak) IBOutlet NSView *callView;

- (ProfileView*) getProfileView;

@end
