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

+(BOOL)importContacts:(NSString*)path {
    NSMutableArray *contactsFromVCard = [self contactsFromVCardWithPath:path];
    [self mergeContactsWithExisitings:contactsFromVCard];
    if (contactsFromVCard.count > 0) {
        return YES;
    } else {
        return NO;
    }
}

+(void)exportContactsByPath:(NSString*)path{
    
    [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    NSMutableArray *contactInfos;
    contactInfos = [[LinphoneContactService sharedInstance] contactList];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
    
    for (NSDictionary *contact in contactInfos) {
        
        NSString *vcard = @"BEGIN:VCARD\nVERSION:3.0\n";
        
        vcard = [vcard stringByAppendingFormat:@"FN:%@\n",
                 ([contact objectForKey:@"name"] ? [contact objectForKey:@"name"] : @"")
                 ];
        vcard = [vcard stringByAppendingFormat:@"TEL;VALUE=uri:%@\n",
                 ([contact objectForKey:@"phone"] ? [contact objectForKey:@"phone"] : @"")];
        
        vcard = [vcard stringByAppendingString:@"END:VCARD\n"];
        
        if (fileHandle) {
            [fileHandle seekToEndOfFile];
            [fileHandle writeData:[vcard dataUsingEncoding:NSUTF8StringEncoding]];
        } else {
            NSLog(@"Error writing contacts in file");
        }
    }
    
    [fileHandle closeFile];

    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:[NSString stringWithFormat:@"Contacts exported to %@", path]];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert runModal];
    
}

+ (NSMutableArray*)contactsFromVCardWithPath:(NSString*)path {
    
    NSArray *lines;
    NSMutableArray *importedContacts = [NSMutableArray new];
    
    lines = [[NSString stringWithContentsOfFile:path
                                       encoding:NSUTF8StringEncoding
                                          error:nil]
             componentsSeparatedByString:@"BEGIN:VCARD\n"];
    
    for (int i = 0; i < lines.count; ++i) {
        
        NSString *str = [lines objectAtIndex:i];
        
        if (![str isEqualToString:@""]) {
            
            NSCharacterSet *separator = [NSCharacterSet newlineCharacterSet];
            NSArray *vCardRows = [str componentsSeparatedByCharactersInSet:separator];
            
            NSString *rawFN = [vCardRows objectAtIndex:1];
            NSString *rawTEL = [vCardRows objectAtIndex:2];
            
            NSArray* splitRawFN = [rawFN  componentsSeparatedByString:@"FN:"];
            NSString *FN = [splitRawFN objectAtIndex:1];
            
            NSArray* splitRawTEL = [rawTEL  componentsSeparatedByString:@"TEL;VALUE=uri:"];
            NSString *TEL = [splitRawTEL objectAtIndex:1];
            
            NSDictionary *contactDict = @{@"name": FN,
                                          @"phone" : TEL
                                          };
            [importedContacts addObject:contactDict];
        }
    }
    
    return importedContacts;
}

+ (void)mergeContactsWithExisitings:(NSMutableArray*)importedContacts {
    for (NSDictionary *dict in importedContacts) {
        [[LinphoneContactService sharedInstance] addContactWithDisplayName:[dict objectForKey:@"name"] andSipUri:[dict objectForKey:@"phone"]];
    }
}

@end
