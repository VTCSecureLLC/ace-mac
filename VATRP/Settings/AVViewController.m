//
//  AVViewController.m
//  ACE
//
//  Created by Norayr Harutyunyan on 1/11/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import "AVViewController.h"

@interface AVViewController () {
    BOOL isChanged;
}

@property (weak) IBOutlet NSButton *buttonSpeakerMute;
@property (weak) IBOutlet NSButton *buttonMicMute;
@property (weak) IBOutlet NSButton *buttonEchoCancel;
@property (weak) IBOutlet NSButton *buttonShowSelfView;
@property (weak) IBOutlet NSButton *buttonShowPreview;

@end

@implementation AVViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.

    isChanged = NO;
}

- (void) viewWillAppear {
    [super viewWillAppear];

    self.buttonSpeakerMute.state = [[NSUserDefaults standardUserDefaults] boolForKey:@"SPEAKER_MUTE"];
    self.buttonMicMute.state = [[NSUserDefaults standardUserDefaults] boolForKey:@"MICROPHONE_MUTE"];
    self.buttonEchoCancel.state = [[NSUserDefaults standardUserDefaults] boolForKey:@"ECHO_CANCEL"];
    self.buttonShowSelfView.state = [[NSUserDefaults standardUserDefaults] boolForKey:@"VIDEO_SHOW_SELF_VIEW"];
    self.buttonShowPreview.state = [[NSUserDefaults standardUserDefaults] boolForKey:@"VIDEO_SHOW_PREVIEW"];
}

- (IBAction)onCheckBoxSpeakerMute:(id)sender {
    isChanged = YES;
}

- (IBAction)onCheckBoxMicMute:(id)sender {
    isChanged = YES;
}

- (IBAction)onCheckBoxEchoCancel:(id)sender {
    isChanged = YES;
}

- (IBAction)onCheckBoxShowSelfView:(id)sender {
    isChanged = YES;
}

- (IBAction)onCheckBoxShowPreview:(id)sender {
    isChanged = YES;
}

- (void) save {
    if (!isChanged) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:self.buttonSpeakerMute.state forKey:@"SPEAKER_MUTE"];
    [[NSUserDefaults standardUserDefaults] setBool:self.buttonMicMute.state forKey:@"MICROPHONE_MUTE"];
    [[NSUserDefaults standardUserDefaults] setBool:self.buttonEchoCancel.state forKey:@"ECHO_CANCEL"];
    [[NSUserDefaults standardUserDefaults] setBool:self.buttonShowSelfView.state forKey:@"VIDEO_SHOW_SELF_VIEW"];
    [[NSUserDefaults standardUserDefaults] setBool:self.buttonShowPreview.state forKey:@"VIDEO_SHOW_PREVIEW"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
