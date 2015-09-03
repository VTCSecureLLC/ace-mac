//
//  RecentsViewController.m
//  MacApp
//
//  Created by Norayr Harutyunyan on 8/28/15.
//  Copyright (c) 2015 Cinehost. All rights reserved.
//

#import "RecentsViewController.h"

@interface RecentsViewController ()

@end

@implementation RecentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return 10;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
    NSString *entity = [NSString stringWithFormat:@"%ld", (long)row];
    [cellView.textField setStringValue:entity];
    
    return cellView;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 22;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
//    selectedRow = marrayLoad[row];
    
    return YES;
}

@end
