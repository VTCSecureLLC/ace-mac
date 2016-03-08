//
//  DockView.h
//  ACE
//
//  Created by Norayr Harutyunyan on 11/10/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BackgroundedViewController.h"

typedef enum : NSUInteger {
    DockViewItemRecents,
    DockViewItemContacts,
    DockViewItemDialpad,
    DockViewItemResources,
    DockViewItemSettings,
} DockViewItem;

@protocol DockViewDelegate;

@interface DockView : BackgroundedViewController

@property (nonatomic, assign) id<DockViewDelegate> delegate;

- (void) selectItemWithDocViewItem:(DockViewItem)docViewItem;
- (void)clearDockViewButtonsBackgroundColorsExceptDialPadButton:(BOOL)clear;
- (void)clearDockViewSettingsBackgroundColor:(BOOL)clear;
- (void)clearDockViewMessagesBackgroundColor:(BOOL)clear;
@end

@protocol DockViewDelegate <NSObject>

@optional

- (void) didClickDockViewRecents:(DockView*)docView_;
- (void) didClickDockViewContacts:(DockView*)docView_;
- (void) didClickDockViewDialpad:(DockView*)docView_;
- (void) didClickDockViewResources:(DockView*)docView_;
- (void) didClickDockViewSettings:(DockView*)docView_;


@end