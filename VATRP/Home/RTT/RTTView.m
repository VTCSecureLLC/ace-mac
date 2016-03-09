//
//  RTTView.m
//  ACE
//
//  Created by Norayr Harutyunyan on 11/25/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "RTTView.h"
#import "Utils.h"
#import "LinphoneManager.h"
#import "ViewManager.h"
#import "CallService.h"
#import "ChatService.h"
#import "ChatItemTableCellView.h"
#import "BackgroundedView.h"

//integers duplicate format as Android
//const NSInteger TEXT_MODE;
const NSInteger NO_TEXT=-1;
const NSInteger RTT=0;
const NSInteger SIP_SIMPLE=1;

@interface RTTView () {
    MSList *contacts;
    
    LinphoneCall *currentCall;
    
    LinphoneChatRoom *selectedChatRoom;
    MSList *messageList;
    
    BOOL stateNewMessage;
    
    LinphoneChatMessage *incomingChatMessage;
    ChatItemTableCellView *incomingCellView;
    LinphoneChatMessage *outgoingChatMessage;
    CGFloat incomingTextLinesCount;
}

@property (weak) IBOutlet NSButton *buttonSend;
@property (weak) IBOutlet BackgroundedView *messageEnterBG;
@property (weak) IBOutlet NSTextField *textFieldMessage;

@property (weak) IBOutlet NSScrollView *scrollViewContent;
@property (weak) IBOutlet NSTableView *tableViewContent;

- (LinphoneChatRoom*)getCurrentChatRoom;

@end


@implementation RTTView

-(id) init
{
    self = [super initWithNibName:@"RTTView" bundle:nil];
    if (self)
    {
        // init
    }
    return self;
    
}
- (void) awakeFromNib {
    [super awakeFromNib];
    
    [ViewManager sharedInstance].rttView = self;
}

- (void) setCustomFrame:(NSRect)frame {
    self.view.frame = frame;
    [self.scrollViewContent setFrame:NSMakeRect(0, 100, frame.size.width, frame.size.height - 100)];
}


- (void) viewWillAppear {
    
    [self setBackgroundColor:[NSColor colorWithRed:44.0/255.0 green:55.0/255.0 blue:61.0/255.0 alpha:1.0]];
    [Utils setUIBorderColor:[NSColor whiteColor] CornerRadius:0 Width:1 Control:(NSControl*)self];
    
    self.buttonSend.wantsLayer = YES;
    self.messageEnterBG.wantsLayer = YES;
    
    [self.buttonSend.layer setBackgroundColor:[NSColor colorWithRed:44.0/255.0 green:55.0/255.0 blue:61.0/255.0 alpha:1.0].CGColor];
    [Utils setUIBorderColor:[NSColor whiteColor] CornerRadius:0 Width:1 Control:self.buttonSend];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonSend];
    
    [self.messageEnterBG setBackgroundColor:[NSColor colorWithRed:44.0/255.0 green:55.0/255.0 blue:61.0/255.0 alpha:1.0]];
    [Utils setUIBorderColor:[NSColor whiteColor] CornerRadius:0 Width:1 Control:(NSControl*)self.messageEnterBG];
    
    self.textFieldMessage.focusRingType = NSFocusRingTypeNone;
    
    [self.tableViewContent setBackgroundColor:[NSColor clearColor]];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName, nil];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:@"Message" attributes:attributes];
    self.textFieldMessage.placeholderAttributedString = attributedString;
    
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
                                                  selector:@selector(textDidBeginEditing:)
                                                      name:NSTextDidBeginEditingNotification
                                                    object:nil];
    
    contacts = nil;
    selectedChatRoom = nil;
    incomingChatMessage = nil;
    outgoingChatMessage = nil;
    incomingCellView = nil;
    incomingTextLinesCount = 1;
    stateNewMessage = NO;
    
    [self updateContentData];
    [self.tableViewContent reloadData];
    int count = ms_list_size(messageList);
    [self.tableViewContent scrollRowToVisible:count-1];
}

