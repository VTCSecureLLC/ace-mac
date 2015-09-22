//
//  ViewController.m
//  MacApp
//
//  Created by Norayr Harutyunyan on 8/27/15.
//  Copyright (c) 2015 Cinehost. All rights reserved.
//

#import "ViewController.h"
#import "ContactsWindowController.h"
#import "RecentsWindowController.h"
#import "DialpadWindowController.h"
#import "VideoMailWindowController.h"
#import "SettingsWindowController.h"
#import "AppDelegate.h"
#import "LinphoneManager.h"


@interface ViewController () {
    
}

@property (nonatomic, retain) ContactsWindowController *contactsWindowController;
@property (nonatomic, retain) RecentsWindowController *recentsWindowController;
@property (nonatomic, retain) DialpadWindowController *dialpadWindowController;
@property (nonatomic, retain) VideoMailWindowController *videoMailWindowController;
@property (nonatomic, retain) SettingsWindowController *settingsWindowController;

@property (weak) IBOutlet NSTextField *textFieldRegistrationStatus;
@property (weak) IBOutlet NSTextField *textFieldAccount;

- (IBAction)onButtonRecents:(id)sender;
- (IBAction)onButtonContacts:(id)sender;
- (IBAction)onButtonDialpad:(id)sender;
- (IBAction)onButtonVidelMail:(id)sender;
- (IBAction)onButtonSettings:(id)sender;


@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    [AppDelegate sharedInstance].viewController = self;

    [[AppDelegate sharedInstance].menuItemPreferences setAction:@selector(onMenuItemPreferences:)];


    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(registrationUpdateEvent:)
                                                 name:kLinphoneRegistrationUpdate
                                               object:nil];    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)onButtonRecents:(id)sender {
    if (!self.recentsWindowController) {
        self.recentsWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"Recents"];
        [self.recentsWindowController showWindow:self];
    } else {
        if (self.recentsWindowController.isShow) {
            [self.recentsWindowController close];
        } else {
            [self.recentsWindowController showWindow:self];
            self.recentsWindowController.isShow = YES;
        }
    }
}

- (IBAction)onButtonContacts:(id)sender {
    if (!self.contactsWindowController) {
        self.contactsWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"Contacts"];
        [self.contactsWindowController showWindow:self];
    } else {
        if (self.contactsWindowController.isShow) {
            [self.contactsWindowController close];
        } else {
            [self.contactsWindowController showWindow:self];
            self.contactsWindowController.isShow = YES;
        }
    }
}

- (IBAction)onButtonDialpad:(id)sender {
    if (!self.dialpadWindowController) {
        self.dialpadWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"Dialpad"];
        [self.dialpadWindowController showWindow:self];
    } else {
        if (self.dialpadWindowController.isShow) {
            [self.dialpadWindowController close];
        } else {
            [self.dialpadWindowController showWindow:self];
            self.dialpadWindowController.isShow = YES;
        }
    }
}

- (IBAction)onButtonVidelMail:(id)sender {
    if (!self.videoMailWindowController) {
        self.videoMailWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"VideoMail"];
        [self.videoMailWindowController showWindow:self];
    } else {
        if (self.videoMailWindowController.isShow) {
            [self.videoMailWindowController close];
        } else {
            [self.videoMailWindowController showWindow:self];
            self.videoMailWindowController.isShow = YES;
        }
    }
}

- (IBAction)onButtonSettings:(id)sender {
    if (!self.settingsWindowController) {
        self.settingsWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"Settings"];
        [self.settingsWindowController showWindow:self];
    } else {
        if (self.settingsWindowController.isShow) {
            [self.settingsWindowController close];
        } else {
            [self.settingsWindowController showWindow:self];
            self.settingsWindowController.isShow = YES;
        }
    }
}

- (void) showSettingsWindow {
    [self onButtonSettings:nil];
}

- (void)registrationUpdateEvent:(NSNotification*)notif {
    NSString* message = [notif.userInfo objectForKey:@"message"];
    [self registrationUpdate:[[notif.userInfo objectForKey: @"state"] intValue] message:message];
    
    LinphoneCore *lc = [LinphoneManager getLc];
    LinphoneProxyConfig *cfg=NULL;
    linphone_core_get_default_proxy(lc,&cfg);
    const char *identity=linphone_proxy_config_get_identity(cfg);
    LinphoneAddress *addr=linphone_address_new(identity);
    const char* user = linphone_address_get_username(addr);
    NSString *username = [NSString stringWithUTF8String:user];
    
    self.textFieldAccount.stringValue = username;
}

- (void)registrationUpdate:(LinphoneRegistrationState)state message:(NSString*)message{
    switch (state) {
        case LinphoneRegistrationOk: {
            self.textFieldRegistrationStatus.stringValue = @"Registered";
            break;
        }
        case LinphoneRegistrationNone:
        case LinphoneRegistrationCleared:  {
            self.textFieldRegistrationStatus.stringValue = @"Registration None";
            break;
        }
        case LinphoneRegistrationFailed: {
            self.textFieldRegistrationStatus.stringValue = @"Registration Failed";
            break;
        }
        case LinphoneRegistrationProgress: {
            self.textFieldRegistrationStatus.stringValue = @"Registration in progress";
            break;
        }
        default:
            break;
    }
}

@end
