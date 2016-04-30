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
#import "LinphoneAPI.h"
#import "MoreSectionViewController.h"

#define DOCKVIEW_BUTTONS_SELECTION_COLOR [NSColor colorWithRed:252.0/255.0 green:98.0/255.0 blue:32.0/255.0 alpha:1.0].CGColor

@interface DockView () {
    NSButton *selectedDocViewItem;
    NSArray *dockViewButtons;
    
    NSTextField *labelMessedCalls;
    bool observersAdded;
}
@property (strong) HomeViewController* parent;

@property (weak) IBOutlet NSButton *buttonRecents;
@property (weak) IBOutlet NSButton *buttonContacts;
@property (weak) IBOutlet NSButton *buttonDialpad;
@property (weak) IBOutlet NSButton *buttonResources;
@property (weak) IBOutlet NSButton *buttonSettings;
@property (weak) IBOutlet NSTextField *badgeOnMessages;
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
    [selectedDocViewItem.layer setBackgroundColor:DOCKVIEW_BUTTONS_SELECTION_COLOR];
    dockViewButtons = [NSArray arrayWithObjects:self.buttonRecents, self.buttonContacts, self.buttonDialpad, self.buttonResources, self.buttonSettings, nil];
    
    labelMessedCalls = [[NSTextField alloc] initWithFrame:NSMakeRect(41, 59, 20, 20)];
    labelMessedCalls.editable = NO;
    labelMessedCalls.stringValue = @"";
    [labelMessedCalls.cell setBordered:NO];
    [labelMessedCalls setBackgroundColor:[NSColor redColor]];
    [labelMessedCalls setTextColor:[NSColor whiteColor]];
    [labelMessedCalls setFont:[NSFont systemFontOfSize:14]];
#if defined __MAC_10_9 || __MAC_10_8
    [labelMessedCalls.cell setAlignment:kCTTextAlignmentCenter];
#else
    [labelMessedCalls.cell setAlignment:NSAlignmentCenter];
#endif
    [labelMessedCalls setWantsLayer:YES];
    [labelMessedCalls.layer setCornerRadius:9.0];
    [labelMessedCalls setHidden:YES];
    [self.view addSubview:labelMessedCalls];
    
    if (!observersAdded)
    {
        observersAdded = true;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(callUpdateEvent:)
                                                     name:kLinphoneCallUpdate
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textReceivedEvent:)
                                                     name:kLinphoneTextReceived
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyReceived:) name:kLinphoneNotifyReceived object:nil];
    }
    [self createBadgeLabel];
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
    [self.badgeOnMessages setHidden:YES];
        if (self.parent != nil)
        {
            [self.parent didClickDockViewResources];
        }
    //}
    
    
//    self.resourcesWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"Resources"];
//   [self.resourcesWindowController showWindow:self];
    

}

- (IBAction)onButtonSettings:(id)sender {
    [self.buttonSettings setImage:[NSImage imageNamed:@"more1"]];
    
    [self.parent didClickDockViewSettings];
    
    
//    AppDelegate *app = [AppDelegate sharedInstance];
//    if (!app.settingsWindowController) {
//        app.settingsWindowController = [[SettingsWindowController alloc] init];
//        [app.settingsWindowController  initializeData];
//        [app.settingsWindowController showWindow:self];
////        if (self.parent != nil) {
////            [self.parent didClickDockViewSettings];
////        }
//    } else {
//        if (app.settingsWindowController.isShow) {
//            [app.settingsWindowController close];
//            app.settingsWindowController = nil;
//        } else {
//            [app.settingsWindowController showWindow:self];
//            [app.settingsWindowController  initializeData];
//            app.settingsWindowController.isShow = YES;
////            if (self.parent != nil) {
////                [self.parent didClickDockViewSettings];
////            }
//        }
//    }


//    if (self.parent != nil) {
//        [self.parent didClickDockViewSettings];
//    }
}

- (void)createBadgeLabel {
    [self.badgeOnMessages setHidden:YES];
    [self.badgeOnMessages setWantsLayer:YES];
    [self.badgeOnMessages.layer setBackgroundColor:DOCKVIEW_BUTTONS_SELECTION_COLOR];
    [self.badgeOnMessages.layer setCornerRadius:12];
    [self.badgeOnMessages setTextColor:[NSColor whiteColor]];
    [self.badgeOnMessages setAlignment:NSTextAlignmentCenter];
    self.badgeOnMessages.stringValue = @"!";
    [self.badgeOnMessages setBackgroundColor:[NSColor colorWithRed:252.0/255.0 green:98.0/255.0 blue:32.0/255.0 alpha:1.0]];
}

