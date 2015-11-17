//
//  HomeViewController.m
//  ACE
//
//  Created by Norayr Harutyunyan on 11/10/15.
//  Copyright © 2015 Home. All rights reserved.
//

#import "HomeViewController.h"
#import "ViewManager.h"
#import "DocView.h"
#import "DialPadView.h"
#import "ProfileView.h"
#import "RecentsView.h"


@interface HomeViewController () <DocViewDelegate> {
    BackgroundedView *viewCurrent;
}

@property (weak) IBOutlet BackgroundedView *viewConteiner;
@property (weak) IBOutlet DocView *docView;
@property (weak) IBOutlet DialPadView *dialPadView;
@property (weak) IBOutlet ProfileView *profileView;
@property (weak) IBOutlet RecentsView *recentsView;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self.viewConteiner setBackgroundColor:[NSColor clearColor]];
    BackgroundedView *v = (BackgroundedView*)self.view;
    [v setBackgroundColor:[NSColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:1.0]];
    self.docView.delegate = self;
    
    [self.viewConteiner setBackgroundColor:[NSColor redColor]];
    
    [ViewManager sharedInstance].docView = self.docView;
    [ViewManager sharedInstance].dialPadView = self.dialPadView;
    [ViewManager sharedInstance].profileView = self.profileView;
    [ViewManager sharedInstance].recentsView = self.recentsView;
    
    viewCurrent = (BackgroundedView*)self.recentsView;
}

#pragma mark DocView Delegate

- (void) didClickDocViewRecents:(DocView*)docView_ {
    [self.viewConteiner setFrame:NSMakeRect(0, 81, 310, 567)];
    [viewCurrent setFrame:NSMakeRect(0, 0, 310, 567)];
    [self.docView selectItemWithDocViewItem:DocViewItemRecents];
}

- (void) didClickDocViewContacts:(DocView*)docView_ {
}

- (void) didClickDocViewDialpad:(DocView*)docView_ {
    if (self.viewConteiner.frame.origin.y == 81) {
        [self.viewConteiner setFrame:NSMakeRect(0, 351, 310, 297)];
        [viewCurrent setFrame:NSMakeRect(0, 0, 310, 297)];
        [self.docView selectItemWithDocViewItem:DocViewItemDialpad];
    } else {
        [self.viewConteiner setFrame:NSMakeRect(0, 81, 310, 567)];
        [viewCurrent setFrame:NSMakeRect(0, 0, 310, 567)];
        [self.docView selectItemWithDocViewItem:DocViewItemRecents];
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

- (void) didClickDocViewResources:(DocView*)docView_ {
}

- (void) didClickDocViewSettings:(DocView*)docView_ {
}

@end
