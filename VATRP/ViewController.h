//
//  ViewController.h
//  MacApp
//
//  Created by Norayr Harutyunyan on 8/27/15.
//  Copyright (c) 2015 Cinehost. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SettingsWindowController.h"

@interface ViewController : NSViewController

@property (nonatomic, retain) SettingsWindowController *settingsWindowController;

- (void) showSettingsWindow;

@end

