//
//  CustomComboBoxCell.m
//  ACE
//
//  Created by Karen Muradyan on 1/30/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import "CustomComboBoxCell.h"

@interface CustomComboBoxCell () {
    NSColor *_backgroundColor;
}

@end

@implementation CustomComboBoxCell

- (void) setBackgroundColor:(NSColor*)color {
    _backgroundColor = color;
    
    [self needsToDrawRect:self.bounds];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    
    [_backgroundColor set];
    NSBezierPath * path = [NSBezierPath bezierPathWithRect:self.bounds];
    [path fill];
}

@end
