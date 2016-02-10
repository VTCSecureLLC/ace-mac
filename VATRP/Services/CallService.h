//
//  CallService.h
//  ACE
//
//  Created by Ruben Semerjyan on 10/16/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CallWindowController.h"
#import "LinphoneManager.h"

@interface CallService : NSObject

+ (CallService *)sharedInstance;
- (CallWindowController*) getCallWindowController;
+ (void) callTo:(NSString*)number;
- (int) decline:(LinphoneCall*)aCall;
- (void) accept:(LinphoneCall*)aCall;
- (void) pause:(LinphoneCall*)aCall;
- (void) resume:(LinphoneCall*)aCall;
- (void) swapCallsToCall:(LinphoneCall*)aCall;
- (LinphoneCall*) getCurrentCall;

//-(void)tempDebugMethodForIncomingCall:(NSString*)message call:(LinphoneCall*)call

@end
