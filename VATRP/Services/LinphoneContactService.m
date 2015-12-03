//
//  LinphoneContactService.m
//  ACE
//
//  Created by User on 30/11/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "LinphoneContactService.h"

@implementation LinphoneContactService

+ (LinphoneContactService *)sharedInstance
{
    static LinphoneContactService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LinphoneContactService alloc] init];
    });
    
    return sharedInstance;
}

- (id) init {
    self = [super init];
    
    if (self) {
        // Add code here.
    }
    
    return self;
}

- (void)addContactWithDisplayName:(NSString *)name andSipUri:(NSString *)sipURI {
    
    LinphoneFriend *friend = linphone_friend_new_with_address ([sipURI UTF8String]);
    if (!friend) {
        return;
    }
    int t = linphone_friend_set_name(friend, [name  UTF8String]);
    if  (t == 0) {
        linphone_friend_enable_subscribes(friend,TRUE);
        linphone_friend_set_inc_subscribe_policy(friend,LinphoneSPAccept);
        linphone_core_add_friend([LinphoneManager getLc],friend);
    }
}

- (LinphoneFriend*)createContactFromName:(NSString *)name andSipUri:(NSString *)sipURI {
    LinphoneFriend *newFriend = linphone_friend_new_with_address ([sipURI  UTF8String]);
    linphone_friend_set_name(newFriend, [name  UTF8String]);
    return newFriend;
}

- (NSMutableArray*)contactList {
    NSMutableArray *contacts = [NSMutableArray new];
    const MSList* proxies = linphone_core_get_friend_list([LinphoneManager getLc]);
    while (proxies != NULL) {
        LinphoneFriend* friend = (LinphoneFriend*)proxies->data;
        const LinphoneAddress *address = linphone_friend_get_address(friend);
        const char *addressString = linphone_address_as_string_uri_only(address);
        const char *name = linphone_friend_get_name(friend);
        [contacts addObject:@{@"name" : [[NSString alloc] initWithUTF8String:name],
                             @"phone" : [[NSString alloc] initWithUTF8String:addressString]}];
        proxies = ms_list_next(proxies);
    }
    
    return contacts;
}

- (NSMutableArray*)contactListBySearchText:(NSString *)searchText {
    NSMutableArray *contacts = [NSMutableArray new];
    const MSList* proxies = linphone_core_get_friend_list([LinphoneManager getLc]);
    while (proxies != NULL) {
        LinphoneFriend* friend = (LinphoneFriend*)proxies->data;
        const LinphoneAddress *address = linphone_friend_get_address(friend);
        const char *addressString = linphone_address_as_string_uri_only(address);
        const char *name = linphone_friend_get_name(friend);
        NSString *sipURI = [NSString stringWithUTF8String:addressString];
        NSString *displayName = [NSString stringWithUTF8String:name];
        if (![searchText isEqualToString:@""] && searchText != nil) {
            if  ( ([displayName rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) ||
                 ([sipURI rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) )  {
                [contacts addObject:@{@"name" : displayName, @"phone" : sipURI}];
            }
        } else {
            [contacts addObject:@{@"name" : displayName, @"phone" : sipURI}];
        }
        proxies = ms_list_next(proxies);
    }

    return contacts;
}

- (void)deleteContact:(const LinphoneFriend *)contact {
    LinphoneAddress *deletedAddress = (LinphoneAddress*)linphone_friend_get_address(contact);
    char* delAddress = linphone_address_as_string(deletedAddress);
    const MSList* friends = linphone_core_get_friend_list([LinphoneManager getLc]);
    while (friends != NULL) {
        LinphoneFriend* friend = (LinphoneFriend*)friends->data;
        friends = ms_list_next(friends);
        LinphoneAddress *friendAddress = (LinphoneAddress*)linphone_friend_get_address(friend);
        char* frAddress = linphone_address_as_string(friendAddress);
        if (strcmp(delAddress, frAddress) == 0) {
            linphone_core_remove_friend([LinphoneManager getLc], friend);
        }
    }
}

- (void)deleteContactWithDisplayName:(NSString *)name andSipUri:(NSString *)sipURI {
    const LinphoneFriend* friend = [self createContactFromName:name andSipUri:sipURI];
    [self deleteContact:friend];
}

- (void)deleteContactList {
    const MSList* friends = linphone_core_get_friend_list([LinphoneManager getLc]);
    while (friends != NULL) {
        LinphoneFriend* friend = (LinphoneFriend*)friends->data;
        friends = ms_list_next(friends);
        linphone_core_remove_friend([LinphoneManager getLc], friend);
    }
}

@end
