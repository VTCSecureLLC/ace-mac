//
//  CallWindowController.m
//  ACE
//
//  Created by Ruben Semerjyan on 9/23/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "CallWindowController.h"
#import "AppDelegate.h"

@interface CallWindowController ()

@end

@implementation CallWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSPoint barOrigin = [[AppDelegate sharedInstance] getTabWindowOrigin];
    
    NSPoint currentWindowSize = {self.window.frame.size.width, self.window.frame.size.height};
    NSPoint barWindowSize = [[AppDelegate sharedInstance] getTabWindowSize];
    
    NSPoint pos;
    pos.x = barOrigin.x - currentWindowSize.x;
    pos.y = barOrigin.y;
    [self.window setFrameOrigin : pos];
    
    [self.window setTitle:@"CallWindowController"];
}

- (CallViewController*) getCallViewController {
    return (CallViewController*)self.contentViewController;
}

@end
