//
//  ChatWindowController.h
//  ACE
//
//  Created by Ruben Semerjyan on 10/13/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ChatViewController.h"

@interface ChatWindowController : NSWindowController

@property (nonatomic, assign) BOOL isShow;

- (ChatViewController*) getChatViewController;

@end
