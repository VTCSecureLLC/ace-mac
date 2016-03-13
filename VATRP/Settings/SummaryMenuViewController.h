//
//  SummaryMenuViewController.h
//  ACE
//
//  Created by Norayr Harutyunyan on 1/11/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SummaryMenuViewController : NSViewController

// note: 10.9 - viewWillAppear not being called. using explicit initialization to keep code a little cleaner (fewer if defs)
-(void) initializeData;
- (void) save;

@end
