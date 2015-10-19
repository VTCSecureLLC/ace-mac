//
//  ChatService.m
//  ACE
//
//  Created by Edgar Sukiasyan on 10/19/15.
//  Copyright © 2015 Home. All rights reserved.
//

#import "ChatService.h"
#import "CallService.h"
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
        unread_messages = 0;
    }
    
    return self;
}

- (void) openChatWindow {
    unread_messages = 0;

    if (!chatWindowController) {
        chatWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"ChatWindowController"];
        [chatWindowController showWindow:self];
    } else {
        if (!chatWindowController.isShow) {
            [chatWindowController showWindow:self];
            chatWindowController.isShow = YES;
        }
    }
}

- (void) closeChatWindow {
    [chatWindowController close];
}

- (BOOL) sendMessagt:(NSString*)message {
    LinphoneCall *call = [[CallService sharedInstance] getCurrentCall];
    
    if (!call)
        return NO;
        
    LinphoneChatRoom *chat_room = linphone_call_get_chat_room(call);
    
    if (chat_room) {
        LinphoneChatMessage* rtt_message = linphone_chat_room_create_message(chat_room, NULL);
        
        const char* character = [message UTF8String];
    
        for (int i = 0; i < strlen(character); i++) {
            int result = linphone_chat_message_put_char(rtt_message, character[i]);
            
//            if (!result) {
//                linphone_chat_room_send_chat_message(chat_room, rtt_message);
//                
//                return YES;
//            }
        }
        
    }
    
    return NO;
}

- (BOOL) sendEnter {
    [self sendChar:(char)10];
    
    return YES;
}

- (BOOL) sendBackward {
    [self sendChar:(char)8];
    
    return YES;
}

- (BOOL) sendTab {
    [self sendChar:(char)9];
    
    return YES;
}

- (BOOL) sendChar:(char)char_simbol {
    LinphoneCall *call = [[CallService sharedInstance] getCurrentCall];
    
    if (!call) {
        return NO;
    }
    
    LinphoneChatRoom* room = linphone_call_get_chat_room(call);
    
    if (room) {
        LinphoneChatMessage* msg = linphone_chat_room_create_message(room, "");
        linphone_chat_message_put_char(msg, char_simbol);
        
        return YES;
    }
    
    return NO;
}

- (void)textComposeEvent:(NSNotification *)notif {
    LinphoneChatRoom *room = [[[notif userInfo] objectForKey:@"room"] pointerValue];
    if (room) {
        BOOL composing = linphone_chat_room_is_remote_composing(room);
        NSLog(@"composing: %d", composing);
        
        uint32_t rttCode = linphone_chat_room_get_char(room);
        NSString *string = [NSString stringWithFormat:@"%c", rttCode];
        NSLog(@"string: %@", string);
        
        if (!chatWindowController || !chatWindowController.isShow) {
            unread_messages++;
            [[NSNotificationCenter defaultCenter] postNotificationName:kCHAT_UNREAD_MESSAGE
                                                                object:@{@"unread_messages_count" : [NSNumber numberWithInt:unread_messages]}
                                                              userInfo:nil];
        }

        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:composing], @"composing",
                                                                        string, @"text", nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kCHAT_RECEIVE_MESSAGE
                                                            object:dict
                                                          userInfo:nil];
    }
}


//- (void)textComposeEvent:(NSNotification *)notif {
//    LinphoneChatRoom *room = [[[notif userInfo] objectForKey:@"room"] pointerValue];
//    if (room) {
//        uint32_t c = linphone_chat_room_get_char(room);
//        
//        if (c == 0x2028 || c == 10){ // In case of enter.
//            [self performSelectorOnMainThread:@selector(runonmainthread:) withObject:@"\n" waitUntilDone:NO];
//        }
//        else if (c == '\b' || c == 8){ // In case of backspace.
//            [self performSelectorOnMainThread:@selector(runonmainthreadremove) withObject:nil waitUntilDone:NO];
//        }
//        else// In case of everything else except empty.
//        {
//            NSLog(@"The logging: %d", c);
//            NSString * string = [NSString stringWithFormat:@"%C", (unichar)c];
//            [self performSelectorOnMainThread:@selector(runonmainthread:) withObject:string waitUntilDone:NO];
//        }
//    }
//}

@end
