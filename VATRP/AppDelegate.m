//
//  AppDelegate.m
//  VATRP
//
//  Created by Ruben Semerjyan on 8/27/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import "AppDelegate.h"
#import "AboutWindowController.h"
#import "LinphoneManager.h"
#import "AccountsService.h"
#import "RegistrationService.h"
#import "CallService.h"
#import "CallLogService.h"
#import "ChatService.h"
#import <HockeySDK/HockeySDK.h>
#import "LinphoneLocationManager.h"
#import "SettingsHandler.h"
#import "LinphoneAPI.h"

typedef struct _LinphoneCardDAVStats {
    int sync_done_count;
    int new_contact_count;
    int removed_contact_count;
    int updated_contact_count;
} LinphoneCardDAVStats;

@interface AppDelegate () <NSURLConnectionDelegate>
{
    NSWindow *window;
    VideoCallWindowController *videoCallWindowController;
    AboutWindowController *aboutWindowController;
    LinphoneCardDAVStats _cardDavStats;
}

@end

@implementation AppDelegate

@synthesize account;
@synthesize loginWindowController;
@synthesize loginViewController;
@synthesize homeWindowController;
@synthesize viewController;


-(void) applicationWillFinishLaunching:(NSNotification *)notification
{
#ifdef DEBUG
    NSLog(@"Debug: No crashes will be reported");
#else
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"b7b28171bab92ce345aac7d54f435020"];
    [[BITHockeyManager sharedHockeyManager].crashManager setAutoSubmitCrashReport: YES];
    [[BITHockeyManager sharedHockeyManager] startManager];
#endif
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // TODO: Uncomment the line below before going the AppStore
    //[self checkUpdates];
    
    // Insert code here to initialize your application
    // Initialize settings on launch if they have not been.
    [SettingsHandler.settingsHandler initializeUserDefaults:false settingForNoConfig:false];
    
    self.account = nil;
    
    [AccountsService sharedInstance];
    [CallLogService sharedInstance];
    [RegistrationService sharedInstance];
    [CallService sharedInstance];
    [ChatService sharedInstance];

    videoCallWindowController = nil;
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    [[LinphoneLocationManager sharedManager] startMonitoring];
    // Set observers
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(registrationUpdateEvent:)
                                                 name:kLinphoneRegistrationUpdate
                                               object:nil];
    NSString* linphoneVersion = [NSString stringWithUTF8String:linphone_core_get_version()];
    NSLog(@"LinphoneVersion: %@", linphoneVersion);


    linphone_core_set_log_level(ORTP_DEBUG);
    linphone_core_enable_logs_with_cb(linphone_iphone_log_handler);
    
    //[self.menuItemSignOut setAction:@selector(onMenuItemPreferencesSignOut:)];
    
    self.loginWindowController = [[LoginWindowController alloc] init];
    
    [self.loginWindowController showWindow:self];
   //[self.loginWindowController.window makeKeyAndOrderFront:self];
}

//- (NSMenu *)applicationDockMenu:(NSApplication *)sender {
//    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Main app menu"];
//    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"My Quit" action:@selector(myQuit:) keyEquivalent:@""];
//    [menu addItem:item];
//    
//    return menu;
//}
//
//-(void)myQuit:(id)sender {
//    NSLog(@"My Quit called");
//    [[NSApplication sharedApplication] terminate:self];
//}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return true;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    LinphoneCore *lc = [LinphoneManager getLc];
    
    if((lc != nil) && linphone_core_get_current_call(lc)){
        linphone_core_terminate_all_calls(lc);
    }

    BOOL shouldAutoLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"auto_login"];
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"auto_login"]){
        shouldAutoLogin = NO;
    }
    
    if (!shouldAutoLogin)
    {
        AccountModel *accountModel = [[AccountsService sharedInstance] getDefaultAccount];
        
        if (accountModel)
        {
            [[AccountsService sharedInstance] removeAccountWithUsername:accountModel.username];
//            [SettingsHandler.settingsHandler resetDefaultsWithCoreRunning];
        }
        
    }
    // Get the default proxyCfg in Linphone
    if (lc != nil)
    {
        LinphoneProxyConfig* proxyCfg = linphone_core_get_default_proxy_config([LinphoneManager getLc]);
        if (proxyCfg != nil)
        {
            // To unregister from SIP
            linphone_proxy_config_edit(proxyCfg);
            linphone_proxy_config_enable_register(proxyCfg, false);
            linphone_proxy_config_done(proxyCfg);
        }
    }
    [[LinphoneManager instance] destroyLinphoneCore];
    [LinphoneManager instanceRelease];

}

+ (AppDelegate*)sharedInstance {
    return (AppDelegate*)[NSApplication sharedApplication].delegate;
}

