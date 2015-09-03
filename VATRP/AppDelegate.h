//
//  AppDelegate.h
//  VATRP
//
//  Created by Edgar Sukiasyan on 8/27/15.
//  Copyright (c) 2015 Home. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LoginWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, retain) LoginWindowController *loginWindowController;

+ (AppDelegate*)sharedInstance;
- (void) showTabWindow;

@end

