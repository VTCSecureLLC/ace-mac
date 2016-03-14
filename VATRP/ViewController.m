//
//  ViewController.m
//  MacApp
//
//  Created by Norayr Harutyunyan on 8/27/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import "ViewController.h"
#import "ContactsWindowController.h"
#import "RecentsWindowController.h"
#import "DialpadWindowController.h"
#import "ChatWindowController.h"
#import "AppDelegate.h"
#import "LinphoneManager.h"
#import "ChatService.h"
#import "ResourcesWindowController.h"

@interface ViewController () {
    ChatWindowController *chatWindowController;
}

@property (nonatomic, retain) ContactsWindowController *contactsWindowController;
@property (nonatomic, retain) RecentsWindowController *recentsWindowController;
@property (nonatomic, retain) DialpadWindowController *dialpadWindowController;

@property (weak) IBOutlet NSTextField *textFieldRegistrationStatus;
@property (weak) IBOutlet NSTextField *textFieldAccount;
@property (weak) IBOutlet NSTextField *labelMessageBadgNumber;

- (IBAction)onButtonRecents:(id)sender;
- (IBAction)onButtonContacts:(id)sender;
- (IBAction)onButtonDialpad:(id)sender;
- (IBAction)onButtonVideoMail:(id)sender;
- (IBAction)onButtonSettings:(id)sender;
- (void) updateUI;


@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    [AppDelegate sharedInstance].viewController = self;

//    [[AppDelegate sharedInstance].menuItemPreferences setAction:@selector(onMenuItemPreferences:)];


    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(registrationUpdateEvent:)
                                                 name:kLinphoneRegistrationUpdate
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(chatUnreadMessageEvent:)
                                                 name:kCHAT_UNREAD_MESSAGE
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(chatCleareUnreadMessageEvent:)
                                                 name:kCHAT_CLEARE_UNREAD_MESSAGES
                                               object:nil];
    
    linphone_core_set_native_video_window_id([LinphoneManager getLc], (__bridge void *)(self.view));
    linphone_core_use_preview_window([LinphoneManager getLc], YES);
    linphone_core_set_native_preview_window_id([LinphoneManager getLc], (__bridge void *)(self.view));
    linphone_core_enable_self_view([LinphoneManager getLc], TRUE);
    
    [self updateUI];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)onButtonRecents:(id)sender {
    if (!self.recentsWindowController) {
        self.recentsWindowController = [[RecentsWindowController alloc] init];
//        self.recentsWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"Recents"];
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
//        self.contactsWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"Contacts"];
        self.contactsWindowController = [[ContactsWindowController alloc] init];
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
//        self.dialpadWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"Dialpad"];
        self.dialpadWindowController = [[DialpadWindowController alloc] init];
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

- (IBAction)onButtonVideoMail:(id)sender {
    //[[ChatService sharedInstance] openChatWindowWithUser:nil];    
}

- (IBAction)onButtonSettings:(id)sender {
    if (!self.settingsWindowController) {
        self.settingsWindowController = [[SettingsWindowController alloc] init];
        [self.settingsWindowController showWindow:self];
    } else {
        if (self.settingsWindowController.isShow) {
            [self.settingsWindowController close];
            self.settingsWindowController = nil;
        } else {
            [self.settingsWindowController showWindow:self];
            self.settingsWindowController.isShow = YES;
        }
    }
}

- (void) showSettingsWindow {
    [self onButtonSettings:nil];
}

- (void) showVideoMailWindow {
    if (!self.videoMailWindowController) {
//        self.videoMailWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"VideoMail"];
        self.videoMailWindowController = [[VideoMailWindowController alloc] init];
        [self.videoMailWindowController showWindow:self];
    }

    [self.videoMailWindowController showWindow:self];
    self.videoMailWindowController.isShow = YES;
}

- (void)chatUnreadMessageEvent:(NSNotification*)notif {
    NSLog(@"notif: %@", notif);
    
    NSDictionary *object = (NSDictionary*)[notif object];
    self.labelMessageBadgNumber.integerValue = [[object objectForKey:@"unread_messages_count"] integerValue];
}

- (void)chatCleareUnreadMessageEvent:(NSNotification*)notif {
    
}

- (void)registrationUpdateEvent:(NSNotification*)notif {
    NSString* message = [notif.userInfo objectForKey:@"message"];
    [self registrationUpdate:[[notif.userInfo objectForKey: @"state"] intValue] message:message];
    
    LinphoneCore *lc = [LinphoneManager getLc];
    LinphoneProxyConfig *cfg=NULL;
    linphone_core_get_default_proxy(lc,&cfg);
    
    if (cfg) {
        const char *identity=linphone_proxy_config_get_identity(cfg);
        LinphoneAddress *addr=linphone_address_new(identity);
        const char* user = linphone_address_get_username(addr);
        NSString *username = [NSString stringWithUTF8String:user];
        
        self.textFieldAccount.stringValue = [NSString stringWithFormat:@"Account: %@", username];
    }
}

- (void)registrationUpdate:(LinphoneRegistrationState)state message:(NSString*)message{
    switch (state) {
        case LinphoneRegistrationOk: {
            self.textFieldRegistrationStatus.stringValue = @"Registered";

            [[NSNotificationCenter defaultCenter] removeObserver:[AppDelegate sharedInstance].loginViewController
                                                            name:kLinphoneConfiguringStateUpdate
                                                          object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:[AppDelegate sharedInstance].loginViewController
                                                            name:kLinphoneRegistrationUpdate
                                                          object:nil];

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

- (void) updateUI {
    LinphoneCore *lc = [LinphoneManager getLc];
    LinphoneProxyConfig *cfg=NULL;
    linphone_core_get_default_proxy(lc,&cfg);
    
    if (cfg) {
        const char *identity=linphone_proxy_config_get_identity(cfg);
        LinphoneAddress *addr=linphone_address_new(identity);
        const char* user = linphone_address_get_username(addr);
        NSString *username = [NSString stringWithUTF8String:user];
        
        self.textFieldAccount.stringValue = [NSString stringWithFormat:@"Account: %@", username];

        LinphoneRegistrationState state = linphone_proxy_config_get_state(cfg);
        [self registrationUpdate:state message:nil];
    }
}

- (void) closeAllWindows {
    if (self.recentsWindowController.isShow) {
        [self.recentsWindowController close];
        self.recentsWindowController = nil;
    }

    if (self.contactsWindowController.isShow) {
        [self.contactsWindowController close];
        self.contactsWindowController = nil;
    }

    if (self.dialpadWindowController.isShow) {
        [self.dialpadWindowController close];
        self.dialpadWindowController = nil;
    }

    if (self.videoMailWindowController.isShow) {
        [self.videoMailWindowController close];
        self.videoMailWindowController = nil;
    }

    if (self.settingsWindowController.isShow) {
        [self.settingsWindowController close];
        self.settingsWindowController = nil;
    }
}

@end
