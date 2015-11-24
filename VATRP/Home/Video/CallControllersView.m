//
//  CallControllersView.m
//  ACE
//
//  Created by Norayr Harutyunyan on 11/12/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "CallControllersView.h"
#import "CallInfoWindowController.h"
#import "ChatService.h"
#import "Utils.h"


@interface CallControllersView () {
    LinphoneCall* call;
    
    BOOL last_update_state;
    BOOL isSendingVideo;

    CallInfoWindowController *callInfoWindowController;
}

@property (weak) IBOutlet NSButton *buttonAnswer;
@property (weak) IBOutlet NSButton *buttonDecline;

@property (weak) IBOutlet NSButton *buttonVideo;
@property (weak) IBOutlet NSButton *buttonMute;
@property (weak) IBOutlet NSButton *buttonSpeaker;
@property (weak) IBOutlet NSButton *buttonKeypad;
@property (weak) IBOutlet NSButton *buttonChat;
@property (weak) IBOutlet NSProgressIndicator *videoProgressIndicator;

@end


@implementation CallControllersView

@synthesize delegate = _delegate;

- (void) awakeFromNib {
    [super awakeFromNib];

    isSendingVideo = YES;
    self.buttonVideo.wantsLayer = YES;
    self.buttonMute.wantsLayer = YES;
    self.buttonSpeaker.wantsLayer = YES;
    self.buttonKeypad.wantsLayer = YES;
    self.buttonChat.wantsLayer = YES;
    self.buttonAnswer.wantsLayer = YES;
    self.buttonDecline.wantsLayer = YES;

    [self.buttonVideo.layer setBackgroundColor:[NSColor colorWithRed:92.0/255.0 green:117.0/255.0 blue:132.0/255.0 alpha:0.8].CGColor];
    [self.buttonMute.layer setBackgroundColor:[NSColor colorWithRed:92.0/255.0 green:117.0/255.0 blue:132.0/255.0 alpha:0.8].CGColor];
    [self.buttonSpeaker.layer setBackgroundColor:[NSColor colorWithRed:92.0/255.0 green:117.0/255.0 blue:132.0/255.0 alpha:0.8].CGColor];
    [self.buttonKeypad.layer setBackgroundColor:[NSColor colorWithRed:92.0/255.0 green:117.0/255.0 blue:132.0/255.0 alpha:0.8].CGColor];
    [self.buttonChat.layer setBackgroundColor:[NSColor colorWithRed:92.0/255.0 green:117.0/255.0 blue:132.0/255.0 alpha:0.8].CGColor];
    
    [self.buttonAnswer.layer setBackgroundColor:[NSColor greenColor].CGColor];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonAnswer];
    [self.buttonDecline.layer setBackgroundColor:[NSColor redColor].CGColor];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonDecline];
    
    self.wantsLayer = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callUpdateEvent:)
                                                 name:kLinphoneCallUpdate
                                               object:nil];    
}

- (IBAction)onButtonVideo:(id)sender {
    [self.videoProgressIndicator startAnimation:self];
    
    isSendingVideo = !isSendingVideo;
    
    if (isSendingVideo) {
        [self onVideoOn];
    } else {
        [self onVideoOff];
    }
}

- (IBAction)onButtonMute:(id)sender {
    LinphoneCore *lc = [LinphoneManager getLc];

    linphone_core_mute_mic(lc, !linphone_core_is_mic_muted(lc));
    
    if (linphone_core_is_mic_muted(lc)) {
        [self.buttonMute.layer setBackgroundColor:[NSColor colorWithRed:182.0/255.0 green:60.0/255.0 blue:60.0/255.0 alpha:0.8].CGColor];
    } else {
        [self.buttonMute.layer setBackgroundColor:[NSColor colorWithRed:92.0/255.0 green:117.0/255.0 blue:132.0/255.0 alpha:0.8].CGColor];
    }
}

- (IBAction)onButtonSpeaker:(id)sender {
    if (linphone_call_get_speaker_volume_gain(call)) {
        linphone_call_set_speaker_volume_gain(call, 0.0f);
    } else {
        linphone_call_set_speaker_volume_gain(call, 1.0f);
    }
}

- (IBAction)onButtonKeypad:(id)sender {
}

- (IBAction)onButtonChat:(id)sender {
}


- (IBAction)onButtonAnswer:(id)sender {
    [[CallService sharedInstance] accept];
}

- (IBAction)onButtonDecline:(id)sender {
    [[CallService sharedInstance] decline];
}

- (IBAction)onButtonCallInfo:(id)sender {
    callInfoWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"CallInfo"];
    [callInfoWindowController showWindow:self];
}

- (void)dismisCallInfoWindow {
    [callInfoWindowController close];
    callInfoWindowController = nil;
}

//- (IBAction)onButtonOpenMessage:(id)sender {
//    const LinphoneAddress* addr = linphone_call_get_remote_address([[CallService sharedInstance] getCurrentCall]);
//    NSString *userName = nil;
//    
//    if (addr != NULL) {
//        const char* lUserName = linphone_address_get_username(addr);
//        
//        if (lUserName)
//            userName = [NSString stringWithUTF8String:lUserName];
//    }
//    
//    [[ChatService sharedInstance] openChatWindowWithUser:userName];
//}

#pragma mark - Property Functions

- (void)setCall:(LinphoneCall*)acall {
    call = acall;
    
    [self callUpdate:call state:linphone_call_get_state(call)];

    self.buttonAnswer.hidden = NO;
    self.buttonDecline.frame = CGRectMake(self.frame.size.width - self.buttonDecline.frame.size.width,
                                          self.buttonDecline.frame.origin.y,
                                          self.buttonDecline.frame.size.width,
                                          self.buttonDecline.frame.size.height);
    [self.buttonDecline setTitle:@"Decline"];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonDecline];
    [self enableDisableButtons:NO];
}

