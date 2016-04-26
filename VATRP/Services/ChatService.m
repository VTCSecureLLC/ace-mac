//
//  ChatService.m
//  ACE
//
//  Created by Ruben Semerjyan on 10/19/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "ChatService.h"
#import "CallService.h"
#import "ChatWindowController.h"
#import "HomeViewController.h"
#import "AppDelegate.h"
#import "Utils.h"


@interface ChatService () {
    int unread_messages;
    
    ChatWindowController *chatWindowController;
}

@end

@implementation ChatService




+ (ChatService *)sharedInstance
{
    static ChatService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ChatService alloc] init];
    });
    
    return sharedInstance;
}

- (id) init {
    self = [super init];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textComposeEvent:)
                                                     name:kLinphoneTextComposeEvent
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textReceivedEvent:)
                                                     name:kLinphoneTextReceived
                                                   object:nil];
        unread_messages = 0;
    }
    
    return self;
}

- (BOOL) openChatWindowWithUser:(NSString*)user {
    unread_messages = 0;
    
    if (!chatWindowController) {
//        chatWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"ChatWindowController"];
        chatWindowController = [[ChatWindowController alloc] init];
        if (user) {
            ChatViewController *chatViewController = [chatWindowController getChatViewController];
            chatViewController.selectUser = user;
        }
        
        [chatWindowController showWindow:self];
        return YES;
    } else {
        if (!chatWindowController.isShow) {
            if (user) {
                ChatViewController *chatViewController = [chatWindowController getChatViewController];
                chatViewController.selectUser = user;
            }
            [chatWindowController showWindow:self];
            chatWindowController.isShow = YES;
            return YES;
        } else {
            [chatWindowController close];
            chatWindowController = nil;
        }
    }
    
    return NO;
}

- (BOOL)isOpened {
    return chatWindowController.isShow;
}

- (void) closeChatWindow {
    [chatWindowController close];
}

- (void) closeChatWindowAndClear {
    [self closeChatWindow];
    chatWindowController = nil;
}

// Note: Outgoign may be working properly based on how Windows is behaving. verify display of incoming first
// the inProgressChatMessage is for an RTT message that the user is currently composing (the enter key has not yet been tapped)
//-(bool)sendCharacter:(NSString*)message inProgressChatMessage:(LinphoenChatMessage*)inProgressChatMessage
//{
//    // verify that the message is valid
//    LinphoneCall *call = [[CallService sharedInstance] getCurrentCall];
//
//    if (!call)
//        return NO;
//
//
//}

- (BOOL) sendMessagt:(NSString*)message {
    LinphoneCall *call = [[CallService sharedInstance] getCurrentCall];
    
    if (!call)
        return NO;
    
    LinphoneChatRoom *chat_room = linphone_call_get_chat_room(call);
    
    if (chat_room) {
        // we shoulkd not be creating a new message with every character. add a send message method for rtt that will accept an existing message.
        LinphoneChatMessage* rtt_message = linphone_chat_room_create_message(chat_room, NULL);
        
        const char* character = [message UTF8String];
        
        if (character) {
            for (int i = 0; i < strlen(character); i++) {
                if(i % 29 == 0 && i != 0){
                    [NSThread sleepForTimeInterval:1];
                }
                if (linphone_chat_message_put_char(rtt_message, character[i]))
                    return NO;
            }
        }
    }
    
    return YES;
}

- (BOOL) sendEnter:(LinphoneChatMessage*)messagePtr ChatRoom:(LinphoneChatRoom*)chatroom_ptr {
//    linphone_chat_message_ref((LinphoneChatMessage*)messagePtr);
//    linphone_chat_message_set_user_data((LinphoneChatMessage*)messagePtr, (void*)0x2028);
//    linphone_chat_room_send_chat_message((LinphoneChatRoom*)chatroom_ptr, (LinphoneChatMessage*)messagePtr);
    
    [self sendChar:(uint32_t)0x2028];
    
    return YES;
}

- (BOOL) sendBackward {
    [self sendChar:(uint32_t)8];
    
    return YES;
}

- (BOOL) sendTab {
    [self sendChar:(uint32_t)9];
    
    return YES;
}


- (BOOL) sendChar:(uint32_t)char_simbol
{
    LinphoneCall *call = [[CallService sharedInstance] getCurrentCall];
    
    if (!call) {
        return NO;
    }
    
    LinphoneChatRoom* room = linphone_call_get_chat_room(call);
    
    if (room) {
        LinphoneChatMessage* msg = linphone_chat_room_create_message(room, "");
        
        if (!linphone_chat_message_put_char(msg, char_simbol))
            return YES;
        
        return NO;
    }
    
    return NO;
}

