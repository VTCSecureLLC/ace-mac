//
//  HomeViewController.h
//  ACE
//
//  Created by Norayr Harutyunyan on 11/10/15.
//  Developed pursuant to contract FCC15C0008 as open source software under GNU General Public License version 2.. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VideoView.h"
#import "ProfileView.h"
#import "DialPadView.h"
#import "RTTView.h"
#import "BackgroundedView.h"
#import "MoreSectionViewController.h"

@interface HomeViewController : NSViewController<NSTableViewDelegate, NSTableViewDataSource>
@property (strong) IBOutlet NSView *dockViewContainer;
@property (strong) IBOutlet NSView *profileViewContainer;
@property (strong) IBOutlet NSView *dialPadContainer;
@property (strong) IBOutlet NSView *rttViewContainer;
@property (strong) IBOutlet NSView *moreSectionContainer;

@property (strong) ProfileView *profileView;
@property (strong) DialPadView *dialPadView;
@property (strong)  MoreSectionViewController *moreSectionView;
@property (strong) IBOutlet BackgroundedView *viewContainer;
@property (strong) RTTView *rttView;
@property (strong) IBOutlet VideoView *videoView;
@property (strong) IBOutlet BackgroundedView *callView;

@property (nonatomic, assign) BOOL isAppFullScreen;
@property (nonatomic) bool isMoreSectionHidden;
@property (nonatomic) bool switchSelfViewOn;

-(void) initializeData;
-(void)refreshForNewLogin;
-(void)clearData;
- (void) closeSelfPreview;

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
