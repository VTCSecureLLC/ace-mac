//
//  ChatViewController.m
//  ACE
//
//  Created by Ruben Semerjyan on 10/13/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "ChatViewController.h"
#import "ContactPictureManager.h"
#import "ChatContactTableCellView.h"
#import "ChatItemTableCellView.h"
#import "BackgroundedView.h"
#import "NewMessageCellView.h"
#import "NSImage+Merge.h"
#import "LinphoneManager.h"
#import "CallService.h"
#import "ChatService.h"

@interface ChatViewController () <NSTextFieldDelegate>//,NSTableViewDelegate, NSTableViewDataSource>
{
    ChatContactTableCellView *selectedContactCell;
    
    MSList *contacts;
    
    LinphoneCall *currentCall;
    
    LinphoneChatRoom *selectedChatRoom;
    MSList *messageList;
    
    BOOL stateNewMessage;
    
    LinphoneChatMessage *incomingChatMessage;
    ChatItemTableCellView *incomingCellView;
    LinphoneChatMessage *outgoingChatMessage;
    CGFloat incomingTextLinesCount;
    
    bool observersAdded;
    bool viewControlsInitialized;
}


@property (weak) IBOutlet NSScrollView *scrollViewContacts;
@property (weak) IBOutlet NSTableView *tableViewContacts;
@property (weak) IBOutlet NSScrollView *scrollViewContent;
@property (weak) IBOutlet NSTableView *tableViewContent;
@property (weak) IBOutlet BackgroundedView *viewTextEnterBG;
@property (weak) IBOutlet BackgroundedView *viewSeparateLine;
@property (weak) IBOutlet BackgroundedView *viewChatContentBG;
@property (weak) IBOutlet NSTextField *textFieldRemoteUri;
@property (weak) IBOutlet NSTextField *textFieldMessage;
@property (weak) IBOutlet NSTextField *textFieldNoRecipient;
@property (weak) IBOutlet NSScrollView *scrollViewIncoming;
@property (unsafe_unretained) IBOutlet NSTextView *textViewIncoming;
@property (weak) IBOutlet NSScrollView *scrollViewOutgoing;
@property (unsafe_unretained) IBOutlet NSTextView *textViewOutgoing;


- (IBAction)onButtonNewChat:(id)sender;
- (IBAction)onButtonSend:(id)sender;


@end

@implementation ChatViewController

@synthesize selectUser;

-(id) init
{
    self = [super initWithNibName:@"ChatViewController" bundle:nil];
    if (self)
    {
        // init
    }
    return self;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    if (viewControlsInitialized)
    {
        return;
    }
    viewControlsInitialized = true;
    // Do view setup here.
    if (!observersAdded)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(callUpdateEvent:)
                                                     name:kLinphoneCallUpdate
                                                   object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(textComposeEvent:)
//                                                     name:kLinphoneTextComposeEvent
//                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textReceivedEvent:)
                                                     name:kLinphoneTextReceived
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveMessage:)
                                                     name:kCHAT_RECEIVE_MESSAGE
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contactInfoFillDone:)
                                                     name:@"contactInfoFilled"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contactEditDone:)
                                                     name:@"contactInfoEditDone"
                                                   object:nil];
        observersAdded = true;
    }
    
    [self.viewTextEnterBG setBackgroundColor:[NSColor clearColor]];
    [self.viewSeparateLine setBackgroundColor:[NSColor lightGrayColor]];
    [self.viewChatContentBG setBackgroundColor:[NSColor whiteColor]];
    [self.viewChatContentBG setWantsLayer:YES];
    [self.viewChatContentBG.layer setBorderWidth:1.0];
    [self.viewChatContentBG.layer setBorderColor:[NSColor lightGrayColor].CGColor];
    [self.textFieldMessage setDelegate:self];

    BackgroundedView *backgroundedView = (BackgroundedView*)self.view;
    [backgroundedView setBackgroundColor:[NSColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0]];
    contacts = nil;
    selectedChatRoom = nil;
    selectedContactCell = nil;
    incomingChatMessage = nil;
    outgoingChatMessage = nil;
    incomingCellView = nil;
    incomingTextLinesCount = 1;
    stateNewMessage = NO;
}

