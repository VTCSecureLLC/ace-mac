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
    IBOutlet NSView *viewContainer;
    IBOutlet NSButton *saveBtn;
    NSViewController* currentViewController;
    
    NSUInteger preferencesIndex;
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
    testingViewController = [[TestingViewController alloc] init:self];
    
    preferencesIndex = -1;

    [self changeViewTo:generalViewController.view];
    
    [self.window setTitle:@"Settings"];

}

-(void) initializeData
{
    [generalViewController initializeData];
    [avViewController initializeData];
    [themeMenuViewController initializeData];
    [textMenuViewController initializeData];
//    [summaryMenuViewController initializeData]; // does not have data to initialize
    [accountsViewController initializeData];
    [preferencesViewController initializeData];
    [mediaViewController initializeData];
    [testingViewController initializeData];
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

- (void) changeViewTo:(NSView*)view
{
    for (NSView *subview in [viewContainer subviews]) {
        [subview removeFromSuperview];
    }
    [viewContainer addSubview:view];
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
    if ([self isPreferencesInToolbar])
    {
        [preferencesViewController save];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    if([AppDelegate sharedInstance].viewController.videoMailWindowController.isShow){
        [[AppDelegate sharedInstance].viewController.videoMailWindowController close];
    }

    [self close];
}

- (void) addPreferencesToolbarItem
{
    if (![self isPreferencesInToolbar])
    {
        NSArray *visibleItems = self.toolbar.visibleItems;
        [self.toolbar insertItemWithItemIdentifier:@"preferences" atIndex:[self.toolbar visibleItems].count];
        preferencesIndex = [self.toolbar visibleItems].count;
    }
}

-(bool)isPreferencesInToolbar
{
    NSArray *visibleItems = self.toolbar.visibleItems;
    for (NSToolbarItem *toolbarItem in visibleItems)
    {
        if ([toolbarItem.itemIdentifier isEqualToString:@"preferences"])
        {
            return true;
        }
    }
    return false;
}
-(void)closeWindow
{
    [self close];
}

- (void) dealloc {
    
    if (preferencesIndex > -1)
    {
        [self.toolbar removeItemAtIndex:preferencesIndex];
    }
}

@end
