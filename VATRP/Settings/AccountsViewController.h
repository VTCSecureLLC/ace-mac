//
//  AccountsViewController.h
//  vatrp
//
//  Created by Ruben Semerjyan on 9/22/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BFNavigationController.h"
#import "NSViewController+BFNavigationController.h"

@interface AccountsViewController : NSViewController

// note: 10.9 - viewWillAppear not being called. using explicit initialization to keep code a little cleaner (fewer if defs)
-(void) initializeData;
- (BOOL) save;

@end
