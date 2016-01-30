//
//  CustomComboBoxCell.h
//  ACE
//
//  Created by Karen Muradyan on 1/30/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CustomComboBoxCell : NSTableCellView

@property (weak, nonatomic) IBOutlet NSImageView *imgView;
@property (weak, nonatomic) IBOutlet NSTextField *txtLabel;

@end
