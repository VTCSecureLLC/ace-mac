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
- (int) decline;
- (void) accept;
- (LinphoneCall*) getCurrentCall;

@end
