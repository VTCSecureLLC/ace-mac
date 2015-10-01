//
//  CallWindowController.h
//  ACE
//
//  Created by Ruben Semerjyan on 9/23/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CallViewController.h"

@interface CallWindowController : NSWindowController

- (CallViewController*) getCallViewController;

@end
