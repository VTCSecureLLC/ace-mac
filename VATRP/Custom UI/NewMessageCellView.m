//
//  NewMessageCellView.m
//  ACE
//
//  Created by Norayr Harutyumyan on 10/26/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "NewMessageCellView.h"

@implementation NewMessageCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    
    [[NSColor grayColor] set];
    NSBezierPath * path = [NSBezierPath bezierPathWithOvalInRect:CGRectMake(8, 8, 48, 48)];
    [path fill];
}

@end
