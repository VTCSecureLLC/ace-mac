//
//  CustomComboBox.m
//  ACE
//
//  Created by Karen Muradyan on 1/30/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import "CustomComboBox.h"
#import "CustomComboBoxCell.h"
#import "BackgroundedView.h"

@interface CustomComboBox ()<NSTableViewDataSource, NSTableViewDelegate> {
    NSColor *_backgroundColor;
}

@property (weak, nonatomic) IBOutlet NSTableView *itemsTableView;
@property (weak, nonatomic) IBOutlet NSImageView *itemImageView;
@property (weak, nonatomic) IBOutlet NSButton *comboButton;
@property (weak, nonatomic) IBOutlet NSTextField *selectedItemTextField;
@property (weak, nonatomic) IBOutlet BackgroundedView *backgroundView;
@property  NSUInteger selectedItemIndex;

@end

@implementation CustomComboBox

- (void) setBackgroundColor:(NSColor*)color {
    _backgroundColor = color;
    [self needsToDrawRect:self.bounds];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [_backgroundColor set];
    NSBezierPath * path = [NSBezierPath bezierPathWithRect:self.bounds];
    [path fill];
    _backgroundColor = [NSColor whiteColor];
    [self setWantsLayer: YES];
    [self.layer setBorderWidth:0.2];
    [_itemsTableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
    _selectedItemIndex = 0;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    return YES;
}

#pragma mark - TableView delegate methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _dataSource.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    CustomComboBoxCell *cellView = [tableView makeViewWithIdentifier:@"CustomComboBoxCell" owner:self];
   
    NSDictionary *dict = [_dataSource objectAtIndex:row];
    NSString *imageName = [dict objectForKey:@"providerLogo"];
    NSString *providerName = [dict objectForKey:@"name"];
    
    [cellView.imgView setImage:[[NSImage alloc]initWithContentsOfFile:imageName]];
    [cellView.txtLabel setStringValue:providerName];
    
    if ([providerName isEqualToString:[_selectedItemTextField stringValue]]) {
        [cellView setBackgroundColor:[NSColor colorWithCalibratedRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f]];
    } else {
        [cellView setBackgroundColor:[NSColor whiteColor]];
    }
    return cellView;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 30;
}

- (IBAction)didSelectedTableRow:(id)sender {
    int selectedRow = (int)[self.itemsTableView selectedRow];
    if (selectedRow >= 0 && selectedRow < _dataSource.count) {
        [self selectItemAtIndex:selectedRow];
        self.backgroundView.hidden = YES;
        if ([self.delegate respondsToSelector:@selector(customComboBox:didOpenedComboTable:)]) {
            [self.delegate customComboBox:self didOpenedComboTable:NO];
        }
        if ([self.delegate respondsToSelector:@selector(customComboBox:didSelectedItem:)]) {
            [self.delegate customComboBox:self didSelectedItem:[_dataSource objectAtIndex:selectedRow]];
        }
    }
}

- (IBAction)onExpandButton:(id)sender {
    _backgroundView.hidden = !_backgroundView.hidden;
    if (_backgroundView.hidden == NO) {
        if ([self.delegate respondsToSelector:@selector(customComboBox:didOpenedComboTable:)]) {
            [self.delegate customComboBox:self didOpenedComboTable:YES];
        }
        [self.itemsTableView reloadData];
    } else {
        if ([self.delegate respondsToSelector:@selector(customComboBox:didOpenedComboTable:)]) {
            [self.delegate customComboBox:self didOpenedComboTable:NO];
        }
    }
}

- (NSUInteger)indexOfSelectedItem {
    return _selectedItemIndex;
}

- (void)selectItemAtIndex:(int)selectedItemIndex {
    NSDictionary *dict = [_dataSource objectAtIndex:selectedItemIndex];
    NSString *imageName = [dict objectForKey:@"providerLogo"];
    [_itemImageView setImage:[[NSImage alloc]initWithContentsOfFile:imageName]];
    [_selectedItemTextField setStringValue:[dict objectForKey:@"name"]];
    _selectedItemIndex = selectedItemIndex;
}

- (void)selectItemByName:(NSString*)selectItemName {
    NSUInteger index = [_dataSource indexOfObjectPassingTest:^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                            return [[dict objectForKey:@"name"] isEqual:selectItemName];
                        }];
    if (index != NSNotFound) {
        [self selectItemAtIndex:(int)index];
        _selectedItemIndex = index;
    } else {
        [self selectItemAtIndex:(int)(_dataSource.count - 1)];
        _selectedItemIndex = (int)(_dataSource.count - 1);
    }
}

- (void)selectItemByDomain:(NSString*)selectItemDomain {
    NSUInteger index = [_dataSource indexOfObjectPassingTest:^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
        return [[dict objectForKey:@"domain"] isEqual:selectItemDomain];
    }];
    if (index != NSNotFound) {
        [self selectItemAtIndex:(int)index];
        _selectedItemIndex = index;
    } else {
        [self selectItemAtIndex:(int)(_dataSource.count - 1)];
        _selectedItemIndex = (int)(_dataSource.count - 1);
    }
}

- (void)addEmptyProviderInDataSource {
    NSDictionary *dict = @{@"name" : @"No Provider",
                           @"domain" : @"No Provider",
                           @"providerLogo" : @"whiteIcon"
                           };
    [_dataSource addObject:dict];
}

@end
