//
//  CallDeclineMessagesView.h
//  ACE
//
//  Created by Norayr Harutyunyan on 4/7/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol CallDeclineMessagesViewDelegate;

@interface CallDeclineMessagesView : NSViewController

@property (nonatomic, assign) id<CallDeclineMessagesViewDelegate> delegate;

@end

@protocol CallDeclineMessagesViewDelegate <NSObject>

@optional

- (void) didClickCallDeclineMessagesViewItem:(CallDeclineMessagesView*)callDeclineMessagesView_ Message:(NSString*)msg;

@end