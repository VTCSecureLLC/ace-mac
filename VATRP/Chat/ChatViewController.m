//
//  ChatViewController.m
//  ACE
//
//  Created by Ruben Semerjyan on 10/13/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "ChatViewController.h"
#import "ContactTableCellView.h"
#import "ChatItemTableCellView.h"
#import "BackgroundedView.h"
#import "NSImage+Merge.h"
#import "LinphoneManager.h"
#import "CallService.h"
#import "ChatService.h"

@interface ChatViewController () {
    ContactTableCellView *selectedContactCell;
    
    MSList *contacts;
    
    LinphoneCall *currentCall;

    LinphoneChatRoom *selectedChatRoom;
    MSList *messageList;
}

@property (weak) IBOutlet NSTableView *tableViewContacts;
@property (weak) IBOutlet NSTableView *tableViewContent;
@property (weak) IBOutlet BackgroundedView *viewTextEnterBG;
@property (weak) IBOutlet BackgroundedView *viewSeparateLine;
@property (weak) IBOutlet BackgroundedView *viewChatContentBG;
@property (weak) IBOutlet NSTextField *textFieldRemoteUri;
@property (weak) IBOutlet NSTextField *textFieldMessage;
//@property (unsafe_unretained) IBOutlet NSTextView *textViewIncoming;

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
                                             selector:@selector(textReceivedEvent:)
                                                 name:kLinphoneTextReceived
                                               object:nil];    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange:)
                                                 name:NSControlTextDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMessage:)
                                                 name:kCHAT_RECEIVE_MESSAGE
                                               object:nil];

    [self.viewTextEnterBG setBackgroundColor:[NSColor clearColor]];
    [self.viewSeparateLine setBackgroundColor:[NSColor lightGrayColor]];
    [self.viewChatContentBG setBackgroundColor:[NSColor whiteColor]];
    [self.viewChatContentBG setWantsLayer:YES];
    [self.viewChatContentBG.layer setBorderWidth:1.0];
    [self.viewChatContentBG.layer setBorderColor:[NSColor lightGrayColor].CGColor];
    
    BackgroundedView *backgroundedView = (BackgroundedView*)self.view;
    [backgroundedView setBackgroundColor:[NSColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0]];
    contacts = nil;
    selectedChatRoom = nil;
    selectedContactCell = nil;
    
    [self loadData];
    
//    if (contacts && ms_list_size(contacts)) {
////        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:1];
////        [self.tableViewContacts selectRowIndexes:indexSet byExtendingSelection:NO];
//        [self tableView:self.tableViewContacts shouldSelectRow:0];
//    }
    
    [self performSelector:@selector(selectTableCell) withObject:nil afterDelay:0.0];
}