- (void) initializeData
{
    
    self.scrollViewIncoming.hidden = YES;
    self.scrollViewOutgoing.hidden = YES;
    
    [self loadData];

    if (self.selectUser) {
        LinphoneCore *lc = [LinphoneManager getLc];
        LinphoneProxyConfig *cfg = NULL;
        linphone_core_get_default_proxy(lc,&cfg);
        
        if (!cfg) {
            self.selectUser = nil;
            return;
        }
        
        const char *domain = linphone_proxy_config_get_domain(cfg);
        
        NSString *sip_url = [NSString stringWithFormat:@"sip:%@@%s", self.selectUser, domain];
        LinphoneAddress *addr = linphone_address_new([sip_url UTF8String]);
        
        if (!addr) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Invalid address. Please specify the entire SIP address for the chat"];
            [alert runModal];
        } else {
            selectedChatRoom = linphone_core_get_chat_room(lc, addr);
        }
        
        if (selectedChatRoom) {
            int index = ms_list_index(contacts, selectedChatRoom);
            
            if (index == -1) {
                [self loadData];
                index = ms_list_index(contacts, selectedChatRoom);
            }
            
            if (index >= 0 ) {
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
                [self.tableViewContacts selectRowIndexes:indexSet byExtendingSelection:NO];
//                [self performSelector:@selector(selectTableCell:) withObject:[NSNumber numberWithInt:index] afterDelay:0.0];
            }
        }
        
        self.selectUser = nil;
        return;
        
        int count = ms_list_size(contacts);
        
        for (int i = 0; i < count; i++) {
            LinphoneChatRoom *chatRoom = (LinphoneChatRoom *)ms_list_nth_data(contacts,  i);
            
            if (chatRoom == nil) {
                NSLog(@"Cannot update chat cell: null chat");
                continue;
            }
            
            const LinphoneAddress *linphoneAddress = linphone_chat_room_get_peer_address(chatRoom);
            
            if (linphoneAddress == NULL)
                continue;
            
            const char *username_char = linphone_address_get_username(linphoneAddress);
            
            if (username_char) {
                NSString *username = [NSString stringWithUTF8String:username_char];
                
                if (username && [username isEqualToString:self.selectUser]) {
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:i];
                    [self.tableViewContacts selectRowIndexes:indexSet byExtendingSelection:NO];
//                    [self performSelector:@selector(selectTableCell:) withObject:[NSNumber numberWithInt:i] afterDelay:0.0];
                    
                    break;
                }
            }
        }
        
        self.selectUser = nil;
    }
    // do not forace a selection it is not handled during windows setup - the row selected method is not called.
    //    and having the first index selected manually leaves the table thinking that it already has a selection, so it still
    // does not call shouldSelectRow if the first row is selected. in the event that the user has only one contact, they will never see the history.

}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)loadData {
    if (contacts != NULL) {
        ms_list_free_with_data(contacts, chatTable_free_chatrooms);
    }
    
    contacts = [self sortChatRooms];
    [self.tableViewContacts reloadData];
}

- (void)updateContentData {
    [self clearMessageList];
    
    if (!selectedChatRoom)
        return;
    
    messageList = linphone_chat_room_get_history(selectedChatRoom, 0);
    
//    int count = ms_list_size(messageList);
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
    const MSList *unsorted = linphone_core_get_chat_rooms([LinphoneManager getLc]);
    const MSList *iter = unsorted;
    
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
        int count = ms_list_size(contacts);
        
        if (stateNewMessage) {
            return count + 1;
        }
        
        return count;
    }
    
    NSInteger count = ms_list_size(messageList);
    return count;
}
- (IBAction)onNewClick:(NSButton *)sender
{
    stateNewMessage = YES;
    
    [self.tableViewContacts deselectAll:nil];
    if (selectedContactCell) [selectedContactCell.layer setBackgroundColor:[NSColor clearColor].CGColor];
    selectedChatRoom = NULL;
    [self updateContentData];
    
    [self selectNewMessage];
    
    [self.tableViewContacts reloadData];
    [self.tableViewContent reloadData];
    
    [self.tableViewContacts scrollRowToVisible:0];
}

