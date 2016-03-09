//
//  RecentsWindowController.m
//  MacApp
//
//  Created by Norayr Harutyunyan on 8/27/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import "RecentsWindowController.h"
#import "RecentsView.h"

@interface RecentsWindowController ()

@end

@implementation RecentsWindowController

@synthesize isShow;

-(id) init
{
    self = [super initWithWindowNibName:@"RecentsWindowController"];
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
    self.isShow = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myWindowWillClose:) name:NSWindowWillCloseNotification object:[self window]];
    
    RecentsView* recentsView = [[RecentsView alloc] init];
    [self.window.contentView addSubview:recentsView.view];
    [self.window setTitle:@"RecentsWindowController"];

}

- (void)myWindowWillClose:(NSNotification *)notification
{
    self.isShow = NO;
}

@end
