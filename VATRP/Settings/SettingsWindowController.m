//
//  SettingsWindowController.m
//  MacApp
//
//  Created by Norayr Harutyunyan on 8/27/15.
//  Copyright (c) 2015 Cinehost. All rights reserved.
//

#import "SettingsWindowController.h"
#import "AccountsViewController.h"
#import "CodecsViewController.h"
#import "MediaViewController.h"
#import "AppDelegate.h"

@interface SettingsWindowController () {
    AccountsViewController *accountsViewController;
    CodecsViewController *codecsViewController;
    MediaViewController *mediaViewController;
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
    codecsViewController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"CodecsViewController"];
    mediaViewController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"MediaViewController"];
    
    self.window.contentView = accountsViewController.view;
}

- (void)myWindowWillClose:(NSNotification *)notification
{
    self.isShow = NO;
    [AppDelegate sharedInstance].viewController.settingsWindowController = nil;
}

- (IBAction)onToolbarItemAccount:(id)sender {
    self.window.contentView = accountsViewController.view;
}

- (IBAction)onToolbarItemCodecs:(id)sender {
    self.window.contentView = codecsViewController.view;
}

- (IBAction)onToolbarItemMedia:(id)sender {
    self.window.contentView = mediaViewController.view;
}

@end
