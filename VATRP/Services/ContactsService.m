//
//  ContactsService.m
//  ACE
//
//  Created by Zack Matthews on 11/23/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//
#import <AppKit/NSAlert.h>
#import "ContactsService.h"
#import <AddressBook/ABPerson.h>
#import <AddressBook/ABAddressBook.h>
@implementation ContactsService

-(id) init{
    self = [super init];
    return self;
}

+(void) exportContact: (NSString*) firstName : (NSString*) lastName : (NSString*) sipAddress :(NSString*)path{
    ABPerson *person = [[ABPerson alloc] initWithAddressBook:[ABAddressBook sharedAddressBook]];
    [person setValue:firstName forKey:kABFirstNameProperty];
    [person setValue:lastName forKey:kABLastNameProperty];
    [person setValue:sipAddress forKey:kABJobTitleProperty];
    [[ABAddressBook sharedAddressBook] addRecord:(ABPerson*)person];
    
    NSData *data = [person vCardRepresentation];
    
    NSString *filePath = path;
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil];
    
    NSAlert *alert = [[NSAlert alloc] init];
    
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:[NSString stringWithFormat:@"Contact exported to %@", filePath]];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert runModal];
    
}
@end