- (void)textComposeEvent:(NSNotification *)notif {
    //    LinphoneChatRoom *room = [[[notif userInfo] objectForKey:@"room"] pointerValue];
    //    if (room) {
    //        BOOL composing = linphone_chat_room_is_remote_composing(room);
    //        NSLog(@"composing: %d", composing);
    //        BOOL composing = linphone_chat_room_is_remote_composing(room);
    //        NSLog(@"composing: %d.", composing);
    //
    //        uint32_t rttCode = linphone_chat_room_get_char(room);
    //        NSString *string = [NSString stringWithFormat:@"%c", rttCode];
    //
    //        if (!string || !string.length) {
    //            return;
    //        }
    //
    //        if (!chatWindowController || !chatWindowController.isShow) {
    //            unread_messages++;
    //            [[NSNotificationCenter defaultCenter] postNotificationName:kCHAT_UNREAD_MESSAGE
    //                                                                object:@{@"unread_messages_count" : [NSNumber numberWithInt:unread_messages]}
    //                                                              userInfo:nil];
    //        }
    //
    //        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:composing], @"composing",
    //                                                                        string, @"text", nil];
    //
    //        [[NSNotificationCenter defaultCenter] postNotificationName:kCHAT_RECEIVE_MESSAGE
    //                                                            object:dict
    //                                                          userInfo:nil];
    //    }
}

- (void)textReceivedEvent:(NSNotification *)notif {
    NSDictionary *dict = notif.userInfo;

    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        LinphoneChatMessage *msg = [[notif.userInfo objectForKey:@"message"] pointerValue];
        const LinphoneAddress* from_addr = linphone_chat_message_get_from_address(msg);
        
        const char *text = linphone_chat_message_get_text(msg);
        
        NSString *messageText = text ? [Utils decodeTextMessage:text] : @"";
        
        if ([messageText hasPrefix:CALL_DECLINE_PREFIX]) {
            LinphoneCall *call = [[CallService sharedInstance] getCurrentCall];
            
            NSString *callerUsername = nil;
            
            if (!call) {
                callerUsername = [[CallService sharedInstance] getLastCalledUsername];
            } else {
                const LinphoneAddress* call_addr = linphone_call_get_remote_address(call);
                const char *call_username = linphone_address_get_username(call_addr);
                callerUsername = [NSString stringWithUTF8String:call_username];
            }
            

            const char *msg_username = linphone_address_get_username(from_addr);
            
            if ([callerUsername isEqualToString:[NSString stringWithUTF8String:msg_username]]) {
                [[CallService sharedInstance] setDeclineMessage:[messageText substringFromIndex:CALL_DECLINE_PREFIX.length]];
            }
        } else {
            const MSList *calls = linphone_core_get_calls([LinphoneManager getLc]);
            LinphoneCall *call;
            if(calls && ms_list_size(calls) > 0){
                for(int i = 0; i < ms_list_size(calls); i++){
                    call = ms_list_nth_data(calls, i);
                    if(strcmp(linphone_call_get_remote_address_as_string(call), linphone_address_as_string(from_addr)) == 0 && linphone_call_get_state(call) == LinphoneCallStreamsRunning){
                        return;
                    }
                }
            }
            if (!chatWindowController || !chatWindowController.isShow) {
                unread_messages++;
                [[NSNotificationCenter defaultCenter] postNotificationName:kCHAT_UNREAD_MESSAGE
                                                                    object:@{@"unread_messages_count" : [NSNumber numberWithInt:unread_messages]}
                                                                  userInfo:nil];
                
                [self showNotification:msg];
            }
        }
    }
}

- (void)showNotification:(LinphoneChatMessage*)msg {
    if (!msg) {
        return;
    }
       
    const LinphoneAddress* remoteAddress = linphone_chat_message_get_from_address(msg);
    const char *c_username                = linphone_address_get_username(remoteAddress);
    
    const char *text = linphone_chat_message_get_text(msg);
    NSString *messageText = text ? [Utils decodeTextMessage:text] : @"";
    
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = [NSString stringWithUTF8String:c_username];
    //    notification.subtitle = @"Sub title";
    notification.informativeText = messageText;
    notification.soundName = NSUserNotificationActivationTypeNone;
//    notification.hasReplyButton = YES;
//    notification.hasActionButton = YES;
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

@end