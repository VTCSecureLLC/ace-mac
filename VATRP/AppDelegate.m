//
//  AppDelegate.m
//  VATRP
//
//  Created by Edgar Sukiasyan on 8/27/15.
//  Copyright (c) 2015 Home. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "HomeWindowController.h"

@interface AppDelegate () {
    ViewController *viewController;
    HomeWindowController *homeWindowController;
}

@end

@implementation AppDelegate

@synthesize loginWindowController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
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

@end
