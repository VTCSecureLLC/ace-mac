//
//  DockView.m
//  ACE
//
//  Created by Norayr Harutyunyan on 11/10/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import "DockView.h"
#import "Utils.h"
#import "AppDelegate.h"
#import "ChatService.h"


@interface DockView () {
    NSButton *selectedDocViewItem;
}

@property (weak) IBOutlet NSButton *buttonRecents;
@property (weak) IBOutlet NSButton *buttonContacts;
@property (weak) IBOutlet NSButton *buttonDialpad;
@property (weak) IBOutlet NSButton *buttonResources;
@property (weak) IBOutlet NSButton *buttonSettings;

@end


@implementation DockView

@synthesize delegate = _delegate;

- (void) awakeFromNib {
    [super awakeFromNib];
    
    [self setBackgroundColor:[NSColor colorWithRed:44.0/255.0 green:55.0/255.0 blue:61.0/255.0 alpha:1.0]];
    
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonRecents];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonContacts];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonDialpad];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonSettings];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonResources];
    
    selectedDocViewItem = self.buttonDialpad;
    [selectedDocViewItem setWantsLayer:YES];
    [selectedDocViewItem.layer setBackgroundColor:[NSColor colorWithRed:90.0/255.0 green:115.0/255.0 blue:128.0/255.0 alpha:1.0].CGColor];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (IBAction)onButtonRecents:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickDockViewRecents:)]) {
        [_delegate didClickDockViewRecents:self];
    }    
}

- (IBAction)onButtonContacts:(id)sender {
//    AppDelegate *app = [AppDelegate sharedInstance];
//    if (!app.contactsWindowController) {
//        app.contactsWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"Contacts"];
//        [app.contactsWindowController showWindow:self];
//    } else {
//        if (app.contactsWindowController.isShow) {
//            [app.contactsWindowController close];
//        } else {
//            [app.contactsWindowController showWindow:self];
//            app.contactsWindowController.isShow = YES;
//        }
//    }

    if ([_delegate respondsToSelector:@selector(didClickDockViewContacts:)]) {
        [_delegate didClickDockViewContacts:self];
    }
}

- (IBAction)onButtonDialpad:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickDockViewDialpad:)]) {
        [_delegate didClickDockViewDialpad:self];
    }
}

- (IBAction)onButtonResources:(id)sender {
    [[ChatService sharedInstance] openChatWindowWithUser:nil];

    if ([_delegate respondsToSelector:@selector(didClickDockViewResources:)]) {
        [_delegate didClickDockViewResources:self];
    }
}

- (IBAction)onButtonSettings:(id)sender {
    AppDelegate *app = [AppDelegate sharedInstance];
    if (!app.settingsWindowController) {
        app.settingsWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"Settings"];
        [app.settingsWindowController showWindow:self];
    } else {
        if (app.settingsWindowController.isShow) {
            [app.settingsWindowController close];
            app.settingsWindowController = nil;
        } else {
            [app.settingsWindowController showWindow:self];
            app.settingsWindowController.isShow = YES;
        }
    }

    if ([_delegate respondsToSelector:@selector(didClickDockViewSettings:)]) {
        [_delegate didClickDockViewSettings:self];
    }
}

- (void) selectItemWithDocViewItem:(DockViewItem)docViewItem {
    [selectedDocViewItem setWantsLayer:YES];
    [selectedDocViewItem.layer setBackgroundColor:[NSColor clearColor].CGColor];
    
    switch (docViewItem) {
        case DockViewItemRecents: {
            selectedDocViewItem = self.buttonRecents;
        }
            break;
        case DockViewItemContacts: {
            selectedDocViewItem = self.buttonContacts;
        }
            break;
        case DockViewItemDialpad: {
            selectedDocViewItem = self.buttonDialpad;
        }
            break;
        case DockViewItemResources: {
            selectedDocViewItem = self.buttonResources;
        }
            break;
        case DockViewItemSettings: {
            selectedDocViewItem = self.buttonSettings;
        }
            break;
            
        default:
            break;
    }

    [selectedDocViewItem setWantsLayer:YES];
    [selectedDocViewItem.layer setBackgroundColor:[NSColor colorWithRed:90.0/255.0 green:115.0/255.0 blue:128.0/255.0 alpha:1.0].CGColor];
}

@end
