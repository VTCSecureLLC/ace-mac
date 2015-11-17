//
//  HomeWindowController.h
//  VATRP
//
//  Created by Norayr Harutyunyan on 9/3/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HomeViewController.h"

@interface HomeWindowController : NSWindowController

- (HomeViewController*) getHomeViewController;

-(NSPoint) getWindowOrigin;
-(CGSize) getWindowSize;

-(void) setWindowPos:(NSPoint) pos;
@end
