//
//  ViewController.h
//  MacApp
//
//  Created by Norayr Harutyunyan on 8/27/15.
//  Developed pursuant to contract FCC15C0008 as open source software under GNU General Public License version 2.. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SettingsWindowController.h"
#import "VideoMailWindowController.h"

@interface ViewController : NSViewController

@property (nonatomic, retain) SettingsWindowController *settingsWindowController;
@property (nonatomic, retain) VideoMailWindowController *videoMailWindowController;

- (void) showSettingsWindow;
- (void) showVideoMailWindow;
- (void) closeAllWindows;

@end

