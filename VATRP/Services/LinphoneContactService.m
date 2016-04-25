//
//  LinphoneContactService.m
//  ACE
//
//  Created by User on 30/11/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "LinphoneContactService.h"
#import "ContactFavoriteManager.h"

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

- (BOOL)addContactWithDisplayName:(NSString *)name andSipUri:(NSString *)sipURI {
    
    LinphoneFriend *friend = linphone_core_create_friend([LinphoneManager getLc]);
    
    if (!friend) {
        return NO;
    }
    
    linphone_friend_set_name(friend, [name  UTF8String]);
    
    linphone_friend_enable_subscribes(friend,FALSE);
    linphone_friend_set_inc_subscribe_policy(friend,LinphoneSPAccept);
    
    const LinphoneAddress *lAddr = linphone_core_create_address([LinphoneManager getLc],  [sipURI UTF8String]);
    linphone_friend_set_address(friend, lAddr);
    
    NSString * timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
    linphone_friend_set_ref_key(friend, [timestamp UTF8String]);
    
    LinphoneFriendList *friendList = linphone_core_get_default_friend_list([LinphoneManager getLc]);
    
    if (linphone_friend_list_add_friend(friendList, friend) == LinphoneFriendListOK) {
        return YES;
    }
    
    return NO;
}

- (LinphoneFriend*)createContactFromName:(NSString *)name andSipUri:(NSString *)sipURI {
    LinphoneFriend *newFriend = linphone_friend_new_with_address ([sipURI  UTF8String]);
    linphone_friend_set_name(newFriend, [name  UTF8String]);
    return newFriend;
}

- (BOOL)addContactFromByAddress:(LinphoneAddress*)address {
    BOOL contactExistsInCore = NO;
    LinphoneFriend *friend  = linphone_core_find_friend([LinphoneManager getLc], address);
    if (friend) {
        return contactExistsInCore;
    } else {
        
        linphone_core_add_friend([LinphoneManager getLc], friend);
        contactExistsInCore = YES;
    }
    
    return contactExistsInCore;
}

- (BOOL) editContactWithNewDisplayName:(NSString *)name andSipUri:(NSString *)sipURI andWithRefKey:(NSString*)refKey {
    
    NSAssert(refKey, nil);
    
    LinphoneFriend * editableFriend = linphone_core_get_friend_by_ref_key([LinphoneManager getLc], [refKey UTF8String]);
    
    if (editableFriend) {
        linphone_friend_edit(editableFriend);
        
        linphone_friend_set_name(editableFriend, [name  UTF8String]);
        
        const LinphoneAddress* address = linphone_core_create_address([LinphoneManager getLc], [sipURI UTF8String]);
        
        linphone_friend_set_address(editableFriend, address);
        
        linphone_friend_done(editableFriend);
        
    } else {
        return NO;
    }
    

    return YES;
}

- (NSMutableArray*)contactList {
    NSMutableArray *contacts = [NSMutableArray new];
    LinphoneFriendList *friendList = linphone_core_get_default_friend_list([LinphoneManager getLc]);
    const MSList* proxies = linphone_friend_list_get_friends(friendList);
    while (proxies != NULL) {
        LinphoneFriend* friend = (LinphoneFriend*)proxies->data;
        const LinphoneAddress *address = linphone_friend_get_address(friend);
        const char *addressString = linphone_address_as_string_uri_only(address);
        const char *providerName = linphone_address_get_domain(address);
        const char *name = linphone_friend_get_name(friend);
        const char *refKey = linphone_friend_get_ref_key(friend);
        NSString *refKeyString = @"";
        if (refKey) {
            refKeyString = [[NSString alloc] initWithUTF8String:refKey];
        }
        [contacts addObject:@{@"name" : [[NSString alloc] initWithUTF8String:name],
                              @"phone" : [[NSString alloc] initWithUTF8String:addressString],
                              @"provider" : [[NSString alloc] initWithUTF8String:providerName],
                              @"refKey" : refKeyString}];
        proxies = ms_list_next(proxies);
    }
    
    return contacts;
}

- (NSMutableArray*)contactFavoritesList {
    NSMutableArray *contacts = [NSMutableArray new];
    LinphoneFriendList *friendList = linphone_core_get_default_friend_list([LinphoneManager getLc]);
    const MSList* proxies = linphone_friend_list_get_friends(friendList);
    while (proxies != NULL) {
        LinphoneFriend* friend = (LinphoneFriend*)proxies->data;
        const LinphoneAddress *address = linphone_friend_get_address(friend);
        const char *addressString = linphone_address_as_string_uri_only(address);
        const char *providerName = linphone_address_get_domain(address);
        const char *name = linphone_friend_get_name(friend);
        if ([[ContactFavoriteManager sharedInstance] isContactFavoriteWithName:[[NSString alloc] initWithUTF8String:name] andAddress:[[NSString alloc] initWithUTF8String:addressString]] ) {
        [contacts addObject:@{@"name" : [[NSString alloc] initWithUTF8String:name],
                              @"phone" : [[NSString alloc] initWithUTF8String:addressString],
                              @"provider" : [[NSString alloc] initWithUTF8String:providerName]}];
        }
        proxies = ms_list_next(proxies);
    }
    
    return contacts;
}

- (NSMutableArray*)contactListBySearchText:(NSString *)searchText {
    NSMutableArray *contacts = [NSMutableArray new];
    LinphoneFriendList *friendList = linphone_core_get_default_friend_list([LinphoneManager getLc]);
    const MSList* proxies = linphone_friend_list_get_friends(friendList);
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
    LinphoneFriendList *friendList = linphone_core_get_default_friend_list([LinphoneManager getLc]);
    const MSList* friends = linphone_friend_list_get_friends(friendList);
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

- (BOOL)deleteContactWithRefKey:(NSString *)refKey {
    
    LinphoneFriend * deletedFriend = linphone_core_get_friend_by_ref_key([LinphoneManager getLc], [refKey UTF8String]);
    
    if (deletedFriend) {
        
        LinphoneFriendList *defaultFriendList = linphone_core_get_default_friend_list([LinphoneManager getLc]);
        if (linphone_friend_list_remove_friend(defaultFriendList, deletedFriend) == LinphoneFriendListOK) {
            return YES;
        }
        
    }

    return NO;
}

- (void)deleteContactList {
    LinphoneFriendList *friendList = linphone_core_get_default_friend_list([LinphoneManager getLc]);
    const MSList* friends = linphone_friend_list_get_friends(friendList);
    while (friends != NULL) {
        LinphoneFriend* friend = (LinphoneFriend*)friends->data;
        friends = ms_list_next(friends);
        linphone_core_remove_friend([LinphoneManager getLc], friend);
    }
}

- (NSString*)contactNameFromAddress:(LinphoneAddress*)address {
    NSString *name = @"";
    
    LinphoneFriend *friend  = linphone_core_find_friend([LinphoneManager getLc], address);
    
    if (friend) {
        const char *str = linphone_friend_get_name(friend);
        name = [NSString stringWithUTF8String:str];
        return name;
    }
    
    return name;
}

@end
