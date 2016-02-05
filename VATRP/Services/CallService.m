//
//  CallService.m
//  ACE
//
//  Created by Ruben Semerjyan on 10/16/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "CallService.h"
#import "ChatService.h"
#import "ViewManager.h"
#import "AppDelegate.h"
#import "SettingsService.h"


@interface CallService () {
    CallWindowController *callWindowController;
    
    LinphoneCall *currentCall;
}

+ (int) callsCount;

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
    [[[AppDelegate sharedInstance].homeWindowController getHomeViewController].videoView showVideoPreview];
    linphone_core_enable_self_view([LinphoneManager getLc], [SettingsHandler.settingsHandler isShowSelfViewEnabled]);
    [[CallService sharedInstance] performSelector:@selector(callUsingLinphoneManager:) withObject:number afterDelay:1.0];
}

- (void) callUsingLinphoneManager:(NSString*)number {
    [[LinphoneManager instance] call:number displayName:number transfer:NO];
}
    
- (int) decline:(LinphoneCall *)aCall {
    return linphone_core_terminate_call([LinphoneManager getLc], aCall);
}

- (void) accept:(LinphoneCall *)aCall {
    linphone_core_enable_self_view([LinphoneManager getLc], [SettingsHandler.settingsHandler isShowSelfViewEnabled]);
    [[LinphoneManager instance] acceptCall:aCall];
}

- (void) pause:(LinphoneCall*)aCall {
    linphone_core_pause_call([LinphoneManager getLc], aCall);
}

- (void) resume:(LinphoneCall*)aCall {
    linphone_core_resume_call([LinphoneManager getLc], aCall);
}

- (void) swapCallsToCall:(LinphoneCall*)aCall {
    [[[AppDelegate sharedInstance].homeWindowController getHomeViewController].videoView setCallToSecondCallView:currentCall];
    [[[AppDelegate sharedInstance].homeWindowController getHomeViewController].videoView setCall:aCall];

    linphone_core_pause_call([LinphoneManager getLc], currentCall);
    linphone_core_resume_call([LinphoneManager getLc], aCall);

    currentCall = aCall;
}

- (LinphoneCall*) getCurrentCall {
    return currentCall;
}

