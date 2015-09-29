//
//  VideoCallWindowController.m
//  vatrp
//
//  Created by Edgar Sukiasyan on 9/21/15.
//  Copyright © 2015 Home. All rights reserved.
//

#import "VideoCallWindowController.h"

@interface VideoCallWindowController ()

@end

@implementation VideoCallWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self.window makeKeyAndOrderFront:nil];
    [self.window setLevel:NSStatusWindowLevel];
}

@end