- (void) showTabWindow {
    
//    self.homeWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"HomeWindowController"];
    [[AppDelegate sharedInstance].loginWindowController close];
    [AppDelegate sharedInstance].loginWindowController = nil;
    
    if (self.homeWindowController == nil)
    {
        self.homeWindowController = [[HomeWindowController alloc] init];
    }
    else
    {
        [self.homeWindowController refreshForNewLogin];
    }
    [self.homeWindowController showWindow:self];
    if ([[SettingsHandler settingsHandler] isShowPreviewEnabled])
    {
        [[LinphoneAPI instance] linphoneShowSelfPreview:true];
    }
    [self.menuItemSignOut setEnabled:true];
    [self.menuItemPreferences setEnabled:true];
    [self.menuItemMessages setEnabled:true];
    [self.menuItemSelfPreview setEnabled:true];
}

-(NSPoint) getTabWindowOrigin{
    NSPoint origin = [self.homeWindowController getWindowOrigin];
    return origin;
}

-(NSPoint) getTabWindowSize{
    CGSize cgSize = [self.homeWindowController getWindowSize];
    NSPoint size = {cgSize.width, cgSize.height};
    return size;
}

-(void) applicationDidResignActive:(NSNotification *)notification{
    CallWindowController *callWindowController = [[CallService sharedInstance] getCallWindowController];
    if(callWindowController){
        LinphoneCall *call = linphone_core_get_current_call([LinphoneManager getLc]);
        if(call){
            [callWindowController.window orderFrontRegardless];
            [callWindowController.window setLevel:NSFloatingWindowLevel];
            [self.viewController.videoMailWindowController enableSelfVideo];
        }
    }
}

-(void) setTabWindowPos:(NSPoint)pos{
    [self.homeWindowController setWindowPos:pos];
}

- (void) closeTabWindow {
    [self.homeWindowController clearData];
    [self.homeWindowController close];
    
    //self.homeWindowController = nil;
}


-(void)dismissCallWindows
{
    if (videoCallWindowController != nil)
    {
        [videoCallWindowController close];
    }
    
    [[CallService sharedInstance] closeCallWindowController];

}
- (VideoCallWindowController*) getVideoCallWindow {
    if (!videoCallWindowController) {
//        videoCallWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"VideoCall"];
        videoCallWindowController = [[VideoCallWindowController alloc] init];
        [videoCallWindowController showWindow:self];
    }
    
    return videoCallWindowController;
}

