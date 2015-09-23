//
//  CallViewController.h
//  ACE
//
//  Created by Edgar Sukiasyan on 9/23/15.
//  Copyright © 2015 Home. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LinphoneManager.h"

@interface CallViewController : NSViewController

@property (nonatomic, assign) LinphoneCall* call;

- (void)setOutgoingCall:(LinphoneCall*)acall;

@end
