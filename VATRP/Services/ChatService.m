//
//  ChatService.m
//  ACE
//
//  Created by Ruben Semerjyan on 10/19/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "ChatService.h"
#import "ChatWindowController.h"


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

- (void) closeChatWindow {
    [chatWindowController close];
}

- (void) closeChatWindowAndClear {
    [self closeChatWindow];
    chatWindowController = nil;
}

- (BOOL) sendMessagt:(NSString*)message {
    LinphoneCall *call = [[CallService sharedInstance] getCurrentCall];
    
    if (!call)
        return NO;
    
    LinphoneChatRoom *chat_room = linphone_call_get_chat_room(call);
    
    if (chat_room) {
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

- (BOOL) sendChar:(uint32_t)char_simbol {
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
    if (!chatWindowController || !chatWindowController.isShow) {
        unread_messages++;
        [[NSNotificationCenter defaultCenter] postNotificationName:kCHAT_UNREAD_MESSAGE
                                                            object:@{@"unread_messages_count" : [NSNumber numberWithInt:unread_messages]}
                                                          userInfo:nil];
    }
}

@end