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
#import "DockView.h"

#import "LinphoneContactService.h"
#include "LinphoneManager.h"
#import "AppDelegate.h"
#import "AddContactDialogBox.h"

@interface ContactsView ()<ContactTableCellViewDelegate> {
    AddContactDialogBox *editContactDialogBox;
    NSString *selectedProviderName;
}

@property (weak) IBOutlet NSScrollView *scrollViewContacts;
@property (weak) IBOutlet NSTableView *tableViewContacts;
@property (weak) IBOutlet NSButton *addContactButton;
@property (weak) IBOutlet NSButton *clearListButton;
@property (weak) IBOutlet NSButton *syncButton;
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
        [self refreshContactList];
        firstTime = NO;
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (void) setFrame:(NSRect)frame {
    [super setFrame:frame];
    [self.scrollViewContacts setFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height - 40)];
    [self.addContactButton setFrame:NSMakeRect(135, frame.size.height - 40, self.addContactButton.frame.size.width, self.addContactButton.frame.size.height)];
        [self.syncButton setFrame:NSMakeRect(250, frame.size.height - 40, self.syncButton.frame.size.width, self.syncButton.frame.size.height)];
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
            [[LinphoneContactService sharedInstance] deleteContactList];
        }
    }];
}

- (IBAction)onSyncButton:(id)sender {
    AppDelegate *app = [AppDelegate sharedInstance];
    if (!app.contactsWindowController) {
        app.contactsWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"Contacts"];
        [app.contactsWindowController showWindow:self];
    } else {
        if (app.contactsWindowController.isShow) {
            [app.contactsWindowController close];
        } else {
            [app.contactsWindowController showWindow:self];
            app.contactsWindowController.isShow = YES;
        }
    }
}

#pragma mark - Observer functions declarations

- (void)contactInfoFillDone:(NSNotification*)notif {
    
    NSDictionary *contactInfo = (NSDictionary*)[notif object];
    selectedProviderName = [contactInfo objectForKey:@"provider"];
    
    NSString *newDisplayName = [contactInfo objectForKey:@"name"];
    NSString *newSipURI = [self makeSipURIWith:[contactInfo objectForKey:@"phone"] andProviderAddress:[contactInfo objectForKey:@"provider"]];
    
    [[LinphoneContactService sharedInstance] addContactWithDisplayName:newDisplayName andSipUri:newSipURI];
    [self refreshContactList];
}

- (void)contactEditDone:(NSNotification*)notif {
    
    NSDictionary *contactInfo = (NSDictionary*)[notif object];
    selectedProviderName = [contactInfo objectForKey:@"provider"];
    
    NSString *oldDisplayName = [contactInfo objectForKey:@"oldName"];
    NSString *oldSipURI = [self makeSipURIWith:[contactInfo objectForKey:@"oldPhone"] andProviderAddress:[contactInfo objectForKey:@"provider"]];
    
    [[LinphoneContactService sharedInstance] deleteContactWithDisplayName:oldDisplayName andSipUri:oldSipURI];
    
    NSString *newDisplayName = [contactInfo objectForKey:@"name"];
    NSString *newSipURI = [self makeSipURIWith:[contactInfo objectForKey:@"phone"] andProviderAddress:[contactInfo objectForKey:@"provider"]];
    
    [[LinphoneContactService sharedInstance] addContactWithDisplayName:newDisplayName andSipUri:newSipURI];
    
    [self refreshContactList];
}

- (void)refreshContactList {
    [self.contactInfos removeAllObjects];
    self.contactInfos = [[LinphoneContactService sharedInstance] contactList];
    [self.tableViewContacts reloadData];
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
    if (selectedRow >= 0 && selectedRow < self.contactInfos.count) {
        NSDictionary *calltoContact = [self.contactInfos objectAtIndex:selectedRow];
        [self callTo:[self makeAccountnameFromSipURI:[calltoContact objectForKey:@"phone"]]];
    }
}

#pragma mark - ContactTableCellView delegate methods

- (void)didClickDeleteButton:(ContactTableCellView *)contactCellView {
    [[LinphoneContactService sharedInstance] deleteContactWithDisplayName:[contactCellView.nameTextField stringValue] andSipUri:[contactCellView.phoneTextField stringValue]];
    
    [self refreshContactList];
}

- (void)didClickEditButton:(ContactTableCellView *)contactCellView {
    editContactDialogBox = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"AddContactDialogBox"];
    editContactDialogBox.isEditing = YES;
    editContactDialogBox.oldName = [contactCellView.nameTextField stringValue];
    editContactDialogBox.oldPhone = [self makeAccountnameFromSipURI:[contactCellView.phoneTextField stringValue]];
    editContactDialogBox.oldProviderName = selectedProviderName;
    [[AppDelegate sharedInstance].homeWindowController.contentViewController presentViewControllerAsModalWindow:editContactDialogBox];
}

#pragma mark - Functions related to the call

- (void)callTo:(NSString*)name {
    [[LinphoneManager instance] call:name displayName:name transfer:NO];
}

#pragma mark - Helper functions

- (NSString*)makeSipURIWith:(NSString*)accountName andProviderAddress:(NSString*)providerAddress {
    return  [[[@"sip:" stringByAppendingString:accountName] stringByAppendingString:@"@"] stringByAppendingString:providerAddress];
}

- (NSString*)makeAccountnameFromSipURI:(NSString*)sipURI {
    NSString *str = [sipURI substringFromIndex:4];
    NSArray *subStrings = [str componentsSeparatedByString:@"@"];
    return [subStrings objectAtIndex:0];
}

@end
