//
//  HomeWindowController.m
//  VATRP
//
//  Created by Norayr Harutyunyan on 9/3/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import "HomeWindowController.h"

@interface HomeWindowController ()

@end

@implementation HomeWindowController

-(id) init
{
    self = [super initWithWindowNibName:@"HomeWindowController"];
    if (self)
    {
        // init
    }
    return self;
    
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.

    self.window.acceptsMouseMovedEvents = YES;

    NSPoint pos;
    

    pos.x = [[NSScreen mainScreen] frame].origin.x + [[NSScreen mainScreen] frame].size.width / 2 - [self.window frame].size.width /2;
    pos.y = [[NSScreen mainScreen] frame].origin.y + ([[NSScreen mainScreen] frame].size.height / 2) + ([self.window frame].size.height * 2);
    [self setWindowPos: pos];

    self.window.title = [self getACEBuildNumber];
    [self.window setFrame:NSMakeRect(self.window.frame.origin.x, self.window.frame.origin.y, 310, self.window.frame.size.height)
                  display:YES
                  animate:NO];
    HomeViewController* homeViewController = [[HomeViewController alloc] init];
    [self.window.contentView addSubview:homeViewController.view];
    [self.window setTitle:@"ACE"];

}

- (HomeViewController*) getHomeViewController {
    return (HomeViewController*)self.contentViewController;
}

-(NSString*)getACEBuildNumber{
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* version = [infoDict objectForKey:@"CFBundleShortVersionString"];
    
    return [NSString stringWithFormat:@"ACE: v%@", version];
}

-(void) setWindowPos:(NSPoint) pos{
    [self.window setFrameOrigin : pos];
}

-(NSPoint) getWindowOrigin{
    return [self.window frame].origin;
}

-(CGSize) getWindowSize{
    return [self.window frame].size;
}

- (void)mouseMoved:(NSEvent *)theEvent {
    HomeViewController *homeViewController = [self getHomeViewController];
    
    NSPoint mousePosition = [homeViewController.view convertPoint:[theEvent locationInWindow] fromView:nil];
    [homeViewController mouseMovedWithPoint:mousePosition];
}

- (void)mouseDown:(NSEvent *)theEvent {
    HomeViewController *homeViewController = [self getHomeViewController];
    
    NSPoint mousePosition = [homeViewController.view convertPoint:[theEvent locationInWindow] fromView:nil];
    [homeViewController mouseMovedWithPoint:mousePosition];
}

@end