- (void)setOutgoingCall:(LinphoneCall*)acall {
    call = acall;
    
    self.buttonAnswer.hidden = YES;
    self.buttonDecline.frame = CGRectMake((self.frame.size.width - self.buttonDecline.frame.size.width)/2,
                                          self.buttonDecline.frame.origin.y,
                                          self.buttonDecline.frame.size.width,
                                          self.buttonDecline.frame.size.height);
    [self.buttonDecline setTitle:@"Cancel"];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonDecline];
    [self enableDisableButtons:NO];
}

#pragma mark - Event Functions

- (void)callUpdateEvent:(NSNotification*)notif {
    LinphoneCall *acall = [[notif.userInfo objectForKey: @"call"] pointerValue];
    LinphoneCallState astate = [[notif.userInfo objectForKey: @"state"] intValue];
    [self callUpdate:acall state:astate];
}

#pragma mark -

- (void)callUpdate:(LinphoneCall *)acall state:(LinphoneCallState)astate {
    if(call == acall && (astate == LinphoneCallEnd || astate == LinphoneCallError)) {
        return;
    }
    
    LinphoneCore *lc = [LinphoneManager getLc];
    
    switch (astate) {
        case LinphoneCallIncomingReceived: {
        }
        case LinphoneCallIncomingEarlyMedia:
        {
            break;
        }
        case LinphoneCallConnected: {
            self.buttonAnswer.hidden = YES;
            
            [self.buttonDecline setTitle:@"End Call"];
            [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonDecline];
            self.buttonDecline.frame = CGRectMake((self.frame.size.width - self.buttonDecline.frame.size.width) / 2,
                                                  self.buttonDecline.frame.origin.y,
                                                  self.buttonDecline.frame.size.width,
                                                  self.buttonDecline.frame.size.height);
            
            [self enableDisableButtons:YES];
        }
            break;
        case LinphoneCallOutgoingInit: {
        }
            break;
        case LinphoneCallOutgoingRinging: {
        }
            break;
        case LinphoneCallPausedByRemote:
        case LinphoneCallStreamsRunning:
        {
            [self update];

            break;
        }
        case LinphoneCallUpdatedByRemote:
        {
            break;
        }
        case LinphoneCallError:
        {
            break;
        }
        case LinphoneCallEnd:
        {
            break;
        }
        default:
            break;
    }
}

- (void)onVideoOn {
    LinphoneCore *lc = [LinphoneManager getLc];
    
    if (!linphone_core_video_enabled(lc))
        return;
    
    if (call) {
        LinphoneCallAppData *callAppData = (__bridge LinphoneCallAppData *)linphone_call_get_user_pointer(call);
        callAppData->videoRequested =
        TRUE; /* will be used later to notify user if video was not activated because of the linphone core*/
        LinphoneCallParams *call_params = linphone_call_params_copy(linphone_call_get_current_params(call));
        linphone_call_params_enable_video(call_params, TRUE);
        linphone_core_update_call(lc, call, call_params);
        linphone_call_params_destroy(call_params);
    } else {
        NSLog(@"Cannot toggle video button, because no current call");
    }
}

- (void)onVideoOff {
    LinphoneCore *lc = [LinphoneManager getLc];
    
    if (!linphone_core_video_enabled(lc))
        return;
    
    if (call) {
        LinphoneCallParams *call_params = linphone_call_params_copy(linphone_call_get_current_params(call));
        linphone_call_params_enable_video(call_params, FALSE);
        linphone_core_update_call(lc, call, call_params);
        linphone_call_params_destroy(call_params);
    } else {
        NSLog(@"Cannot toggle video button, because no current call");
    }
}

- (bool)update {
    bool video_enabled = false;
    LinphoneCore *lc = [LinphoneManager getLc];
    LinphoneCall *currentCall = linphone_core_get_current_call(lc);
    if (linphone_core_video_supported(lc)) {
        if (linphone_core_video_enabled(lc) && currentCall && !linphone_call_media_in_progress(currentCall) &&
            linphone_call_get_state(currentCall) == LinphoneCallStreamsRunning) {
            video_enabled = TRUE;
        }
    }
    
    [self.videoProgressIndicator stopAnimation:self];
    
    if (video_enabled) {
        video_enabled = linphone_call_params_video_enabled(linphone_call_get_current_params(currentCall));
    }
    
    last_update_state = video_enabled;
    
    if (isSendingVideo) {
        [self.buttonVideo setImage:[NSImage imageNamed:@"video_active"]];
        [self.buttonVideo.layer setBackgroundColor:[NSColor colorWithRed:92.0/255.0 green:117.0/255.0 blue:132.0/255.0 alpha:0.8].CGColor];
    } else {
        [self.buttonVideo setImage:[NSImage imageNamed:@"video_inactive"]];
        [self.buttonVideo.layer setBackgroundColor:[NSColor colorWithRed:92.0/255.0 green:117.0/255.0 blue:132.0/255.0 alpha:0.8].CGColor];
    }

    

    return video_enabled;
}

- (void) enableDisableButtons:(BOOL)enable {
    [self.buttonVideo setEnabled:enable];
    [self.buttonMute setEnabled:enable];
    [self.buttonSpeaker setEnabled:enable];
    [self.buttonKeypad setEnabled:enable];
    [self.buttonChat setEnabled:enable];
}

@end
