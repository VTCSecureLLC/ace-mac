//
//  BackgroundedViewController.h
//  ACE
//
//  Created by Lizann Epley on 2/29/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#ifndef BackgroundedViewController_h
#define BackgroundedViewController_h

#import <Cocoa/Cocoa.h>

@interface BackgroundedViewController : NSViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

#pragma mark expose view methods as needed
-(void)setHidden:(bool)hidden;
-(bool)isHidden;

-(NSRect)getFrame;

- (void) addTrackingArea:(NSTrackingArea*)trackingArea;
- (void) setBackgroundColor:(NSColor*)color;
- (void) drawRect:(NSRect)dirtyRect;

@end


#endif /* BackgroundedViewController_h */
