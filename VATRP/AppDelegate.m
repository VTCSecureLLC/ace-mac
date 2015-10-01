//
//  AppDelegate.m
//  VATRP
//
//  Created by Edgar Sukiasyan on 8/27/15.
//  Copyright (c) 2015 Home. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeWindowController.h"
#import "LinphoneManager.h"
#import "AccountsService.h"
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

    videoCallWindowController = nil;

    [self.menuItemPreferences setAction:nil];
    
    // Set observers
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callUpdate:)
                                                 name:kLinphoneCallUpdate
                                               object:nil];
    
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"b7b28171bab92ce345aac7d54f435020"];
    [[BITHockeyManager sharedHockeyManager].crashManager setAutoSubmitCrashReport: YES];
    [[BITHockeyManager sharedHockeyManager] startManager];
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
}

- (VideoCallWindowController*) getVideoCallWindow {
    if (!videoCallWindowController) {
        videoCallWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"VideoCall"];
        [videoCallWindowController showWindow:self];
    }
    
    return videoCallWindowController;
}

- (IBAction)onMenuItemPreferences:(id)sender {
    [viewController showSettingsWindow];
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
//            [self changeCurrentView:[InCallViewController compositeViewDescription]];
            break;
        }
        case LinphoneCallUpdatedByRemote:
        {
//            const LinphoneCallParams* current = linphone_call_get_current_params(call);
//            const LinphoneCallParams* remote = linphone_call_get_remote_params(call);
//            
//            if (linphone_call_params_video_enabled(current) && !linphone_call_params_video_enabled(remote)) {
//                [self changeCurrentView:[InCallViewController compositeViewDescription]];
//            }
            break;
        }
        case LinphoneCallError:
        {
//            [self displayCallError:call message: message];
        }
        case LinphoneCallEnd:
        {
//            if (canHideInCallView) {
//                // Go to dialer view
//                DialerViewController *controller = DYNAMIC_CAST([self changeCurrentView:[DialerViewController compositeViewDescription]], DialerViewController);
//                if(controller != nil) {
//                    [controller setAddress:@""];
//                    [controller setTransferMode:FALSE];
//                }
//            } else {
//                [self changeCurrentView:[InCallViewController compositeViewDescription]];
//            }
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

@end
