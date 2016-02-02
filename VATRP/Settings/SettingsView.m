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
#import "SDPNegotiationService.h"

@interface SettingsView () <NSTextFieldDelegate> {
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

                SettingsHeaderModel *object = settingsList[row];
                NSInteger index = row;

                while (![object isKindOfClass:[SettingsHeaderModel class]]) {
                    index--;
                    object = settingsList[index];
                }
                
                if (object && object.title && ([object.title isEqualToString:@"Audio Codecs"] || [object.title isEqualToString:@"Video Codecs"])) {
                    checkbox.state = [self getAudioCodecEnabledStateWithUserDefaultsKey:item];
                } else {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    if (item.userDefaultsKey && [[[defaults dictionaryRepresentation] allKeys] containsObject:item.userDefaultsKey]) {
                        NSInteger value = [[NSUserDefaults standardUserDefaults] boolForKey:item.userDefaultsKey];
                        checkbox.state = value;
                    } else {
                        [checkbox setState:[item.defaultValue boolValue]];
                    }
                }
                
                [checkbox setAction:@selector(checkboxHandler:)];
                [checkbox setTarget:self];
                [cellView addSubview:checkbox];
                
                if ([item.userDefaultsKey isEqualToString:@"ACE_ENABLE_UPNP"]) {
                    [checkbox setEnabled:linphone_core_upnp_available()];
                }
            }
                break;
            case controllerType_textfield: {
                NSTextField *labelTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(10 + 10*(object.position-1), 3, 100, 20)];
                labelTitle.editable = NO;
                labelTitle.stringValue = item.title;
                [labelTitle.cell setBordered:NO];
                [labelTitle setBackgroundColor:[NSColor clearColor]];
                [cellView addSubview:labelTitle];
                
                NSString *textfieldValue = [self textFieldValueWithUserDefaultsKey:item.userDefaultsKey];
                
                NSTextField *textFieldValue = [[NSTextField alloc] initWithFrame:NSMakeRect(120 + 10*(object.position-1), 3, 170, 20)];
                textFieldValue.delegate = self;
                textFieldValue.tag = row;
                textFieldValue.stringValue = textfieldValue ? textfieldValue : item.defaultValue;
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

- (NSString*) textFieldValueWithUserDefaultsKey:(NSString*)key {
    if ([key isEqualToString:@"ACE_USERNAME"]) {
        AccountModel *accountModel = [[AccountsService sharedInstance] getDefaultAccount];
        return accountModel.username;
    } else if ([key isEqualToString:@"ACE_AUTH_ID"]) {
        AccountModel *accountModel = [[AccountsService sharedInstance] getDefaultAccount];
        return accountModel.userID;
    } else if ([key isEqualToString:@"ACE_DOMAIN"]) {
        AccountModel *accountModel = [[AccountsService sharedInstance] getDefaultAccount];
        return accountModel.domain;
    } else {
        return [[NSUserDefaults standardUserDefaults] objectForKey:key];
    }
    
    return nil;
}

- (BOOL) getAudioCodecEnabledStateWithUserDefaultsKey:(SettingsItemModel*)settingsItemModel {
    LinphoneCore *lc = [LinphoneManager getLc];
    PayloadType *pt;
    const MSList *elem;
    const MSList *audioCodecs = linphone_core_get_audio_codecs(lc);
    NSDictionary *dictAudioCodec = [[NSUserDefaults standardUserDefaults] objectForKey:kUSER_DEFAULTS_AUDIO_CODECS_MAP];
    
    for (elem = audioCodecs; elem != NULL; elem = elem->next) {
        pt = (PayloadType *)elem->data;
        NSString *pref = [SDPNegotiationService getPreferenceForCodec:pt->mime_type withRate:pt->clock_rate];
        
        if (pref && [pref isEqualToString:settingsItemModel.userDefaultsKey]) {
            if ([dictAudioCodec objectForKey:pref]) {
                return [[dictAudioCodec objectForKey:pref] boolValue];
            } else {
                return linphone_core_payload_type_enabled(lc, pt);
            }
        }
    }
    
    const MSList *videoCodecs = linphone_core_get_video_codecs(lc);
    NSDictionary *dictVideoCodec = [[NSUserDefaults standardUserDefaults] objectForKey:kUSER_DEFAULTS_VIDEO_CODECS_MAP];

    for (elem = videoCodecs; elem != NULL; elem = elem->next) {
        pt = (PayloadType *)elem->data;
        NSString *pref = [SDPNegotiationService getPreferenceForCodec:pt->mime_type withRate:pt->clock_rate];
        
        if (pref && [pref isEqualToString:settingsItemModel.userDefaultsKey]) {
            if ([dictVideoCodec objectForKey:pref]) {
                return [[dictVideoCodec objectForKey:pref] boolValue];
            } else {
                return linphone_core_payload_type_enabled(lc, pt);
            }
        }
    }
    
    return [settingsItemModel.defaultValue  boolValue];
}

