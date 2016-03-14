//
//  KeypadWindowController.m
//  ACE
//
//  Created by Ruben Semerjyan on 10/13/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "KeypadWindowController.h"
#import "DialPadView.h"

@interface KeypadWindowController ()

@end

@implementation KeypadWindowController

-(id) init
{
    self = [super initWithWindowNibName:@"KeypadWindowController"];
    if (self)
    {
        // init
    }
    return self;
    
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [self.window setTitle:@"KeypadWindowController"];

    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    DialPadView* dialPadView = [[DialPadView alloc] init];
    [self.window.contentView addSubview:[dialPadView view]];
}

@end
