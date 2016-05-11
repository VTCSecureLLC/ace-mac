//
//  ChatItemTableCellView.h
//  ACE
//
//  Created by Norayr Harutyunyan on 10/22/15.
//  Developed pursuant to contract FCC15C0008 as open source software under GNU General Public License version 2.. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LinphoneManager.h"

@interface ChatItemTableCellView : NSTableCellView

@property (weak) IBOutlet NSImageView *imageViewUserPicture;

- (void)setChatMessage:(LinphoneChatMessage *)message;
+ (CGFloat)height:(LinphoneChatMessage*)chatMessage width:(int)width;

@end
