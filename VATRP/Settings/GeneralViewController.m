//
//  GeneralViewController.m
//  ACE
//
//  Created by Norayr Harutyunyan on 2/2/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import "GeneralViewController.h"
#import "SettingsService.h"
#import "SettingsHandler.h"

@interface GeneralViewController () <InCallSettingsDelegate> {
    SettingsHandler* settingsHandler;
    
    BOOL isChanged;
}

@property (weak) IBOutlet NSButton *checkBoxStartOnBoot;
@property (weak) IBOutlet NSButton *checkBoxAutoAnswerCall;
@property (weak) IBOutlet NSButton *buttonSpeakerMute;
@property (weak) IBOutlet NSButton *buttonMicMute;
@property (weak) IBOutlet NSButton *buttonEchoCancel;
@property (weak) IBOutlet NSButton *buttonShowSelfView;
@property (weak) IBOutlet NSButton *buttonForce508;

@end

@implementation GeneralViewController

-(id) init
{
    self = [super initWithNibName:@"GeneralViewController" bundle:nil];
    if (self)
    {
        // init
    }
    return self;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Do view setup here.
    [self initializeData];
}

-(void) initializeData
{
    settingsHandler = [SettingsHandler settingsHandler];
    settingsHandler.inCallSettingsDelegate = self;

    self.checkBoxAutoAnswerCall.state = [[NSUserDefaults standardUserDefaults] boolForKey:@"ACE_AUTO_ANSWER_CALL"];
    self.checkBoxStartOnBoot.state = [[NSUserDefaults standardUserDefaults] boolForKey:@"start_at_boot_preference"];
    self.buttonSpeakerMute.state = [settingsHandler isSpeakerMuted];
    self.buttonMicMute.state = [settingsHandler isMicrophoneMuted];
    self.buttonEchoCancel.state = [settingsHandler isEchoCancellationEnabled];
    self.buttonShowSelfView.state = [settingsHandler isShowSelfViewEnabled];
    self.buttonForce508.state = [[NSUserDefaults standardUserDefaults] boolForKey:@"APP_FORCE_508"];

    isChanged = NO;
}

- (IBAction)onCheckBox:(id)sender {
    isChanged = YES;
}

- (IBAction)onCheckBoxSpeakerMute:(id)sender {
    isChanged = YES;
    bool muteSpeaker = [self.buttonSpeakerMute state];
    [settingsHandler setMuteSpeaker:muteSpeaker];
}

- (IBAction)onCheckBoxMicMute:(id)sender {
    isChanged = YES;
    bool muteMicrophone = [self.buttonMicMute state];
    [settingsHandler setMuteMicrophone:muteMicrophone];
}

- (IBAction)onCheckBoxEchoCancel:(id)sender {
    isChanged = YES;
    bool enableEchoCancellation = [self.buttonEchoCancel state];
    [settingsHandler setEnableEchoCancellation:enableEchoCancellation];
}

- (IBAction)onCheckBoxShowSelfView:(id)sender {
    isChanged = YES;
    bool showSelfView = [self.buttonShowSelfView state];
    [settingsHandler setShowSelfView:showSelfView];
}

- (IBAction)onCheckBoxHighContrast:(id)sender {
    isChanged = YES;
}

- (void) save {
    if (!isChanged) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:self.checkBoxStartOnBoot.state forKey:@"start_at_boot_preference"];
    [[NSUserDefaults standardUserDefaults] setBool:self.checkBoxAutoAnswerCall.state forKey:@"ACE_AUTO_ANSWER_CALL"];
    [[NSUserDefaults standardUserDefaults] setBool:self.buttonForce508.state forKey:@"APP_FORCE_508"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [SettingsService setStartAppOnBoot:self.checkBoxStartOnBoot.state];
}

#pragma mark settings handler selectors
- (void)speakerWasMuted:(bool)mute {
    if ([self isViewLoaded]) {
        self.buttonSpeakerMute.state = mute;
    }
}

- (void)microphoneWasMuted:(bool)mute {
    if ([self isViewLoaded]) {
        self.buttonMicMute.state = mute;
    }
}

@end
