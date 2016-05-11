//
//  AboutWindowController.m
//  VATRP
//
//  Created by Norayr Harutyunyan on 10/26/15.
//  Developed pursuant to contract FCC15C0008 as open source software under GNU General Public License version 2.. All rights reserved.
//

#import "AboutWindowController.h"
#import "AboutViewController.h"

@interface AboutWindowController ()

@property (strong) IBOutlet NSView *aboutView;
@end

@implementation AboutWindowController

-(id) init
{
    self = [super initWithWindowNibName:@"AboutWindowController"];
    if (self)
    {
        // init
//        self.contentViewController = navigationController;
    }
    return self;
    
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    AboutViewController* aboutViewController = [[AboutViewController alloc] init];
    [self.window.contentView addSubview:aboutViewController.view];
//    [self.aboutView addSubview:aboutViewController.view];
}

@end
