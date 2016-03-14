//
//  AddContactWindowController.m
//  ACE
//
//  Created by Lizann Epley on 3/12/16.
//  Copyright (c) 2016 VTCSecure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddContactWindowController.h"
#import "AddContactDialogBox.h"

@interface AddContactWindowController ()
{
    AddContactDialogBox *addContactDialogBox;
}
@end

@implementation AddContactWindowController
-(id) init
{
    self = [super initWithWindowNibName:@"AddContactWindowController"];
    if (self)
    {
        // init
        //        self.contentViewController = navigationController;
    }
    return self;
    
}

- (void)windowDidLoad {
    [super windowDidLoad];
    addContactDialogBox = [[AddContactDialogBox alloc]init];
    [self.window.contentView addSubview:addContactDialogBox.view];
    [self.window setTitle:@"Add Contact"];
}

-(void) setIsEditing:(bool)isEditing
{
    if (addContactDialogBox != nil)
    {
        addContactDialogBox.isEditing = isEditing;
        if (isEditing)
        {
            [self.window setTitle:@"Edit Contact"];
        }
        else
        {
            [self.window setTitle:@"Add Contact"];
            addContactDialogBox.isEditing = isEditing;
            addContactDialogBox.oldName = @"";
            addContactDialogBox.oldPhone = @"";
            addContactDialogBox.oldProviderName = @"";
            [addContactDialogBox initializeData];
        }
    }
}

-(void)initializeDataWith:(bool)isEditing oldName:(NSString*)oldName oldPhone:(NSString*)oldPhone oldProviderName:(NSString*)oldProviderName
{
    if (addContactDialogBox != nil)
    {
        addContactDialogBox.isEditing = isEditing;
        addContactDialogBox.oldName = oldName;
        addContactDialogBox.oldPhone = oldPhone;
        addContactDialogBox.oldProviderName = oldProviderName;
        [addContactDialogBox initializeData];
    }
}




@end