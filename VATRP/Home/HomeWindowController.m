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

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    NSPoint pos;
    

    pos.x =  [[NSScreen mainScreen] frame].origin.x + [[NSScreen mainScreen] frame].size.width / 2 - [self.window frame].size.width /2;
    pos.y = [[NSScreen mainScreen] frame].origin.y + ([[NSScreen mainScreen] frame].size.height / 2) + ([self.window frame].size.height * 2);
    [self setWindowPos: pos];

    self.window.title = [self getACEBuildNumber];
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
@end