#if defined __MAC_10_9 || defined __MAC_10_8
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
#else
- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
#endif
    NSString *identifier = [tableColumn identifier];
    
    if (tableView == self.tableViewContacts) {
        if ([identifier isEqualTo:@"ContactCell"]) {
            ChatContactTableCellView *cellView = [tableView makeViewWithIdentifier:@"Contact" owner:self];
            
            if (stateNewMessage && row == 0) {
                [cellView.textFieldUnredMessageCount setHidden:YES];
                
                cellView.textField.stringValue = @"New Message";
                cellView.textFieldInitials.stringValue = @"N";
                cellView.textFieldLastMessage.stringValue = @"";
                [cellView setWantsLayer:YES];
                [cellView.layer setBackgroundColor:[NSColor colorWithDeviceRed:43.0/255.0 green:146.0/255.0 blue:245.0/255.0 alpha:1.0].CGColor];
                selectedContactCell = cellView;
                
                return cellView;
            }
            
            int index = (int)row;
            
            if (stateNewMessage) index--;
            
            LinphoneChatRoom *chatRoom = (LinphoneChatRoom *)ms_list_nth_data(contacts,  index);
            
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

            LinphoneFriendList *friendList = linphone_core_get_default_friend_list([LinphoneManager getLc]);
            LinphoneFriend *linphoneFriend = linphone_friend_list_find_friend_by_address(friendList, linphoneAddress);
            
            if (linphoneFriend) {
                const char *name = linphone_friend_get_name(linphoneFriend);
                displayName = [NSString stringWithUTF8String:name];
                
                const char *friendName = linphone_friend_get_name(linphoneFriend);
                const char *addressString = linphone_address_as_string_uri_only(linphoneAddress);

                NSImage *contactImage = [[NSImage alloc]initWithContentsOfFile:
                                         [[ContactPictureManager sharedInstance] imagePathByName:[NSString stringWithUTF8String:friendName]
                                                                                       andSipURI:[NSString stringWithUTF8String:addressString]]];
                if (contactImage) {
                    [cellView.imageView setImage:contactImage];
                } else {
                    [cellView.imageView setImage:[NSImage imageNamed:@"male"]];
                }
                
                cellView.imageView.hidden = NO;
                [cellView.imageView setWantsLayer:YES];
                cellView.imageView.layer.cornerRadius = cellView.imageView.frame.size.height/2.0;
                cellView.imageView.layer.masksToBounds = YES;

                cellView.textFieldInitials.hidden = YES;
            } else {
                cellView.textFieldInitials.stringValue = [[displayName substringToIndex:1] uppercaseString];
                cellView.textFieldInitials.layer.cornerRadius = cellView.textFieldInitials.frame.size.height/2;
                [cellView.textFieldInitials setDrawsBackground:YES];
                [cellView.textFieldInitials setBackgroundColor:[NSColor clearColor]];
                [cellView.textFieldInitials wantsUpdateLayer];
                
                cellView.imageView.hidden = YES;
                cellView.textFieldInitials.hidden = NO;
            }

            cellView.textField.stringValue = displayName;
            
            if (selectedChatRoom && selectedChatRoom == chatRoom) {
                if (selectedContactCell) {
                    [selectedContactCell.layer setBackgroundColor:[NSColor clearColor].CGColor];
                }
                
                [cellView setWantsLayer:YES];
                [cellView.layer setBackgroundColor:[NSColor colorWithDeviceRed:43.0/255.0 green:146.0/255.0 blue:245.0/255.0 alpha:1.0].CGColor];
                selectedContactCell = cellView;
            }
            
            LinphoneChatMessage *last_message = linphone_chat_room_get_user_data(chatRoom);
            
            if (last_message) {
                const char *text = linphone_chat_message_get_text(last_message);
                NSString *lastMessageStr = [NSString stringWithUTF8String:text];
                
                if ([lastMessageStr hasPrefix:CALL_DECLINE_PREFIX]) {
                    lastMessageStr = [lastMessageStr substringFromIndex:CALL_DECLINE_PREFIX.length];
                    lastMessageStr = [@"Call declined with message: %@" stringByAppendingString:lastMessageStr];
                }

                [cellView.textFieldLastMessage setStringValue:lastMessageStr];
                
//                time_t new = linphone_chat_message_get_time(last_message);
                
                
            }
            
            int unreadMessageCount = linphone_chat_room_get_unread_messages_count(chatRoom);
            
            if (unreadMessageCount) {
                [cellView.textFieldUnredMessageCount setHidden:NO];
                [cellView.textFieldUnredMessageCount setWantsLayer:YES];
                [cellView.textFieldUnredMessageCount.layer setBackgroundColor:[NSColor redColor].CGColor];
                [cellView.textFieldUnredMessageCount.layer setCornerRadius:cellView.textFieldUnredMessageCount.frame.size.height/2.0];
                cellView.textFieldUnredMessageCount.intValue = unreadMessageCount > 99 ? 99 : unreadMessageCount;
            } else {
                [cellView.textFieldUnredMessageCount setHidden:YES];
            }
            
            return cellView;
        }
    } else if (tableView == self.tableViewContent) {
        //        LinphoneChatMessage *msg = linphone_chat_room_create_message(selectedChatRoom, [message UTF8String]);
        //        const char *text = linphone_chat_message_get_text(chat);
        
        
        
        LinphoneChatMessage *chat = ms_list_nth_data(self->messageList, (int)row);
        
        ChatItemTableCellView *cellView = [tableView makeViewWithIdentifier:@"ChatCell" owner:self];
        [cellView setChatMessage:chat];
        
        if (!linphone_chat_message_is_outgoing(chat) && incomingChatMessage) {
            incomingCellView = cellView;
        }
        
        
        return cellView;
    }
    
    return nil;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    if (tableView == self.tableViewContacts) {
        return 64;
    } else if (tableView == self.tableViewContent) {
        LinphoneChatMessage *message = ms_list_nth_data(self->messageList, (int)row);
        if (message) {
            CGFloat cellHeight = [ChatItemTableCellView height:message width:[self.view frame].size.width];
            return cellHeight;
        }
        
        return 1;
    }
    
    return 20;
}

