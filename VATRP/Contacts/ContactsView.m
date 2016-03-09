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
#import "Utils.h"
#import "CallService.h"
#import "ContactPictureManager.h"
#import "ContactsService.h"
#import "ContactFavoriteManager.h"

@interface ContactsView ()<ContactTableCellViewDelegate> {
    AddContactDialogBox *editContactDialogBox;
    NSString *selectedProviderName;
    NSString *dialPadFilter;
}

@property (weak) IBOutlet NSScrollView *scrollViewContacts;
@property (weak) IBOutlet NSTableView *tableViewContacts;
@property (weak) IBOutlet NSButton *addContactButton;
@property (weak) IBOutlet NSButton *clearListButton;
@property (weak) IBOutlet NSButton *importButton;
@property (weak) IBOutlet NSButton *exportButton;
@property IBOutlet NSButton *allContactsButton;
@property IBOutlet NSButton *favoriteContactsButton;
@property (strong, nonatomic) NSMutableArray *contactInfos;

@end

@implementation ContactsView


#pragma mark - View lifecycle methods

-(id) init
{
    self = [super initWithNibName:@"ContactsView" bundle:nil];
    if (self)
    {
        // init
    }
    return self;
    
}

- (void) awakeFromNib {
    [super awakeFromNib];
    static BOOL firstTime = YES;
    if (firstTime) {
        // ToDo VATRP-2376: defining the allCOntats and favoriteContacts buttons programmatically until the storyboard is managable.
        //   Once the custom controls are written for each panel, move all control creation to the control definition.
        _allContactsButton = [[NSButton alloc]init];//[[NSButton alloc]initWithFrame:CGRectMake(0, 50, 75, 38)];
        
        [_allContactsButton setTitle:@"All"];
        [_allContactsButton setButtonType:NSPushOnPushOffButton]; //Set what type button You want
        [_allContactsButton setBezelStyle:NSShadowlessSquareBezelStyle]; //Set what style You want
        [_allContactsButton setState:NSOffState];
//        [_allContactsButton setEnabled:false]; // initialize for toggle being controlled by the two buttons, not by the button itself
        [_allContactsButton setTarget:self];
        [_allContactsButton setAction:@selector(allContacts_Click)];
        [self.view addSubview:_allContactsButton];
        
        _favoriteContactsButton = [[NSButton alloc]init];//[[NSButton alloc] initWithFrame:CGRectMake(100, self.view.frame.origin.y + self.view.frame.size.height -50 , 100, 50 )];
        [_favoriteContactsButton setTitle:@"Favorites"];
        [_favoriteContactsButton setButtonType:NSPushOnPushOffButton]; //Set what type button You want
        [_favoriteContactsButton setBezelStyle:NSShadowlessSquareBezelStyle]; //Set what style You want
        [_favoriteContactsButton setState:NSOnState];
        [_favoriteContactsButton setTarget:self];
        [_favoriteContactsButton setAction:@selector(favoriteContacts_Click)];
        [self.view addSubview:_favoriteContactsButton];
        
        [self.addContactButton setTarget:self];
        [self.addContactButton setAction:@selector(onButtonAddContact:)];
        
        [self.addContactButton becomeFirstResponder];
        [self setObservers];
        
        self.contactInfos = [NSMutableArray new];
        firstTime = NO;
    }
    [self refreshContactList];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

#pragma mark - Observers related functions

- (void)setObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contactInfoFillDone:)
                                                 name:@"contactInfoFilled"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contactEditDone:)
                                                 name:@"contactInfoEditDone"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dialpadTextUpdate:)
                                                 name:@"DIALPAD_TEXT_CHANGED"
                                               object:nil];
}

