//
//  ChatViewController.m
//  ACE
//
//  Created by Edgar Sukiasyan on 10/13/15.
//  Copyright © 2015 Home. All rights reserved.
//

#import "ChatViewController.h"
#import "ContactTableCellView.h"
#import "BackgroundedView.h"
#import "LinphoneManager.h"
#import "ChatService.h"

@interface ChatViewController () {
    MSList *contacts;
    
    LinphoneCall *currentCall;

    LinphoneChatRoom *selectedChatRoom;
    MSList *messageList;
}

@property (weak) IBOutlet NSTableView *tableViewContacts;
@property (weak) IBOutlet NSTableView *tableViewContent;
@property (weak) IBOutlet BackgroundedView *viewTextEnterBG;
@property (weak) IBOutlet BackgroundedView *viewSeparateLine;
@property (weak) IBOutlet NSTextField *textFieldRemoteUri;
@property (weak) IBOutlet NSTextField *textFieldMessage;
@property (unsafe_unretained) IBOutlet NSTextView *textViewIncoming;
@property (unsafe_unretained) IBOutlet NSTextView *textViewOutgoing;

- (IBAction)onButtonNewChat:(id)sender;
- (IBAction)onButtonSend:(id)sender;


@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callUpdateEvent:)
                                                 name:kLinphoneCallUpdate
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textComposeEvent:)
                                                 name:kLinphoneTextComposeEvent
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange:)
                                                 name:NSControlTextDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMessage:)
                                                 name:kCHAT_RECEIVE_MESSAGE
                                               object:nil];

    
    

    [self.viewTextEnterBG setBackgroundColor:[NSColor whiteColor]];
    [self.viewSeparateLine setBackgroundColor:[NSColor lightGrayColor]];
    BackgroundedView *backgroundedView = (BackgroundedView*)self.view;
    [backgroundedView setBackgroundColor:[NSColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0]];
    contacts = nil;
    selectedChatRoom = nil;
    
    [self loadData];
}

- (void)loadData {
    if (contacts != NULL) {
        ms_list_free_with_data(contacts, chatTable_free_chatrooms);
    }
    contacts = [self sortChatRooms];
    [self.tableViewContacts reloadData];
}

- (void)updateContentData {
    if (!selectedChatRoom)
        return;
    
    [self clearMessageList];
    messageList = linphone_chat_room_get_history(selectedChatRoom, 0);
    
    int count = ms_list_size(messageList);
//    // also append transient upload messages because they are not in history yet!
//    for (FileTransferDelegate *ftd in [[LinphoneManager instance] fileTransferDelegates]) {
//        if (linphone_chat_room_get_peer_address(linphone_chat_message_get_chat_room(ftd.message)) ==
//            linphone_chat_room_get_peer_address(selectedChatRoom) &&
//            linphone_chat_message_is_outgoing(ftd.message)) {
//            NSLog(@"Appending transient upload message %p", ftd.message);
//            messageList = ms_list_append(messageList, linphone_chat_message_ref(ftd.message));
//        }
//    }
}

- (void)clearMessageList {
    if (messageList) {
        ms_list_free_with_data(messageList, (void (*)(void *))linphone_chat_message_unref);
        messageList = nil;
    }
}

#pragma mark -

static int sorted_history_comparison(LinphoneChatRoom *to_insert, LinphoneChatRoom *elem) {
    LinphoneChatMessage *last_new_message = linphone_chat_room_get_user_data(to_insert);
    LinphoneChatMessage *last_elem_message = linphone_chat_room_get_user_data(elem);
    
    if (last_new_message && last_elem_message) {
        time_t new = linphone_chat_message_get_time(last_new_message);
        time_t old = linphone_chat_message_get_time(last_elem_message);
        if (new < old)
            return 1;
        else if (new > old)
            return -1;
    }
    return 0;
}

- (MSList *)sortChatRooms {
    MSList *sorted = nil;
    MSList *unsorted = linphone_core_get_chat_rooms([LinphoneManager getLc]);
    MSList *iter = unsorted;
    
    while (iter) {
        // store last message in user data
        LinphoneChatRoom *chat_room = iter->data;
        MSList *history = linphone_chat_room_get_history(iter->data, 1);
        LinphoneChatMessage *last_msg = history ? history->data : NULL;
        linphone_chat_room_set_user_data(chat_room, last_msg);
        sorted = ms_list_insert_sorted(sorted, chat_room, (MSCompareFunc)sorted_history_comparison);
        
        iter = iter->next;
    }
    return sorted;
}

