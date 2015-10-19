//
//  ContactTableCellView.m
//  ACE
//
//  Created by Edgar Sukiasyan on 10/14/15.
//  Copyright © 2015 Home. All rights reserved.
//

#import "ContactTableCellView.h"

@implementation ContactTableCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    
    [[NSColor grayColor] set];
    NSBezierPath * path = [NSBezierPath bezierPathWithOvalInRect:CGRectMake(8, 8, 48, 48)];
    [path fill];
}

@end
