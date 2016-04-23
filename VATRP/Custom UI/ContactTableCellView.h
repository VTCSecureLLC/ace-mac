//
//  ContactTableCellView.h
//  ACE
//
//  Created by User on 24/11/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ContactTableCellViewDelegate;

@interface ContactTableCellView : NSTableCellView

@property (weak) IBOutlet NSTextField *nameTextField;
@property (weak) IBOutlet NSTextField *phoneTextField;
@property (strong, nonatomic) NSString *providerName;
@property (weak) IBOutlet NSImageView *imgView;
@property (weak) IBOutlet NSButton *deleteButton;
@property (weak) IBOutlet NSButton *editButton;
@property (nonatomic, assign) id<ContactTableCellViewDelegate> delegate;
@property (nonatomic, strong) NSString *refKey;

@end

@protocol ContactTableCellViewDelegate <NSObject>

@optional

- (void) didClickEditButton:(ContactTableCellView*)contactCellView;
- (void) didClickDeleteButton:(ContactTableCellView*)contactCellView;

@end