- (void)contactInfoFillDone:(NSNotification*)notif {
    
    NSDictionary *contactInfo = (NSDictionary*)[notif object];
    selectedProviderName = [contactInfo objectForKey:@"provider"];
    
    NSString *newDisplayName = [contactInfo objectForKey:@"name"];
    NSString *newSipURI = [contactInfo objectForKey:@"phone"];
    
    if ([[LinphoneContactService sharedInstance] addContactWithDisplayName:newDisplayName andSipUri:newSipURI]) {
        
        int isFavorite = [[contactInfo objectForKey:@"isFavorite"] intValue];
        [[ContactFavoriteManager sharedInstance] updateContactFavoriteOptionByName:newDisplayName contactAddress:newSipURI andFavoriteOptoin:isFavorite];
        
        [self refreshContactList];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Invalid sip uri"
                                         defaultButton:@"OK" alternateButton:@""
                                           otherButton:nil informativeTextWithFormat:
                          @"Please enter valid account name"];
        [alert beginSheetModalForWindow:[self.clearListButton window] completionHandler:^(NSModalResponse returnCode) {
        }];
    }
}

- (void)contactEditDone:(NSNotification*)notif {
    
    NSDictionary *contactInfo = (NSDictionary*)[notif object];
    selectedProviderName = [contactInfo objectForKey:@"provider"];
    NSString *newDisplayName = [contactInfo objectForKey:@"name"];
    NSString *newSipURI = [contactInfo objectForKey:@"phone"];
    if (![self isChnagedContactFields:contactInfo]) {
        int isFavorite = [[contactInfo objectForKey:@"isFavorite"] intValue];
        [[ContactFavoriteManager sharedInstance] updateContactFavoriteOptionByName:newDisplayName contactAddress:newSipURI andFavoriteOptoin:isFavorite];
        [self refreshContactList];
        return;
    }
    [self refreshContactList];
    if ([[LinphoneContactService sharedInstance] addContactWithDisplayName:newDisplayName andSipUri:newSipURI]) {
        int isFavorite = [[contactInfo objectForKey:@"isFavorite"] intValue];
        [[ContactFavoriteManager sharedInstance] updateContactFavoriteOptionByName:newDisplayName contactAddress:newSipURI andFavoriteOptoin:isFavorite];
        NSString *oldDisplayName = [contactInfo objectForKey:@"oldName"];
        NSString *oldSipURI = [contactInfo objectForKey:@"oldPhone"];
        [[LinphoneContactService sharedInstance] deleteContactWithDisplayName:oldDisplayName andSipUri:oldSipURI];
        [self refreshContactList];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Incorrect number format"
                                         defaultButton:@"OK" alternateButton:@""
                                           otherButton:nil informativeTextWithFormat:
                          @"Please enter correct formatted Account Number"];
        [alert beginSheetModalForWindow:[self.clearListButton window] completionHandler:^(NSModalResponse returnCode) {
        }];
    }
}

- (BOOL)isChnagedContactFields:(NSDictionary*)contactInfo {
    NSString *newDisplayName = [contactInfo objectForKey:@"name"];
    NSString *newSipURI = [contactInfo objectForKey:@"phone"];
    NSString *oldDisplayName = [contactInfo objectForKey:@"oldName"];
    NSString *oldSipURI = [contactInfo objectForKey:@"oldPhone"];
    if ([newDisplayName isEqualToString:oldDisplayName] &&
        [newSipURI isEqualToString:oldSipURI]) {
        return NO;
    }

    return YES;
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"contactInfoFilled" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"contactInfoEditDone" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DIALPAD_TEXT_CHANGED" object: nil];
}

