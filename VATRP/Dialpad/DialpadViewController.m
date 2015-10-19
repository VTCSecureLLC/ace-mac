//
//  DialpadViewController.m
//  MacApp
//
//  Created by Norayr Harutyunyan on 8/27/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import "DialpadViewController.h"
#import "VideoCallWindowController.h"
#import "VideoCallViewController.h"
#import "AppDelegate.h"
#import "LinphoneManager.h"
#import "CallService.h"

@interface DialpadViewController () <NSAlertDelegate>

@property (weak) IBOutlet NSTextField *textFieldNumber;
@property (weak) IBOutlet NSButton *buttonVideoCall;

- (IBAction)onButtonNumber:(id)sender;
- (IBAction)onButtonVideo:(id)sender;


@end

@implementation DialpadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.

    self.buttonVideoCall.wantsLayer = YES;
    [self.buttonVideoCall.layer setBackgroundColor:[NSColor greenColor].CGColor];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(callUpdateEvent:)
//                                                 name:kLinphoneCallUpdate
//                                               object:nil];
    
    
}

- (IBAction)onButtonNumber:(id)sender {
    NSButton *button = (NSButton*)sender;
    
    switch (button.tag) {
        case 10: {
            self.textFieldNumber.stringValue = [self.textFieldNumber.stringValue stringByAppendingString:@"*"];
            linphone_core_play_dtmf([LinphoneManager getLc], '*', 100);
        }
            break;
        case 11: {
            self.textFieldNumber.stringValue = [self.textFieldNumber.stringValue stringByAppendingString:@"#"];
            linphone_core_play_dtmf([LinphoneManager getLc], '#', 100);
        }
            break;
        default: {
            NSString *number = [NSString stringWithFormat:@"%ld", (long)button.tag];
            const char *charArray = [number UTF8String];
            char charNumber = charArray[0];
            linphone_core_play_dtmf([LinphoneManager getLc], charNumber, 100);
            self.textFieldNumber.stringValue = [self.textFieldNumber.stringValue stringByAppendingString:number];
        }
            break;
    }
}

- (IBAction)onButtonVideo:(id)sender {
    LinphoneCore *lc = [LinphoneManager getLc];
    LinphoneCallParams *params = linphone_core_create_default_call_parameters(lc);
    LinphoneAddress* linphoneAddress = linphone_core_interpret_url(lc, [self.textFieldNumber.stringValue cStringUsingEncoding:[NSString defaultCStringEncoding]]);
    linphone_call_params_enable_realtime_text(params, true);
    linphone_core_invite_address_with_params(lc, linphoneAddress, params);
    
//    [self call:self.textFieldNumber.stringValue displayName:@"ACE"];
}

- (void)call:(NSString*)address displayName:(NSString *)displayName {
    [[LinphoneManager instance] call:address displayName:displayName transfer:NO];
}

#pragma mark - Event Functions

- (void)callUpdateEvent:(NSNotification*)notif {
    LinphoneCall *call = [[notif.userInfo objectForKey: @"call"] pointerValue];
    LinphoneCallState state = [[notif.userInfo objectForKey: @"state"] intValue];
    [self callUpdate:call state:state];
}


#pragma mark -

- (void)callUpdate:(LinphoneCall*)call state:(LinphoneCallState)state {
    LinphoneCore* lc = [LinphoneManager getLc];
    
    switch(state) {
        case LinphoneCallEnd:
        case LinphoneCallError:
        case LinphoneCallOutgoing:
            break;
        case LinphoneCallConnected: {
            CallWindowController *videoCallWindowController = [[CallService sharedInstance] getCallWindowController];
            CallViewController *videoCallViewController = (CallViewController*)videoCallWindowController.contentViewController;
            linphone_core_set_native_video_window_id([LinphoneManager getLc], (__bridge void *)(videoCallViewController.remoteVideoView));
        }
            break;
        case LinphoneCallUpdatedByRemote:
        {
            const LinphoneCallParams* current = linphone_call_get_current_params(call);
            const LinphoneCallParams* remote = linphone_call_get_remote_params(call);
            
            /* remote wants to add video */
            if (linphone_core_video_enabled(lc) && !linphone_call_params_video_enabled(current) &&
                linphone_call_params_video_enabled(remote) &&
                !linphone_core_get_video_policy(lc)->automatically_accept) {
                linphone_core_defer_call_update(lc, call);
//                [self displayAskToEnableVideoCall:call];
                LinphoneCallParams* paramsCopy = linphone_call_params_copy(linphone_call_get_current_params(call));
                linphone_call_params_enable_video(paramsCopy, TRUE);
                linphone_core_accept_call_update([LinphoneManager getLc], call, paramsCopy);
                linphone_call_params_destroy(paramsCopy);
                
            } else if (linphone_call_params_video_enabled(current) && !linphone_call_params_video_enabled(remote)) {
//                [self displayTableCall:animated];
            }
            break;
        }
        case LinphoneCallIncoming: {
            NSInteger auto_answer = [[NSUserDefaults standardUserDefaults] boolForKey:@"ACE_AUTO_ANSWER_CALL"];

            if (auto_answer) {
                LinphoneCall* call = linphone_core_get_current_call(lc);
                [[LinphoneManager instance] acceptCall:call];
            }
        }
            
        default:
            break;
    }
}

#pragma mark - ActionSheet Functions

- (void)displayAskToEnableVideoCall:(LinphoneCall*) call {
    if (linphone_core_get_video_policy([LinphoneManager getLc])->automatically_accept)
        return;
    
    const char* lUserNameChars = linphone_address_get_username(linphone_call_get_remote_address(call));
    NSString* lUserName = lUserNameChars?[[NSString alloc] initWithUTF8String:lUserNameChars]:NSLocalizedString(@"Unknown",nil);
    const char* lDisplayNameChars =  linphone_address_get_display_name(linphone_call_get_remote_address(call));
    NSString* lDisplayName = lDisplayNameChars?[[NSString alloc] initWithUTF8String:lDisplayNameChars]:@"";
    
    NSString* message = [NSString stringWithFormat : NSLocalizedString(@"'%@' would like to enable video",nil), ([lDisplayName length] > 0)?lDisplayName:lUserName];
    
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Accept"];
    [alert addButtonWithTitle:@"Decline"];
    [alert setMessageText:message];
    NSInteger returnValue = [alert runModal];
    
    switch (returnValue) {
        case NSAlertFirstButtonReturn: {
            LinphoneCallParams* paramsCopy = linphone_call_params_copy(linphone_call_get_current_params(call));
            linphone_call_params_enable_video(paramsCopy, TRUE);
            linphone_core_accept_call_update([LinphoneManager getLc], call, paramsCopy);
            linphone_call_params_destroy(paramsCopy);
        }
            break;
        case NSAlertSecondButtonReturn: {
            LinphoneCallParams* paramsCopy = linphone_call_params_copy(linphone_call_get_current_params(call));
            linphone_core_accept_call_update([LinphoneManager getLc], call, paramsCopy);
            linphone_call_params_destroy(paramsCopy);
        }
            break;
            
        default:
            break;
    }
}

- (IBAction)onLongPressZeroButton:(id)sender {
    NSPressGestureRecognizer *pressGestureRecognizer = (NSPressGestureRecognizer*)sender;
    NSGestureRecognizerState state = pressGestureRecognizer.state;
    
    if (state == NSGestureRecognizerStateBegan) {
        self.textFieldNumber.stringValue = [self.textFieldNumber.stringValue stringByAppendingString:@"+"];
    }
}

@end
