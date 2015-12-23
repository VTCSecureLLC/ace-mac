//
//  ResourcesViewController.h
//  ACE
//
//  Created by Zack Matthews on 12/21/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ResourcesViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSTableView *tableView;


@end
