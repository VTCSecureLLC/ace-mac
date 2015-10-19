//
//  CallService.h
//  ACE
//
//  Created by Edgar Sukiasyan on 10/16/15.
//  Copyright © 2015 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CallWindowController.h"
#import "LinphoneManager.h"

@interface CallService : NSObject

+ (CallService *)sharedInstance;
- (CallWindowController*) getCallWindowController;
- (int) decline;
- (void) accept;
- (LinphoneCall*) getCurrentCall;

@end