-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    if (tableView == self.tableViewContacts) {
        int index = (int)row;
        
        if (stateNewMessage) {
            if (row == 0) {
                [self.textFieldNoRecipient becomeFirstResponder];
                
                return YES;
            }
            
            index--;
        }
        
        if (selectedContactCell) {
            [selectedContactCell.layer setBackgroundColor:[NSColor clearColor].CGColor];
        }
        
        ChatContactTableCellView *selectedCell = (ChatContactTableCellView*)[tableView viewAtColumn:0 row:index makeIfNecessary:NO];
        [selectedCell setWantsLayer:YES];
        [selectedCell.layer setBackgroundColor:[NSColor colorWithDeviceRed:43.0/255.0 green:146.0/255.0 blue:245.0/255.0 alpha:1.0].CGColor];
        selectedContactCell = selectedCell;
        
        selectedChatRoom = (LinphoneChatRoom *)ms_list_nth_data(contacts, (int)index);
        if (selectedChatRoom != nil)
        {
            linphone_chat_room_mark_as_read(selectedChatRoom);
        }
        //        linphone_chat_room_delete_history(selectedChatRoom);
        //        linphone_chat_room_unref(selectedChatRoom);
        //        contacts = ms_list_remove(contacts, selectedChatRoom);
        
        [self updateContentData];
        [self.tableViewContent reloadData];
        [self.tableViewContacts reloadData];
        
        
        NSInteger count = ms_list_size(messageList);
        [self.tableViewContent scrollRowToVisible:count-1];
        if (selectedChatRoom != nil)
        {
            const LinphoneAddress *addr = linphone_chat_room_get_peer_address(selectedChatRoom);
            const char* lUserName = linphone_address_get_username(addr);
        
            if (lUserName)
                self.textFieldRemoteUri.stringValue = [NSString stringWithUTF8String:lUserName];
        
        [self.textFieldNoRecipient setHidden:YES];
        [self.textFieldNoRecipient resignFirstResponder];
        [self.textFieldRemoteUri setHidden:NO];
        
        stateNewMessage = NO;
        
        [self.textFieldMessage becomeFirstResponder];
        
        self.scrollViewIncoming.hidden = YES;
        self.scrollViewOutgoing.hidden = YES;
        self.scrollViewContent.hidden = NO;
        
        LinphoneCall *currentCall_ = [[CallService sharedInstance] getCurrentCall];
        
        if (currentCall_ && lUserName) {
            NSString *remote_address;
            const LinphoneAddress* addr = linphone_call_get_remote_address(currentCall_);
            if (addr != NULL) {
                BOOL useLinphoneAddress = true;
                // contact name
                if(useLinphoneAddress) {
                    const char* remote_user_name = linphone_address_get_username(addr);
                    if(remote_user_name)
                        remote_address = [NSString stringWithUTF8String:remote_user_name];
                }
            }
            
            // Set Address
            if (remote_address == nil) {
                remote_address = @"Unknown";
            }
            
            NSString *displayName = [NSString stringWithUTF8String:lUserName];
            
            if (remote_address && remote_address == displayName) {
                //                self.scrollViewIncoming.hidden = NO;
                //                self.scrollViewOutgoing.hidden = NO;
                //                self.scrollViewContent.hidden = YES;
            }
        }
        }
        return YES;
    }
    
    return NO;
}

