//
//  ChatService.h
//  ACE
//
//  Created by Ruben Semerjyan on 10/19/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kCHAT_UNREAD_MESSAGE @"kCHAT_UNREAD_MESSAGE"
#define kCHAT_CLEARE_UNREAD_MESSAGES @"kCHAT_CLEARE_UNREAD_MESSAGES"
#define kCHAT_RECEIVE_MESSAGE @"kCHAT_RECEIVE_MESSAGE"

@interface ChatService : NSObject

+ (ChatService *)sharedInstance;
- (BOOL) openChatWindowWithUser:(NSString*)user;
- (void) closeChatWindow;
- (BOOL) sendMessagt:(NSString*)message;
- (BOOL) sendEnter;
- (BOOL) sendBackward;
- (BOOL) sendTab;

@end
