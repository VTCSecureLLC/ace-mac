//
//  CallControllersView.h
//  ACE
//
//  Created by Norayr Harutyunyan on 11/12/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CallService.h"
#import "SettingsHandler.h"

@protocol CallControllersViewDelegate;

@interface CallControllersView : NSViewController<SettingsHandlerDelegate, PreferencesHandlerDelegate>

@property (nonatomic, assign) id<CallControllersViewDelegate> delegate;

- (void)setCall:(LinphoneCall*)acall;
- (void)setIncomingCall:(LinphoneCall*)acall;
- (void)setOutgoingCall:(LinphoneCall*)acall;
- (void)dismisCallInfoWindow;
- (void)performChatButtonClick;
- (BOOL)bool_chat_window_open;
- (void)set_bool_chat_window_open:(BOOL)open;
@end

@protocol CallControllersViewDelegate <NSObject>

@optional

- (BOOL) didClickCallControllersViewVideo:(CallControllersView*)callControllersView_;
- (void) didClickCallControllersViewNumpad:(CallControllersView*)callControllersView_;


@end