//
//  ChatWindowController.m
//  ACE
//
//  Created by Edgar Sukiasyan on 10/13/15.
//  Copyright © 2015 Home. All rights reserved.
//

#import "ChatWindowController.h"

@interface ChatWindowController ()

@end

@implementation ChatWindowController

@synthesize isShow;

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myWindowWillClose:) name:NSWindowWillCloseNotification object:[self window]];
    
    self.isShow = YES;
}

- (void)myWindowWillClose:(NSNotification *)notification {
    self.isShow = NO;
}

@end
