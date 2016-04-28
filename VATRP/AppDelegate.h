//
//  AppDelegate.h
//  VATRP
//
//  Created by Ruben Semerjyan on 8/27/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LoginWindowController.h"
#import "LoginViewController.h"
#import "HomeWindowController.h"

#import "VideoCallWindowController.h"
#import "ContactsWindowController.h"
#import "RecentsWindowController.h"
#import "ChatWindowController.h"
#import "ViewController.h"
#import "AddContactWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong, nonatomic, retain) LoginWindowController *loginWindowController;
@property (nonatomic, retain) NSString *account;
@property (nonatomic, retain) LoginViewController *loginViewController;
@property (strong, nonatomic, retain) HomeWindowController *homeWindowController;
@property (strong, nonatomic, retain) ViewController *viewController;
@property (weak) IBOutlet NSMenuItem *menuItemPreferences;
@property (weak) IBOutlet NSMenuItem *menuItemSignOut;
@property (weak) IBOutlet NSMenuItem *menuItemMessages;
@property (weak) IBOutlet NSMenuItem *menuItemSelfPreview;
@property (weak) IBOutlet NSMenuItem *menuItemGoToSupport;
@property (weak) IBOutlet NSMenuItem *menuItemWelcomeTour;
@property (weak) IBOutlet NSMenuItem *menuItemSyncContacts;

//@property (weak) IBOutlet NSMenuItem *menuItemFEDVRS;
//@property (weak) IBOutlet NSMenuItem *menuItemZVRS;
//@property (weak) IBOutlet NSMenuItem *menuItemPurple;
//@property (weak) IBOutlet NSMenuItem *menuItemSorenson;
//@property (weak) IBOutlet NSMenuItem *menuItemConvo;
//@property (weak) IBOutlet NSMenuItem *menuItemGlobalENus;
//@property (weak) IBOutlet NSMenuItem *menuItemGlobalENes;
//@property (weak) IBOutlet NSMenuItem *menuItemCAAG;

@property (nonatomic, retain) ContactsWindowController *contactsWindowController;
@property (nonatomic, retain) RecentsWindowController *recentsWindowController;
@property (nonatomic, retain) SettingsWindowController *settingsWindowController;
@property (nonatomic, retain) VideoMailWindowController *videoMailWindowController;
@property (nonatomic, retain) ChatWindowController *chatWindowController;
@property (nonatomic, retain) AddContactWindowController *addContactWindowController;

+ (AppDelegate*)sharedInstance;
- (void) showTabWindow;
- (void) closeTabWindow;
-(void) dismissCallWindows;
//- (VideoCallWindowController*) getVideoCallWindow;

-(NSPoint) getTabWindowSize;
-(NSPoint) getTabWindowOrigin;
-(void) setTabWindowPos:(NSPoint) pos;
-(void) SignOut;
- (IBAction)onSignOut:(NSMenuItem *)sender;
void linphone_iphone_log_handler(const char *domain, OrtpLogLevel lev, const char *fmt, va_list args);
@end

