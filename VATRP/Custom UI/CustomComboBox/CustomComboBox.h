//
//  CustomComboBox.h
//  ACE
//
//  Created by Karen Muradyan on 1/30/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CustomComboBox;
@protocol CustomComboBoxDelegate <NSObject>
- (void)customComboBox:(CustomComboBox*)sender didSelectedItem:(NSDictionary*)selectedItem;
@end

@interface CustomComboBox : NSView

@property (strong, nonatomic) NSArray *dataSource;
@property (weak, nonatomic) id <CustomComboBoxDelegate> delegate;

- (void)selectItemAtIndex:(int)selectedItemIndex;

@end
