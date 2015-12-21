//
//  SettingsView.m
//  ACE
//
//  Created by Norayr Harutyunyan on 12/8/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "SettingsView.h"
#import "LinphoneManager.h"
#import "SettingsService.h"
#import "SettingsHeaderModel.h"
#import "SettingsItemModel.h"
#import "AccountsService.h"
#import "RegistrationService.h"

@interface SettingsView () {
    NSArray *settings;
    NSMutableArray *settingsList;
    
    NSTextField *labelTitleColor;
}

@property (weak) IBOutlet NSScrollView *scrollViewContacts;
@property (weak) IBOutlet NSTableView *tableViewContacts;

@end

@implementation SettingsView

- (void) awakeFromNib {
    [super awakeFromNib];
    
    static BOOL first = YES;
    
    if (first) {
        first = NO;
        settingsList = [[NSMutableArray alloc] init];
        
        NSString *FileDB = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"SettingsUI.plist"]; // SettingsAdvancedUI.plist
        settings = [NSArray arrayWithContentsOfFile:FileDB];
        
        [self loadSettingsFromArray:settings];
    }
}

- (void) loadSettingsFromArray:(NSArray*)array_  {
    static int position = 0;
    SettingsHeaderModel *settingsHeaderModel;
    for (NSDictionary *dict in array_) {
        if ([dict isKindOfClass:[NSString class]]) {
            settingsHeaderModel = [[SettingsHeaderModel alloc] initWithTitle:(NSString *)dict];
            settingsHeaderModel.position = position;
            [settingsList addObject:settingsHeaderModel];
        } else if ([dict isKindOfClass:[NSDictionary class]]) {
            SettingsItemModel *settingsItemModel = [[SettingsItemModel alloc] initWithDictionary:dict];
            settingsItemModel.position = settingsHeaderModel.position;
            [settingsList addObject:settingsItemModel];
        } else if ([dict isKindOfClass:[NSArray class]]) {
            position++;
            [self loadSettingsFromArray:(NSArray *)dict];
            position--;
        }
    }
}

- (void) setFrame:(NSRect)frame {
    [super setFrame:frame];
    [self.scrollViewContacts setFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height)];
}

#pragma mark - TableView delegate methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return settingsList.count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    SettingsHeaderModel *object = settingsList[row];
    
    if ([object isKindOfClass:[SettingsHeaderModel class]]) {
        return 20;
    } else if ([object isKindOfClass:[SettingsItemModel class]]) {
        return 26;
    }
    
    return 1;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    SettingsHeaderModel *object = settingsList[row];

    NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"SettingsCell" owner:self];

    NSArray *subviews = [cellView subviews];
    
    int index = 0;
    while (index < subviews.count) {
        id v = [subviews objectAtIndex:index];

        if ([v isKindOfClass:[NSTextField class]] || [v isKindOfClass:[NSButton class]] || [v isKindOfClass:[NSColorWell class]]) {
            [v removeFromSuperview];
            
            continue;
        }
        
        index++;
    }
    
    
    if ([object isKindOfClass:[SettingsHeaderModel class]]) {

        NSTextField *labelTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(10*(object.position-1), 3, 100, 20)];
        labelTitle.editable = NO;
        labelTitle.stringValue = object.title;
        [labelTitle.cell setBordered:NO];
        [labelTitle setBackgroundColor:[NSColor clearColor]];
        [cellView addSubview:labelTitle];

        return cellView;
    } if ([object isKindOfClass:[SettingsItemModel class]]) {
        
        SettingsItemModel *item = (SettingsItemModel*)object;
        
        switch (item.controller_Type) {
            case controllerType_checkbox: {
                NSButton *checkbox= [[NSButton alloc] initWithFrame:NSMakeRect(10 + 10*(object.position-1), 3, 200, 20)];
                checkbox.tag = row;
                [checkbox setButtonType:NSSwitchButton];
                [checkbox setBezelStyle:0];
                [checkbox setTitle:item.title];

                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                if (item.userDefaultsKey && [[[defaults dictionaryRepresentation] allKeys] containsObject:item.userDefaultsKey]) {
                    NSInteger value = [[NSUserDefaults standardUserDefaults] boolForKey:item.userDefaultsKey];
                    checkbox.state = value;
                } else {
                    [checkbox setState:[item.defaultValue boolValue]];
                }
                
                [checkbox setAction:@selector(checkboxHandler:)];
                [checkbox setTarget:self];
                [cellView addSubview:checkbox];
            }
                break;
            case controllerType_textfield: {
                NSTextField *labelTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(10 + 10*(object.position-1), 3, 100, 20)];
                labelTitle.editable = NO;
                labelTitle.stringValue = item.title;
                [labelTitle.cell setBordered:NO];
                [labelTitle setBackgroundColor:[NSColor clearColor]];
                [cellView addSubview:labelTitle];
                
                NSTextField *textFieldValue = [[NSTextField alloc] initWithFrame:NSMakeRect(120 + 10*(object.position-1), 3, 170, 20)];
                textFieldValue.tag = row;
                textFieldValue.stringValue = item.defaultValue;
                textFieldValue.editable = YES;
                [cellView addSubview:textFieldValue];
                
            }
                break;
            case controllerType_color: {
                NSTextField *labelTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(10 + 10*(object.position-1), 3, 100, 20)];
                labelTitle.editable = NO;
                labelTitle.stringValue = item.title;
                [labelTitle.cell setBordered:NO];
                [labelTitle setBackgroundColor:[NSColor clearColor]];
                [cellView addSubview:labelTitle];
                
                NSColor *color = [SettingsService getColorWithKey:item.userDefaultsKey];
                NSColorWell *colorWell = [[NSColorWell alloc] initWithFrame:NSMakeRect(120 + 10*(object.position-1), 1, 170, 24)];
                colorWell.tag = row;
                [colorWell setColor:color ? color : [NSColor whiteColor]];
                [colorWell setAction:@selector(chartColorChange:)];
                [colorWell setTarget:self];
                [cellView addSubview:colorWell];
            }
                break;
            case controllerType_button: {
                NSTextField *labelTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(10 + 10*(object.position-1), 3, 100, 20)];
                labelTitle.editable = NO;
                labelTitle.stringValue = item.title;
                [labelTitle.cell setBordered:NO];
                [labelTitle setBackgroundColor:[NSColor clearColor]];
                [cellView addSubview:labelTitle];

                NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(120 + 10*(object.position-1), 2, 170, 24)];
                [button setTarget:self];
                [button setAction:@selector(onButtonHandler:)];
                button.tag = row;
                [button setTitle:item.title];
                [cellView addSubview:button];
            }
                break;
            default:
                break;
        }
        
        return cellView;
    }
    
    return nil;
}

