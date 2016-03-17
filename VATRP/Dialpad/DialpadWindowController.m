//
//  DialpadWindowController.m
//  MacApp
//
//  Created by Norayr Harutyunyan on 8/27/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import "DialpadWindowController.h"
#import "AppDelegate.h"
@interface DialpadWindowController ()

@end

@implementation DialpadWindowController

@synthesize isShow;

-(id) init
{
    self = [super initWithWindowNibName:@"DialpadWindow"];
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
    
    NSPoint barOrigin = [[AppDelegate sharedInstance] getTabWindowOrigin];
    
    NSPoint currentWindowSize = {self.window.frame.size.width, self.window.frame.size.height};
    NSPoint barWindowSize = [[AppDelegate sharedInstance] getTabWindowSize];
    
    NSPoint pos;
    pos.x = barOrigin.x + barWindowSize.x / 2 - currentWindowSize.x / 2 ;
    pos.y = barOrigin.y - currentWindowSize.y - barWindowSize.y;
    [self.window setFrameOrigin : pos];
    
    DialPadView* dialPadView = [[DialPadView alloc] init];
    [self.window.contentView addSubview:[dialPadView view]];
    
    [self.window setTitle:@"DialpadWindowController"];

}

- (void)myWindowWillClose:(NSNotification *)notification
{
    self.isShow = NO;
}

@end
