//
//  MoreSection.m
//  ACE
//
//  Created by Karen Muradyan on 4/7/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import "MoreSectionViewController.h"
#import "MoreSectionTableViewCell.h"

@interface MoreSectionViewController () <NSTableViewDelegate, NSTableViewDataSource>
{
    NSArray *moreSectionsTextsArray;
    NSArray *moreSectionsLeftImagesArray;
    NSArray *moreSectionsRightImagesArray;
}

@property (weak) IBOutlet NSView *moreSectionView;
@property (weak) IBOutlet NSTableView *moreSectionViewTableView;

@end

@implementation MoreSectionViewController

- (void) awakeFromNib {
    [super awakeFromNib];
    [self initMoreSectionData];
    [self.moreSectionViewTableView reloadData];
}

- (void)initMoreSectionData {
    moreSectionsTextsArray = @[@"Settings",
                               @"Resources",
                               @"Videomail",
                               @"Self-Preview"];
    moreSectionsLeftImagesArray = @[@"male",
                                    @"male",
                                    @"male",
                                    @"male"];
    moreSectionsRightImagesArray = @[];
    _moreSectionViewTableView.delegate = self;
    _moreSectionViewTableView.dataSource = self;
}

#pragma mark - TableView delegate methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return moreSectionsTextsArray.count;
}

#if defined __MAC_10_9 || defined __MAC_10_8
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
#else
    - (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
#endif

            MoreSectionTableViewCell *moreSectionCellView = [tableView makeViewWithIdentifier:@"MoreSectionTableViewCell" owner:self];
            moreSectionCellView.moreSectionLeftImageView = [moreSectionsLeftImagesArray objectAtIndex:row];
            moreSectionCellView.moreSectionTextField.stringValue = [moreSectionsTextsArray objectAtIndex:row];
            //moreSectionCellView.moreSectionRightImageView = [moreSectionsRightImagesArray objectAtIndex:row];
            return moreSectionCellView;
}
    
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
        return 53;
}
    
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
        
        return false;
}
    

@end
