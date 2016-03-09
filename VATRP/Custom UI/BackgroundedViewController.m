//
//  BackgroundedViewController.m
//  ACE
//
//  Created by Lizann Epley on 2/29/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BackgroundedView.h"
#import "BackgroundedViewController.h"

@interface BackgroundedViewController ()
{
    NSColor *_backgroundColor;

}

@end

@implementation BackgroundedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Initialization code here.
        _backgroundColor = [NSColor whiteColor];
    }
    
    return self;
}


#pragma mark expose view methods as needed
-(void)setHidden:(bool)hidden
{
    [self.view setHidden:hidden];
}
-(bool)isHidden
{
    return self.view.isHidden;
}
-(NSRect)getFrame
{
    return self.view.frame;
}

-(void) addTrackingArea:(NSTrackingArea*)trackingArea
{
    [self.view addTrackingArea:trackingArea];
}


- (void) setBackgroundColor:(NSColor*)color {
    _backgroundColor = color;
    
    [self.view needsToDrawRect:self.view.bounds];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super.view drawRect:dirtyRect];
    
    // Drawing code here.
    
    [_backgroundColor set];
    NSBezierPath * path = [NSBezierPath bezierPathWithRect:self.view.bounds];
    [path fill];
}

@end
