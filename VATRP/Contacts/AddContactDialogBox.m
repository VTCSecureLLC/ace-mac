//
//  AddContactDialogBox.m
//  ACE
//
//  Created by User on 24/11/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "AddContactDialogBox.h"

@interface AddContactDialogBox ()

@property (weak) IBOutlet NSTextField *nameTextField;
@property (weak) IBOutlet NSTextField *phoneTextField;

@end


@implementation AddContactDialogBox

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.isEditing) {
        [self setTitle:@"Edit contact"];
        [self.nameTextField setStringValue:self.oldName];
        [self.phoneTextField setStringValue:self.oldPhone];
    } else {
        [self setTitle:@"Add contact"];
    }
}

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
        [[NSNotificationCenter defaultCenter] postNotificationName:@"contactInfoEditDone"
                                                            object:@{@"name" : [self.nameTextField stringValue],
                                                                     @"phone": [self.phoneTextField stringValue],
                                                                     @"oldName": self.oldName,
                                                                     @"oldPhone" : self.oldPhone}
                                                          userInfo:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"contactInfoFilled"
                                                            object:@{@"name" : [self.nameTextField stringValue],
                                                                     @"phone": [self.phoneTextField stringValue]}
                                                          userInfo:nil];
    }
    [self dismissController:nil];
}

@end
