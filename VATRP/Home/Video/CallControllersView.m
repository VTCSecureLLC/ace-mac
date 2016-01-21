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
#import "ViewManager.h"
#import "SettingsService.h"
#import "Utils.h"


@interface CallControllersView () {
    LinphoneCall* call;
    
    BOOL last_update_state;
    BOOL isSendingVideo;
    BOOL chat_window_open;
    
    
    CallInfoWindowController *callInfoWindowController;
}

@property (weak) IBOutlet NSTextField *labelCallState;

@property (weak) IBOutlet NSButton *buttonAnswer;
@property (weak) IBOutlet NSButton *buttonDecline;

@property (weak) IBOutlet NSButton *buttonHold;
@property (weak) IBOutlet NSButton *buttonVideo;
@property (weak) IBOutlet NSButton *buttonMute;
@property (weak) IBOutlet NSButton *buttonSpeaker;
@property (weak) IBOutlet NSButton *buttonKeypad;
@property (weak) IBOutlet NSButton *buttonChat;
@property (weak) IBOutlet NSProgressIndicator *videoProgressIndicator;
@property (weak) IBOutlet NSButton *rttStatusButton;
@end


@implementation CallControllersView

@synthesize delegate = _delegate;

- (void) awakeFromNib {
    [super awakeFromNib];

    [ViewManager sharedInstance].callControllersView_delegate = self;
    
    isSendingVideo = YES;
    self.buttonHold.wantsLayer = YES;
    self.buttonVideo.wantsLayer = YES;
    self.buttonMute.wantsLayer = YES;
    self.buttonSpeaker.wantsLayer = YES;
    self.buttonKeypad.wantsLayer = YES;
    self.buttonChat.wantsLayer = YES;
    self.buttonAnswer.wantsLayer = YES;
    self.buttonDecline.wantsLayer = YES;
    self.rttStatusButton.wantsLayer = YES;
    self.rttStatusButton.enabled = NO;

    [self.buttonHold.layer setBackgroundColor:[NSColor colorWithRed:92.0/255.0 green:117.0/255.0 blue:132.0/255.0 alpha:0.8].CGColor];
    [self.buttonVideo.layer setBackgroundColor:[NSColor colorWithRed:92.0/255.0 green:117.0/255.0 blue:132.0/255.0 alpha:0.8].CGColor];
    [self.buttonMute.layer setBackgroundColor:[NSColor colorWithRed:92.0/255.0 green:117.0/255.0 blue:132.0/255.0 alpha:0.8].CGColor];
    [self.buttonSpeaker.layer setBackgroundColor:[NSColor colorWithRed:92.0/255.0 green:117.0/255.0 blue:132.0/255.0 alpha:0.8].CGColor];
    [self.buttonKeypad.layer setBackgroundColor:[NSColor colorWithRed:92.0/255.0 green:117.0/255.0 blue:132.0/255.0 alpha:0.8].CGColor];
    [self.buttonChat.layer setBackgroundColor:[NSColor colorWithRed:92.0/255.0 green:117.0/255.0 blue:132.0/255.0 alpha:0.8].CGColor];
    [self.rttStatusButton.layer setBackgroundColor:[NSColor redColor].CGColor];
    
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

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)onButtonHold:(id)sender {
    if (call) {
        LinphoneCallState call_state = linphone_call_get_state(call);
     
        if (call_state == LinphoneCallPaused) {
            linphone_core_resume_call([LinphoneManager getLc], call);
        } else {
            linphone_core_pause_call([LinphoneManager getLc], call);
        }
        
        [self.buttonHold setEnabled:NO];
    }
}

- (IBAction)onButtonVideo:(id)sender {
    [self.videoProgressIndicator startAnimation:self];
    
    isSendingVideo = !isSendingVideo;
    
    if (isSendingVideo) {
        [self onVideoOn];
        [self.buttonVideo.layer setBackgroundColor:[NSColor colorWithRed:92.0/255.0 green:117.0/255.0 blue:132.0/255.0 alpha:0.8].CGColor];
    } else {
        [self onVideoOff];
        [self.buttonVideo.layer setBackgroundColor:[NSColor colorWithRed:182.0/255.0 green:60.0/255.0 blue:60.0/255.0 alpha:0.8].CGColor];
    }
    [self.videoProgressIndicator stopAnimation:self];
}

