//
//  AppDelegate.m
//  VATRP
//
//  Created by Ruben Semerjyan on 8/27/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeWindowController.h"
#import "LinphoneManager.h"
#import "AccountsService.h"
#import "RegistrationService.h"
#import "CallLogService.h"
#import <HockeySDK/HockeySDK.h>

@interface AppDelegate () {
    HomeWindowController *homeWindowController;
    VideoCallWindowController *videoCallWindowController;
}

@end

@implementation AppDelegate

@synthesize loginWindowController;
@synthesize loginViewController;
@synthesize callWindowController;
@synthesize viewController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    [AccountsService sharedInstance];
    [CallLogService sharedInstance];
    [RegistrationService sharedInstance];

    videoCallWindowController = nil;
    
    // Set observers
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callUpdate:)
                                                 name:kLinphoneCallUpdate
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(registrationUpdateEvent:)
                                                 name:kLinphoneRegistrationUpdate
                                               object:nil];
    
    
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"b7b28171bab92ce345aac7d54f435020"];
    [[BITHockeyManager sharedHockeyManager].crashManager setAutoSubmitCrashReport: YES];
    [[BITHockeyManager sharedHockeyManager] startManager];
    
    linphone_core_set_log_level(ORTP_DEBUG);
    linphone_core_set_log_handler((OrtpLogFunc)linphone_iphone_log_handler);
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

+ (AppDelegate*)sharedInstance {
    return (AppDelegate*)[NSApplication sharedApplication].delegate;
}

- (void) showTabWindow {
    homeWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"HomeWindowController"];
    [homeWindowController showWindow:self];

    [[AppDelegate sharedInstance].loginWindowController close];
    [AppDelegate sharedInstance].loginWindowController = nil;
}

-(NSPoint) getTabWindowOrigin{
    NSPoint origin = [homeWindowController getWindowOrigin];
    return origin;
}

-(NSPoint) getTabWindowSize{
    CGSize cgSize = [homeWindowController getWindowSize];
    NSPoint size = {cgSize.width, cgSize.height};
    return size;
}

-(void) applicationDidResignActive:(NSNotification *)notification{
    if(callWindowController){
        LinphoneCall *call = linphone_core_get_current_call([LinphoneManager getLc]);
        if(call){
            [callWindowController.window orderFrontRegardless];
            [callWindowController.window setLevel:NSFloatingWindowLevel];
            [viewController.videoMailWindowController enableSelfVideo];
        }
    }

}

-(void) setTabWindowPos:(NSPoint)pos{
    [homeWindowController setWindowPos:pos];
}

- (void) closeTabWindow {
    [homeWindowController close];
    homeWindowController = nil;
}

- (VideoCallWindowController*) getVideoCallWindow {
    if (!videoCallWindowController) {
        videoCallWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"VideoCall"];
        [videoCallWindowController showWindow:self];
    }
    
    return videoCallWindowController;
}

- (void)onMenuItemPreferences:(id)sender {
    [viewController showSettingsWindow];
}

- (void)onMenuItemPreferencesSignOut:(id)sender {
    AccountModel *accountModel = [[AccountsService sharedInstance] getDefaultAccount];
    
    if (accountModel) {
        [[AccountsService sharedInstance] removeAccountWithUsername:accountModel.username];
        [[AccountsService sharedInstance] addAccountWithUsername:accountModel.username
                                                        Password:@""
                                                          Domain:@""
                                                       Transport:@""
                                                            Port:0
                                                       isDefault:YES];
    }
    
    [self closeTabWindow];
    [viewController closeAllWindows];
    
    // Get the default proxyCfg in Linphone
    LinphoneProxyConfig* proxyCfg = NULL;
    linphone_core_get_default_proxy([LinphoneManager getLc], &proxyCfg);
    
    // To unregister from SIP
    linphone_proxy_config_edit(proxyCfg);
    linphone_proxy_config_enable_register(proxyCfg, false);
    linphone_proxy_config_done(proxyCfg);
    
    self.loginWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"LoginWindowController"];
    [self.loginWindowController showWindow:self];
}

- (void)callUpdate:(NSNotification*)notif {
    LinphoneCall *call = [[notif.userInfo objectForKey: @"call"] pointerValue];
    LinphoneCallState state = [[notif.userInfo objectForKey: @"state"] intValue];
    NSString *message = [notif.userInfo objectForKey: @"message"];
    
    bool canHideInCallView = (linphone_core_get_calls([LinphoneManager getLc]) == NULL);
    
//    // Don't handle call state during incoming call view
//    if([[self currentView] equal:[IncomingCallViewController compositeViewDescription]] && state != LinphoneCallError && state != LinphoneCallEnd) {
//        return;
//    }
    
    switch (state) {
        case LinphoneCallIncomingReceived:
        case LinphoneCallIncomingEarlyMedia:
        {
            [self displayIncomingCall:call];
            
            NSInteger auto_answer = [[NSUserDefaults standardUserDefaults] boolForKey:@"ACE_AUTO_ANSWER_CALL"];
            
            if (auto_answer) {
                [[LinphoneManager instance] acceptCall:call];
            }
            
            break;
        }
        case LinphoneCallOutgoingInit: {
            [self displayOutgoingCall:call];
        }
            break;
        case LinphoneCallPausedByRemote:
        case LinphoneCallConnected:
        case LinphoneCallStreamsRunning:
        {
            break;
        }
        case LinphoneCallUpdatedByRemote:
        {
            break;
        }
        case LinphoneCallError:
        {
        }
        case LinphoneCallEnd:
        {
            break;
        }
        default:
            break;
    }
}

- (void)displayIncomingCall:(LinphoneCall*) call{
    LinphoneCallLog* callLog = linphone_call_get_call_log(call);
    NSString* callId         = [NSString stringWithUTF8String:linphone_call_log_get_call_id(callLog)];

    LinphoneManager* lm = [LinphoneManager instance];
    BOOL callIDFromPush = [lm popPushCallID:callId];
    BOOL autoAnswer     = [lm lpConfigBoolForKey:@"autoanswer_notif_preference"];
    
    if (callIDFromPush && autoAnswer){
        // accept call automatically
        [lm acceptCall:call];
        
    } else {
        self.callWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"XXX"];
        [self.callWindowController showWindow:self];

        if(self.callWindowController != nil) {
            CallViewController *callViewController = [self.callWindowController getCallViewController];
            [callViewController setCall:call];
//          [callViewController setDelegate:self];
        }
        
    }
}

- (void)displayOutgoingCall:(LinphoneCall*) call{    
    self.callWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"XXX"];
    [self.callWindowController showWindow:self];
    
    if(self.callWindowController != nil) {
        CallViewController *callViewController = [self.callWindowController getCallViewController];
        [callViewController setOutgoingCall:call];
    }
}

- (void)registrationUpdateEvent:(NSNotification*)notif {
    LinphoneRegistrationState state = (LinphoneRegistrationState)[[notif.userInfo objectForKey: @"state"] intValue];
    
    if (state == LinphoneRegistrationOk) {
        [self.menuItemSignOut setAction:@selector(onMenuItemPreferencesSignOut:)];
    } else {
        [self.menuItemSignOut setAction:nil];
    }
}

void linphone_iphone_log_handler(int lev, const char *fmt, va_list args) {
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
    NSLog(@"%c %@", levelC, [formatedString stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"]);
}

@end
