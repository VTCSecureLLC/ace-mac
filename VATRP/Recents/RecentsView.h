//
//  RecentsView.h
//  ACE
//
//  Created by Norayr Harutyunyan on 11/11/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BackgroundedViewController.h"

@interface RecentsView : BackgroundedViewController

@property (weak) IBOutlet NSSegmentedControl *callsSegmentControll;

- (void) reloadCallLogs;

@end
