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
#import "ContactsView.h"


@interface HomeViewController () <DockViewDelegate> {
    BackgroundedView *viewCurrent;
}

@property (weak) IBOutlet BackgroundedView *viewContainer;
@property (weak) IBOutlet DockView *dockView;
@property (weak) IBOutlet DialPadView *dialPadView;
@property (weak) IBOutlet ProfileView *profileView;
@property (weak) IBOutlet RecentsView *recentsView;
@property (weak) IBOutlet ContactsView *contactsView;

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
    
    viewCurrent = (BackgroundedView*)self.recentsView;
    
    [self.contactsView setBackgroundColor:[NSColor yellowColor]];
}

#pragma mark DocView Delegate

- (void) didClickDockViewRecents:(DockView*)docView_ {
    [self.viewContainer setFrame:NSMakeRect(0, 81, 310, 567)];
    viewCurrent.hidden = YES;
    viewCurrent = (BackgroundedView*)self.recentsView;
    viewCurrent.hidden = NO;
    [viewCurrent setFrame:NSMakeRect(0, 0, 310, 567)];
    [self.dockView selectItemWithDocViewItem:DockViewItemRecents];
}

- (void) didClickDockViewContacts:(DockView*)docView_ {
    [self.viewContainer setFrame:NSMakeRect(0, 81, 310, 567)];
    viewCurrent.hidden = YES;
    viewCurrent = (BackgroundedView*)self.contactsView;
    viewCurrent.hidden = NO;
    [viewCurrent setFrame:NSMakeRect(0, 0, 310, 567)];
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
        
        if ([viewCurrent isKindOfClass:[RecentsView class]]) {
            [self.dockView selectItemWithDocViewItem:DockViewItemRecents];
        } else if ([viewCurrent isKindOfClass:[ContactsView class]]) {
            [self.dockView selectItemWithDocViewItem:DockViewItemContacts];
        }
    }
    
    
    
    
    
    
//    if (self.dialPadView.superview) {
//        [self.dialPadView removeFromSuperview];
//        [viewCurrent setFrame:NSMakeRect(0, 0, 310, 568)];
//    } else {
//        [self.dialPadView setFrame:NSMakeRect(0, 81, 310, self.dialPadView.frame.size.height)];
//        [self.view addSubview:self.dialPadView];
//        [viewCurrent setFrame:NSMakeRect(0, 270, 310, 297)];
//    }
}

- (void) didClickDockViewResources:(DockView*)dockView_ {
}

- (void) didClickDockViewSettings:(DockView*)dockView_ {
}

@end
