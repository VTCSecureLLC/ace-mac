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
#import "DockView.h"
#import "DialPadView.h"
#import "RTTView.h"
#import "CallQualityIndicator.h"

@interface HomeViewController : NSViewController

@property (weak) IBOutlet DockView *dockView;
@property (weak) IBOutlet ProfileView *profileView;
@property (weak) IBOutlet DialPadView *dialPadView;
@property (weak) IBOutlet BackgroundedView *viewContainer;
@property (weak) IBOutlet RTTView *rttView;
@property (weak) IBOutlet VideoView *videoView;
@property (weak) IBOutlet BackgroundedView *callView;
@property (weak) IBOutlet CallQualityIndicator *callQualityIndicator;

@property (nonatomic, assign) BOOL isAppFullScreen;

- (ProfileView*) getProfileView;
- (BOOL) isCurrentTabRecents;
- (void)mouseMovedWithPoint:(NSPoint)mousePosition;

@end
