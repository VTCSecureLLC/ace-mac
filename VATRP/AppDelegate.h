//
//  AppDelegate.h
//  VATRP
//
//  Created by Edgar Sukiasyan on 8/27/15.
//  Copyright (c) 2015 Home. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LoginWindowController.h"
#import "VideoCallWindowController.h"
#import "CallWindowController.h"
#import "ViewController.h"


@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, retain) LoginWindowController *loginWindowController;
@property (nonatomic, retain) CallWindowController *callWindowController;
@property (nonatomic, retain) ViewController *viewController;
@property (weak) IBOutlet NSMenuItem *menuItemPreferences;

+ (AppDelegate*)sharedInstance;
- (void) showTabWindow;
- (VideoCallWindowController*) getVideoCallWindow;
- (IBAction)onMenuItemPreferences:(id)sender;

@end

