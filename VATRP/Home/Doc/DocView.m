//
//  DocView.m
//  ACE
//
//  Created by Norayr Harutyunyan on 11/10/15.
//  Copyright © 2015 Home. All rights reserved.
//

#import "DocView.h"
#import "Utils.h"
#import "AppDelegate.h"
#import "ChatService.h"


@interface DocView () {
    NSButton *selectedDocViewItem;
}

@property (weak) IBOutlet NSButton *buttonRecents;
@property (weak) IBOutlet NSButton *buttonContacts;
@property (weak) IBOutlet NSButton *buttonDialpad;
@property (weak) IBOutlet NSButton *buttonResources;
@property (weak) IBOutlet NSButton *buttonSettings;

@end


@implementation DocView

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
    if ([_delegate respondsToSelector:@selector(didClickDocViewRecents:)]) {
        [_delegate didClickDocViewRecents:self];
    }    
}

- (IBAction)onButtonContacts:(id)sender {
    AppDelegate *app = [AppDelegate sharedInstance];
    if (!app.contactsWindowController) {
        app.contactsWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"Contacts"];
        [app.contactsWindowController showWindow:self];
    } else {
        if (app.contactsWindowController.isShow) {
            [app.contactsWindowController close];
        } else {
            [app.contactsWindowController showWindow:self];
            app.contactsWindowController.isShow = YES;
        }
    }

    if ([_delegate respondsToSelector:@selector(didClickDocViewContacts:)]) {
        [_delegate didClickDocViewContacts:self];
    }
}

- (IBAction)onButtonDialpad:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickDocViewDialpad:)]) {
        [_delegate didClickDocViewDialpad:self];
    }
}

- (IBAction)onButtonResources:(id)sender {
    [[ChatService sharedInstance] openChatWindowWithUser:nil];

    if ([_delegate respondsToSelector:@selector(didClickDocViewResources:)]) {
        [_delegate didClickDocViewResources:self];
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

    if ([_delegate respondsToSelector:@selector(didClickDocViewSettings:)]) {
        [_delegate didClickDocViewSettings:self];
    }
}

- (void) selectItemWithDocViewItem:(DocViewItem)docViewItem {
    [selectedDocViewItem setWantsLayer:YES];
    [selectedDocViewItem.layer setBackgroundColor:[NSColor clearColor].CGColor];
    
    switch (docViewItem) {
        case DocViewItemRecents: {
            selectedDocViewItem = self.buttonRecents;
        }
            break;
        case DocViewItemContacts: {
            selectedDocViewItem = self.buttonContacts;
        }
            break;
        case DocViewItemDialpad: {
            selectedDocViewItem = self.buttonDialpad;
        }
            break;
        case DocViewItemResources: {
            selectedDocViewItem = self.buttonResources;
        }
            break;
        case DocViewItemSettings: {
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
