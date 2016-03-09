//
//  SecondIncomingCallView.h
//  ACE
//
//  Created by Norayr Harutyunyan on 11/27/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "BackgroundedViewController.h"
#import "CallService.h"

@interface SecondIncomingCallView : BackgroundedViewController

@property (nonatomic, assign) LinphoneCall* call;

- (void) reorderControllersForFrame:(NSRect)frame;

@end
