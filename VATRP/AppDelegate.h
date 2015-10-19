//
//  AppDelegate.h
//  VATRP
//
//  Created by Ruben Semerjyan on 8/27/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LoginWindowController.h"
#import "LoginViewController.h"
#import "VideoCallWindowController.h"
#import "ViewController.h"


@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, retain) LoginWindowController *loginWindowController;
@property (nonatomic, retain) LoginViewController *loginViewController;
@property (nonatomic, retain) ViewController *viewController;
@property (weak) IBOutlet NSMenuItem *menuItemPreferences;
@property (weak) IBOutlet NSMenuItem *menuItemSignOut;

+ (AppDelegate*)sharedInstance;
- (void) showTabWindow;
- (void) closeTabWindow;
- (VideoCallWindowController*) getVideoCallWindow;

-(NSPoint) getTabWindowSize;
-(NSPoint) getTabWindowOrigin;
-(void) setTabWindowPos:(NSPoint) pos;

@end