- (void) viewWillDisappear {
    selectedChatRoom = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)updateContentData {
    [self clearMessageList];
    
    if (![self getCurrentChatRoom])
        return;
    
    messageList = linphone_chat_room_get_history([self getCurrentChatRoom], 0);
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
    NSInteger count = ms_list_size(messageList);
    return count;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    LinphoneChatMessage *chat = ms_list_nth_data(self->messageList, (int)row);
    
    ChatItemTableCellView *cellView = [tableView makeViewWithIdentifier:@"ChatCell" owner:self];
    [cellView setChatMessage:chat];
    
    if (!linphone_chat_message_is_outgoing(chat) && incomingChatMessage) {
        incomingCellView = cellView;
    }
    
    return cellView;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    LinphoneChatMessage *message = ms_list_nth_data(self->messageList, (int)row);
    if (message) {
        CGFloat cellHeight = [ChatItemTableCellView height:message width:[self getFrame].size.width];
        return cellHeight;
    }
    
    return 1;
}

-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    return NO;
}

- (IBAction)onButtonSend:(id)sender {
    [self eventENTER];
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
        case LinphoneCallConnected:{
            [self clearMessageList];
            [self.tableViewContent reloadData];
        }
        break;
        case LinphoneCallStreamsRunning: {
            //            [self updateContentData];
        }
            break;
        default:
            break;
    }
}

