//
//  ContactTableCellView.m
//  ACE
//
//  Created by Ruben Semerjyan on 10/14/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "ChatContactTableCellView.h"

@implementation ChatContactTableCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    
    [[NSColor grayColor] set];
    NSBezierPath * path = [NSBezierPath bezierPathWithOvalInRect:CGRectMake(8, 8, 48, 48)];
    [path fill];
}

@end