- (CGImageRef)nsImageToCGImageRef:(NSImage*)image;
{
    NSSize imageSize = [image size];
    
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL, imageSize.width, imageSize.height, 8, 0, [[NSColorSpace genericRGBColorSpace] CGColorSpace], kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:bitmapContext flipped:NO]];
    [image drawInRect:NSMakeRect(0, 0, imageSize.width, imageSize.height) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
    [NSGraphicsContext restoreGraphicsState];
    
    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
    CGContextRelease(bitmapContext);
    return cgImage;
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
   
    NSInteger count = ms_list_size(messageList);
    return count;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *identifier = [tableColumn identifier];
    
    if (tableView == self.tableViewContacts) {
        if ([identifier isEqualTo:@"ContactCell"]) {
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
        
        ChatItemTableCellView *cellView = [tableView makeViewWithIdentifier:@"ChatCell" owner:self];
        [cellView setChatMessage:chat];
        
        return cellView;
    }
    
    return nil;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    if (tableView == self.tableViewContacts) {
        return 64;
    } else if (tableView == self.tableViewContent) {
        LinphoneChatMessage *message = ms_list_nth_data(self->messageList, (int)row);
        return [ChatItemTableCellView height:message width:[self.view frame].size.width];
    }
    
    return 20;
}

-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    if (tableView == self.tableViewContacts) {
        if (selectedContactCell) {
            [selectedContactCell.layer setBackgroundColor:[NSColor clearColor].CGColor];
        }
        
        ContactTableCellView *selectedCell = (ContactTableCellView*)[tableView viewAtColumn:0 row:row makeIfNecessary:NO];
        [selectedCell setWantsLayer:YES];
        [selectedCell.layer setBackgroundColor:[NSColor colorWithDeviceRed:43.0/255.0 green:146.0/255.0 blue:245.0/255.0 alpha:1.0].CGColor];
        selectedContactCell = selectedCell;
        
        selectedChatRoom = (LinphoneChatRoom *)ms_list_nth_data(contacts, (int)row);
        
//        linphone_chat_room_delete_history(selectedChatRoom);
        
        [self updateContentData];
        [self.tableViewContent reloadData];

        NSInteger count = ms_list_size(messageList);
        [self.tableViewContent scrollRowToVisible:count-1];
        
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
//    // Push ChatRoom
//    LinphoneChatRoom *room = linphone_core_get_or_create_chat_room([LinphoneManager getLc], [addressField.text UTF8String]);
//    if (room != nil) {
//        ChatRoomViewController *controller = DYNAMIC_CAST(
//                                                          [[PhoneMainView instance] changeCurrentView:[ChatRoomViewController compositeViewDescription] push:TRUE],
//                                                          ChatRoomViewController);
//        if (controller != nil) {
//            LinphoneChatRoom *room =
//            linphone_core_get_or_create_chat_room([LinphoneManager getLc], [addressField.text UTF8String]);
//            [controller setChatRoom:room];
//        }
//    } else {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Invalid address", nil)
//                                                        message:@"Please specify the entire SIP address for the chat"
//                                                       delegate:nil
//                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
//                                              otherButtonTitles:nil];
//        [alert show];
//    }
//    addressField.text = @"";
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

- (void)textReceivedEvent:(NSNotification *)notif {
    LinphoneAddress *from = [[[notif userInfo] objectForKey:@"from_address"] pointerValue];
    LinphoneChatRoom *room = [[notif.userInfo objectForKey:@"room"] pointerValue];
    LinphoneChatMessage *chat = [[notif.userInfo objectForKey:@"message"] pointerValue];
    
    if (from == NULL || chat == NULL || !selectedChatRoom) {
        return;
    }
    
    char *fromStr = linphone_address_as_string_uri_only(from);
    const LinphoneAddress *cr_from = linphone_chat_room_get_peer_address(selectedChatRoom);
    char *cr_from_string = linphone_address_as_string_uri_only(cr_from);
    
    if (fromStr && cr_from_string) {
        
        if (strcasecmp(cr_from_string, fromStr) == 0) {
            linphone_chat_room_mark_as_read(room);
            
            [self updateContentData];
            [self.tableViewContent reloadData];
            
            NSInteger count = ms_list_size(messageList);
            [self.tableViewContent scrollRowToVisible:count-1];

//            [tableController addChatEntry:chat];
//            [tableController scrollToLastUnread:TRUE];
        }
    }
    ms_free(fromStr);
    ms_free(cr_from_string);
}

- (void)didReceiveMessage:(NSNotification *)aNotification {
    NSDictionary *dict_message = [aNotification object];
    
//    BOOL composing = [[dict_message objectForKey:@"composing"] boolValue];
    NSString *text = [dict_message objectForKey:@"text"];
    NSLog(@"text: %@", text);
    
//    if ([text isEqualToString:@"\b"]) {
//        self.textViewIncoming.string = [self.textViewIncoming.string substringToIndex:self.textViewIncoming.string.length - 1];
//    } else {
//        self.textViewIncoming.string = [self.textViewIncoming.string stringByAppendingString:text];
//    }
    
    
    
    LinphoneChatRoom *room = [[[aNotification userInfo] objectForKey:@"room"] pointerValue];
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

- (void)textDidChange:(NSNotification *)aNotification {
    NSTextField *textField = [aNotification object];
    
    LinphoneCall *currentCall = [[CallService sharedInstance] getCurrentCall];
    
    if (currentCall) {
        if (textField == self.textFieldMessage) {
            NSUInteger lastSimbolIndex = textField.stringValue.length - 1;
            NSString *lastSimbol = [textField.stringValue substringFromIndex:lastSimbolIndex];
            [[ChatService sharedInstance] sendMessagt:lastSimbol];
        }
    }
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector
{
    NSLog(@"Selector method is (%@)", NSStringFromSelector( commandSelector ) );
    
    if (commandSelector == @selector(insertNewline:)) {
        //Do something against ENTER key
        
        LinphoneCall *currentCall = [[CallService sharedInstance] getCurrentCall];
        
        if (currentCall) {
            [[ChatService sharedInstance] sendEnter];
            
            //        self.textViewOutgoing.string = [self.textViewOutgoing.string stringByAppendingString:@"\n\n"];
        } else {
            if ([self sendMessage:self.textFieldMessage.stringValue withExterlBodyUrl:nil withInternalURL:nil]) {
//                scrollOnGrowingEnabled = FALSE;
//                [messageField setText:@""];
//                scrollOnGrowingEnabled = TRUE;
//                [self onMessageChange:nil];
            }
        }
        
        self.textFieldMessage.stringValue = @"";
        
        return YES;
        
    } else if (commandSelector == @selector(deleteForward:)) {
        //Do something against DELETE key
        
        return NO;
        
    } else if (commandSelector == @selector(deleteBackward:)) {
        //Do something against BACKSPACE key
        
        if ([[ChatService sharedInstance] sendBackward] && self.textFieldMessage.stringValue && self.textFieldMessage.stringValue.length) {
            self.textFieldMessage.stringValue = [self.textFieldMessage.stringValue substringToIndex:self.textFieldMessage.stringValue.length - 1];
//            self.textViewOutgoing.string = [self.textViewOutgoing.string substringToIndex:self.textViewOutgoing.string.length - 1];
        }
        
        return YES;
        
    } else if (commandSelector == @selector(insertTab:)) {
        //Do something against TAB key

        [[ChatService sharedInstance] sendTab];
        
//        self.textViewOutgoing.string = [self.textViewOutgoing.string stringByAppendingString:@"    "];
        
        return YES;
    }
    
    // return YES if the action was handled; otherwise NO
    
    return NO;
}

- (BOOL)sendMessage:(NSString *)message withExterlBodyUrl:(NSURL *)externalUrl withInternalURL:(NSURL *)internalUrl {
    if (selectedChatRoom == NULL) {
        NSLog(@"Cannot send message: No chatroom");
        return FALSE;
    }
    
    LinphoneChatMessage *msg = linphone_chat_room_create_message(selectedChatRoom, [message UTF8String]);
    if (externalUrl) {
        linphone_chat_message_set_external_body_url(msg, [[externalUrl absoluteString] UTF8String]);
    }
    
    linphone_chat_room_send_message2(selectedChatRoom, msg, message_status, (__bridge void *)(self));
    
    if (internalUrl) {
        // internal url is saved in the appdata for display and later save
        [LinphoneManager setValueInMessageAppData:[internalUrl absoluteString] forKey:@"localimage" inMessage:msg];
    }


    [self updateContentData];
    [self.tableViewContent reloadData];

    NSInteger count = ms_list_size(messageList);
    [self.tableViewContent scrollRowToVisible:count-1];

//    [tableController addChatEntry:msg];
//    [tableController scrollToBottom:true];
    
    return TRUE;
}

static void message_status(LinphoneChatMessage *msg, LinphoneChatMessageState state, void *ud) {
    const char *text = (linphone_chat_message_get_file_transfer_information(msg) != NULL)
    ? "photo transfer"
    : linphone_chat_message_get_text(msg);
    NSLog(@"Delivery status for [%s] is [%s]", text, linphone_chat_message_state_to_string(state));
    ChatViewController *thiz = (__bridge ChatViewController *)ud;
    
    
//    [thiz.tableController updateChatEntry:msg];
}

- (void) selectTableCell {
    if (contacts && ms_list_size(contacts)) {
        [self tableView:self.tableViewContacts shouldSelectRow:0];
    }
}

@end
