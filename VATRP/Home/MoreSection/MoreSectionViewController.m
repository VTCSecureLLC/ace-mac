//
//  MoreSection.m
//  ACE
//
//  Created by Karen Muradyan on 4/7/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import "MoreSectionViewController.h"
#import "MoreSectionTableViewCell.h"
#import "LinphoneManager.h"

@interface MoreSectionViewController () <NSTableViewDelegate, NSTableViewDataSource>
{
    NSArray *moreSectionsTextsArray;
    NSArray *moreSectionsLeftImagesArray;
    NSArray *moreSectionsRightImagesArray;
    
    int messagesUnreadCount;
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
    moreSectionsLeftImagesArray = @[@"setting",
                                    @"resource",
                                    @"videomail",
                                    @"self-preview"];
    moreSectionsRightImagesArray = @[];
    _moreSectionViewTableView.delegate = self;
    _moreSectionViewTableView.dataSource = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyReceived:) name:kLinphoneNotifyReceived object:nil];
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
        [moreSectionCellView.moreSectionLeftImageView setImage:[NSImage imageNamed:[moreSectionsLeftImagesArray objectAtIndex:row]]];
        
        NSString *title = [moreSectionsTextsArray objectAtIndex:row];
        
        if ([title isEqualToString:@"Videomail"]) {
            messagesUnreadCount = lp_config_get_int(linphone_core_get_config([LinphoneManager getLc]), "app", "voice_mail_messages_count", 0);
            
            moreSectionCellView.moreSectionTextField.stringValue = [NSString stringWithFormat:@"Videomail (%d)", messagesUnreadCount];
        } else {
            moreSectionCellView.moreSectionTextField.stringValue = title;
        }
        
        return moreSectionCellView;
}
    
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
        return 53;
}
    
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    
    if ([self.delegate respondsToSelector:@selector(didPressSection:)]) {
        switch (row) {
            case 0: {
                [self.delegate didPressSection:eSettings];
            }
                break;
            case 1: {
                [self.delegate didPressSection:eResources];
            }
                break;
            case 2: {
                [self.delegate didPressSection:eVideomail];
            }
                break;
            case 3: {
                [self.delegate didPressSection:eSelfPreview];
            }
                break;
            default: {
                [self.delegate didPressSection:eSettings];
            }
                break;
        }
        
    }
    
        return false;
}
    
- (void)notifyReceived:(NSNotification *)notif {
    const LinphoneContent * content = [[notif.userInfo objectForKey: @"content"] pointerValue];
    
    if ((content == NULL)
        || (strcmp("application", linphone_content_get_type(content)) != 0)
        || (strcmp("simple-message-summary", linphone_content_get_subtype(content)) != 0)
        || (linphone_content_get_buffer(content) == NULL)) {
        return;
    }
    const char* body = linphone_content_get_buffer(content);
    if ((body = strstr(body, "Voicemail: ")) == NULL) {
        NSLog(@"Received new NOTIFY from voice mail but could not find 'voice-message' in BODY. Ignoring it.");
        
        return;
    }
    
    sscanf(body, "Voicemail: %d", &messagesUnreadCount);
    
    // save in lpconfig for future
    lp_config_set_int(linphone_core_get_config([LinphoneManager getLc]), "app", "voice_mail_messages_count", messagesUnreadCount);
    
    [self.moreSectionViewTableView reloadData];
}

- (void) refreshVideomailCount {
    [self.moreSectionViewTableView reloadData];
}
    
@end
