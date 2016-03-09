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
@property (strong) IBOutlet NSView *dockViewContainer;
@property (strong) IBOutlet NSView *profileViewContainer;
@property (strong) IBOutlet NSView *dialPadContainer;
@property (strong) IBOutlet NSView *rttViewContainer;

@property (strong) IBOutlet DockView *dockView;
@property (strong) IBOutlet ProfileView *profileView;
@property (strong) IBOutlet DialPadView *dialPadView;
@property (strong) IBOutlet BackgroundedView *viewContainer;
@property (strong) IBOutlet RTTView *rttView;
@property (strong) IBOutlet VideoView *videoView;
@property (strong) IBOutlet BackgroundedView *callView;
@property (strong) IBOutlet CallQualityIndicator *callQualityIndicator;

@property (nonatomic, assign) BOOL isAppFullScreen;

- (ProfileView*) getProfileView;
- (BOOL) isCurrentTabRecents;
- (void)mouseMovedWithPoint:(NSPoint)mousePosition;

@end
