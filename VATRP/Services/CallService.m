//
//  CallService.m
//  ACE
//
//  Created by Ruben Semerjyan on 10/16/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "CallService.h"
#import "ChatService.h"
#import "AppDelegate.h"


@interface CallService () {
    CallWindowController *callWindowController;
    
    LinphoneCall *currentCall;
}

@end


@implementation CallService

+ (CallService *)sharedInstance
{
    static CallService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CallService alloc] init];
    });
    
    return sharedInstance;
}

- (id) init {
    self = [super init];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(callUpdate:)
                                                     name:kLinphoneCallUpdate
                                                   object:nil];
    }
    
    return self;
}

- (CallWindowController*) getCallWindowController {
    return callWindowController;
}

+ (void) callTo:(NSString*)number {
    LinphoneCore *lc = [LinphoneManager getLc];
    
    LinphoneCall *thiscall;
    thiscall = linphone_core_get_current_call(lc);
    LinphoneCallParams *params = linphone_core_create_call_params(lc, thiscall);
    LinphoneAddress* linphoneAddress = linphone_core_interpret_url(lc, [number cStringUsingEncoding:[NSString defaultCStringEncoding]]);
    linphone_call_params_enable_realtime_text(params, [[NSUserDefaults standardUserDefaults] boolForKey:kREAL_TIME_TEXT_ENABLED]);
    linphone_core_invite_address_with_params(lc, linphoneAddress, params);
}

- (int) decline {
    return linphone_core_terminate_call([LinphoneManager getLc], currentCall);
}

- (void) accept {
    [[LinphoneManager instance] acceptCall:currentCall];
}

- (LinphoneCall*) getCurrentCall {
    return currentCall;
}

- (void)callUpdate:(NSNotification*)notif {
    LinphoneCall *aCall = [[notif.userInfo objectForKey: @"call"] pointerValue];
    LinphoneCallState state = [[notif.userInfo objectForKey: @"state"] intValue];

    if(currentCall == aCall && (state == LinphoneCallEnd || state == LinphoneCallError)) {
        [callWindowController performSelector:@selector(close) withObject:nil afterDelay:1.0];
        callWindowController = nil;
    }

    NSString *message = [notif.userInfo objectForKey: @"message"];

    //    // Don't handle call state during incoming call view
    //    if([[self currentView] equal:[IncomingCallViewController compositeViewDescription]] && state != LinphoneCallError && state != LinphoneCallEnd) {
    //        return;
    //    }
    
    LinphoneCore *lc = [LinphoneManager getLc];
    
    switch (state) {
        case LinphoneCallIncomingReceived:
        case LinphoneCallIncomingEarlyMedia:
        {
            [self displayIncomingCall:aCall];
            
            NSInteger auto_answer = [[NSUserDefaults standardUserDefaults] boolForKey:@"ACE_AUTO_ANSWER_CALL"];
            
            if (auto_answer) {
                [[LinphoneManager instance] acceptCall:aCall];
            }
            
            break;
        }
        case LinphoneCallOutgoingInit: {
            const LinphoneCallParams* current = linphone_call_get_current_params(aCall);

            if (!linphone_call_params_realtime_text_enabled(current)) {
                [self displayOutgoingCall:aCall];
            }
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
            const LinphoneCallParams* current = linphone_call_get_current_params(currentCall);
            const LinphoneCallParams* remote = linphone_call_get_remote_params(currentCall);
            
            /* remote wants to add video */
            if (linphone_core_video_enabled(lc) && !linphone_call_params_video_enabled(current) &&
                linphone_call_params_video_enabled(remote) &&
                !linphone_core_get_video_policy(lc)->automatically_accept) {
                linphone_core_defer_call_update(lc, currentCall);
                LinphoneCallParams* paramsCopy = linphone_call_params_copy(linphone_call_get_current_params(currentCall));
                linphone_call_params_enable_video(paramsCopy, TRUE);
                linphone_core_accept_call_update([LinphoneManager getLc], currentCall, paramsCopy);
                linphone_call_params_destroy(paramsCopy);
            } else if (linphone_call_params_video_enabled(current) && !linphone_call_params_video_enabled(remote)) {

            }
        }
            break;
        case LinphoneCallError:
        case LinphoneCallEnd: {
            [[ChatService sharedInstance] closeChatWindow];

            [self performSelector:@selector(closeCallWindow) withObject:nil afterDelay:1.0];
        }
            break;
        case LinphoneCallReleased: {
            [[ChatService sharedInstance] closeChatWindow];
            currentCall = NULL;

            [self performSelector:@selector(closeCallWindow) withObject:nil afterDelay:1.0];
        }
            break;
        default:
            break;
    }
}

- (void)displayIncomingCall:(LinphoneCall*)call {
    currentCall = call;
    
    LinphoneCallLog* callLog = linphone_call_get_call_log(call);
    NSString* callId         = [NSString stringWithUTF8String:linphone_call_log_get_call_id(callLog)];
    
    LinphoneManager* lm = [LinphoneManager instance];
    BOOL callIDFromPush = [lm popPushCallID:callId];
    BOOL autoAnswer     = [lm lpConfigBoolForKey:@"autoanswer_notif_preference"];
    
    if (callIDFromPush && autoAnswer){
        // accept call automatically
        [lm acceptCall:call];
        
    } else {
        [self openCallWindow];

        [[[AppDelegate sharedInstance].homeWindowController getHomeViewController].videoView setCall:call];
//        
//        callWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"XXX"];
//        [callWindowController showWindow:self];
//        
//        if (callWindowController != nil) {
//            CallViewController *callViewController = [callWindowController getCallViewController];
//            [callViewController setCall:call];
//        }
    }
}

- (void)displayOutgoingCall:(LinphoneCall*)call {
    currentCall = call;

    [self openCallWindow];
    [[[AppDelegate sharedInstance].homeWindowController getHomeViewController].videoView setOutgoingCall:call];
    
//    callWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"XXX"];
//    [callWindowController showWindow:self];
//    
//    if (callWindowController != nil) {
//        CallViewController *callViewController = [callWindowController getCallViewController];
//        [callViewController setOutgoingCall:call];
//    }
}

- (void) openCallWindow {
    NSWindow *window = [AppDelegate sharedInstance].homeWindowController.window;
    [window setFrame:NSMakeRect(window.frame.origin.x, window.frame.origin.y, 1013, window.frame.size.height)
             display:YES
             animate:YES];
}

- (void) closeCallWindow {
    NSWindow *window = [AppDelegate sharedInstance].homeWindowController.window;
    [window setFrame:NSMakeRect(window.frame.origin.x, window.frame.origin.y, 310, window.frame.size.height)
             display:YES
             animate:YES];
}

@end
