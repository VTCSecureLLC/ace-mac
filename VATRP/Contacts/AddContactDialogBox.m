//
//  AddContactDialogBox.m
//  ACE
//
//  Created by User on 24/11/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "AddContactDialogBox.h"
#import "LinphoneManager.h"
#import "Utils.h"
#import "CustomComboBox.h"

@interface AddContactDialogBox ()<NSComboBoxDelegate, CustomComboBoxDelegate> {
    NSMutableArray *providerNames;
    NSString *providerAddress;
    NSDictionary *providers;
    NSString *name;
    NSString *phone;
}

@property (weak) IBOutlet NSTextField *nameTextField;
@property (weak) IBOutlet NSTextField *phoneTextField;
@property (weak) IBOutlet NSComboBox *providerComboBox;
@property (weak) IBOutlet NSButton *doneButton;
@property (strong, nonatomic) IBOutlet CustomComboBox *customComboBox;

@end


@implementation AddContactDialogBox

#pragma mark - Controller lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.isEditing) {
        [self setTitle:@"Edit contact"];
        [self.nameTextField setStringValue:self.oldName];
        [self.phoneTextField setStringValue:[Utils makeAccountNumberFromSipURI:self.oldPhone]];
        name = [self.nameTextField stringValue];
        phone = [self.phoneTextField stringValue];
    } else {
        [self setTitle:@"Add contact"];
    }
    [self initCustomComboBox];
    [self.providerComboBox reloadData];
}

- (void)initCustomComboBox {
    _customComboBox.delegate = self;
    _customComboBox.dataSource = [[Utils cdnResources] mutableCopy];
    if (self.isEditing) {
        [_customComboBox selectItemByDomain:self.oldProviderName];
        providerAddress = self.oldProviderName;
    } else {
        [_customComboBox selectItemAtIndex:0];
        NSDictionary *dict = [[Utils cdnResources] objectAtIndex:[_customComboBox indexOfSelectedItem]];
        providerAddress = [dict objectForKey:@"domain"];
    }
}

#pragma mark - Buttons action functions

- (IBAction)onButtonDone:(id)sender {
    
    if ([[self.nameTextField stringValue] isEqualToString:@""] || [[self.phoneTextField stringValue] isEqualToString:@""]) {
        [self dismissController:nil];
        return;
    }
    if (self.isEditing) {
        if ([self.oldName isEqualToString:[self.nameTextField stringValue]] &&
            [self.oldPhone isEqualToString:[self.phoneTextField stringValue]]) {
            [self dismissController:nil];
            return;
        }
        if ([self isDoneEditions]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"contactInfoEditDone"
                                                                object:@{@"name" : [self.nameTextField stringValue],
                                                                         @"phone": [self createFullSipUriFromString:[self.phoneTextField stringValue]],
                                                                         @"oldName": self.oldName,
                                                                         @"oldPhone" : self.oldPhone,
                                                                         @"provider" : providerAddress}
                                                              userInfo:nil];
        }
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"contactInfoFilled"
                                                            object:@{@"name" : [self.nameTextField stringValue],
                                                                     @"phone": [self createFullSipUriFromString:[self.phoneTextField stringValue]],
                                                                     @"provider" : providerAddress}
                                                          userInfo:nil];
    }
    [self dismissController:nil];
}

#pragma mark - Combobox delegate methods

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox {
    return [providerNames count];
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index {
    if (self.providerComboBox == aComboBox) {
        return [providerNames objectAtIndex:index];
    }
    return nil;
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
    NSString *providerDisplayName = [providerNames objectAtIndex:[(NSComboBox *)[notification object] indexOfSelectedItem]];
    providerAddress = [providers objectForKey:providerDisplayName];
}

#pragma mark - helper functions

- (void)makeProviderName {
    LinphoneProxyConfig* current_conf = NULL;
    linphone_core_get_default_proxy([LinphoneManager getLc], &current_conf);
    if( current_conf != NULL ){
        const char *domain = linphone_proxy_config_get_domain(current_conf);
        providerAddress = [NSString stringWithUTF8String:domain];
    }
}

- (NSString*)createFullSipUriFromString:(NSString*)str {
    NSString *sipUri = str;
    if ([Utils nsStringIsValidSip:sipUri]) {
        sipUri = [@"sip:" stringByAppendingString:sipUri];
    } else {
        sipUri = [Utils makeSipURIWithAccountName:str andProviderAddress:providerAddress];
    }
    
    return sipUri;
}

- (BOOL)isDoneEditions {
    
    if (![name isEqualToString:[self.nameTextField stringValue]] || ![phone isEqualToString:[self.phoneTextField stringValue]]) {
        return YES;
    }
    
    return NO;
}

#pragma mark - CustomComboBox delegate methods

- (void)customComboBox:(CustomComboBox *)sender didSelectedItem:(NSDictionary *)selectedItem {
    providerAddress = [selectedItem objectForKey:@"domain"];
}

- (void)customComboBox:(CustomComboBox *)sender didOpenedComboTable:(BOOL)isOpened {
    [_doneButton setEnabled:!isOpened];
}

@end
