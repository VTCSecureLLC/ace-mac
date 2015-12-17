//
//  SettingsView.m
//  ACE
//
//  Created by Norayr Harutyunyan on 12/8/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "SettingsView.h"
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
    
    settingsList = [[NSMutableArray alloc] init];
    
    NSString *FileDB = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"SettingsUI.plist"];
    settings = [NSArray arrayWithContentsOfFile:FileDB];
    
    for (NSArray *array in settings) {
        for (NSDictionary *dict in array) {
            if ([dict isKindOfClass:[NSString class]]) {
                SettingsHeaderModel *settingsHeaderModel = [[SettingsHeaderModel alloc] initWithTitle:(NSString *)dict];
                [settingsList addObject:settingsHeaderModel];
            } else {
                SettingsItemModel *settingsItemModel = [[SettingsItemModel alloc] initWithDictionary:dict];
                [settingsList addObject:settingsItemModel];
            }
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

    if ([object isKindOfClass:[SettingsHeaderModel class]]) {
        NSTextField *groupCell = [tableView makeViewWithIdentifier:@"GroupCell" owner:self];
        [groupCell setStringValue:object.title];
        return groupCell;
    } if ([object isKindOfClass:[SettingsItemModel class]]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"SettingsCell" owner:self];
        
        SettingsItemModel *item = (SettingsItemModel*)object;
        
        switch (item.controller_Type) {
            case controllerType_checkbox: {
                NSButton *checkbox= [[NSButton alloc] initWithFrame:NSMakeRect(10, 3, 200, 20)];
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
                NSTextField *labelTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 3, 100, 20)];
                labelTitle.editable = NO;
                labelTitle.stringValue = item.title;
                [labelTitle.cell setBordered:NO];
                [labelTitle setBackgroundColor:[NSColor clearColor]];
                [cellView addSubview:labelTitle];
                
                NSTextField *textFieldValue = [[NSTextField alloc] initWithFrame:NSMakeRect(120, 3, 170, 20)];
                textFieldValue.tag = row;
                textFieldValue.stringValue = item.defaultValue;
                textFieldValue.editable = YES;
                [cellView addSubview:textFieldValue];
                
            }
                break;
            case controllerType_color: {
                NSTextField *labelTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 3, 100, 20)];
                labelTitle.editable = NO;
                labelTitle.stringValue = item.title;
                [labelTitle.cell setBordered:NO];
                [labelTitle setBackgroundColor:[NSColor clearColor]];
                [cellView addSubview:labelTitle];
                
                NSColor *color = [SettingsService getColorWithKey:item.userDefaultsKey];
                NSColorWell *colorWell = [[NSColorWell alloc] initWithFrame:NSMakeRect(120, 1, 170, 24)];
                colorWell.tag = row;
                [colorWell setColor:color ? color : [NSColor whiteColor]];
                [colorWell setAction:@selector(chartColorChange:)];
                [colorWell setTarget:self];
                [cellView addSubview:colorWell];
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

    if ([item.userDefaultsKey isEqualToString:@"SIP_ENCRYPTION"]) {
        [SettingsService setSIPEncryption:checkbox.state];
    } else if ([item.userDefaultsKey isEqualToString:@"START_ON_BOOT"]) {
        [SettingsService setStartAppOnBoot:checkbox.state];
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

@end
