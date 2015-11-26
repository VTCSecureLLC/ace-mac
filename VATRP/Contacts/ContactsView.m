//
//  ContactsView.m
//  ACE
//
//  Created by User on 24/11/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "ContactsView.h"
#import "ContactTableCellView.h"
#import "AddContactDialogBox.h"
#include "linphone/linphonecore.h"
#include "linphone/linphone_tunnel.h"
#include "LinphoneManager.h"

@interface ContactsView ()<ContactTableCellViewDelegate>

@property (weak) IBOutlet NSScrollView *scrollViewContacts;
@property (weak) IBOutlet NSTableView *tableViewContacts;
@property (weak) IBOutlet NSButton *addContactButton;
@property (weak) IBOutlet NSButton *clearListButton;
@property (strong, nonatomic) NSMutableArray *contactInfos;

@end

@implementation ContactsView

- (void) awakeFromNib {
    [super awakeFromNib];
    static BOOL firstTime = YES;
    if (firstTime) {
        [self.addContactButton becomeFirstResponder];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contactInfoDone:)
                                                     name:@"contactInfoFilled"
                                                   object:nil];
        
        self.contactInfos = [NSMutableArray new];
        firstTime = NO;
        [self getContactInfosFromCore];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (void) setFrame:(NSRect)frame {
    [super setFrame:frame];
    [self.scrollViewContacts setFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height - 40)];
    [self.addContactButton setFrame:NSMakeRect(135, 568 - 40, self.addContactButton.frame.size.width, self.addContactButton.frame.size.height)];
    [self.clearListButton setFrame:NSMakeRect(20, 568 - 40, self.clearListButton.frame.size.width, self.clearListButton.frame.size.height)];
}

- (IBAction)onButtonAddContact:(id)sender {
}

- (IBAction)onButtonClearList:(id)sender {
    NSAlert *alert = [NSAlert alertWithMessageText:@"Deleting the list"
                                     defaultButton:@"Cancel" alternateButton:@"OK"
                                       otherButton:nil informativeTextWithFormat:
                      @"Are you sure?. You want to delete all the contacts?"];
    
    
    [alert beginSheetModalForWindow:[self.clearListButton window] completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == 0) {
            [self clearFriendsList];
        }
    }];

}

- (void)contactInfoDone:(NSNotification*)notif {
    NSDictionary *contactInfo = (NSDictionary*)[notif object];
    [self checkAndAddFriendIntoLPCore:contactInfo];
    [self reloadData];
}

- (void)checkAndAddFriendIntoLPCore:(NSDictionary*)contactInfo {
    NSString *phoneString = [contactInfo objectForKey:@"phone"];
    if ([phoneString length] >= 3) {
        NSString *str = [phoneString substringToIndex:4];
        if (![str isEqualToString:@"sip:"]) {
            return;
        }
    } else {
        return;
    }
    LinphoneFriend *newFriend = linphone_friend_new_with_address ([[contactInfo objectForKey:@"phone"]  UTF8String]);
    if (!newFriend) {
        return;
    }
    int t = linphone_friend_set_name(newFriend, [[contactInfo objectForKey:@"name"]  UTF8String]);
    if  (t == 0) {
        linphone_friend_enable_subscribes(newFriend,TRUE);
        linphone_friend_set_inc_subscribe_policy(newFriend,LinphoneSPAccept);
        linphone_core_add_friend([LinphoneManager getLc],newFriend);
    }
}

- (void)reloadData {
    [self.contactInfos removeAllObjects];
    const MSList* friends = linphone_core_get_friend_list([LinphoneManager getLc]);
    while (friends != NULL) {
        LinphoneFriend* friend = (LinphoneFriend*)friends->data;
        const LinphoneAddress *address = linphone_friend_get_address(friend);
        const char *addressString = linphone_address_as_string_uri_only(address);
        const char *name = linphone_friend_get_name(friend);
        [self.contactInfos addObject:@{@"name" : [[NSString alloc] initWithUTF8String:name],
                                       @"phone" : [[NSString alloc] initWithUTF8String:addressString]}];
        friends =ms_list_next(friends);
    }
    
    [self.tableViewContacts reloadData];
}

- (void)getContactInfosFromCore {
    const MSList* proxies = linphone_core_get_friend_list([LinphoneManager getLc]);
    while (proxies != NULL) {
        LinphoneFriend* friend = (LinphoneFriend*)proxies->data;
        const LinphoneAddress *address = linphone_friend_get_address(friend);
        const char *addressString = linphone_address_as_string_uri_only(address);
        const char *name = linphone_friend_get_name(friend);
        [self.contactInfos addObject:@{@"name" : [[NSString alloc] initWithUTF8String:name],
                                       @"phone" : [[NSString alloc] initWithUTF8String:addressString]}];
        proxies = ms_list_next(proxies);
    }
    if (self.contactInfos && self.contactInfos.count > 0) {
        [self.tableViewContacts reloadData];
    }
}

#pragma mark - TableView delegate methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.contactInfos.count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 50;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    ContactTableCellView *cellView = [tableView makeViewWithIdentifier:@"ContactCell" owner:self];
    NSDictionary *dict = [self.contactInfos objectAtIndex:row];
    [cellView.nameTextField setStringValue:[dict objectForKey:@"name"]];
    [cellView.phoneTextField setStringValue:[dict objectForKey:@"phone"]];
    cellView.delegate = self;
    return cellView;
}

#pragma mark - ContactTableCellView delegate methods

- (void)didClickDeleteButton:(ContactTableCellView *)contactCellView {
    
}

- (void)didClickEditButton:(ContactTableCellView *)contactCellView {
    
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"contactInfoFilled" object:nil];
}

- (void)clearFriendsList {
    [self.contactInfos removeAllObjects];
    const MSList* friends = linphone_core_get_friend_list([LinphoneManager getLc]);
    while (friends != NULL) {
        LinphoneFriend* friend = (LinphoneFriend*)friends->data;
        friends = ms_list_next(friends);
        linphone_core_remove_friend([LinphoneManager getLc], friend);
    }
    [self.tableViewContacts reloadData];
}

@end
