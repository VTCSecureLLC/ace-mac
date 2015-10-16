//
//  CallViewController.h
//  ACE
//
//  Created by Ruben Semerjyan on 9/23/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LinphoneManager.h"

@interface CallViewController : NSViewController

@property (nonatomic, assign) LinphoneCall* call;

- (void)setOutgoingCall:(LinphoneCall*)acall;
@property (weak) IBOutlet NSView *remoteVideoView;

@end