- (IBAction)onButtonMute:(id)sender {
    LinphoneCore *lc = [LinphoneManager getLc];
    linphone_core_enable_mic(lc, !linphone_core_mic_enabled(lc));
    if (!linphone_core_mic_enabled(lc)) {
        [self.buttonMute setImage:[NSImage imageNamed:@"mute_disabled"]];
        [self.buttonMute.layer setBackgroundColor:[NSColor colorWithRed:182.0/255.0 green:60.0/255.0 blue:60.0/255.0 alpha:0.8].CGColor];
    } else {
        [self.buttonMute setImage:[NSImage imageNamed:@"mute_active"]];
        [self.buttonMute.layer setBackgroundColor:[NSColor colorWithRed:92.0/255.0 green:117.0/255.0 blue:132.0/255.0 alpha:0.8].CGColor];


    }
}

- (IBAction)onButtonSpeaker:(id)sender {
    const float mute_db = -1000.0f;
    if (linphone_core_get_playback_gain_db([LinphoneManager getLc]) == mute_db) {
        linphone_core_set_playback_gain_db([LinphoneManager getLc], 0.0f);
        [self.buttonSpeaker setImage:[NSImage imageNamed:@"speaker_active"]];
        [self.buttonSpeaker.layer setBackgroundColor:[NSColor colorWithRed:92.0/255.0 green:117.0/255.0 blue:132.0/255.0 alpha:0.8].CGColor];
    } else {
        linphone_core_set_playback_gain_db([LinphoneManager getLc], mute_db);
        [self.buttonSpeaker setImage:[NSImage imageNamed:@"speaker_inactive"]];
        [self.buttonSpeaker.layer setBackgroundColor:[NSColor colorWithRed:182.0/255.0 green:60.0/255.0 blue:60.0/255.0 alpha:0.8].CGColor];
    }
}

- (IBAction)onButtonKeypad:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(didClickCallControllersViewNumpad:)]) {
        [_delegate didClickCallControllersViewNumpad:self];
    }
}
- (void)performChatButtonClick{
    if (self.window.frame.size.width == 1328) {
        [self.window setFrame:NSMakeRect(self.window.frame.origin.x, self.window.frame.origin.y, 1030, self.window.frame.size.height)
                      display:YES
                      animate:YES];
        chat_window_open=NO;
    } else {
        if (self.window.frame.origin.x + 1328 > [[NSScreen mainScreen] frame].size.width) {
            [self.window setFrame:NSMakeRect([[NSScreen mainScreen] frame].size.width  - 1328 - 5, self.window.frame.origin.y, 1328, self.window.frame.size.height)
                          display:YES
                          animate:YES];
        } else {
            [self.window setFrame:NSMakeRect(self.window.frame.origin.x, self.window.frame.origin.y, 1328, self.window.frame.size.height)
                          display:YES
                          animate:YES];
            chat_window_open=YES;
          }
    }

}
- (BOOL)bool_chat_window_open{
    return chat_window_open;
}

- (IBAction)onButtonChat:(id)sender {
    self.performChatButtonClick;
}


- (IBAction)onButtonAnswer:(id)sender {
    [[CallService sharedInstance] accept:call];
}

- (IBAction)onButtonDecline:(id)sender {
    LinphoneCall *activeCall = [[CallService sharedInstance] getCurrentCall];
    [[CallService sharedInstance] decline:activeCall];
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
    if (call) {
        LinphoneCallState call_state = linphone_call_get_state(call);
        [self callUpdate:call state:call_state];
    }
}