- (void)callUpdate:(NSNotification*)notif {
    LinphoneCall *aCall = [[notif.userInfo objectForKey: @"call"] pointerValue];
    LinphoneCallState state = [[notif.userInfo objectForKey: @"state"] intValue];

    LinphoneCore *lc = [LinphoneManager getLc];
    
    NSLog(@"****** callupdate");
    switch (state) {
        case LinphoneCallIncomingReceived:
            NSLog(@"****** LinphoneCallIncomingReceived");
        case LinphoneCallIncomingEarlyMedia:
        {
            NSLog(@"****** LinphoneCallIncomingEarlyMedia");
            int call_count = [CallService callsCount];
            
            if (call_count == 3) {
                [self decline:aCall]; //    linphone_core_set_max_calls(lc, 2);

                
                break;
            }
            
            if (currentCall && aCall != currentCall) {
                [[[AppDelegate sharedInstance].homeWindowController getHomeViewController].videoView showSecondIncomingCallView:aCall];
            } else {
                [self displayIncomingCall:aCall];
            }
            
            NSInteger auto_answer = [[NSUserDefaults standardUserDefaults] boolForKey:@"ACE_AUTO_ANSWER_CALL"];
            
            if (auto_answer) {
                [[LinphoneManager instance] acceptCall:aCall];
            }
            
            break;
        }
        case LinphoneCallOutgoingInit: {
            NSLog(@"****** LinphoneCallOutgoingInit");
            const LinphoneCallParams* current = linphone_call_get_current_params(aCall);

            if (!linphone_call_params_realtime_text_enabled(current)) {
                [self displayOutgoingCall:aCall];
            }
        }
            break;
        case LinphoneCallConnected: {
            NSLog(@"****** LinphoneCallConnected");
            int call_count = [CallService callsCount];
            
            if (currentCall && aCall != currentCall && call_count > 1) {
                [[[AppDelegate sharedInstance].homeWindowController getHomeViewController].videoView setCallToSecondCallView:currentCall];
            }
            
            currentCall = aCall;
            [[[AppDelegate sharedInstance].homeWindowController getHomeViewController].videoView setCall:currentCall];
            //const char *speakerString = linphone_core_get_playback_device([LinphoneManager getLc]);
            //NSString *speaker = [[NSString alloc] initWithUTF8String:speakerString];
            //NSLog([NSString stringWithFormat:@"SPEAKER IS %@", speaker ]);
            //bool echoCancellation = [SettingsService getEchoCancel];
            linphone_call_enable_echo_cancellation(aCall, [SettingsService getEchoCancel]);
        }
            break;
        case LinphoneCallPausedByRemote:
            NSLog(@"****** LinphoneCallPausedByRemote");
        case LinphoneCallStreamsRunning:
        {
            NSLog(@"****** LinphoneCallStreamsRunning");
            // The streams are set up. Make sure that the initial call settings are handled on call set up here.
            SettingsHandler* settingsHandler = [SettingsHandler settingsHandler];
            bool microphoneMuted = [settingsHandler isMicrophoneMuted];
            linphone_core_enable_mic(lc, !microphoneMuted);
            bool speakerMuted = [settingsHandler isSpeakerMuted];
            [LinphoneManager.instance muteSpeakerInCall:speakerMuted];
            bool micIsEnabled = linphone_core_mic_enabled(lc);
            linphone_core_set_play_level(lc, 100);
            int playLevel = linphone_core_get_play_level(lc);
            int playbackGain = linphone_core_get_playback_gain_db(lc);
            NSLog([NSString stringWithFormat:@"   play level IS %d, playback gain is %d ********************************", playLevel, playbackGain ]);
            const char *speakerString = linphone_core_get_playback_device([LinphoneManager getLc]);
            NSString *speaker = [[NSString alloc] initWithUTF8String:speakerString];
            NSLog([NSString stringWithFormat:@"SPEAKER IS %@", speaker ]);
            bool speakerCanPlayback = linphone_core_sound_device_can_playback(lc, speakerString);
            if (speakerCanPlayback)
            {
                NSLog(@"    speaker can playback");
            }
            else
            {
                NSLog(@"    speaker can NOT playback");
            }
            break;
        }
        case LinphoneCallUpdatedByRemote:
        {
            NSLog(@"****** LinphoneCallUpdatedByRemote");
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
            NSLog(@"****** LinphoneCallError");
        case LinphoneCallEnd: {
            NSLog(@"****** LinphoneCallEnd");
            int call_count = [CallService callsCount];

            if (call_count == 1) {
                [[[AppDelegate sharedInstance].homeWindowController getHomeViewController].videoView hideSecondCallView];
                const MSList *call_list = linphone_core_get_calls(lc);
                currentCall = (LinphoneCall*)call_list->data;
            }
            
            if (currentCall && aCall != currentCall) {
                [[[AppDelegate sharedInstance].homeWindowController getHomeViewController].videoView hideSecondIncomingCallView];
            } else {
                [[ChatService sharedInstance] closeChatWindow];
                [self performSelector:@selector(closeCallWindow) withObject:nil afterDelay:1.0];
            }
            
            [[ChatService sharedInstance] closeChatWindow];
            [[ViewManager sharedInstance].rttView viewWillDisappear];

        }
            break;
        case LinphoneCallReleased: {
            NSLog(@"****** LinphoneCallReleased");
            if (currentCall && aCall != currentCall) {
                [[[AppDelegate sharedInstance].homeWindowController getHomeViewController].videoView hideSecondIncomingCallView];
            }
            
            [[ChatService sharedInstance] closeChatWindow];
            [[ViewManager sharedInstance].rttView viewWillDisappear];
            currentCall = NULL;

            [self performSelector:@selector(closeCallWindow) withObject:nil afterDelay:1.0];

            const MSList *call_list = linphone_core_get_calls(lc);
            if (call_list) {
                int count = ms_list_size(call_list);
                
                if (count) {
                    currentCall = (LinphoneCall*)call_list->data;

                    if (currentCall) {
                        [[[AppDelegate sharedInstance].homeWindowController getHomeViewController].videoView setCall:currentCall];
                    }
                }
            }
        }
            break;
        default:
            break;
    }
}

- (void)displayIncomingCall:(LinphoneCall*)call {
    if ([AppDelegate sharedInstance].homeWindowController.window.miniaturized) {
        [[AppDelegate sharedInstance].homeWindowController.window makeKeyAndOrderFront:self];
    } else {
        [NSApp activateIgnoringOtherApps:YES];
    }

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
        [[ViewManager sharedInstance].rttView viewWillAppear];
        [self openCallWindow];

        [[[AppDelegate sharedInstance].homeWindowController getHomeViewController].videoView setIncomingCall:call];
    }
}

- (void)displayOutgoingCall:(LinphoneCall*)call {
    currentCall = call;

    [[ViewManager sharedInstance].rttView viewWillAppear];
    
    [self openCallWindow];
    [[[AppDelegate sharedInstance].homeWindowController getHomeViewController].videoView setOutgoingCall:call];
}

- (void) openCallWindow {
    NSWindow *window = [AppDelegate sharedInstance].homeWindowController.window;
    if (window.frame.origin.x + 1030 > [[NSScreen mainScreen] frame].size.width) {
        [window setFrame:NSMakeRect([[NSScreen mainScreen] frame].size.width  - 1030 - 5, window.frame.origin.y, 1030, window.frame.size.height)
                 display:YES
                 animate:YES];
    } else {
        [window setFrame:NSMakeRect(window.frame.origin.x, window.frame.origin.y, 1030, window.frame.size.height)
                 display:YES
                 animate:YES];
    }
}

- (void) closeCallWindow {
    LinphoneCore *lc = [LinphoneManager getLc];

    if (!linphone_core_get_calls(lc)) {
        
        if ([[AppDelegate sharedInstance].homeWindowController getHomeViewController].isAppFullScreen) {
            NSWindow *window = [AppDelegate sharedInstance].homeWindowController.window;
            [window toggleFullScreen:self];
            [window setStyleMask:[window styleMask] & ~NSResizableWindowMask]; // non-resizable
        }
        
        NSWindow *window = [AppDelegate sharedInstance].homeWindowController.window;
        [window setFrame:NSMakeRect(window.frame.origin.x, window.frame.origin.y, 310, window.frame.size.height)
                 display:YES
                 animate:YES];
    }
}

+ (int) callsCount {
    const MSList *call_list = linphone_core_get_calls([LinphoneManager getLc]);
    int call_count = ms_list_size(call_list);
    
    return call_count;
}

@end