- (void) setFrame:(NSRect)frame {
    [self.view setFrame:frame];
    [self.scrollViewContacts setFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height - 40)];
    
    [self.allContactsButton setFrame:NSMakeRect(0, frame.size.height - 41, 75/*self.addContactButton.frame.size.width*/, self.addContactButton.frame.size.height + 1)];
    [self.favoriteContactsButton setFrame:NSMakeRect(75, frame.size.height - 41, 75/*self.addContactButton.frame.size.width*/, self.addContactButton.frame.size.height + 1)];

    [self.addContactButton setFrame:NSMakeRect(260, frame.size.height - 40, self.addContactButton.frame.size.width, self.addContactButton.frame.size.height)];
    
    [self.exportButton setFrame:NSMakeRect(166, frame.size.height - 40, self.exportButton.frame.size.width, self.exportButton.frame.size.height)];
    
    [self.importButton setFrame:NSMakeRect(213, frame.size.height - 40, self.importButton.frame.size.width, self.importButton.frame.size.height)];
    
    [self.clearListButton setFrame:NSMakeRect(20, frame.size.height - 40, self.clearListButton.frame.size.width, self.clearListButton.frame.size.height)];
    
}

- (void) dealloc {
    [self removeObservers];
}

#pragma mark - Buttons actions methods
-(void) allContacts_Click
{
    // do not allow toggle for these - we are emulating tabs
    [_allContactsButton setState:NSOffState];
    // if not already selected
    if ([_favoriteContactsButton state] == NSOffState)
    {
        // then we need to show all contacts, and fix the tab buttons
        [_favoriteContactsButton setState:NSOnState];
//        [_favoriteContactsButton setEnabled:true];
//        [_allContactsButton setEnabled:false];
        // then show all contacts

    }
    [self refreshContactList];
}

-(void) favoriteContacts_Click
{
    [_favoriteContactsButton setState:NSOffState];
    // if not already selected
    if ([_allContactsButton state] == NSOffState)
    {
        // then we need to show favorite contacts, and fix the tab buttons
        [_allContactsButton setState:NSOnState];
//        [_favoriteContactsButton setEnabled:false];
//        [_allContactsButton setEnabled:true];
        // show only favorite contacts
    }
    [self refreshContactList];
}

- (IBAction)onButtonAddContact:(id)sender
{
    editContactDialogBox = [[AddContactDialogBox alloc] init];
    editContactDialogBox.isEditing = NO;
    [[AppDelegate sharedInstance].homeWindowController.contentViewController presentViewControllerAsModalWindow:editContactDialogBox];
}
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

- (IBAction)onExportButton:(id)sender {
    
    if (self.contactInfos.count > 0) {
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        [panel setCanChooseFiles:NO];
        [panel setCanChooseDirectories:YES];
        [panel setAllowsMultipleSelection:NO];
        NSInteger clicked = [panel runModal];
        if (clicked == NSFileHandlingPanelOKButton) {
            NSString *path = panel.directoryURL.path;
            path = [path stringByAppendingString:[NSString stringWithFormat:@"/%@%@.vcard", @"ACE_", @"Contacts"]];
            LinphoneFriendList *friendList = linphone_core_get_default_friend_list([LinphoneManager getLc]);
            linphone_friend_list_export_friends_as_vcard4_file(friendList, [path UTF8String]);
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Contacts have been succefully exported"];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert runModal];
        }
    } else {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"The contacts list is empty"];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
    }
}

- (IBAction)onImportButton:(id)sender {
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    NSInteger clicked = [panel runModal];
    int contactsCount = 0;
    if (clicked == NSFileHandlingPanelOKButton) {
        NSString *filePath = [[[panel URLs] objectAtIndex:0] absoluteString];
        NSArray* tmpStr = [filePath componentsSeparatedByString:@"file://"];
        NSString *pureFilePath = [tmpStr objectAtIndex:1];
        LinphoneFriendList *friendList = linphone_core_get_default_friend_list([LinphoneManager getLc]);
        contactsCount =  linphone_friend_list_import_friends_from_vcard4_file (friendList, [pureFilePath UTF8String]);
        if (contactsCount > 0) {
            [self refreshContactList];
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Contacts have been succefully imported"];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert runModal];
        } else {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"The file doesn't contain any compatible vCard contact"];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert runModal];
        }
    }
}

