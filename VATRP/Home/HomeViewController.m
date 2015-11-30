//
//  HomeViewController.m
//  ACE
//
//  Created by Norayr Harutyunyan on 11/10/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import "HomeViewController.h"
#import "ViewManager.h"
#import "DockView.h"
#import "DialPadView.h"
#import "ProfileView.h"
#import "RecentsView.h"
#import "VideoView.h"
#import "NumpadView.h"
#import "ProviderTableCellView.h"


@interface HomeViewController () <DockViewDelegate, NSTableViewDelegate, NSTableViewDataSource> {
    BackgroundedView *viewCurrent;
    NSArray *providersArray;
}

@property (weak) IBOutlet BackgroundedView *viewContainer;
@property (weak) IBOutlet DockView *dockView;
@property (weak) IBOutlet DialPadView *dialPadView;
@property (weak) IBOutlet ProfileView *profileView;
@property (weak) IBOutlet RecentsView *recentsView;

@property (weak) IBOutlet NSTableView *providerTableView;
@property (weak) IBOutlet NSView *providersView;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self.viewContainer setBackgroundColor:[NSColor clearColor]];
    BackgroundedView *v = (BackgroundedView*)self.view;
    [v setBackgroundColor:[NSColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:1.0]];
    self.dockView.delegate = self;
    
    [self.viewContainer setBackgroundColor:[NSColor redColor]];
    
    [ViewManager sharedInstance].dockView = self.dockView;
    [ViewManager sharedInstance].dialPadView = self.dialPadView;
    [ViewManager sharedInstance].profileView = self.profileView;
    [ViewManager sharedInstance].recentsView = self.recentsView;
    [ViewManager sharedInstance].callView = self.callView;
    
    viewCurrent = (BackgroundedView*)self.recentsView;
    [self initProvidersArray];
    [self.dialPadView setProvButtonImage:[NSImage imageNamed:@"provider_logo_zvrs"]];
    [self.providerTableView reloadData];
}

#pragma mark DocView Delegate

- (void) didClickDockViewRecents:(DockView*)docView_ {
    self.providersView.hidden = YES;
    [self.viewContainer setFrame:NSMakeRect(0, 81, 310, 567)];
    [viewCurrent setFrame:NSMakeRect(0, 0, 310, 567)];
    [self.dockView selectItemWithDocViewItem:DockViewItemRecents];
}

- (void) didClickDockViewContacts:(DockView*)docView_ {
}

- (void) didClickDockViewDialpad:(DockView*)dockView_ {
    if (self.viewContainer.frame.origin.y == 81) {
        [self.viewContainer setFrame:NSMakeRect(0, 351, 310, 297)];
        [viewCurrent setFrame:NSMakeRect(0, 0, 310, 297)];
        [self.dockView selectItemWithDocViewItem:DockViewItemDialpad];
    } else {
        [self.viewContainer setFrame:NSMakeRect(0, 81, 310, 567)];
        [viewCurrent setFrame:NSMakeRect(0, 0, 310, 567)];
        [self.dockView selectItemWithDocViewItem:DockViewItemRecents];
    }
}

- (void) didClickDockViewResources:(DockView*)dockView_ {
}

- (void) didClickDockViewSettings:(DockView*)dockView_ {
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector {
    NSLog(@"- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector");
    return NO;
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
    NSInteger selectedRow = [self.providerTableView selectedRow];
    if (selectedRow >= 0 && selectedRow < providersArray.count) {
        NSString *imageStrname = [providersArray objectAtIndex:selectedRow];
        [self.dialPadView setProvButtonImage:[NSImage imageNamed:imageStrname]];
        self.providersView.hidden = YES;

    }
}

- (IBAction)onButtonProv:(id)sender {
    self.providersView.hidden = !self.providersView.hidden;
}

@end