-(void) mouseDown:(NSEvent *)theEvent {
    //    CGPoint location = theEvent.locationInWindow;
    //
    //    if (CGRectContainsPoint(self.viewNewMessage.frame, location)) {
    //        [self selectNewMessage];
    //        [self.tableViewContacts reloadData];
    //        [self.tableViewContent reloadData];
    //    }
}

- (IBAction)onButtonSend:(id)sender {
    if (selectedChatRoom != NULL) {
//        LinphoneCore *lc = [LinphoneManager getLc];
//        const LinphoneAddress *addr = linphone_chat_room_get_peer_address(selectedChatRoom);
//        LinphoneCallParams *lcallParams = linphone_core_create_default_call_parameters(lc);
//        linphone_call_params_enable_audio(lcallParams, false);
//        linphone_call_params_enable_realtime_text(lcallParams, true);
//        currentCall = linphone_core_invite_address_with_params(lc, addr, lcallParams);
    }
}

#pragma mark - Event Functions

- (void)callUpdateEvent:(NSNotification*)notif {
    LinphoneCall *acall = [[notif.userInfo objectForKey: @"call"] pointerValue];
    LinphoneCallState astate = [[notif.userInfo objectForKey: @"state"] intValue];
    [self callUpdate:acall state:astate];
    NSLog(@"*** --> RTT.callUpdateEvent called");

}

#pragma mark -

