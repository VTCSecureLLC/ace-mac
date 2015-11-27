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
#import "AppDelegate.h"
#import "AddContactDialogBox.h"

@interface ContactsView ()<ContactTableCellViewDelegate> {
    AddContactDialogBox *editContactDialogBox;
}

@property (weak) IBOutlet NSScrollView *scrollViewContacts;
@property (weak) IBOutlet NSTableView *tableViewContacts;
@property (weak) IBOutlet NSButton *addContactButton;
@property (weak) IBOutlet NSButton *clearListButton;
@property (strong, nonatomic) NSMutableArray *contactInfos;

@end

@implementation ContactsView


#pragma mark - View lifecycle methods

- (void) awakeFromNib {
    [super awakeFromNib];
    static BOOL firstTime = YES;
    if (firstTime) {
        [self.addContactButton becomeFirstResponder];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contactInfoFillDone:)
                                                     name:@"contactInfoFilled"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contactEditDone:)
                                                     name:@"contactInfoEditDone"
                                                   object:nil];
        
        self.contactInfos = [NSMutableArray new];
        firstTime = NO;
        [self refreshContactList];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (void) setFrame:(NSRect)frame {
    [super setFrame:frame];
    [self.scrollViewContacts setFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height - 40)];
    [self.addContactButton setFrame:NSMakeRect(135, frame.size.height - 40, self.addContactButton.frame.size.width, self.addContactButton.frame.size.height)];
    [self.clearListButton setFrame:NSMakeRect(20, frame.size.height - 40, self.clearListButton.frame.size.width, self.clearListButton.frame.size.height)];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"contactInfoFilled" object:nil];
}

#pragma mark - Buttons actions methods

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

#pragma mark - Observer functions declarations

- (void)contactInfoFillDone:(NSNotification*)notif {
    NSDictionary *contactInfo = (NSDictionary*)[notif object];
    [self addFriendInLPCoreWithInfo:contactInfo];
    [self refreshContactList];
}

- (void)contactEditDone:(NSNotification*)notif {
    NSDictionary *contactInfo = (NSDictionary*)[notif object];
    [self deleteFriendFromLPCoreWithName:[contactInfo objectForKey:@"oldName"]
                              andAddress:[contactInfo objectForKey:@"oldPhone"]];
    [self addFriendInLPCoreWithInfo:contactInfo];
    [self refreshContactList];
}

#pragma mark - Linphonefriend related functions

- (void)addFriendInLPCoreWithInfo:(NSDictionary*)contactInfo {
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

- (void)refreshContactList {
    [self.contactInfos removeAllObjects];
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
    [self.tableViewContacts reloadData];
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

- (LinphoneFriend*)makeFriendFrom:(NSString*)name and:(NSString*)phone {
    
    LinphoneFriend *newFriend = linphone_friend_new_with_address ([phone  UTF8String]);
    linphone_friend_set_name(newFriend, [name  UTF8String]);
    
    return newFriend;
}

- (void)deleteFriendFromLPCore:(const LinphoneFriend*)contact {
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

- (void)deleteFriendFromLPCoreWithName:(NSString*)name andAddress:(NSString*)sipURI {
    const LinphoneFriend* selectedFriend = [self makeFriendFrom:name
                                                            and:sipURI];
    [self deleteFriendFromLPCore:selectedFriend];
}

- (void)deleteFriendFromLPCoreWithInfo:(NSDictionary*)dict {
    [self deleteFriendFromLPCoreWithName:[dict objectForKey:@"name"] andAddress:[dict objectForKey:@"phone"]];
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

- (IBAction)columnChangeSelected:(id)sender {
    NSInteger selectedRow = [self.tableViewContacts selectedRow];
    NSDictionary *calltoContact = [self.contactInfos objectAtIndex:selectedRow];
    [self callTo:[calltoContact objectForKey:@"name"]];
}

#pragma mark - ContactTableCellView delegate methods

- (void)didClickDeleteButton:(ContactTableCellView *)contactCellView {
    const LinphoneFriend* selectedFriend = [self makeFriendFrom:[contactCellView.nameTextField stringValue]
                                                            and:[contactCellView.phoneTextField stringValue]];
    [self deleteFriendFromLPCore:selectedFriend];
    [self refreshContactList];
}

- (void)didClickEditButton:(ContactTableCellView *)contactCellView {
    editContactDialogBox = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"AddContactDialogBox"];
    editContactDialogBox.isEditing = YES;
    editContactDialogBox.oldName = [contactCellView.nameTextField stringValue];
    editContactDialogBox.oldPhone = [contactCellView.phoneTextField stringValue];
    [[AppDelegate sharedInstance].homeWindowController.contentViewController presentViewControllerAsModalWindow:editContactDialogBox];
}

#pragma mark - Functions related to the call

- (void)callTo:(NSString*)name {
    [[LinphoneManager instance] call:name displayName:name transfer:NO];
}


@end
