//
//  SettingsWindowController.m
//  MacApp
//
//  Created by Norayr Harutyunyan on 8/27/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import "SettingsWindowController.h"
#import "SettingsViewController.h"
#import "AVViewController.h"
#import "ThemeMenuViewController.h"
#import "SummaryMenuViewController.h"
#import "AccountsViewController.h"
#import "PreferencesViewController.h"
#import "CodecsViewController.h"
#import "MediaViewController.h"
#import "TestingViewController.h"
#import "AppDelegate.h"
#import "LinphoneManager.h"

@interface SettingsWindowController () <SettingsViewControllerDelegate> {
    AVViewController *avViewController;
    ThemeMenuViewController *themeMenuViewController;
    SummaryMenuViewController *summaryMenuViewController;
    AccountsViewController *accountsViewController;
    PreferencesViewController *preferencesViewController;
    CodecsViewController *codecsViewController;
    MediaViewController *mediaViewController;
    TestingViewController *testingViewController;
    
    NSView *prevView;
}

@property (weak) IBOutlet NSToolbar *toolbar;
@property (weak) IBOutlet NSToolbarItem *toolbarItemPreferences;

@end

@implementation SettingsWindowController

@synthesize isShow;

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    self.isShow = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myWindowWillClose:) name:NSWindowWillCloseNotification object:[self window]];
    
    avViewController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"AVViewController"];
    themeMenuViewController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"ThemeMenuViewController"];
    summaryMenuViewController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"SummaryMenuViewController"];
    accountsViewController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"AccountsViewController"];
    preferencesViewController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"PreferencesViewController"];
    codecsViewController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"CodecsViewController"];
    mediaViewController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"MediaViewController"];
    testingViewController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"TestingViewController"];
    
    [self changeViewTo:avViewController.view];
    
    SettingsViewController *settingsViewController = (SettingsViewController*)self.contentViewController;
    settingsViewController.delegate = self;
}

- (void)myWindowWillClose:(NSNotification *)notification
{
    self.isShow = NO;
    [AppDelegate sharedInstance].viewController.settingsWindowController = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didClosedSettingsWindow" object:nil];
}

- (IBAction)onToolbarItemAudioVideo:(id)sender {
    [self changeViewTo:avViewController.view];
}

- (IBAction)onToolbarItemThemeMenu:(id)sender {
    [self changeViewTo:themeMenuViewController.view];
}

- (IBAction)onToolbarItemSummaryMenu:(id)sender {
    [self changeViewTo:summaryMenuViewController.view];
}

- (IBAction)onToolbarItemAccount:(id)sender {
    [self changeViewTo:accountsViewController.view];
}

- (IBAction)onToolbarItemPreferences:(id)sender {
    [self changeViewTo:preferencesViewController.view];
}

- (IBAction)onToolbarItemCodecs:(id)sender {
    [self changeViewTo:codecsViewController.view];
}

- (IBAction)onToolbarItemMedia:(id)sender {
    [self changeViewTo:mediaViewController.view];
}

- (IBAction)onToolbarItemTesting:(id)sender {
    [self changeViewTo:testingViewController.view];
}

- (void) changeViewTo:(NSView*)view {
    [prevView removeFromSuperview];
    prevView = view;
    prevView.frame = CGRectMake(0, self.window.contentView.frame.size.height - prevView.frame.size.height, prevView.frame.size.width, prevView.frame.size.height);
    [self.window.contentView addSubview:prevView];
}

- (void) didClickSettingsViewControllerSeve:(SettingsViewController*)settingsViewController {
    if (![accountsViewController save]) {
        return;
    }
    
    [avViewController save];
    [themeMenuViewController save];
    [codecsViewController save];
    [mediaViewController save];
    [testingViewController save];
    [summaryMenuViewController save];
    [preferencesViewController save];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self close];
}

- (void) addPreferencesToolbarItem {
    NSArray *visibleItems = self.toolbar.visibleItems;
    
    BOOL found = NO;
    
    for (NSToolbarItem *toolbarItem in visibleItems) {
        if ([toolbarItem.itemIdentifier isEqualToString:@"preferences"]) {
            found = YES;
            
            break;
        }
    }
    
    if (!found) {
        [self.toolbar insertItemWithItemIdentifier:@"preferences" atIndex:[self.toolbar visibleItems].count];
    }
}

- (void) dealloc {
    if([AppDelegate sharedInstance].viewController.videoMailWindowController.isShow){
        [[AppDelegate sharedInstance].viewController.videoMailWindowController close];
    }
    linphone_core_enable_video_preview([LinphoneManager getLc], FALSE);
    linphone_core_use_preview_window([LinphoneManager getLc], FALSE);
    linphone_core_set_native_preview_window_id([LinphoneManager getLc], LINPHONE_VIDEO_DISPLAY_NONE);
}

@end
