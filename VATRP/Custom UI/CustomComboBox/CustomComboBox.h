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
@optional
- (void)customComboBox:(CustomComboBox*)sender didOpenedComboTable:(BOOL)isOpened;

@end

@interface CustomComboBox : NSView

@property (strong, nonatomic) NSMutableArray *dataSource;
@property (weak, nonatomic) id <CustomComboBoxDelegate> delegate;

- (void)selectItemAtIndex:(int)selectedItemIndex;
- (void)selectItemByName:(NSString*)selectItemName;
- (void)selectItemByDomain:(NSString*)selectItemDomain;
- (NSUInteger)indexOfSelectedItem;

- (void)addEmptyProviderInDataSource;

@end