static void chatTable_free_chatrooms(void *data) {
    LinphoneChatMessage *lastMsg = linphone_chat_room_get_user_data(data);
    if (lastMsg) {
        linphone_chat_message_unref(lastMsg);
        linphone_chat_room_set_user_data(data, NULL);
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView == self.tableViewContacts) {
        return ms_list_size(contacts);
    }
    
    return ms_list_size(messageList);
}

//- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
//    NSString *identifier = [tableColumn identifier];
//
//    if (tableView == self.tableViewContacts) {
//        if ([identifier isEqualTo:@"Contact"]) {
//            LinphoneChatRoom *chatRoom = (LinphoneChatRoom *)ms_list_nth_data(contacts, (int)row);
//            
//            NSString *displayName = nil;
//
//            if (chatRoom == nil) {
//                NSLog(@"Cannot update chat cell: null chat");
//                return @"";
//            }
//            
//            const LinphoneAddress *linphoneAddress = linphone_chat_room_get_peer_address(chatRoom);
//            
//            if (linphoneAddress == NULL)
//                return @"";
//            
//            // Display name
//            if (displayName == nil) {
//                const char *username = linphone_address_get_username(linphoneAddress);
//                char *address = linphone_address_as_string(linphoneAddress);
//                displayName = [NSString stringWithUTF8String:username ?: address];
//                ms_free(address);
//            }
//            
//            return displayName;
//        }
//    } else if (tableView == self.tableViewContent) {
//        LinphoneChatMessage *chat = ms_list_nth_data(self->messageList, (int)row);
//    }
//    
//    
//
//    return nil;
//}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *identifier = [tableColumn identifier];
    
    if (tableView == self.tableViewContacts) {
        if ([identifier isEqualTo:@"Contact"]) {
            ContactTableCellView *cellView = [tableView makeViewWithIdentifier:@"Contact" owner:self];

            LinphoneChatRoom *chatRoom = (LinphoneChatRoom *)ms_list_nth_data(contacts, (int)row);
            
            NSString *displayName = nil;
            
            if (chatRoom == nil) {
                NSLog(@"Cannot update chat cell: null chat");
                return nil;
            }
            
            const LinphoneAddress *linphoneAddress = linphone_chat_room_get_peer_address(chatRoom);
            
            if (linphoneAddress == NULL)
                return nil;
            
            // Display name
            if (displayName == nil) {
                const char *username = linphone_address_get_username(linphoneAddress);
                char *address = linphone_address_as_string(linphoneAddress);
                displayName = [NSString stringWithUTF8String:username ?: address];
                ms_free(address);
            }
            
            cellView.textField.stringValue = displayName;
            cellView.textFieldInitials.stringValue = [[displayName substringToIndex:1] uppercaseString];
            cellView.textFieldInitials.layer.cornerRadius = cellView.textFieldInitials.frame.size.height/2;
            [cellView.textFieldInitials setDrawsBackground:YES];
            [cellView.textFieldInitials setBackgroundColor:[NSColor clearColor]];
            [cellView.textFieldInitials wantsUpdateLayer];
            
            return cellView;
        }
    } else if (tableView == self.tableViewContent) {
        LinphoneChatMessage *chat = ms_list_nth_data(self->messageList, (int)row);
    }
    
    
    
    return nil;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    if (tableView == self.tableViewContacts) {
        return 64;
    }
    
    return 20;
}

-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    if (tableView == self.tableViewContacts) {
        selectedChatRoom = (LinphoneChatRoom *)ms_list_nth_data(contacts, (int)row);
        
        [self updateContentData];
        [self.tableViewContent reloadData];

        return YES;
    }
    
    return NO;
}

- (void)dealloc {
    if (contacts != nil) {
//        ms_list_free_with_data(contacts, chatTable_free_chatrooms);
    }
}

- (IBAction)onButtonNewChat:(id)sender {
}

- (IBAction)onButtonSend:(id)sender {
    if (selectedChatRoom != NULL) {
        LinphoneCore *lc = [LinphoneManager getLc];
        const LinphoneAddress *addr = linphone_chat_room_get_peer_address(selectedChatRoom);
        LinphoneCallParams *lcallParams = linphone_core_create_default_call_parameters(lc);
        linphone_call_params_enable_audio(lcallParams, false);
        linphone_call_params_enable_realtime_text(lcallParams, true);
        currentCall = linphone_core_invite_address_with_params(lc, addr, lcallParams);
    }
}

