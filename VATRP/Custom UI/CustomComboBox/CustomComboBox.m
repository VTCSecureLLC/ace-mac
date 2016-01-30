//
//  CustomComboBox.m
//  ACE
//
//  Created by Karen Muradyan on 1/30/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import "CustomComboBox.h"
#import "CustomComboBoxCell.h"
#import "NSImageView+WebCache.h"
#import "BackgroundedView.h"

@interface CustomComboBox ()<NSTableViewDataSource, NSTableViewDelegate> {
    NSColor *_backgroundColor;
}

@property (weak, nonatomic) IBOutlet NSTableView *itemsTableView;
@property (weak, nonatomic) IBOutlet NSImageView *itemImageView;
@property (weak, nonatomic) IBOutlet NSButton *comboButton;
@property (weak, nonatomic) IBOutlet NSTextField *selectedItemTextField;
@property (weak, nonatomic) IBOutlet BackgroundedView *backgroundView;

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
}

#pragma mark - TableView delegate methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _dataSource.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    CustomComboBoxCell *cellView = [tableView makeViewWithIdentifier:@"CustomComboBoxCell" owner:self];
   
    NSDictionary *dict = [_dataSource objectAtIndex:row];
    NSString *imageName = [dict objectForKey:@"providerLogo"];
    NSURL *imageURL = [NSURL URLWithString:imageName];
    
    [cellView.imgView setImageURL:imageURL];
    [cellView.txtLabel setStringValue:[dict objectForKey:@"name"]];
    
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
        if ([self.delegate respondsToSelector:@selector(customComboBox:didSelectedItem:)]) {
            [self.delegate customComboBox:self didSelectedItem:[_dataSource objectAtIndex:selectedRow]];
        }
    }
}

- (IBAction)onExpandButton:(id)sender {
    _backgroundView.hidden = !_backgroundView.hidden;
    if (_backgroundView.hidden == NO) {
        //[NSTableView selectRowIndexes:byExendingSelection:]
        [self.itemsTableView reloadData];
    }
}

- (void)selectItemAtIndex:(int)selectedItemIndex {
    NSDictionary *dict = [_dataSource objectAtIndex:selectedItemIndex];
    NSString *imageName = [dict objectForKey:@"providerLogo"];
    NSURL *imageURL = [NSURL URLWithString:imageName];
    [_itemImageView setImageURL:imageURL];
    [_selectedItemTextField setStringValue:[dict objectForKey:@"name"]];
}

@end
