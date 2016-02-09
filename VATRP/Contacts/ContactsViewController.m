//
//  ContactsViewController.m
//  ACE
//
//  Created by Zack Matthews on 11/22/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "ContactsViewController.h"
#import "AddressBook/AddressBook.h"
#import "ContactsService.h"
@interface ContactsViewController ()
@property NSTextField *firstNameField;
@property NSTextField *lastNameField;
@property NSTextField *sipAddressField;
@property NSButton *exportButton;
@property NSButton *importButton;
@end

@implementation ContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Temp GUI to test VCard import / export
    
    _firstNameField = [[NSTextField alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, 250, 25)];
    _firstNameField.placeholderString = @"First name";
    _firstNameField.editable = YES;
    
    _lastNameField = [[NSTextField alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 25, 250, 25)];
    _lastNameField.editable = YES;
    _lastNameField.placeholderString = @"Last name";
    
    _sipAddressField = [[NSTextField alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 50, 250, 25)];
    _sipAddressField.editable = YES;
    _sipAddressField.placeholderString = @"SIP Address";
    
    
    _exportButton = [[NSButton alloc] initWithFrame:CGRectMake(self.view.frame.origin.x + self.view.frame.size.width / 2,self.view.frame.origin.y + self.view.frame.size.height -50 , 100, 50 )];
    [_exportButton setTitle:@"Export contact"];
    [_exportButton setTarget:self];
    [_exportButton setAction:@selector(exportContactToVCard)];

    _importButton = [[NSButton alloc] initWithFrame:CGRectMake(self.view.frame.origin.x + self.view.frame.size.width / 2,self.view.frame.origin.y + self.view.frame.size.height -100 , 100, 50 )];
    [_importButton setTitle:@"Import Contact"];
    
    [_importButton setTarget:self];
    [_importButton setAction:@selector(importContactFromVCard)];
    [self.view addSubview:_firstNameField];
    [self.view addSubview:_lastNameField];
    [self.view addSubview:_sipAddressField];
    [self.view addSubview:_exportButton];
    [self.view addSubview:_importButton];
     // Do view setup here.
}


-(void) importContactFromVCard{
//    ABPerson *person;
//    NSOpenPanel *panel = [NSOpenPanel openPanel];
//    [panel setCanChooseFiles:YES];
//    [panel setCanChooseDirectories:NO];
//    [panel setAllowsMultipleSelection:NO];
//    
//    NSInteger clicked = [panel runModal];
//    
//    if (clicked == NSFileHandlingPanelOKButton) {
//        
//        NSString *path = panel.URL.relativePath;
//        person = [ContactsService importContact: path];
//    }
//    
//    if(person){
//        _firstNameField.stringValue = [person valueForKey:kABFirstNameProperty];
//        _lastNameField.stringValue = [person valueForKey:kABLastNameProperty];
//        _sipAddressField.stringValue = [person valueForKey:kABJobTitleProperty];
//    }

    
}
-(void) exportContactToVCard{
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setAllowsMultipleSelection:NO];
    
    NSInteger clicked = [panel runModal];
    
    if (clicked == NSFileHandlingPanelOKButton) {
        
        NSString *path = panel.directoryURL.path;
        path = [path stringByAppendingString:[NSString stringWithFormat:@"/%@%@.vcard", _firstNameField.stringValue, _lastNameField.stringValue]];
        [ContactsService exportContactsByPath:path];
    }

   
}

@end