#pragma mark - Event Functions

- (void)callUpdateEvent:(NSNotification*)notif {
    LinphoneCall *acall = [[notif.userInfo objectForKey: @"call"] pointerValue];
    LinphoneCallState astate = [[notif.userInfo objectForKey: @"state"] intValue];
    [self callUpdate:acall state:astate];
}

#pragma mark -

- (void)callUpdate:(LinphoneCall *)acall state:(LinphoneCallState)astate {
    LinphoneCore* lc = [LinphoneManager getLc];
    
    switch (astate) {
        case LinphoneCallStreamsRunning: {
        }
             break;
        case LinphoneCallIncomingReceived: {
        }
            break;
        default:
            break;
    }
}

- (void)textComposeEvent:(NSNotification *)notif {
    LinphoneChatRoom *room = [[[notif userInfo] objectForKey:@"room"] pointerValue];
    if (room && room == selectedChatRoom) {
        BOOL composing = linphone_chat_room_is_remote_composing(room);
//        [self setComposingVisible:composing withDelay:0.3];
    }
    
    
    
    
    LinphoneCall *call = linphone_chat_room_get_call(room);
    
    if (call != NULL) {
        const LinphoneCallParams* current = linphone_call_get_current_params(call);
    
        if (linphone_call_params_realtime_text_enabled(current)) {
            char c = (char) linphone_chat_room_get_char(room);
            
            NSLog(@"char: %c", c);
        }
    }
}

- (void)didReceiveMessage:(NSNotification *)aNotification {
    NSDictionary *dict_message = [aNotification object];
    
//    BOOL composing = [[dict_message objectForKey:@"composing"] boolValue];
    NSString *text = [dict_message objectForKey:@"text"];
    NSLog(@"text: %@", text);
    
    if ([text isEqualToString:@"\b"]) {
        self.textViewIncoming.string = [self.textViewIncoming.string substringToIndex:self.textViewIncoming.string.length - 1];
    } else {
        self.textViewIncoming.string = [self.textViewIncoming.string stringByAppendingString:text];
    }
}

- (void)textDidChange:(NSNotification *)aNotification {
    NSTextField *textField = [aNotification object];
    
    if (textField == self.textFieldMessage) {
        NSUInteger lastSimbolIndex = textField.stringValue.length - 1;
        NSString *lastSimbol = [textField.stringValue substringFromIndex:lastSimbolIndex];
        [[ChatService sharedInstance] sendMessagt:lastSimbol];
        
        self.textViewOutgoing.string = [self.textViewOutgoing.string stringByAppendingString:lastSimbol];
    }
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector
{
    NSLog(@"Selector method is (%@)", NSStringFromSelector( commandSelector ) );
    
    if (commandSelector == @selector(insertNewline:)) {
        //Do something against ENTER key
        [[ChatService sharedInstance] sendEnter];
        self.textFieldMessage.stringValue = @"";
        
        self.textViewOutgoing.string = [self.textViewOutgoing.string stringByAppendingString:@"\n\n"];
        
        return YES;
        
    } else if (commandSelector == @selector(deleteForward:)) {
        //Do something against DELETE key
        
        return NO;
        
    } else if (commandSelector == @selector(deleteBackward:)) {
        //Do something against BACKSPACE key
        
        if ([[ChatService sharedInstance] sendBackward] && self.textFieldMessage.stringValue && self.textFieldMessage.stringValue.length) {
            self.textFieldMessage.stringValue = [self.textFieldMessage.stringValue substringToIndex:self.textFieldMessage.stringValue.length - 1];
            self.textViewOutgoing.string = [self.textViewOutgoing.string substringToIndex:self.textViewOutgoing.string.length - 1];
        }
        
        return YES;
        
    } else if (commandSelector == @selector(insertTab:)) {
        //Do something against TAB key

        [[ChatService sharedInstance] sendTab];
        
        self.textViewOutgoing.string = [self.textViewOutgoing.string stringByAppendingString:@"    "];
        
        return YES;
    }
    
    // return YES if the action was handled; otherwise NO
    
    return NO;
}

@end

