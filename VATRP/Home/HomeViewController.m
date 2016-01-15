//
//  HomeViewController.m
//  ACE
//
//  Created by Norayr Harutyunyan on 11/10/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import "HomeViewController.h"
#import "ViewManager.h"
#import "CallService.h"
#import "DockView.h"
#import "DialPadView.h"
#import "RecentsView.h"
#import "VideoView.h"
#import "ContactsView.h"
#import "NumpadView.h"
#import "SettingsView.h"
#import "ProviderTableCellView.h"
#import "DHResourcesView.h"
#import "ResourcesViewController.h"


@interface HomeViewController () <DockViewDelegate, NSTableViewDelegate, NSTableViewDataSource> {
    BackgroundedView *viewCurrent;
    NSArray *providersArray;
}

@property (weak) IBOutlet BackgroundedView *viewContainer;
@property (weak) IBOutlet DockView *dockView;
@property (weak) IBOutlet DialPadView *dialPadView;
@property (weak) IBOutlet ProfileView *profileView;
@property (weak) IBOutlet RecentsView *recentsView;
@property (weak) IBOutlet ContactsView *contactsView;
@property (weak) IBOutlet SettingsView *settingsView;
@property (weak) IBOutlet DHResourcesView *dhResourcesView;

@property (weak) IBOutlet NSTableView *providerTableView;
@property (weak) IBOutlet NSView *providersView;

@property bool hasProviderAlertBeenShown;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    BackgroundedView *v = (BackgroundedView*)self.view;
    [v setBackgroundColor:[NSColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:1.0]];
    self.dockView.delegate = self;
    
    [self.viewContainer setBackgroundColor:[NSColor whiteColor]];
    
    [ViewManager sharedInstance].dockView = self.dockView;
    [ViewManager sharedInstance].dialPadView = self.dialPadView;
    [ViewManager sharedInstance].profileView = self.profileView;
    [ViewManager sharedInstance].recentsView = self.recentsView;
    [ViewManager sharedInstance].callView = self.callView;
    
    viewCurrent = (BackgroundedView*)self.recentsView;
    [self initProvidersArray];
    [self.dialPadView setProvButtonImage:[NSImage imageNamed:@"provider_logo_zvrs"]];
    [self.providerTableView reloadData];
    [self.contactsView setBackgroundColor:[NSColor whiteColor]];
    [self.settingsView setBackgroundColor:[NSColor whiteColor]];
    [self setObservers];
    
    self.hasProviderAlertBeenShown = false;
}

#pragma mark - Observers and related functions

- (void)setObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didClosedSettingsWindow:)
                                                 name:@"didClosedSettingsWindow"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didClosedMessagesWindow:)
                                                 name:@"didClosedMessagesWindow"
                                               object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"didClosedSettingsWindow"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"didClosedMessagesWindow"
                                                  object:nil];
}

- (void)didClosedMessagesWindow:(NSNotification*)not {
    [self.dockView clearDockViewMessagesBackgroundColor:YES];
}

- (void)didClosedSettingsWindow:(NSNotification*)not {
    [self.dockView clearDockViewSettingsBackgroundColor:YES];
}

#pragma mark DocView Delegate

- (void) didClickDockViewRecents:(DockView*)docView_ {
    self.providersView.hidden = YES;
    [self.viewContainer setFrame:NSMakeRect(0, 81, 310, 567)];
    viewCurrent.hidden = YES;
    self.recentsView.callsSegmentControll.hidden = NO;
    viewCurrent = (BackgroundedView*)self.recentsView;
    viewCurrent.hidden = NO;
    [viewCurrent setFrame:NSMakeRect(0, 0, 310, 567)];
    [self.dockView clearDockViewButtonsBackgroundColorsExceptDialPadButton:YES];
    [self.dockView selectItemWithDocViewItem:DockViewItemRecents];
}

- (void) didClickDockViewContacts:(DockView*)docView_ {
    self.providersView.hidden = YES;
    [self.viewContainer setFrame:NSMakeRect(0, 81, 310, 567)];
    viewCurrent.hidden = YES;
    viewCurrent = (BackgroundedView*)self.contactsView;
    viewCurrent.hidden = NO;
    [viewCurrent setFrame:NSMakeRect(0, 0, 310, 567)];
    [self.dockView clearDockViewButtonsBackgroundColorsExceptDialPadButton:YES];
    [self.dockView selectItemWithDocViewItem:DockViewItemContacts];
}

