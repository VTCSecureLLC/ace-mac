//
//  SettingsWindowController.m
//  MacApp
//
//  Created by Norayr Harutyunyan on 8/27/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import "SettingsWindowController.h"
#import "GeneralViewController.h"
#import "AVViewController.h"
#import "ThemeMenuViewController.h"
#import "TextMenuViewController.h"
#import "SummaryMenuViewController.h"
#import "AccountsViewController.h"
#import "PreferencesViewController.h"
#import "MediaViewController.h"
#import "TestingViewController.h"
#import "AppDelegate.h"
#import "LinphoneManager.h"

@interface SettingsWindowController ()
{
    GeneralViewController *generalViewController;
    AVViewController *avViewController;
    ThemeMenuViewController *themeMenuViewController;
    TextMenuViewController *textMenuViewController;
    SummaryMenuViewController *summaryMenuViewController;
    AccountsViewController *accountsViewController;
    PreferencesViewController *preferencesViewController;
    MediaViewController *mediaViewController;
    TestingViewController *testingViewController;
    IBOutlet NSView *prevView;
    IBOutlet NSButton *saveBtn;
    NSViewController* currentViewController;
}

@property (weak) IBOutlet NSToolbar *toolbar;
@property (weak) IBOutlet NSToolbarItem *toolbarItemPreferences;

@end

@implementation SettingsWindowController

@synthesize isShow;

-(id) init
{
    self = [super initWithWindowNibName:@"SettingsWindow"];
    if (self)
    {
        // init
    }
    return self;
    
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    self.isShow = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myWindowWillClose:) name:NSWindowWillCloseNotification object:[self window]];
    
    generalViewController = [[GeneralViewController alloc] init];
    avViewController = [[AVViewController alloc] init];
    themeMenuViewController = [[ThemeMenuViewController alloc] init];
    textMenuViewController = [[TextMenuViewController alloc] init];
    summaryMenuViewController = [[SummaryMenuViewController alloc] init];
    accountsViewController = [[AccountsViewController alloc] init];
    preferencesViewController = [[PreferencesViewController alloc] init];
    mediaViewController = [[MediaViewController alloc] init];
    testingViewController = [[TestingViewController alloc] init];
    

    [self changeViewTo:generalViewController.view];
    
    [self.window setTitle:@"SettingsWindowController"];

}

- (void)myWindowWillClose:(NSNotification *)notification
{
    self.isShow = NO;
    [AppDelegate sharedInstance].viewController.settingsWindowController = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didClosedSettingsWindow" object:nil];
}

- (IBAction)onToolbarItemGeneral:(id)sender {
    [self changeViewTo:generalViewController.view];
}

- (IBAction)onToolbarItemAudioVideo:(id)sender {
    [self changeViewTo:avViewController.view];
}

- (IBAction)onToolbarItemThemeMenu:(id)sender {
    [self changeViewTo:themeMenuViewController.view];
}
- (IBAction)onToolbarItemTextMenu:(id)sender {
     [self changeViewTo:textMenuViewController.view];
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
- (IBAction)onSaveButtonClick:(NSButton *)sender {
    if (![accountsViewController save]) {
        return;
    }
    
    [generalViewController save];
    [avViewController save];
    [themeMenuViewController save];
    [textMenuViewController save];
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
