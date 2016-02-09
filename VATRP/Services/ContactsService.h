//
//  ContactsService.h
//  ACE
//
//  Created by Zack Matthews on 11/23/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/ABPerson.h>
@interface ContactsService : NSObject

+(void)exportContactsByPath:(NSString*)path;
+(BOOL)importContacts:(NSString*)path;
@end
