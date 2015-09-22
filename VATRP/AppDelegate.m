//
//  AppDelegate.m
//  VATRP
//
//  Created by Edgar Sukiasyan on 8/27/15.
//  Copyright (c) 2015 Home. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeWindowController.h"

@interface AppDelegate () {
    HomeWindowController *homeWindowController;
    
    VideoCallWindowController *videoCallWindowController;
}

@end

@implementation AppDelegate

@synthesize loginWindowController;
@synthesize viewController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    videoCallWindowController = nil;

    [self.menuItemPreferences setAction:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

+ (AppDelegate*)sharedInstance {
    return (AppDelegate*)[NSApplication sharedApplication].delegate;
}

- (void) showTabWindow {
    homeWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"HomeWindowController"];
    [homeWindowController showWindow:self];
}

- (VideoCallWindowController*) getVideoCallWindow {
    if (!videoCallWindowController) {
        videoCallWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"VideoCall"];
        [videoCallWindowController showWindow:self];
    }
    
    return videoCallWindowController;
}

- (IBAction)onMenuItemPreferences:(id)sender {
    [viewController showSettingsWindow];
}

@end