- (void) didClickDockViewDialpad:(DockView*)dockView_ {
    if (self.viewContainer.frame.origin.y == 81) {
        [self.viewContainer setFrame:NSMakeRect(0, 351, 310, 297)];
        [viewCurrent setFrame:NSMakeRect(0, 0, 310, 297)];
        [self.dockView selectItemWithDocViewItem:DockViewItemDialpad];
    } else {
        [self.viewContainer setFrame:NSMakeRect(0, 81, 310, 567)];
        [viewCurrent setFrame:NSMakeRect(0, 0, 310, 567)];
        [self.dockView clearDockViewButtonsBackgroundColorsExceptDialPadButton:YES];
        
        if ([viewCurrent isKindOfClass:[RecentsView class]]) {
            [self.dockView selectItemWithDocViewItem:DockViewItemRecents];
        } else if ([viewCurrent isKindOfClass:[ContactsView class]]) {
            [self.dockView selectItemWithDocViewItem:DockViewItemContacts];
        } else if ([viewCurrent isKindOfClass:[SettingsView class]]) {
            [self.dockView selectItemWithDocViewItem:DockViewItemSettings];
        } else if ([viewCurrent isKindOfClass:[DHResourcesView class]]) {
            [self.dockView selectItemWithDocViewItem:DockViewItemResources];
        }
    }
}

- (void) didClickDockViewResources:(DockView*)dockView_ {
    
//    ResourcesViewController *resourceViewController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"DHResources"];
//
    self.providersView.hidden = YES;
    [self.viewContainer setFrame:NSMakeRect(0, 81, 310, 567)];
    viewCurrent.hidden = YES;
    //viewCurrent = (BackgroundedView*)resourceViewController.view;
    viewCurrent = (BackgroundedView*)self.dhResourcesView;
    viewCurrent.hidden = NO;
    [viewCurrent setFrame:NSMakeRect(0, 0, 310, 567)];

    [self.dockView clearDockViewButtonsBackgroundColorsExceptDialPadButton:YES];
    [self.dockView selectItemWithDocViewItem:DockViewItemResources];
    
}

- (void) didClickDockViewSettings:(DockView*)dockView_ {
    self.providersView.hidden = YES;
    [self.viewContainer setFrame:NSMakeRect(0, 81, 310, 567)];
    viewCurrent.hidden = YES;
    viewCurrent = (BackgroundedView*)self.settingsView;
    viewCurrent.hidden = NO;
    [viewCurrent setFrame:NSMakeRect(0, 0, 310, 567)];
    [self.dockView clearDockViewButtonsBackgroundColorsExceptDialPadButton:YES];
    [self.dockView selectItemWithDocViewItem:DockViewItemSettings];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector {
    NSLog(@"- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector");
    return NO;
}

- (void)dealloc {
    [self removeObservers];
}

- (void)initProvidersArray {
    providersArray = @[@"provider_logo_caag", @"provider_logo_convorelay", @"provider_logo_globalvrs",
                       @"provider_logo_purplevrs", @"provider_logo_sorenson", @"provider_logo_zvrs"];
    self.providerTableView.delegate = self;
    self.providerTableView.dataSource = self;
}

#pragma mark - TableView delegate methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return providersArray.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    ProviderTableCellView *cellView = [tableView makeViewWithIdentifier:@"providerCell" owner:self];
    
    NSString *imageName = [providersArray objectAtIndex:row];
    [cellView.providerImageView setImage:[NSImage imageNamed:imageName]];
    
    return cellView;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 53;
}

- (IBAction)didSelectedTableRow:(id)sender {
    // VATRP-1514 - show the items, but do not actually select. Show a message letting the user know that this is for general release.
    // show this once so that the user can look to see the options but not make a selection.
    if (!self.hasProviderAlertBeenShown)
    {
        NSAlert *alert = [[NSAlert alloc]init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Provider Selection will be available in General Release"];
        [alert runModal];
        self.hasProviderAlertBeenShown = true;
    }
    self.providersView.hidden = YES;
    
// VATRP-1514 - show the items, but do not actually select. Show a message letting the user know that this is for general release.
//    NSInteger selectedRow = [self.providerTableView selectedRow];
//    if (selectedRow >= 0 && selectedRow < providersArray.count) {
//        NSString *imageStrname = [providersArray objectAtIndex:selectedRow];
//        [self.dialPadView setProvButtonImage:[NSImage imageNamed:imageStrname]];
//        self.providersView.hidden = YES;

//    }
}

- (IBAction)onButtonProv:(id)sender {
    self.providersView.hidden = !self.providersView.hidden;
}

- (ProfileView*) getProfileView {
    return self.profileView;
}

- (void)mouseMoved:(NSEvent *)theEvent {
    NSPoint mousePosition = [self.view convertPoint:[theEvent locationInWindow] fromView:nil];
    
    if ([[CallService sharedInstance] getCurrentCall]) {
        LinphoneCallState call_state = linphone_call_get_state([[CallService sharedInstance] getCurrentCall]);
        
        if ((call_state != LinphoneCallDeclined && call_state != LinphoneCallEnd && call_state != LinphoneCallError) && mousePosition.x > 300 && mousePosition.x < 1030 && mousePosition.y > 0 && mousePosition.y < 700) {
            [self.videoView setMouseInCallWindow];
        }
    }
}

- (BOOL) isCurrentTabRecents {
    return [viewCurrent isKindOfClass:[RecentsView class]];
}

@end
