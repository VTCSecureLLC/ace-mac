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
#import "LinphoneContactService.h"

@implementation ContactsService

-(id) init{
    self = [super init];
    return self;
}

+(ABPerson*) importContact:(NSString*)path{
    NSData *vCardData = [[NSData alloc] initWithContentsOfFile:path];
    ABPerson *person = [[ABPerson alloc] initWithVCardRepresentation:vCardData];
    
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
    
    NSAlert *alert = [[NSAlert alloc] init];
    
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Contact imported"];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert runModal];
    return person;
}

+(void) exportContact: (NSString*) firstName : (NSString*) lastName : (NSString*) sipAddress :(NSString*)path{
    
    [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    NSMutableArray *contactInfos;
    contactInfos = [[LinphoneContactService sharedInstance] contactList];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];

    for (NSDictionary *contact in contactInfos) {
        
        ABPerson *person = [[ABPerson alloc] initWithAddressBook:[ABAddressBook sharedAddressBook]];
        [person setValue:[contact objectForKey:@"name"] forKey:kABFirstNameProperty];
        [person setValue:[contact objectForKey:@"phone"] forKey:kABJobTitleProperty];
        [[ABAddressBook sharedAddressBook] addRecord:(ABPerson*)person];
        
        NSData *data = [NSData new];
        data = [person vCardRepresentation];
        
        if (fileHandle) {
            [fileHandle seekToEndOfFile];
            [fileHandle writeData:data];
        } else {
            NSLog(@"Error writing contacts in file");
        }
        
    }
    [fileHandle closeFile];
    
    
    NSAlert *alert = [[NSAlert alloc] init];
    
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:[NSString stringWithFormat:@"Contact exported to %@", path]];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert runModal];
    
}
@end
