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
#import "CallWindowController.h"
#import "ViewController.h"


@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, retain) LoginWindowController *loginWindowController;
@property (nonatomic, retain) LoginViewController *loginViewController;
@property (nonatomic, retain) CallWindowController *callWindowController;
@property (nonatomic, retain) ViewController *viewController;
@property (weak) IBOutlet NSMenuItem *menuItemPreferences;

+ (AppDelegate*)sharedInstance;
- (void) showTabWindow;
- (VideoCallWindowController*) getVideoCallWindow;
- (IBAction)onMenuItemPreferences:(id)sender;

@end

