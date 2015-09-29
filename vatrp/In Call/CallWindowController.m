//
//  CallWindowController.m
//  ACE
//
//  Created by Edgar Sukiasyan on 9/23/15.
//  Copyright © 2015 Home. All rights reserved.
//

#import "CallWindowController.h"
#import "AppDelegate.h"

@interface CallWindowController ()

@end

@implementation CallWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.

    [self.window makeKeyAndOrderFront:nil];
    [self.window setLevel:NSStatusWindowLevel];
}

- (CallViewController*) getCallViewController {
    return (CallViewController*)self.contentViewController;
}

@end