- (void)callUpdate:(LinphoneCall *)acall state:(LinphoneCallState)astate {
//    LinphoneCore* lc = [LinphoneManager getLc];
    
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
    NSLog(@"*** --> ChatViewController.textComposeEvent called");

    LinphoneChatRoom *room = [[[notif userInfo] objectForKey:@"room"] pointerValue];
    if (room && room == selectedChatRoom) {
        BOOL composing = linphone_chat_room_is_remote_composing(room);
        //        [self setComposingVisible:composing withDelay:0.3];
    }
    
    LinphoneCall *call = linphone_chat_room_get_call(room);
    
    if (call != NULL) {
        const LinphoneCallParams* current = linphone_call_get_current_params(call);
        
        if (linphone_call_params_realtime_text_enabled(current)) {
            uint32_t rttCode = linphone_chat_room_get_char(room);
            NSString *text = [NSString stringWithFormat:@"%c", rttCode];
            
            if ([text isEqualToString:@"\n\r"] || [text isEqualToString:@"\n"]) {
                incomingChatMessage = nil;
                incomingCellView = nil;
            } else {
                if (incomingChatMessage) {
                    const char *text_char = linphone_chat_message_get_text(incomingChatMessage);
                    ms_list_remove(self->messageList, incomingChatMessage);
                    if (text_char)
                    {
                        // ToDo: Liz E. - there was a crash on this char_text reported as being ""
                        NSString *str_msg = [NSString stringWithUTF8String:text_char];
                        if ([text isEqualToString:@"\b"]) {
                            if (str_msg && str_msg.length > 0) {
                                str_msg = [str_msg substringToIndex:str_msg.length - 1];
                                self.textViewIncoming.string = str_msg;
                            }
                        } else  {
                            str_msg = [str_msg stringByAppendingString:text];
                            self.textViewIncoming.string = [self.textViewIncoming.string stringByAppendingString:text];
                        }
                    
                        incomingChatMessage = linphone_chat_room_create_message(selectedChatRoom, [str_msg UTF8String]);
                    }
                    else
                    {
                        bool test = true;
                        test = false;
                    }
                } else {
                    incomingChatMessage = linphone_chat_room_create_message(selectedChatRoom, [text UTF8String]);
                }
                
                ms_list_append(self->messageList, incomingChatMessage);
                
                if (incomingCellView) {
                    CGFloat lineCount = [ChatItemTableCellView height:incomingChatMessage width:[self.view frame].size.width];
                    if (incomingTextLinesCount == lineCount) {
                        [incomingCellView setChatMessage:incomingChatMessage];
                    } else {
                        [self.tableViewContent reloadData];
                        incomingTextLinesCount = lineCount;
                    }
                } else {
                    [self.tableViewContent reloadData];
                }
                
                NSInteger count = ms_list_size(messageList);
                [self.tableViewContent scrollRowToVisible:count-1];
            }
        }
    }
}

- (void)contactInfoFillDone:(NSNotification*)notif {
    [self.tableViewContacts reloadData];
}
    
- (void)contactEditDone:(NSNotification*)notif {
    [self.tableViewContacts reloadData];
}

- (void)textReceivedEvent:(NSNotification *)notif {
    NSLog(@"*** --> ChatViewController.textRecievedEvent called");

    LinphoneAddress *from = [[[notif userInfo] objectForKey:@"from_address"] pointerValue];
    LinphoneChatRoom *room = [[notif.userInfo objectForKey:@"room"] pointerValue];
    LinphoneChatMessage *chat = [[notif.userInfo objectForKey:@"message"] pointerValue];
    const char *text = linphone_chat_message_get_text(chat);

    if (from == NULL || chat == NULL) {
        return;
    }
    
    char *fromStr = linphone_address_as_string_uri_only(from);
    
    if (selectedChatRoom) {
        const LinphoneAddress *cr_from = linphone_chat_room_get_peer_address(selectedChatRoom);
        char *cr_from_string = linphone_address_as_string_uri_only(cr_from);
        
        if (fromStr && cr_from_string) {
            if (strcasecmp(cr_from_string, fromStr) == 0) {
                linphone_chat_room_mark_as_read(room);
                
                [self updateContentData];
                [self.tableViewContent reloadData];
                
                NSInteger count = ms_list_size(messageList);
                [self.tableViewContent scrollRowToVisible:count-1];
            } else {
                [self loadData];
            }
        }
        
        ms_free(cr_from_string);
    } else {
        [self loadData];
    }
    
    ms_free(fromStr);
}

