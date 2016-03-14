//
//  CallInfoWindowController.m
//  ACE
//
//  Created by Ruben Semerjyan on 10/12/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "CallInfoWindowController.h"
#import "CallInfoViewController.h"

@interface CallInfoWindowController ()

@end

@implementation CallInfoWindowController

-(id) init
{
    self = [super initWithWindowNibName:@"CallInfoWindowController"];
    if (self)
    {
        // init
    }
    return self;
    
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    CallInfoViewController* callInfoViewController = [[CallInfoViewController alloc] init];
    [self.window.contentView addSubview:callInfoViewController.view];
    
    [self.window setTitle:@"CallInfoViewController"];
}

@end
