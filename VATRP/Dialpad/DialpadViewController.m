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
#import "SettingsService.h"

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
    
    LinphoneCall *thiscall;
    thiscall = linphone_core_get_current_call(lc);
    LinphoneCallParams *params = linphone_core_create_call_params(lc, thiscall);
    LinphoneAddress* linphoneAddress = linphone_core_interpret_url(lc, [self.textFieldNumber.stringValue cStringUsingEncoding:[NSString defaultCStringEncoding]]);
    linphone_call_params_enable_realtime_text(params, [SettingsService getRTTEnabled]);
    linphone_core_invite_address_with_params(lc, linphoneAddress, params);
    
//    [self call:self.textFieldNumber.stringValue displayName:@"ACE"];
}

- (void)call:(NSString*)address displayName:(NSString *)displayName {
    [CallService callTo:address];
}

- (IBAction)onLongPressZeroButton:(id)sender {
    NSPressGestureRecognizer *pressGestureRecognizer = (NSPressGestureRecognizer*)sender;
    NSGestureRecognizerState state = pressGestureRecognizer.state;
    
    if (state == NSGestureRecognizerStateBegan) {
        self.textFieldNumber.stringValue = [self.textFieldNumber.stringValue stringByAppendingString:@"+"];
    }
}

@end
