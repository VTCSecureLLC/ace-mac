//
//  SettingsWindowController.m
//  MacApp
//
//  Created by Norayr Harutyunyan on 8/27/15.
//  Copyright (c) 2015 Cinehost. All rights reserved.
//

#import "SettingsWindowController.h"
#import "SettingsViewController.h"
#import "AccountsViewController.h"
#import "CodecsViewController.h"
#import "MediaViewController.h"
#import "AppDelegate.h"

@interface SettingsWindowController () <SettingsViewControllerDelegate> {
    AccountsViewController *accountsViewController;
    CodecsViewController *codecsViewController;
    MediaViewController *mediaViewController;
    
    NSView *prevView;
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
    
    [self changeViewTo:accountsViewController.view];
    
    SettingsViewController *settingsViewController = (SettingsViewController*)self.contentViewController;
    settingsViewController.delegate = self;
}

- (void)myWindowWillClose:(NSNotification *)notification
{
    self.isShow = NO;
    [AppDelegate sharedInstance].viewController.settingsWindowController = nil;
}

- (IBAction)onToolbarItemAccount:(id)sender {
    [self changeViewTo:accountsViewController.view];
}

- (IBAction)onToolbarItemCodecs:(id)sender {
    [self changeViewTo:codecsViewController.view];
}

- (IBAction)onToolbarItemMedia:(id)sender {
    [self changeViewTo:mediaViewController.view];
}

- (void) changeViewTo:(NSView*)view {
    [prevView removeFromSuperview];
    prevView = view;
    prevView.frame = CGRectMake(0, self.window.contentView.frame.size.height - prevView.frame.size.height, prevView.frame.size.width, prevView.frame.size.height);
    [self.window.contentView addSubview:prevView];
}

- (void) didClickSettingsViewControllerSeve:(SettingsViewController*)settingsViewController {
    [accountsViewController save];
    [codecsViewController save];
    [mediaViewController save];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self close];
}

@end
