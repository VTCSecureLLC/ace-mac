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
#import "LinphoneAPI.h"

@interface CallService () {
    CallWindowController *callWindowController;
    
    LinphoneCall *currentCall;
    LinphoneCall *callToSwapTo;
    
    bool screenSaverIsRunning;
    bool screenIsLocked;
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
        NSDistributedNotificationCenter * center
        = [NSDistributedNotificationCenter defaultCenter];
        
        [center addObserver: self
                   selector:    @selector(handleScreenSaverStarted:)
                       name:        @"com.apple.screensaver.didstart"
                     object:      nil
         ];
        [center addObserver: self
                   selector:    @selector(handleScreenSaverStopped:)
                       name:        @"com.apple.screensaver.didstop"
                     object:      nil
         ];
        [center addObserver: self
                   selector:    @selector(handleScreenIsLocked:)
                       name:        @"com.apple.screenIsLocked"
                     object:      nil
         ];
        [center addObserver: self
                   selector:    @selector(handleScreenIsUnlocked:)
                       name:        @"com.apple.screenIsUnlocked"
                     object:      nil
         ];
    }
    
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)closeCallWindowController
{
    if (callWindowController != nil)
    {
        [callWindowController close];
    }
}
- (CallWindowController*) getCallWindowController {
    return callWindowController;
}