- (void)setIncomingCall:(LinphoneCall*)acall {
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
    if (!call || call != acall) {
        return;
    }
    [self.rttStatusButton.layer setBackgroundColor:[NSColor redColor].CGColor];
    [self.buttonAnswer setKeyEquivalent:@""];
    switch (astate) {
        case LinphoneCallIncomingReceived: {
            [self setControllersToDefaultState];
            
            self.labelCallState.hidden = NO;
            self.labelCallState.stringValue = @"Incoming Call...";
            [self.buttonAnswer setKeyEquivalent:@"\r"];
        }
        case LinphoneCallIncomingEarlyMedia: {
            break;
        }
        case LinphoneCallConnected: {
            self.buttonAnswer.hidden = YES;
            self.labelCallState.hidden = YES;
            self.labelCallState.stringValue = @"Connected";

            [self.buttonDecline setTitle:@"End Call"];
            [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonDecline];
            self.buttonDecline.frame = CGRectMake((self.frame.size.width - self.buttonDecline.frame.size.width) / 2,
                                                  self.buttonDecline.frame.origin.y,
                                                  self.buttonDecline.frame.size.width,
                                                  self.buttonDecline.frame.size.height);
            
            [self enableDisableButtons:YES];

            if ([SettingsService getMicMute]) {
                [self onButtonMute:self.buttonMute];
            }
        }
            break;
        case LinphoneCallOutgoingInit: {
            [self setControllersToDefaultState];

            self.labelCallState.hidden = NO;
            self.labelCallState.stringValue = @"Calling...";
        }
            break;
        case LinphoneCallOutgoingRinging: {
            self.labelCallState.stringValue = @"Ringing...";
        }
            break;
        case LinphoneCallPaused: {
            [self.buttonHold setImage:[NSImage imageNamed:@"call resume"]];
            [self.buttonHold setEnabled:YES];
            [self.buttonHold.layer setBackgroundColor:[NSColor colorWithRed:92.0/255.0 green:117.0/255.0 blue:132.0/255.0 alpha:0.8].CGColor];
        }
            break;
        case LinphoneCallPausedByRemote: {
            [self.buttonHold setImage:[NSImage imageNamed:@"call resume"]];
            [self.buttonHold setEnabled:NO];
            [self.buttonHold.layer setBackgroundColor:[NSColor colorWithRed:92.0/255.0 green:117.0/255.0 blue:132.0/255.0 alpha:0.8].CGColor];
        }
            break;
        case LinphoneCallStreamsRunning: {
            const LinphoneCallParams* current = linphone_call_get_current_params(call);
            if (linphone_call_params_realtime_text_enabled(current)) {
                [self.rttStatusButton.layer setBackgroundColor:[NSColor greenColor].CGColor];
            }
            [self.buttonHold setImage:[NSImage imageNamed:@"call hold"]];
            [self.buttonHold setEnabled:YES];
            [self.buttonHold.layer setBackgroundColor:[NSColor colorWithRed:92.0/255.0 green:117.0/255.0 blue:132.0/255.0 alpha:0.8].CGColor];
            [self update];

            break;
        }
        case LinphoneCallUpdatedByRemote: {
            break;
        }
        case LinphoneCallError: {
            break;
        }
        case LinphoneCallEnd: {
            self.labelCallState.stringValue = @"Call End";
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
        linphone_call_enable_camera(call, TRUE);
        
    } else {
        NSString* linphoneVersion = [NSString stringWithUTF8String:linphone_core_get_version()];
        NSLog(@"Cannot toggle video button, because no current call. LinphoneVersion: %@", linphoneVersion);
    }
}

- (void)onVideoOff {
    LinphoneCore *lc = [LinphoneManager getLc];
    
    if (!linphone_core_video_enabled(lc))
        return;
    
    if (call) {
        // ToDo VATRP-842: Setting a static image, but until the static image is working in linphone we are currently seeing a black image.
        //    The choice is this or a no webcam image. For testing, using no webcam image.
//        NSString *pathToImageString = [[NSBundle mainBundle] pathForResource:@"contacts" ofType:@"png"];
//        const char *pathToImage = [pathToImageString UTF8String];
//        linphone_core_set_static_picture(lc, pathToImage);
        linphone_call_enable_camera(call, FALSE);
    } else {
        NSString* linphoneVersion = [NSString stringWithUTF8String:linphone_core_get_version()];
        NSLog(@"Cannot toggle video button, because no current call. LinphoneVersion: %@", linphoneVersion);
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
    [self.buttonHold setEnabled:enable];
    [self.buttonVideo setEnabled:enable];
    [self.buttonMute setEnabled:enable];
    [self.buttonSpeaker setEnabled:enable];
    [self.buttonKeypad setEnabled:enable];
    [self.buttonChat setEnabled:enable];
}

- (void) setControllersToDefaultState {
    [self.buttonMute setImage:[NSImage imageNamed:@"mute_active"]];
    [self.buttonMute.layer setBackgroundColor:[NSColor colorWithRed:92.0/255.0 green:117.0/255.0 blue:132.0/255.0 alpha:0.8].CGColor];

    [self.buttonSpeaker setImage:[NSImage imageNamed:@"speaker_active"]];
    [self.buttonSpeaker.layer setBackgroundColor:[NSColor colorWithRed:92.0/255.0 green:117.0/255.0 blue:132.0/255.0 alpha:0.8].CGColor];
}

@end
