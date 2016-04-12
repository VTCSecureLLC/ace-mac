//
//  MoreSectionTableViewCell.m
//  ACE
//
//  Created by Karen Muradyan on 4/7/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import "MoreSectionTableViewCell.h"

@implementation MoreSectionTableViewCell


- (void) awakeFromNib {
    self.moreSectionTextField.bezeled         = NO;
    self.moreSectionTextField.editable        = NO;
    self.moreSectionTextField.drawsBackground = NO;
    [self.backgroundView setBackgroundColor:[NSColor colorWithRed:64.0/255.0 green:64.0/255.0 blue:64.0/255.0 alpha:1]];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