- (void)openSettings {
    AppDelegate *app = [AppDelegate sharedInstance];
    if (!app.settingsWindowController) {
        app.settingsWindowController = [[SettingsWindowController alloc] init];
        [app.settingsWindowController  initializeData];
        [app.settingsWindowController showWindow:self];
    } else {
        if (app.settingsWindowController.isShow) {
            [app.settingsWindowController close];
            app.settingsWindowController = nil;
        } else {
            [app.settingsWindowController showWindow:self];
            [app.settingsWindowController  initializeData];
            app.settingsWindowController.isShow = YES;
        }
    }
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

- (void)clearSettingsButtonBackgroundColor {
    for (NSButton *bt in dockViewButtons) {
        if ([bt.title isEqualToString:@"More"]) {
            [bt setWantsLayer:YES];
            [bt.layer setBackgroundColor:[NSColor clearColor].CGColor];
        }
    }
}

- (void)clearDockViewSettingsBackgroundColor:(BOOL)clear {
    if (clear) {
        [self.buttonSettings setWantsLayer:YES];
        [self.buttonSettings.layer setBackgroundColor:[NSColor clearColor].CGColor];
    } else {
        [self.buttonSettings setWantsLayer:YES];
        [self.buttonSettings.layer setBackgroundColor:DOCKVIEW_BUTTONS_SELECTION_COLOR];
    }
}

- (void)clearDockViewMessagesBackgroundColor:(BOOL)clear {
    if (clear) {
        [self.buttonResources setWantsLayer:YES];
        [self.buttonResources.layer setBackgroundColor:[NSColor clearColor].CGColor];
    } else {
        [self.buttonResources setWantsLayer:YES];
        [self.buttonResources.layer setBackgroundColor:DOCKVIEW_BUTTONS_SELECTION_COLOR];
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
    [selectedDocViewItem.layer setBackgroundColor:DOCKVIEW_BUTTONS_SELECTION_COLOR];
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
                if (missedCount > 0)
                {
                    [labelMessedCalls setHidden:NO];
                }
            } else {
                linphone_core_reset_missed_calls_count([LinphoneManager getLc]);
            }
        }
            break;
        default:
            break;
    }
}

- (void)textReceivedEvent:(NSNotification *)notif {
    NSDictionary *dict = notif.userInfo;
    const LinphoneAddress* from_addr = NULL;
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        LinphoneChatMessage *msg = [[notif.userInfo objectForKey:@"message"] pointerValue];
         from_addr = linphone_chat_message_get_from_address(msg);
    }
    const MSList *calls = linphone_core_get_calls([LinphoneManager getLc]);
    LinphoneCall *call;
    if(calls && ms_list_size(calls) > 0){
        for(int i = 0; i < ms_list_size(calls); i++){
            call = ms_list_nth_data(calls, i);
            if(strcmp(linphone_call_get_remote_address_as_string(call), linphone_address_as_string( from_addr)) == 0 && linphone_call_get_state(call) == LinphoneCallStreamsRunning){
                return;
            }
        }
    }

    if (![[ChatService sharedInstance] isOpened]) {
        [self.badgeOnMessages setHidden:NO];
    }
}

- (void)notifyReceived:(NSNotification *)notif {
    const LinphoneContent * content = [[notif.userInfo objectForKey: @"content"] pointerValue];
    
    if ((content == NULL)
        || (strcmp("application", linphone_content_get_type(content)) != 0)
        || (strcmp("simple-message-summary", linphone_content_get_subtype(content)) != 0)
        || (linphone_content_get_buffer(content) == NULL)) {
        return;
    }
    const char* body = linphone_content_get_buffer(content);
    if ((body = strstr(body, "Voicemail: ")) == NULL) {
        NSLog(@"Received new NOTIFY from voice mail but could not find 'voice-message' in BODY. Ignoring it.");
        
        return;
    }
    
    const char *messages = linphone_content_get_string_buffer(content);
    
    if (!messages) {
        return;
    }
    
    char char_messages_waiting[3];
    sscanf(messages, "Messages-Waiting:  %3[^;]", char_messages_waiting);

    if (!strlen(char_messages_waiting)) {
        return;
    }

    NSString *messages_waiting = [[NSString stringWithUTF8String:char_messages_waiting] lowercaseString];
    
    if ([messages_waiting isEqualToString:@"yes"]) {
        if ([[AppDelegate sharedInstance].homeWindowController getHomeViewController].moreSectionContainer.hidden) {
            [self.buttonSettings setImage:[NSImage imageNamed:@"more_videoMail"]];
        }
    } else {
        [self.buttonSettings setImage:[NSImage imageNamed:@"more1"]];
    }
}

@end