- (void)didReceiveMessage:(NSNotification *)aNotification {
    NSLog(@"*** --> ChatViewController.didReceiveMessage called");

    NSDictionary *dict_message = [aNotification object];
    
    //    BOOL composing = [[dict_message objectForKey:@"composing"] boolValue];
    NSString *text = [dict_message objectForKey:@"text"];
    NSLog(@"text: %@", text);
    
    LinphoneChatRoom *room = [[[aNotification userInfo] objectForKey:@"room"] pointerValue];
    if (room && room == selectedChatRoom) {
        //        BOOL composing = linphone_chat_room_is_remote_composing(room);
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

- (void)controlTextDidChange:(NSNotification *)aNotification {
    return;
    NSTextField *textField = [aNotification object];
    
    LinphoneCall *currentCall_ = [[CallService sharedInstance] getCurrentCall];
    
    if (currentCall_) {
        NSString *remote_address;
        const LinphoneAddress* addr = linphone_call_get_remote_address(currentCall_);
        if (addr != NULL) {
            BOOL useLinphoneAddress = true;
            // contact name
            if(useLinphoneAddress) {
                const char* lUserName = linphone_address_get_username(addr);
                if(lUserName)
                    remote_address = [NSString stringWithUTF8String:lUserName];
            }
        }
        
        // Set Address
        if (remote_address == nil) {
            remote_address = @"Unknown";
        }
        
        NSString *displayName = nil;
        const LinphoneAddress *linphoneAddress = linphone_chat_room_get_peer_address(selectedChatRoom);
        
        if (linphoneAddress == NULL)
            return;
        
        // Display name
        if (displayName == nil) {
            const char *username = linphone_address_get_username(linphoneAddress);
            char *address = linphone_address_as_string(linphoneAddress);
            displayName = [NSString stringWithUTF8String:username ?: address];
            ms_free(address);
        }
        
        if (remote_address && remote_address == displayName) {
            if (textField == self.textFieldMessage) {
                NSUInteger lastSimbolIndex = textField.stringValue.length - 1;
                NSString *lastSimbol = [textField.stringValue substringFromIndex:lastSimbolIndex];
                self.textViewOutgoing.string = [self.textViewOutgoing.string stringByAppendingString:lastSimbol];
                [[ChatService sharedInstance] sendMessagt:lastSimbol];
            }
        }
    }
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(insertNewline:)) {
        return [self eventENTER];
    } else if (commandSelector == @selector(deleteForward:)) {
        //Do something against DELETE key
        return NO;
    } else if (commandSelector == @selector(deleteBackward:)) {
        //Do something against BACKSPACE key
        
        return [self eventBackward];
    } else if (commandSelector == @selector(insertTab:)) {
        //Do something against TAB key
        return [self eventTab];
    }
    
    // return YES if the action was handled; otherwise NO
    
    return NO;
}

- (BOOL) eventENTER {
    //Do something against ENTER key
    
    LinphoneCall *currentCall_ = [[CallService sharedInstance] getCurrentCall];
    
    if (currentCall_ && outgoingChatMessage) {
        [[ChatService sharedInstance] sendEnter:outgoingChatMessage ChatRoom:selectedChatRoom];
        
        
        outgoingChatMessage = linphone_chat_room_create_message_2(selectedChatRoom, [self.textFieldMessage.stringValue UTF8String], NULL, LinphoneChatMessageStateDelivered, 0, YES, NO);
        ms_list_append(self->messageList, outgoingChatMessage);
        [self.tableViewContent reloadData];
        
        NSInteger count = ms_list_size(messageList);
        [self.tableViewContent scrollRowToVisible:count-1];
    } else {
        if (!selectedChatRoom) {
            LinphoneCore *lc = [LinphoneManager getLc];
            LinphoneProxyConfig *cfg = NULL;
            linphone_core_get_default_proxy(lc,&cfg);
            
            if (!cfg)
                return YES;
            
            const char *domain = linphone_proxy_config_get_domain(cfg);
            
            NSString *sip_url = [NSString stringWithFormat:@"sip:%@@%s", self.textFieldNoRecipient.stringValue, domain];
            LinphoneAddress *addr = linphone_address_new([sip_url UTF8String]);
            
            if (!addr) {
                NSAlert *alert = [[NSAlert alloc] init];
                [alert addButtonWithTitle:@"OK"];
                [alert setMessageText:@"Invalid address. Please specify the entire SIP address for the chat"];
                [alert runModal];
            } else {
                selectedChatRoom = linphone_core_get_chat_room(lc, addr);
                
                if (!selectedChatRoom) {
                    NSAlert *alert = [[NSAlert alloc] init];
                    [alert addButtonWithTitle:@"OK"];
                    [alert setMessageText:@"Invalid address. Please specify the entire SIP address for the chat"];
                    [alert runModal];
                } else {
                    if (selectedContactCell) {
                        [selectedContactCell.layer setBackgroundColor:[NSColor clearColor].CGColor];
                    }
                    
                    selectedContactCell = nil;
                    
                    self.textFieldRemoteUri.stringValue = self.textFieldNoRecipient.stringValue;
                }
            }
        }
        
        if ([self.textFieldMessage.stringValue stringByReplacingOccurrencesOfString:@" " withString:@""].length &&
            [self sendMessage:self.textFieldMessage.stringValue withExterlBodyUrl:nil withInternalURL:nil LinphoneChatRoom:selectedChatRoom]) {
            [[self.scrollViewContacts animator] setFrame:CGRectMake(self.scrollViewContacts.frame.origin.x, self.scrollViewContacts.frame.origin.y, 243, 450)];
            [self loadData];
            [self updateContentData];
            [self.tableViewContent reloadData];
            [self.tableViewContacts reloadData];
            
            stateNewMessage = NO;
            [self.textFieldNoRecipient setHidden:YES];
            [self.textFieldNoRecipient resignFirstResponder];
            [self.textFieldRemoteUri setHidden:NO];
        }
    }
    
    self.textFieldMessage.stringValue = @"";
    
    return YES;
}

- (BOOL) eventBackward {
    if ([[ChatService sharedInstance] sendBackward] && self.textFieldMessage.stringValue && self.textFieldMessage.stringValue.length) {
        self.textFieldMessage.stringValue = [self.textFieldMessage.stringValue substringToIndex:self.textFieldMessage.stringValue.length - 1];
        
        if (self.textViewOutgoing.string && self.textViewOutgoing.string.length) {
            self.textViewOutgoing.string = [self.textViewOutgoing.string substringToIndex:self.textViewOutgoing.string.length - 1];
        }
    }
    
    return YES;
}

- (BOOL) eventTab {
    [[ChatService sharedInstance] sendTab];
    self.textViewOutgoing.string = [self.textViewOutgoing.string stringByAppendingString:@"    "];
    
    return YES;
}

- (BOOL)sendMessage:(NSString *)message withExterlBodyUrl:(NSURL *)externalUrl withInternalURL:(NSURL *)internalUrl LinphoneChatRoom:(LinphoneChatRoom*)room {
    NSLog(@"*** --> ChatViewController.sendMessage called");

    if (room == NULL) {
        NSLog(@"Cannot send message: No chatroom");
        return FALSE;
    }
    
    LinphoneChatMessage *msg = linphone_chat_room_create_message(room, [message UTF8String]);
    if (externalUrl) {
        linphone_chat_message_set_external_body_url(msg, [[externalUrl absoluteString] UTF8String]);
    }
    
    linphone_chat_room_send_message2(room, msg, message_status, (__bridge void *)(self));
    
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

- (void) selectTableCell:(NSNumber*)rowNumber {
    int row = [rowNumber intValue];
    if (contacts && ms_list_size(contacts)) {
        [self tableView:self.tableViewContacts shouldSelectRow:row];
    }
}

- (void) selectNewMessage {
    stateNewMessage = YES;
    selectedChatRoom = NULL;
    [self updateContentData];
    
    [self.textFieldNoRecipient setHidden:NO];
    [self.textFieldNoRecipient becomeFirstResponder];
    [self.textFieldRemoteUri setHidden:YES];
    
    if (selectedContactCell) {
        [selectedContactCell.layer setBackgroundColor:[NSColor clearColor].CGColor];
    }
}

//- (void)dealloc {
////        [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath: kLinphoneCallUpdate];
////        [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:kLinphoneTextComposeEvent];
////        [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:kLinphoneTextReceived];
////        [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:NSControlTextDidChangeNotification];
////        [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:kCHAT_RECEIVE_MESSAGE];
//
//    if (contacts != nil) {
//        //        ms_list_free_with_data(contacts, chatTable_free_chatrooms);
//    }
//}

@end
