//
//  ChatService.h
//  ACE
//
//  Created by Edgar Sukiasyan on 10/19/15.
//  Copyright © 2015 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kCHAT_UNREAD_MESSAGE @"kCHAT_UNREAD_MESSAGE"
#define kCHAT_CLEARE_UNREAD_MESSAGES @"kCHAT_CLEARE_UNREAD_MESSAGES"
#define kCHAT_RECEIVE_MESSAGE @"kCHAT_RECEIVE_MESSAGE"

@interface ChatService : NSObject

+ (ChatService *)sharedInstance;
- (void) openChatWindow;
- (void) closeChatWindow;
- (BOOL) sendMessagt:(NSString*)message;
- (BOOL) sendEnter;
- (BOOL) sendBackward;
- (BOOL) sendTab;

@end
