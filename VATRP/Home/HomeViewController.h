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
#import "DialPadView.h"
#import "RTTView.h"
#import "CallQualityIndicator.h"

@interface HomeViewController : NSViewController<NSTableViewDelegate, NSTableViewDataSource>
@property (strong) IBOutlet NSView *dockViewContainer;
@property (strong) IBOutlet NSView *profileViewContainer;
@property (strong) IBOutlet NSView *dialPadContainer;
@property (strong) IBOutlet NSView *rttViewContainer;

@property (strong) ProfileView *profileView;
@property (strong) DialPadView *dialPadView;
@property (strong) IBOutlet BackgroundedView *viewContainer;
@property (strong) RTTView *rttView;
@property (strong) IBOutlet VideoView *videoView;
@property (strong) IBOutlet BackgroundedView *callView;
@property (strong) IBOutlet CallQualityIndicator *callQualityIndicator;

@property (nonatomic, assign) BOOL isAppFullScreen;

-(void) initializeData;

- (ProfileView*) getProfileView;
- (BOOL) isCurrentTabRecents;
- (void)mouseMovedWithPoint:(NSPoint)mousePosition;

-(void) reloadRecents;

#pragma mark - methods for dialpad
- (void) showProviderList;

#pragma mark - methods for dock view
- (void)hideDockView:(bool)hide;
- (void) didClickDockViewRecents;
- (void) didClickDockViewContacts;
- (void) didClickDockViewDialpad;
- (void) didClickDockViewResources;
- (void) didClickDockViewSettings;

@end