- (void)textComposeEvent:(NSNotification *)notif {
    //New message is received rtt or sip simple

    //VATRP-1292 open chat window immediately when a new message is recieved.
    if(![ViewManager sharedInstance].callControllersView_delegate.bool_chat_window_open){
        [[ViewManager sharedInstance].callControllersView_delegate performChatButtonClick];
    }
    
    
    LinphoneChatRoom *room = [[[notif userInfo] objectForKey:@"room"] pointerValue];
    if (room && room == [self getCurrentChatRoom]) {
        //        BOOL composing = linphone_chat_room_is_remote_composing(room);
        //        [self setComposingVisible:composing withDelay:0.3];
    }
    
    LinphoneCall *call = linphone_chat_room_get_call(room);
    
    if (call != NULL) {
        const LinphoneCallParams* current = linphone_call_get_current_params(call);
        
        if (linphone_call_params_realtime_text_enabled(current)) {
            uint32_t rttCode = linphone_chat_room_get_char(room);
            NSString *text = [NSString stringWithFormat:@"%c", rttCode];
            
            if (rttCode == 0)
                return;
            
            if(rttCode == 8232) {
                incomingChatMessage = nil;
                incomingCellView = nil;
            } else {
                if (incomingChatMessage) {
                    const char *text_char = linphone_chat_message_get_text(incomingChatMessage);
                    
                    if (strlen(text_char)) {
                        self->messageList = ms_list_remove(self->messageList, incomingChatMessage);
                        NSString *str_msg = [NSString stringWithUTF8String:text_char];
                        if ([text isEqualToString:@"\b"]) {
                            if (str_msg && str_msg.length > 0) {
                                str_msg = [str_msg substringToIndex:str_msg.length - 1];
                            }
                        } else {
                            str_msg = [str_msg stringByAppendingString:text];
                        }
                        
                        incomingChatMessage = linphone_chat_room_create_message([self getCurrentChatRoom], [str_msg UTF8String]);
                    } else {
                        incomingChatMessage = linphone_chat_room_create_message([self getCurrentChatRoom], [text UTF8String]);
                    }
                } else {
                    incomingChatMessage = linphone_chat_room_create_message([self getCurrentChatRoom], [text UTF8String]);
                }
                
                self->messageList = ms_list_append(self->messageList, incomingChatMessage);
                
                if (incomingCellView) {
                    CGFloat lineCount = [ChatItemTableCellView height:incomingChatMessage width:[self getFrame].size.width];
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

- (void)textReceivedEvent:(NSNotification *)notif {
    LinphoneAddress *from = [[[notif userInfo] objectForKey:@"from_address"] pointerValue];
    LinphoneChatRoom *room = [[notif.userInfo objectForKey:@"room"] pointerValue];
    LinphoneChatMessage *chat = [[notif.userInfo objectForKey:@"message"] pointerValue];
    
    if (from == NULL || chat == NULL) {
        return;
    }
    
    char *fromStr = linphone_address_as_string_uri_only(from);
    
    if ([self getCurrentChatRoom]) {
        const LinphoneAddress *cr_from = linphone_chat_room_get_peer_address([self getCurrentChatRoom]);
        char *cr_from_string = linphone_address_as_string_uri_only(cr_from);
        
        if (fromStr && cr_from_string) {
            if (strcasecmp(cr_from_string, fromStr) == 0) {
                linphone_chat_room_mark_as_read(room);
                
//                [self updateContentData];
                [self.tableViewContent reloadData];
                
                NSInteger count = ms_list_size(messageList);
                [self.tableViewContent scrollRowToVisible:count-1];
            }
        }
        
        ms_free(cr_from_string);
    }
    
    ms_free(fromStr);
}

- (void)didReceiveMessage:(NSNotification *)aNotification {
    NSDictionary *dict_message = [aNotification object];
    
    //    BOOL composing = [[dict_message objectForKey:@"composing"] boolValue];
    NSString *text = [dict_message objectForKey:@"text"];
    NSLog(@"text: %@", text);
    
    LinphoneChatRoom *room = [[[aNotification userInfo] objectForKey:@"room"] pointerValue];
    if (room && room == [self getCurrentChatRoom]) {
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
long msgSize; //message length buffer

-(void) pasteText:(NSString*) pastedMsg{
        LinphoneCall *call = [[CallService sharedInstance] getCurrentCall];
    
        if (!call)
                return;
    
       LinphoneChatRoom *chat_room = linphone_call_get_chat_room(call);
    
        if (chat_room) {
                const char* character = [pastedMsg UTF8String];
                LinphoneChatMessage* rtt_message = linphone_chat_room_create_message(chat_room, character);
                //RTT limited to 30 cps
                for (int i = 0; i < strlen(character); i++) {
                            if(i % 14 == 0 && i != 0){
                                    [NSThread sleepForTimeInterval:0.5];
                                }
                            if (linphone_chat_message_put_char(rtt_message, character[i]))
                                    return;
                        }
            }
    }
- (void)textDidBeginEditing:(NSNotification *)notification{ //Get length of message string
        msgSize = self.textFieldMessage.stringValue.length-1;
        if(msgSize < 0) msgSize = 0;
    }

- (void)textDidChange:(NSNotification *)aNotification {
    NSUInteger lastSymbolIndex = self.textFieldMessage.stringValue.length - 1;
    NSString *lastSymbol = [self.textFieldMessage.stringValue substringFromIndex:lastSymbolIndex];
    
    int TEXT_MODE=[self getTextMode];
    
    if(TEXT_MODE==RTT){

            if((self.textFieldMessage.stringValue.length-1) - msgSize  > 1){
                    /** Text was pasted **/         /** Difference of length
                                                                                               buffer and current text is
                                                                                               greater than one.User entered
                                                                                               more than one character,
                                                                                               so now parse the pasted string **/
            
                    lastSymbolIndex = msgSize;
                    NSString *pastedMsg = [self.textFieldMessage.stringValue substringFromIndex:lastSymbolIndex];
                    
                    pastedMsg = [pastedMsg stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
                    [self performSelectorInBackground:@selector(pasteText:) withObject:pastedMsg];
                    
            
        }
        else{
            if (![[ChatService sharedInstance] sendMessagt:lastSymbol]) {
                NSAlert *alert = [[NSAlert alloc]init];
                [alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
                [alert setMessageText:NSLocalizedString(@"RTT has been disabled for this call", nil)];
                [alert runModal];
            }
        }
        msgSize = self.textFieldMessage.stringValue.length-1;
    }
    else if(TEXT_MODE==SIP_SIMPLE){
        
        //handle on enter press
        
    }
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector {
    int TEXT_MODE=[self getTextMode];
    if(TEXT_MODE==RTT){
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
    }else if(TEXT_MODE==SIP_SIMPLE){
        if (commandSelector == @selector(insertNewline:)) {
            return [self eventENTER];
        }
    }
    // return YES if the action was handled; otherwise NO
    
    return NO;
}

- (BOOL) eventENTER {
    if (!self.textFieldMessage.stringValue.length || ![self.textFieldMessage.stringValue stringByReplacingOccurrencesOfString:@" " withString:@""].length) {
        return NO;
    }
    
    //Do something against ENTER key
    LinphoneCall *currentCall_ = [[CallService sharedInstance] getCurrentCall];
    
    if (currentCall_) {
        
        int TEXT_MODE = [self getTextMode];
        if (TEXT_MODE == SIP_SIMPLE) {
            [self sendMessage:self.textFieldMessage.stringValue withExterlBodyUrl:nil withInternalURL:nil LinphoneChatRoom:[self getCurrentChatRoom]];
        } else {
        
            outgoingChatMessage = linphone_chat_room_create_message_2([self getCurrentChatRoom], [self.textFieldMessage.stringValue UTF8String], NULL, LinphoneChatMessageStateDelivered, 0, YES, NO);

            [[ChatService sharedInstance] sendEnter:outgoingChatMessage ChatRoom:[self getCurrentChatRoom]];

            self->messageList = ms_list_append(self->messageList, outgoingChatMessage);
            
            [self.tableViewContent reloadData];
            
            NSInteger count = ms_list_size(messageList);
            [self.tableViewContent scrollRowToVisible:count-1];
        }
    }
    
    self.textFieldMessage.stringValue = @"";
     msgSize = 0;
    return YES;
}

- (BOOL) eventBackward {
    if ([[ChatService sharedInstance] sendBackward] && self.textFieldMessage.stringValue && self.textFieldMessage.stringValue.length) {
        self.textFieldMessage.stringValue = [self.textFieldMessage.stringValue substringToIndex:self.textFieldMessage.stringValue.length - 1];
        
                msgSize = self.textFieldMessage.stringValue.length-1;
                if(msgSize < 0) { msgSize = 0; }
    }
    
    return YES;
}

- (BOOL) eventTab {
    [[ChatService sharedInstance] sendTab];
    msgSize = self.textFieldMessage.stringValue.length -1;
    return YES;
}

- (BOOL)sendMessage:(NSString *)message withExterlBodyUrl:(NSURL *)externalUrl withInternalURL:(NSURL *)internalUrl LinphoneChatRoom:(LinphoneChatRoom*)room {
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
    
    int count = ms_list_size(messageList);
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
    //    ChatViewController *thiz = (__bridge ChatViewController *)ud;
    
    
    //    [thiz.tableController updateChatEntry:msg];
}

- (LinphoneChatRoom*)getCurrentChatRoom {
    if (selectedChatRoom)
        return selectedChatRoom;
    
    LinphoneCore *lc = [LinphoneManager getLc];
    LinphoneProxyConfig *cfg = linphone_core_get_default_proxy_config(lc);
    
    if (!cfg)
        return nil;
    
    const LinphoneCall *call = [[CallService sharedInstance] getCurrentCall];
    const LinphoneAddress* addr = linphone_call_get_remote_address(call);

    selectedChatRoom = linphone_core_get_chat_room(lc, addr);

    return selectedChatRoom;
}

/* Text Mode RTT or SIP SIMPLE duplicate with Android*/
-(int) getTextMode{
    return RTT;
    //SET TO RTT BY DEFAULT, THIS WILL CHANGE IN GLOBAL SETTINGS.
    int TEXT_MODE=RTT;
    
    //prefs = PreferenceManager.getDefaultSharedPreferences(LinphoneActivity.instance());
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //String text_mode=prefs.getString(getString(R.string.pref_text_settings_send_mode_key), "RTT");
    NSString* text_mode_string=[defaults stringForKey:@"TEXT_SEND_MODE"];
    
    //Log.d("Text Send Mode" + prefs.getString(getString(R.string.pref_text_settings_send_mode_key), "RTT"));
    NSLog(@"Text mode is %@",text_mode_string);
    //    if(text_mode.equals("SIP_SIMPLE")) {
    //        TEXT_MODE=SIP_SIMPLE;
    //    }else if(text_mode.equals("RTT")) {
    //        TEXT_MODE=RTT;
    //
    //    }
    
    if([text_mode_string isEqualToString:@"SIP SIMPLE"]) {
        TEXT_MODE=SIP_SIMPLE;
    }else if([text_mode_string isEqualToString:@"Real Time Text (RTT)"]) {
        TEXT_MODE=RTT;
    }
    NSLog(@"Text mode is %d",TEXT_MODE);
    //Log.d("TEXT_MODE ", TEXT_MODE);
    return TEXT_MODE;
}


@end