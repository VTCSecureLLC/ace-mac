//
//  VideoView.h
//  ACE
//
//  Created by Norayr Harutyunyan on 11/12/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LinphoneManager.h"

@interface VideoView : NSView

@property (nonatomic, assign) LinphoneCall* call;

- (void)setIncomingCall:(LinphoneCall*)acall;
- (void)setOutgoingCall:(LinphoneCall*)acall;
- (void)showSecondCallView:(LinphoneCall*)aCall;
- (void)hideSecondCallView;

@property (weak) IBOutlet NSView *remoteVideoView;

@end
