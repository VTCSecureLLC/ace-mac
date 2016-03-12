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
#import "ResourcesWindowController.h"

@interface DockView () {
    NSButton *selectedDocViewItem;
    NSArray *dockViewButtons;
    
    NSTextField *labelMessedCalls;
}
@property (strong) HomeViewController* parent;

@property (weak) IBOutlet NSButton *buttonRecents;
@property (weak) IBOutlet NSButton *buttonContacts;
@property (weak) IBOutlet NSButton *buttonDialpad;
@property (weak) IBOutlet NSButton *buttonResources;
@property (weak) IBOutlet NSButton *buttonSettings;
@property (strong) ResourcesWindowController *resourcesWindowController;
@end


@implementation DockView

@synthesize delegate;// = _delegate;

-(id) init:(HomeViewController*)parentController
{
    self = [super initWithNibName:@"DockView" bundle:nil];
    if (self)
    {
        // init
        self.parent = parentController;
    }
    return self;
    
}

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
    dockViewButtons = [NSArray arrayWithObjects:self.buttonRecents, self.buttonContacts, self.buttonDialpad, self.buttonResources, self.buttonSettings, nil];
    
    labelMessedCalls = [[NSTextField alloc] initWithFrame:NSMakeRect(41, 59, 20, 20)];
    labelMessedCalls.editable = NO;
    labelMessedCalls.stringValue = @"";
    [labelMessedCalls.cell setBordered:NO];
    [labelMessedCalls setBackgroundColor:[NSColor redColor]];
    [labelMessedCalls setTextColor:[NSColor whiteColor]];
    [labelMessedCalls setFont:[NSFont systemFontOfSize:14]];
//    [labelMessedCalls.cell setAlignment:<#(NSTextAlignment)#>]
#if defined __MAC_10_9 || __MAC_10_8
    [labelMessedCalls.cell setAlignment:kCTTextAlignmentCenter];
#else
    [labelMessedCalls.cell setAlignment:NSAlignmentCenter];
#endif
    [labelMessedCalls setWantsLayer:YES];
    [labelMessedCalls.layer setCornerRadius:9.0];
    [labelMessedCalls setHidden:YES];
    [self.view addSubview:labelMessedCalls];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callUpdateEvent:)
                                                 name:kLinphoneCallUpdate
                                               object:nil];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//- (void)drawRect:(NSRect)dirtyRect {
//    [super drawRect:dirtyRect];
//
    // Drawing code here.
//}

- (IBAction)onButtonRecents:(id)sender {
//    if (([self delegate] != nil) && [[self delegate] respondsToSelector:@selector(didClickDockViewRecents:)]) {
//        [[self delegate] didClickDockViewRecents:self];
//    }
    if (self.parent != nil)
    {
        [self.parent didClickDockViewRecents];
    }
    labelMessedCalls.stringValue = @"";
    [labelMessedCalls setHidden:YES];
    linphone_core_reset_missed_calls_count([LinphoneManager getLc]);
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

//    if ((self.delegate != nil) && [self.delegate respondsToSelector:@selector(didClickDockViewContacts:)]) {
    if (self.parent != nil)
    {
        [self.parent didClickDockViewContacts];
    }
}

- (IBAction)onButtonDialpad:(id)sender {
    if (self.parent != nil)
    {
        [self.parent didClickDockViewDialpad];
    }
}

- (IBAction)onButtonResources:(id)sender {
   // BOOL isOpenedChatWindow = [[ChatService sharedInstance] openChatWindowWithUser:nil];
   // if (isOpenedChatWindow) {
        if (self.parent != nil)
        {
            [self.parent didClickDockViewResources];
        }
    //}
    
    
//    self.resourcesWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"Resources"];
//   [self.resourcesWindowController showWindow:self];
    

}

- (IBAction)onButtonSettings:(id)sender {
    AppDelegate *app = [AppDelegate sharedInstance];
    if (!app.settingsWindowController) {
        app.settingsWindowController = [[SettingsWindowController alloc] init];
        [app.settingsWindowController showWindow:self];
//        if (self.parent != nil) {
//            [self.parent didClickDockViewSettings];
//        }
    } else {
        if (app.settingsWindowController.isShow) {
            [app.settingsWindowController close];
            app.settingsWindowController = nil;
        } else {
            [app.settingsWindowController showWindow:self];
            app.settingsWindowController.isShow = YES;
//            if (self.parent != nil) {
//                [self.parent didClickDockViewSettings];
//            }
        }
    }


//    if (self.parent != nil) {
//        [self.parent didClickDockViewSettings];
//    }
}

#pragma mark - Functions for buttons background color chnages
- (void)clearDockViewButtonsBackgroundColorsExceptDialPadButton:(BOOL)clear {
    for (NSButton *bt in dockViewButtons) {
        if (clear) {
            [bt setWantsLayer:YES];
            [bt.layer setBackgroundColor:[NSColor clearColor].CGColor];
        } else {
            if (![bt.title isEqualToString:@"Dialpad"]) {
                [bt setWantsLayer:YES];
                [bt.layer setBackgroundColor:[NSColor clearColor].CGColor];
            }
        }
    }
}

- (void)clearDockViewSettingsBackgroundColor:(BOOL)clear {
    if (clear) {
        [self.buttonSettings setWantsLayer:YES];
        [self.buttonSettings.layer setBackgroundColor:[NSColor clearColor].CGColor];
    } else {
        [self.buttonSettings setWantsLayer:YES];
        [self.buttonSettings.layer setBackgroundColor:[NSColor colorWithRed:90.0/255.0 green:115.0/255.0 blue:128.0/255.0 alpha:1.0].CGColor];
    }
}

- (void)clearDockViewMessagesBackgroundColor:(BOOL)clear {
    if (clear) {
        [self.buttonResources setWantsLayer:YES];
        [self.buttonResources.layer setBackgroundColor:[NSColor clearColor].CGColor];
    } else {
        [self.buttonResources setWantsLayer:YES];
        [self.buttonResources.layer setBackgroundColor:[NSColor colorWithRed:90.0/255.0 green:115.0/255.0 blue:128.0/255.0 alpha:1.0].CGColor];
    }
}

- (void) selectItemWithDocViewItem:(DockViewItem)docViewItem {

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

#pragma mark - Event Functions

- (void)callUpdateEvent:(NSNotification*)notif {
    LinphoneCall *acall = [[notif.userInfo objectForKey: @"call"] pointerValue];
    LinphoneCallState astate = [[notif.userInfo objectForKey: @"state"] intValue];
    [self callUpdate:acall state:astate];
}

#pragma mark -

- (void)callUpdate:(LinphoneCall *)acall state:(LinphoneCallState)astate {
    switch (astate) {
        case LinphoneCallError:
        case LinphoneCallEnd:
        {
            if (![[[AppDelegate sharedInstance].homeWindowController getHomeViewController] isCurrentTabRecents]) {
                int missedCount = linphone_core_get_missed_calls_count([LinphoneManager getLc]);
                
                if (missedCount < 10) {
                    labelMessedCalls.frame = NSMakeRect(41, 59, 20, 20);
                } else {
                    labelMessedCalls.frame = NSMakeRect(35, 59, 26, 20);
                }
                
                labelMessedCalls.intValue = missedCount;
                [labelMessedCalls setHidden:NO];
            } else {
                linphone_core_reset_missed_calls_count([LinphoneManager getLc]);
            }
        }
            break;
        default:
            break;
    }
}

@end
