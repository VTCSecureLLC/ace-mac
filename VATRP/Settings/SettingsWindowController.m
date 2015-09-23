//
//  SettingsWindowController.m
//  MacApp
//
//  Created by Norayr Harutyunyan on 8/27/15.
//  Copyright (c) 2015 Cinehost. All rights reserved.
//

#import "SettingsWindowController.h"
#import "BFNavigationController.h"
#import "AccountsViewController.h"
#import "AppDelegate.h"

@interface SettingsWindowController () {
    AccountsViewController *accountsViewController;
}

@end

@implementation SettingsWindowController

@synthesize isShow;

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    self.isShow = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myWindowWillClose:) name:NSWindowWillCloseNotification object:[self window]];
    
    accountsViewController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"AccountsViewController"];
    
    // Init navigation controller and add to window
    BFNavigationController *navigationController = [[BFNavigationController alloc] initWithFrame:NSMakeRect(0, 0, self.window.frame.size.width, self.window.frame.size.height)
                                                      rootViewController:accountsViewController];
    
    [self.window.contentView addSubview:navigationController.view];
}

- (void)myWindowWillClose:(NSNotification *)notification
{
    self.isShow = NO;
    [AppDelegate sharedInstance].viewController.settingsWindowController = nil;
}

- (IBAction)onToolbarItemAccount:(id)sender {
}

@end
