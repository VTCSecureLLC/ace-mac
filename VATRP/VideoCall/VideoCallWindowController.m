//
//  VideoCallWindowController.m
//  vatrp
//
//  Created by Ruben Semerjyan on 9/21/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "VideoCallWindowController.h"
#import "AppDelegate.h"
@interface VideoCallWindowController ()

@end

@implementation VideoCallWindowController

-(id) init
{
    self = [super initWithWindowNibName:@"VideoCallWindowController"];
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
    
    
    NSPoint barOrigin = [[AppDelegate sharedInstance] getTabWindowOrigin];
    
    NSPoint currentWindowSize = {self.window.frame.size.width, self.window.frame.size.height};
    NSPoint barWindowSize = [[AppDelegate sharedInstance] getTabWindowSize];
    
    NSPoint pos;
    pos.x = barOrigin.x - currentWindowSize.x;
    pos.y = barOrigin.y;
    [self.window setFrameOrigin : pos];
    
    VideoView* videoView = [[VideoView alloc] init];
    [self.window.contentView addSubview:[videoView view]];
    [self.window setTitle:@"VideoCallWindowController"];

}

@end
