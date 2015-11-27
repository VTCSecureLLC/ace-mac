//
//  AddContactDialogBox.m
//  ACE
//
//  Created by User on 24/11/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "AddContactDialogBox.h"
#import "LinphoneManager.h"

@interface AddContactDialogBox ()<NSComboBoxDelegate> {
    NSMutableArray *providerNames;
    NSString *providerAddress;
    NSDictionary *providers;
}

@property (weak) IBOutlet NSTextField *nameTextField;
@property (weak) IBOutlet NSTextField *phoneTextField;
@property (weak) IBOutlet NSComboBox *providerComboBox;

@end


@implementation AddContactDialogBox

#pragma mark - Controller lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initProvider];
    if (self.isEditing) {
        [self setTitle:@"Edit contact"];
        [self.nameTextField setStringValue:self.oldName];
        [self.phoneTextField setStringValue:self.oldPhone];
    } else {
        [self setTitle:@"Add contact"];
    }
    [self.providerComboBox reloadData];
}

- (void)initProvider {
    providerNames = [NSMutableArray arrayWithObjects:@"Sorenson VRS", @"ZVRS", @"CAAG", @"Purple VRS", @"Global VRS", @"Convo Relay", nil];
    //TODO: Change this implementation after definitely decided the providers issue.
    providers = @{@"Sorenson VRS" : @"vrs.net",
                  @"ZVRS": @"zvrs.net",
                  @"CAAG": @"caag.net",
                  @"Purple VRS" : @"prpl.net",
                  @"Global VRS": @"glbl.net",
                  @"Convo Relay": @"cnvr.net"};
}

#pragma mark - Buttons action functions

- (IBAction)onButtonDone:(id)sender {
    
    if ([[self.nameTextField stringValue] isEqualToString:@""] || [[self.phoneTextField stringValue] isEqualToString:@""]) {
        [self dismissController:nil];
        return;
    }
    [self makeProviderName];
    if (self.isEditing) {
        if ([self.oldName isEqualToString:[self.nameTextField stringValue]] &&
            [self.oldPhone isEqualToString:[self.phoneTextField stringValue]]) {
            [self dismissController:nil];
            return;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"contactInfoEditDone"
                                                            object:@{@"name" : [self.nameTextField stringValue],
                                                                     @"phone": [self.phoneTextField stringValue],
                                                                     @"oldName": self.oldName,
                                                                     @"oldPhone" : self.oldPhone,
                                                                     @"provider" : providerAddress}
                                                          userInfo:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"contactInfoFilled"
                                                            object:@{@"name" : [self.nameTextField stringValue],
                                                                     @"phone": [self.phoneTextField stringValue],
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

@end