- (IBAction)onMenuItemPreferences:(id)sender {
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

- (IBAction)onMenuItemAbout:(id)sender {
    if (!aboutWindowController) {
        aboutWindowController = [[AboutWindowController alloc] init];
        [aboutWindowController showWindow:self];
    } else {
        [aboutWindowController showWindow:self];
    }
}


- (void)onMenuItemPreferencesSignOut:(id)sender {
    AccountModel *accountModel = [[AccountsService sharedInstance] getDefaultAccount];
    
    if (accountModel) {
        [[AccountsService sharedInstance] removeAccountWithUsername:accountModel.username];
//        [SettingsHandler.settingsHandler resetDefaultsWithCoreRunning];
    }
    
    [self closeTabWindow];
    [viewController closeAllWindows];
    [[ChatService sharedInstance] closeChatWindowAndClear];

    [self.settingsWindowController close];
    self.settingsWindowController = nil;
    
    // Get the default proxyCfg in Linphone
    LinphoneProxyConfig* proxyCfg = linphone_core_get_default_proxy_config([LinphoneManager getLc]);
    
    // To unregister from SIP
    linphone_proxy_config_edit(proxyCfg);
    linphone_proxy_config_enable_register(proxyCfg, false);
    linphone_proxy_config_done(proxyCfg);

    if (self.loginWindowController == nil)
    {
        self.loginWindowController = [[LoginWindowController alloc]init];
    }
    
    [self.settingsWindowController showWindow:false];
    [self.loginWindowController showWindow:self];
    [self.menuItemSignOut setEnabled:false];
    [self.menuItemPreferences setEnabled:false];
    [self.menuItemMessages setEnabled:false];
    [self.menuItemSelfPreview setEnabled:false];
  
    if ([[LinphoneManager instance] coreIsRunning]) {
        [[LinphoneManager instance] destroyLinphoneCore];
        [LinphoneManager instanceRelease];
    }
}

- (IBAction)onMenuItemACEFeedBack:(id)sender
{
    [[[BITHockeyManager sharedHockeyManager] feedbackManager] showFeedbackWindow];
}

- (IBAction)onMenuItemACESyncContacts:(id)sender
{
    [self syncContacts];
}

- (IBAction)onMenuItemMessages:(NSMenuItem *)sender
{
    [[ChatService sharedInstance] openChatWindowWithUser:nil];
}

-(void) SignOut
{
    [self onMenuItemPreferencesSignOut:self.menuItemSignOut];
    [self.settingsWindowController closeWindow];
}

- (IBAction)onSignOut:(NSMenuItem *)sender
{
    [self onMenuItemPreferencesSignOut:sender];
}

- (IBAction)onMenuItemSelfPreview:(NSMenuItem *)sender
{
    [[SettingsHandler settingsHandler] setShowVideoSelfPreview:![[SettingsHandler settingsHandler]isShowPreviewEnabled]];
}

- (IBAction)onMenuItemGoToSupport:(NSMenuItem *)sender
{
    [[[BITHockeyManager sharedHockeyManager] feedbackManager] showFeedbackWindow];
}

- (IBAction)onMenuItemWelcomeTour:(NSMenuItem *)sender
{
    // to come later
}

- (IBAction)onMenuItemPrivacyPolicy:(NSMenuItem *)sender
{
    // to come later
}


- (void)registrationUpdateEvent:(NSNotification*)notif {
    LinphoneRegistrationState state = (LinphoneRegistrationState)[[notif.userInfo objectForKey: @"state"] intValue];
}


void linphone_iphone_log_handler(const char *domain, OrtpLogLevel lev, const char *fmt, va_list args) {
     NSString *format = [[NSString alloc] initWithUTF8String:fmt];
    NSString *formatedString = [[NSString alloc] initWithFormat:format arguments:args];
    char levelC = 'I';
    switch ((OrtpLogLevel)lev) {
        case ORTP_FATAL:
            levelC = 'F';
            break;
        case ORTP_ERROR:
            levelC = 'E';
            break;
        case ORTP_WARNING:
            levelC = 'W';
            break;
        case ORTP_MESSAGE:
            levelC = 'I';
            break;
        case ORTP_TRACE:
        case ORTP_DEBUG:
            levelC = 'D';
            break;
        case ORTP_LOGLEV_END:
            return;
    }
    // since \r are interpreted like \n, avoid double new lines when logging packets
    NSString* linphoneVersion = [NSString stringWithUTF8String:linphone_core_get_version()];
    NSLog(@"%@ %c %@",linphoneVersion, levelC, [formatedString stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"]);
    
}

#pragma mark - local notifications
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

-(void)checkUpdates {
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString* appID = infoDictionary[@"CFBundleIdentifier"];
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@", appID]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
}

#pragma mark - NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSDictionary* lookup = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    if ([lookup[@"resultCount"] integerValue] == 1){
        NSString* appStoreVersion = lookup[@"results"][0][@"version"];
        NSString* currentVersion = infoDictionary[@"CFBundleShortVersionString"];
        if (currentVersion && appStoreVersion) {
            if (![appStoreVersion isEqualToString:currentVersion]){
                NSAlert *alert = [[NSAlert alloc] init];
                [alert addButtonWithTitle:@"OK"];
                [alert setMessageText:@"There is a newer version of this app available."];
                [alert runModal];
            }
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Fail to check a new version existance");
}

- (void)syncContacts {
    
    const char *cardDavUser = "vtcsecure";
    const char *cardDavPass = "top-secret";
    const char *cardDavRealm = "BaikalDAV";
    const char *cardDavServer = "http://dav.linphone.org/card.php/addressbooks/vtcsecure/default";
    const char *cardDavDomain = "dav.linphone.org";
    
    
    //LinphoneFriend *newFriend = linphone_core_create_friend_with_address([LinphoneManager getLc], "sip:example@example.com");
    
    //    LinphoneFriend *newFriend = linphone_friend_new();
    //
    //    const LinphoneAddress *lAddr = linphone_address_new("sip:example@example.com");
    //
    //    linphone_friend_set_address(newFriend, lAddr);
    //    linphone_friend_add_address(newFriend, lAddr);
    //
    //    linphone_friend_set_name(newFriend, "John");
    //    linphone_friend_set_ref_key(newFriend, "123456");
    //
    //    LinphoneFriendList *friendList = linphone_core_get_default_friend_list([LinphoneManager getLc]);
    //    linphone_friend_list_add_friend(friendList, newFriend);
    //
    LinphoneFriendList * cardDAVFriends = linphone_core_get_default_friend_list([LinphoneManager getLc]);
    
    const MSList* proxies = linphone_friend_list_get_friends(cardDAVFriends);
    NSLog(@"contacts_Count = %d", ms_list_size(proxies));
    
    const LinphoneAuthInfo * carddavAuth = linphone_auth_info_new(cardDavUser, nil, cardDavPass, nil, cardDavRealm, cardDavDomain);
    linphone_core_add_auth_info([LinphoneManager getLc], carddavAuth);
    
    LinphoneFriendListCbs * cbs = linphone_friend_list_get_callbacks(cardDAVFriends);
    linphone_friend_list_cbs_set_user_data(cbs, &_cardDavStats);
    linphone_friend_list_cbs_set_sync_status_changed(cbs, carddav_sync_status_changed);
    linphone_friend_list_cbs_set_contact_created(cbs, carddav_contact_created);
    linphone_friend_list_cbs_set_contact_deleted(cbs, carddav_contact_deleted);
    linphone_friend_list_cbs_set_contact_updated(cbs, carddav_contact_updated);
    
    linphone_friend_list_set_uri(cardDAVFriends, cardDavServer);
    linphone_friend_list_synchronize_friends_from_server(cardDAVFriends);
    
}

static void carddav_sync_status_changed(LinphoneFriendList *list, LinphoneFriendListSyncStatus status, const char *msg) {
    
}

static void carddav_contact_created(LinphoneFriendList *list, LinphoneFriend *lf) {
    if (linphone_friend_get_ref_key(lf)) {
        // own contact successully uploaded to the server
    } else {
        // create contact
        // add contact to default friend list
        LinphoneFriendList *friendList = linphone_core_get_default_friend_list([LinphoneManager getLc]);
        NSString * timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
        linphone_friend_set_ref_key(lf, [timestamp UTF8String]);
        LinphoneFriendListStatus status = linphone_friend_list_add_friend(friendList, lf);
        if (status == LinphoneFriendListInvalidFriend) {
            NSLog(@"SYNC ERROR: Invalid friend");
        }
    }
}

static void carddav_contact_deleted(LinphoneFriendList *list, LinphoneFriend *lf) {
    
    if (linphone_friend_get_ref_key(lf)) {
         LinphoneFriendList *friendList = linphone_core_get_default_friend_list([LinphoneManager getLc]);
        linphone_friend_list_remove_friend(friendList, lf);
    } else {
        NSLog(@"SYNC ERROR: Contact doesn't have a ref Key");
    }
}

static void carddav_contact_updated(LinphoneFriendList *list, LinphoneFriend *new_friend, LinphoneFriend *old_friend) {
    
    const char *receivedRefKey = linphone_friend_get_ref_key(new_friend);
    
    if (receivedRefKey) {
        
        LinphoneFriendList * friendList = linphone_core_get_default_friend_list([LinphoneManager getLc]);
        const MSList* friends = linphone_friend_list_get_friends(friendList);
        while (friends != NULL) {
            LinphoneFriend* friend = (LinphoneFriend*)friends->data;
            const char *friendRefKey = linphone_friend_get_ref_key(friend);
            
            if (strcmp(friendRefKey, receivedRefKey)) {
                
                linphone_friend_edit(friend);
                
                // Set the new name
                const char * newName = linphone_friend_get_name(new_friend);
                linphone_friend_set_name(friend, newName);
                
                // Remove sip addresses
                const MSList* friendAddresses = linphone_friend_get_addresses(friend);
                while (friendAddresses != NULL) {
                    LinphoneAddress* lAddress = (LinphoneAddress*)friendAddresses->data;
                    linphone_friend_remove_address(friend, lAddress);
                    friendAddresses = ms_list_next(friendAddresses);
                }
                
                // Remove phones
                const MSList* friendPhoneNumbers = linphone_friend_get_phone_numbers(friend);
                while (friendPhoneNumbers != NULL) {
                    const char* lPhoneNumber = (const char*)friendPhoneNumbers->data;
                    linphone_friend_remove_phone_number(friend, lPhoneNumber);
                    friendPhoneNumbers = ms_list_next(friendPhoneNumbers);
                }
                
                // Add new sip addresses
                const MSList* newFriendAddresses = linphone_friend_get_addresses(new_friend);
                while (newFriendAddresses != NULL) {
                    LinphoneAddress* lAddress = (LinphoneAddress*)friendAddresses->data;
                    linphone_friend_add_address(new_friend, lAddress);
                    newFriendAddresses = ms_list_next(newFriendAddresses);
                }
                
                // Add new phone numbers
                const MSList* newFriendPhoneNumbers = linphone_friend_get_addresses(new_friend);
                while (newFriendPhoneNumbers != NULL) {
                    const char* lPhoneNumber = (const char*)friendPhoneNumbers->data;
                    linphone_friend_add_phone_number(new_friend, lPhoneNumber);
                    newFriendPhoneNumbers = ms_list_next(newFriendPhoneNumbers);
                }
                
                linphone_friend_done (friend);
                
                break;
            }
            
            friends = ms_list_next(friends);
        }
    } else {
        NSLog(@"SYNC ERROR: No such a contact to be deleted");
    }
}


@end