+ (void) callTo:(NSString*)number {
    LinphoneCore *lc = [LinphoneManager getLc];

    if (![number stringByReplacingOccurrencesOfString:@" " withString:@""].length) {
        NSAlert *alert = [[NSAlert alloc]init];
        [alert addButtonWithTitle:NSLocalizedString(@"OK",nil)];
        [alert setMessageText:NSLocalizedString(@"Please enter a valid number", nil)];
        [alert runModal];
        
        return;
    }
    
    // sanity check - make sure that we are not making a call to an address that we already have a call out to.
    const MSList *call_list = linphone_core_get_calls(lc);
    int count = 0;
    if (call_list)
    {
        count = ms_list_size(call_list);
    }

    if (count > 0)
    {
        LinphoneCall* call = (LinphoneCall*)call_list->data;
        const LinphoneAddress* addr = linphone_call_get_remote_address(call);
        if (addr != NULL)
        {
            BOOL useLinphoneAddress = true;
            // contact name
            if(useLinphoneAddress)
            {
                const char* lUserName = linphone_address_get_username(addr);
                if(lUserName && [number isEqualToString:[NSString stringWithUTF8String:lUserName]])
                {
                    return; // do not make a second call to this user
                }
            }
        }
    }

// ToDo? VATRP-2451: If the above is not sufficient to prevent the second call on a double click, then we can prevent a second call
// by doing this and not worrying about comparing the address above.
    if (count == 0)
    {
        @try {
            LinphoneAddress *address = linphone_core_create_address(lc, [number UTF8String]);
            if (address) {
                const char *addr_username = linphone_address_get_username(address);
                NSString *username = [NSString stringWithUTF8String:addr_username];
                
                if (username && username.length && [username hasPrefix:@"00"]) {
                    username = [username substringFromIndex:2];
                    username = [@"+" stringByAppendingString:username];
                }
                
                NSString *expression = @"^\\+(?:[0-9] ?){6,14}[0-9]$";
                NSError *error = NULL;
                
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
                
                NSTextCheckingResult *match = [regex firstMatchInString:username options:0 range:NSMakeRange(0, [username length])];
                
                if (match) {
                    const char *domain = linphone_address_get_domain(address);
                    number = [NSString stringWithFormat:@"sip:%@@%s;user=phone", username, domain];
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"CALL Exception: %@", exception);
        }
        
        [[[AppDelegate sharedInstance].homeWindowController getHomeViewController].videoView showVideoPreview];
        //linphone_core_enable_self_view(lc, [SettingsHandler.settingsHandler isShowSelfViewEnabled]);
        [[CallService sharedInstance] performSelector:@selector(callUsingLinphoneManager:) withObject:number afterDelay:1.0];
    }
}

- (void) callUsingLinphoneManager:(NSString*)number {
    [[LinphoneManager instance] call:number displayName:number transfer:NO];
}
    
- (int) decline:(LinphoneCall *)aCall {
    return linphone_core_terminate_call([LinphoneManager getLc], aCall);
}

- (void) accept:(LinphoneCall *)aCall {
    //linphone_core_enable_self_view([LinphoneManager getLc], [SettingsHandler.settingsHandler isShowSelfViewEnabled]);
    [[LinphoneManager instance] acceptCall:aCall];
}

- (void) pause:(LinphoneCall*)aCall {
    linphone_core_pause_call([LinphoneManager getLc], aCall);
}

- (void) resume:(LinphoneCall*)aCall {
    linphone_core_resume_call([LinphoneManager getLc], aCall);
}

- (void) swapCallsToCall:(LinphoneCall*)aCall {
    linphone_core_pause_call([LinphoneManager getLc], currentCall);
    callToSwapTo = aCall;
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
        case LinphoneCallIdle:					/**<Initial call state */
            NSLog(@"****** LinphoneCallIdle");
            break;
        case LinphoneCallOutgoingProgress: /**<An outgoing call is in progress */
            NSLog(@"****** LinphoneCallOutgoingProgress");
            break;
        case LinphoneCallOutgoingRinging: /**<An outgoing call is ringing at remote end */
            NSLog(@"****** LinphoneCallOutgoingRinging");
            break;
        case LinphoneCallOutgoingEarlyMedia: /**<An outgoing call is proposed early media */
            NSLog(@"****** LinphoneCallOutgoingEarlyMedia");
            break;
        case LinphoneCallPausing: /**<The call is pausing at the initiative of local end */
            NSLog(@"****** LinphoneCallPausing");
            break;
        case LinphoneCallPaused: /**< The call is paused, remote end has accepted the pause */
            NSLog(@"****** LinphoneCallPaused");
            if (callToSwapTo != nil)
            {
                linphone_core_resume_call([LinphoneManager getLc], callToSwapTo);
                // below should be handled by the call resume - when the streams are runnign again
                [[[AppDelegate sharedInstance].homeWindowController getHomeViewController].videoView setCall:callToSwapTo];
            }
            break;
        case LinphoneCallResuming: /**<The call is being resumed by local end*/
            NSLog(@"****** LinphoneCallResuming");
            break;
        case LinphoneCallRefered: /**<The call is being transfered to another party, resulting in a new outgoing call to follow immediately*/
            NSLog(@"****** LinphoneCallRefered");
            break;
        case LinphoneCallUpdating: /**<A call update has been initiated by us */
            NSLog(@"****** LinphoneCallUpdating");
            break;
        case LinphoneCallEarlyUpdatedByRemote: /*<The call is updated by remote while not yet answered (early dialog SIP UPDATE received).*/
            NSLog(@"****** LinphoneCallEarlyUpdatedByRemote");
            break;
        case LinphoneCallEarlyUpdating: /*<We are updating the call while not yet answered (early dialog SIP UPDATE sent)*/
            NSLog(@"****** LinphoneCallEarlyUpdating");
            break;

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
            // tell the rtt window to add observers
            [[[AppDelegate sharedInstance].homeWindowController getHomeViewController].rttView addInCallObservers];
            
            // The streams are set up. Make sure that the initial call settings are handled on call set up here.
            
            // - there is an issue here. As of 2-9-2016 if we can enable mic when there is more than one call there is a crash -
            //    linphone is making the settings on each call without checking to see if the audio stream in null. So for now we need
            //    a notion of whether or not this is the first call on the line
            if ([CallService callsCount] < 2)
            {
                SettingsHandler* settingsHandler = [SettingsHandler settingsHandler];
                bool microphoneMuted = [settingsHandler isMicrophoneMuted];
                linphone_core_enable_mic(lc, !microphoneMuted);
                bool speakerMuted = [settingsHandler isSpeakerMuted];
                [LinphoneManager.instance muteSpeakerInCall:speakerMuted];
//                bool micIsEnabled = linphone_core_mic_enabled(lc);
                linphone_core_set_play_level(lc, 100);
            }
            else
            {
                if (callToSwapTo != nil)
                {
                    [[[AppDelegate sharedInstance].homeWindowController getHomeViewController].videoView setCallToSecondCallView:currentCall];
                    currentCall = callToSwapTo;
                    [[[AppDelegate sharedInstance].homeWindowController getHomeViewController].rttView updateForNewCall];
                    callToSwapTo = nil; // clear after swapping
                }
                else if (currentCall != aCall)
                {
                    // handle change for call waiting
                    // update my pointer
                    currentCall = aCall;
                }
            }
            int playLevel = linphone_core_get_play_level(lc);
            int playbackGain = linphone_core_get_playback_gain_db(lc);
            NSLog([NSString stringWithFormat:@"   play level IS %d, playback gain is %d ********************************", playLevel, playbackGain ]);
            const char *speakerString = linphone_core_get_playback_device([LinphoneManager getLc]);
//            const char *microphoneString = linphone_core_get_playback_device([LinphoneManager getLc]);
//            NSString *speaker = [[NSString alloc] initWithUTF8String:speakerString];
//            NSLog([NSString stringWithFormat:@"SPEAKER IS %@", speaker ]);
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
            else if (call_count == 0)
            {
                [[[AppDelegate sharedInstance].homeWindowController getHomeViewController].rttView removeObservers];
            }
            
            if (currentCall && aCall != currentCall) {
                [[[AppDelegate sharedInstance].homeWindowController getHomeViewController].videoView hideSecondIncomingCallView];
            } else {
                [[ChatService sharedInstance] closeChatWindow];
                [self performSelector:@selector(closeCallWindow) withObject:nil afterDelay:1.0];
            }
            
            [[ChatService sharedInstance] closeChatWindow];
        }
            break;
        case LinphoneCallReleased: {
            NSLog(@"****** LinphoneCallReleased");
            if (currentCall && aCall != currentCall) {
                [[[AppDelegate sharedInstance].homeWindowController getHomeViewController].videoView hideSecondIncomingCallView];
            }
            
            [[ChatService sharedInstance] closeChatWindow];
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
            else
            {
                if ([[SettingsHandler settingsHandler] isShowPreviewEnabled])
                {
                    [[LinphoneAPI instance] linphoneShowSelfPreview:true];
                }

            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - screen saver/lock handlers
-(void) handleScreenSaverStarted:(NSNotification*)notif
{
    screenSaverIsRunning = true;
    NSLog(@"CallService.handleScreenSaverStarted");
}
-(void)handleScreenSaverStopped:(NSNotification*)notif
{
    screenSaverIsRunning = false;
    NSLog(@"CallService.handleScreenSaverStopped");
}
-(void) handleScreenIsLocked:(NSNotification*)notif
{
    screenIsLocked = true;
    NSLog(@"CallService.handleScreenLocked");
}
-(void) handleScreenIsUnlocked:(NSNotification*)notif
{
    screenIsLocked = false;
    NSLog(@"CallService.handleScreenUnLocked");
}

-(void) wakeDisplay
{
    @try
    {
        // execute caffeinate  -u -t 1
        int pid = [[NSProcessInfo processInfo] processIdentifier];
        NSPipe *pipe = [NSPipe pipe];
        NSFileHandle *file = pipe.fileHandleForReading;
    
        NSTask *task = [[NSTask alloc] init];
        task.launchPath = @"/usr/bin/caffeinate";
        task.arguments = @[@"-u", @"-t 1"];
        task.standardOutput = pipe;
    
        [task launch];
    
        NSData *data = [file readDataToEndOfFile];
        [file closeFile];
    
        NSString *cmdOutput = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
        NSLog (@"caffeinate returned:\n%@", cmdOutput);
    }
    @catch (NSException* ex)
    {
        NSLog(@"CallService.wakeDisplay: there is an incoming call but we are unable to wake the screen.");
    }
}
-(void) dismissScreenSaver
{
    @try
    {
        // simulate keystroke - command key
        CGEventSourceRef src =
        CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
        
        CGEventRef cmdd = CGEventCreateKeyboardEvent(src, 0x38, true);
        CGEventRef cmdu = CGEventCreateKeyboardEvent(src, 0x38, false);
        
        
        CGEventTapLocation loc = kCGHIDEventTap; // kCGSessionEventTap also works
        CGEventPost(loc, cmdd);
        CGEventPost(loc, cmdu);
        
        CFRelease(cmdd);
        CFRelease(cmdu);
        CFRelease(src);
        NSLog (@"exitScreenSaver script completed");
        return;
        // execute osacript exitScreenSaver.scpt
        // works on 10.10 in case we need it different than the others. but i think the above will begin
//        int pid = [[NSProcessInfo processInfo] processIdentifier];
//        NSPipe *pipe = [NSPipe pipe];
//        NSFileHandle *file = pipe.fileHandleForReading;

//        NSTask *task = [[NSTask alloc] init];
//        task.launchPath = @"/usr/bin/osacript";
//        task.arguments = @[@"-e", @"'tell application \"System Events\" to key up 56'"];
        
//        task.standardOutput = pipe;
    
//        [task launch];
    
//        NSData *data = [file readDataToEndOfFile];
//        [file closeFile];
    
//        NSString *cmdOutput = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
//        NSLog (@"exitScreenSaver script completed\n%@", cmdOutput);

    }
    @catch (NSException* ex)
    {
        NSLog(@"CallService.dismissScreenSaver: there is an incoming call but we are unable to turn the screen saver off.");
    }
}

- (void)displayIncomingCall:(LinphoneCall*)call {
    // handle screen if it is asleep
    [self wakeDisplay];
    // handle screen saver if it is on
    if (screenSaverIsRunning)
    {
        [self dismissScreenSaver];
    }
    // how to handle a locked screen?
    
    // handles if we are in the background or if we are minimized
    [NSApp activateIgnoringOtherApps:YES];
    [[AppDelegate sharedInstance].homeWindowController.window makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:false];

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
        [[ViewManager sharedInstance].rttView updateViewForDisplay];
        [self openCallWindow];

        [[[AppDelegate sharedInstance].homeWindowController getHomeViewController].videoView setIncomingCall:call];
    }
}

#pragma mark - screen display
- (void)displayOutgoingCall:(LinphoneCall*)call {
    currentCall = call;

    [[ViewManager sharedInstance].rttView updateViewForDisplay];
    
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
        NSWindow *window = [AppDelegate sharedInstance].homeWindowController.window;
        
        if ([[AppDelegate sharedInstance].homeWindowController getHomeViewController].isAppFullScreen) {
            [window toggleFullScreen:self];
            [window setStyleMask:[window styleMask] & ~NSResizableWindowMask]; // non-resizable
        }
        
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