- (void) checkboxHandler:(id)sender {
    NSButton *checkbox = (NSButton*)sender;
    
    SettingsItemModel *item = (SettingsItemModel*)settingsList[checkbox.tag];
    LinphoneCore *lc = [LinphoneManager getLc];
    
    if ((item != nil) && (item.userDefaultsKey != nil)) {
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
        } else if ([item.userDefaultsKey isEqualToString:@"stun_preference"]) {
            [SettingsService setStun:checkbox.state];
        } else if ([item.userDefaultsKey isEqualToString:@"ice_preference"]) {
            [SettingsService setICE:checkbox.state];
        } else if ([item.userDefaultsKey isEqualToString:@"ACE_ENABLE_UPNP"]) {
            [SettingsService setUPNP:checkbox.state];
        } else if ([item.userDefaultsKey isEqualToString:@"random_port_preference"]) {
            [SettingsService setRandomPorts:checkbox.state];
        } else if ([item.userDefaultsKey isEqualToString:@"use_ipv6"]) {
            linphone_core_enable_ipv6(lc, checkbox.state);
            [[NSUserDefaults standardUserDefaults] setBool:checkbox.state forKey:item.userDefaultsKey];
        } else {
            NSDictionary *dictAudioCodec = [[NSUserDefaults standardUserDefaults] objectForKey:kUSER_DEFAULTS_AUDIO_CODECS_MAP];
            NSDictionary *dictVideoCodec = [[NSUserDefaults standardUserDefaults] objectForKey:kUSER_DEFAULTS_VIDEO_CODECS_MAP];

            if (item.userDefaultsKey && [[dictAudioCodec allKeys] containsObject:item.userDefaultsKey]) {
                NSMutableDictionary *mdictForSave = [[NSMutableDictionary alloc] initWithDictionary:dictAudioCodec];
                [mdictForSave setObject:[NSNumber numberWithBool:checkbox.state] forKey:item.userDefaultsKey];
                [[NSUserDefaults standardUserDefaults] setObject:mdictForSave forKey:kUSER_DEFAULTS_AUDIO_CODECS_MAP];
            } else if (item.userDefaultsKey && [[dictVideoCodec allKeys] containsObject:item.userDefaultsKey]) {
                NSMutableDictionary *mdictForSave = [[NSMutableDictionary alloc] initWithDictionary:dictVideoCodec];
                [mdictForSave setObject:[NSNumber numberWithBool:checkbox.state] forKey:item.userDefaultsKey];
                [[NSUserDefaults standardUserDefaults] setObject:mdictForSave forKey:kUSER_DEFAULTS_VIDEO_CODECS_MAP];
            } else {
                [[NSUserDefaults standardUserDefaults] setBool:checkbox.state forKey:item.userDefaultsKey];
            }
        }

        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void) chartColorChange:(id)sender {
    NSColorWell *colorWell = (NSColorWell*)sender;
    NSColor *color = colorWell.color;
    
    SettingsItemModel *item = (SettingsItemModel*)settingsList[colorWell.tag];
    [SettingsService setColorWithKey:item.userDefaultsKey Color:color];
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

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
    NSTextField *textField = (NSTextField*)control;
    LinphoneCore *lc = [LinphoneManager getLc];

    SettingsItemModel *item = (SettingsItemModel*)settingsList[textField.tag];

    if ([item.userDefaultsKey isEqualToString:@"stun_url_preference"]) {
        [[NSUserDefaults standardUserDefaults] setObject:textField.stringValue forKey:@"stun_url_preference"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [SettingsService setStun:[[NSUserDefaults standardUserDefaults] boolForKey:@"stun_preference"]];
    } else if ([item.userDefaultsKey isEqualToString:@"video_preferred_fps_preference"]) {
        // ToDo: Hardcoding on 2-2 per request
        linphone_core_set_preferred_framerate(lc, 30.0f);//textField.floatValue);
    }
    
    return YES;
}

@end

//username
//userID
//domain
//audio codecs
//video codecs
//stun
//stun url
//ice
//upnp
//ipv6
//preferred fps