- (void) checkboxHandler:(id)sender {
    NSButton *checkbox = (NSButton*)sender;
    
    SettingsItemModel *item = (SettingsItemModel*)settingsList[checkbox.tag];
    LinphoneCore *lc = [LinphoneManager getLc];
    
    if ([item.userDefaultsKey isEqualToString:@"SIP_ENCRYPTION"]) {
        [SettingsService setSIPEncryption:checkbox.state];
    } else if ([item.userDefaultsKey isEqualToString:@"START_ON_BOOT"]) {
        [SettingsService setStartAppOnBoot:checkbox.state];
    } else if ([item.userDefaultsKey isEqualToString:@"enable_adaptive_rate_control"]) {
        linphone_core_enable_adaptive_rate_control(lc, checkbox.state);
    } else if ([item.userDefaultsKey isEqualToString:@"enable_video_preference"]) {
        linphone_core_enable_video(lc, checkbox.state, checkbox.state);
    } else if ([item.userDefaultsKey isEqualToString:@"accept_video_preference"]) {
        LinphoneVideoPolicy policy;
        policy.automatically_accept = (BOOL)checkbox.state;
        linphone_core_set_video_policy(lc, &policy);
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:checkbox.state forKey:item.userDefaultsKey];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) chartColorChange:(id)sender {
    NSColorWell *colorWell = (NSColorWell*)sender;
    NSColor *color = colorWell.color;
    
    SettingsItemModel *item = (SettingsItemModel*)settingsList[colorWell.tag];
    [SettingsService setColorWithKey:item.userDefaultsKey Color:color];
//    if ([color isKindOfClass:[NSColor class]]) {
//        NSLog(@"RED: %f, GREEN: %f, BLUE: %f, ALPHA: %f", color.redComponent/(1.0/255.0), color.greenComponent/(1.0/255.0), color.blueComponent/(1.0/255.0), color.alphaComponent);
//    } else {
////        color.numberOfComponents
//    }
    
//    [labelTitleColor setBackgroundColor:color];
    
}

- (void) onButtonHandler:(id)sender {
    NSButton *button = (NSButton*)sender;
    
    SettingsItemModel *item = (SettingsItemModel*)settingsList[button.tag];
    
    if ([item.userDefaultsKey isEqualToString:@"ACE_VIEW_TSS"]) {
        
    } else if ([item.userDefaultsKey isEqualToString:@"ACE_SEND_TSS"]) {
        
    } else if ([item.userDefaultsKey isEqualToString:@"ACE_SHOW_ADVANCED"]) {
        [settingsList removeAllObjects];
        NSString *FileDB = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"SettingsAdvancedUI.plist"];
        settings = [NSArray arrayWithContentsOfFile:FileDB];
        [self loadSettingsFromArray:settings];
        
        [self.tableViewContacts reloadData];
    }
}

@end

//enable_adaptive_rate_control
//enable_video_preference
//accept_video_preference