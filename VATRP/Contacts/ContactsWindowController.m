//
//  ContactsWindowController.m
//  MacApp
//
//  Created by Norayr Harutyunyan on 8/27/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import "ContactsWindowController.h"

@interface ContactsWindowController ()

@end

@implementation ContactsWindowController

@synthesize isShow;

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    self.isShow = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myWindowWillClose:) name:NSWindowWillCloseNotification object:[self window]];
    
    [self.window setTitle:@"ContactsWindowController"];

}

- (void)myWindowWillClose:(NSNotification *)notification
{
    self.isShow = NO;
}

@end