- (void)refreshContactList {
    [self.contactInfos removeAllObjects];
    if ([_allContactsButton state] == NSOffState) {
        self.contactInfos = [[LinphoneContactService sharedInstance] contactList];
    } else {
        self.contactInfos = [[LinphoneContactService sharedInstance] contactFavoritesList];
    }
    self.contactInfos = [self sortListAlphabetically:self.contactInfos];
    [self.tableViewContacts reloadData];
}

-(NSMutableArray*) sortListAlphabetically:(NSMutableArray*) list{
    NSSortDescriptor *firstNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescripters = @[firstNameDescriptor];
    NSArray *sortedContacts = [list sortedArrayUsingDescriptors:sortDescripters];
    return [sortedContacts mutableCopy];
}

- (void)refreshContactListWithBySearchText:(NSString*)searchedText {
    [self.contactInfos removeAllObjects];
    self.contactInfos = [[LinphoneContactService sharedInstance] contactListBySearchText:searchedText];
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
    cellView.providerName = [dict objectForKey:@"provider"];
    NSImage *contactImage = [[NSImage alloc]initWithContentsOfFile:[[ContactPictureManager sharedInstance] imagePathByName:[dict objectForKey:@"name"] andSipURI:[dict objectForKey:@"phone"]]];
    if (contactImage) {
        [cellView.imgView setImage:contactImage];
    } else {
        [cellView.imgView setImage:[NSImage imageNamed:@"male"]];
    }
    cellView.delegate = self;
    return cellView;
}

- (IBAction)columnChangeSelected:(id)sender {
    NSInteger selectedRow = [self.tableViewContacts selectedRow];
    if (selectedRow >= 0 && selectedRow < self.contactInfos.count) {
        NSDictionary *calltoContact = [self.contactInfos objectAtIndex:selectedRow];
        [self callTo:[calltoContact objectForKey:@"phone"]];
    }
}

#pragma mark - ContactTableCellView delegate methods

- (void)didClickDeleteButton:(ContactTableCellView *)contactCellView {
    [[ContactFavoriteManager sharedInstance] deleteContactFavoriteOptionWithName:[contactCellView.nameTextField stringValue] andAddress:[contactCellView.phoneTextField stringValue]];
    [[LinphoneContactService sharedInstance] deleteContactWithDisplayName:[contactCellView.nameTextField stringValue] andSipUri:[contactCellView.phoneTextField stringValue]];
    //NSString *provider  = [Utils providerNameFromSipURI:[contactCellView.phoneTextField stringValue]];
    [[ContactPictureManager sharedInstance] deleteImageWithName:[contactCellView.nameTextField stringValue] andSipURI:[contactCellView.phoneTextField stringValue]];
    [self refreshContactList];
}

- (void)didClickEditButton:(ContactTableCellView *)contactCellView {
//    editContactDialogBox = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"AddContactDialogBox"];
    editContactDialogBox = [[AddContactDialogBox alloc] init];
    editContactDialogBox.isEditing = YES;
    editContactDialogBox.oldName = [contactCellView.nameTextField stringValue];
    editContactDialogBox.oldPhone = [contactCellView.phoneTextField stringValue];
    editContactDialogBox.oldProviderName = contactCellView.providerName;
    [[AppDelegate sharedInstance].homeWindowController.contentViewController presentViewControllerAsModalWindow:editContactDialogBox];
}

#pragma mark - Functions related to the call

- (void)callTo:(NSString*)name {
    [CallService callTo:name];
}

#pragma mark - Helper functions

- (NSString*)makeSipURIWith:(NSString*)accountName andProviderAddress:(NSString*)providerAddress {
    return  [[[@"sip:" stringByAppendingString:accountName] stringByAppendingString:@"@"] stringByAppendingString:providerAddress];
}

- (void)dialpadTextUpdate:(NSNotification*)notif {
    [self refreshContactListWithBySearchText:[notif object]];
}

@end
