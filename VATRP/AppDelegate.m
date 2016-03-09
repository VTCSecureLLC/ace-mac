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

@interface AppDelegate ()
{
    NSWindow *window;
    VideoCallWindowController *videoCallWindowController;
    AboutWindowController *aboutWindowController;
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
    // Insert code here to initialize your application
    // Initialize settings on launch if they have not been.
    [SettingsHandler.settingsHandler initializeUserDefaults:false];
    
    self.account = nil;
    
    [AccountsService sharedInstance];
    [CallLogService sharedInstance];
    [RegistrationService sharedInstance];
    [CallService sharedInstance];
    [ChatService sharedInstance];

    videoCallWindowController = nil;
    
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

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    LinphoneCore *lc = [LinphoneManager getLc];
    if(linphone_core_get_current_call(lc)){
        linphone_core_terminate_all_calls(lc);
    }

    BOOL shouldAutoLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"auto_login"];
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"auto_login"]){
        shouldAutoLogin = NO;
    }
    
    if (!shouldAutoLogin) {
        AccountModel *accountModel = [[AccountsService sharedInstance] getDefaultAccount];
        
        if (accountModel) {
            [[AccountsService sharedInstance] removeAccountWithUsername:accountModel.username];
            [SettingsHandler.settingsHandler resetDefaultsWithCoreRunning];
        }
        
    }
    // Get the default proxyCfg in Linphone
    LinphoneProxyConfig* proxyCfg = linphone_core_get_default_proxy_config([LinphoneManager getLc]);
    
    // To unregister from SIP
    linphone_proxy_config_edit(proxyCfg);
    linphone_proxy_config_enable_register(proxyCfg, false);
    linphone_proxy_config_done(proxyCfg);
    
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
    
    self.homeWindowController = [[HomeWindowController alloc] init];
    [self.homeWindowController showWindow:self];

    [self.menuItemSignOut setEnabled:true];
    [self.menuItemPreferences setEnabled:true];
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
    [self.homeWindowController close];
    self.homeWindowController = nil;
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
        [SettingsHandler.settingsHandler resetDefaultsWithCoreRunning];
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
    
    
    [self.loginWindowController showWindow:self];
    [self.menuItemSignOut setEnabled:false];
    [self.menuItemPreferences setEnabled:false];
  
    if ([[LinphoneManager instance] coreIsRunning]) {
        [[LinphoneManager instance] destroyLinphoneCore];
        [LinphoneManager instanceRelease];
    }
}

- (IBAction)onMenuItemACEFeedBack:(id)sender {
    [[[BITHockeyManager sharedHockeyManager] feedbackManager] showFeedbackWindow];
}

- (void)onMenuItemMessages:(id)sender {
    [[ChatService sharedInstance] openChatWindowWithUser:nil];
}

-(void) SignOut {
    [self onMenuItemPreferencesSignOut:self.menuItemSignOut];
}

- (IBAction)onSignOut:(NSMenuItem *)sender {
    [self onMenuItemPreferencesSignOut:sender];
}

- (void)registrationUpdateEvent:(NSNotification*)notif {
    LinphoneRegistrationState state = (LinphoneRegistrationState)[[notif.userInfo objectForKey: @"state"] intValue];
    
//    if (state == LinphoneRegistrationOk) {
//        [self.menuItemSignOut setAction:@selector(onMenuItemPreferencesSignOut:)];
//    } else {
//        [self.menuItemSignOut setAction:nil];
//    }

    if (state == LinphoneRegistrationOk) {
        [self.menuItemMessages setAction:@selector(onMenuItemMessages:)];
    } else {
        [self.menuItemMessages setAction:nil];
    }
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

@end
