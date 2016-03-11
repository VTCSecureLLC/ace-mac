//
//  AVViewController.m
//  ACE
//
//  Created by Norayr Harutyunyan on 1/11/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import "AVViewController.h"
#import "SettingsHandler.h"
#import "LinphoneManager.h"

@interface AVViewController () {
    BOOL isChanged;
}
@property (strong,nonatomic)SettingsHandler* settingsHandler;

@property (weak) IBOutlet NSButton *buttonSpeakerMute;
@property (weak) IBOutlet NSButton *buttonMicMute;
@property (weak) IBOutlet NSButton *buttonEchoCancel;
@property (weak) IBOutlet NSButton *buttonShowSelfView;
@property (weak) IBOutlet NSButton *buttonShowPreview;

@end

@implementation AVViewController

-(id) init
{
    self = [super initWithNibName:@"AVViewController" bundle:nil];
    if (self)
    {
        // init
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.

    isChanged = NO;
}

- (void) viewWillAppear {
    [super viewWillAppear];

    self.settingsHandler = [SettingsHandler settingsHandler];
    self.settingsHandler.inCallSettingsDelegate = self;
    
    self.buttonSpeakerMute.state = [self.settingsHandler isSpeakerMuted];
    self.buttonMicMute.state = [self.settingsHandler isMicrophoneMuted];
    self.buttonEchoCancel.state = [self.settingsHandler isEchoCancellationEnabled];
    self.buttonShowSelfView.state = [self.settingsHandler isShowSelfViewEnabled];
    self.buttonShowPreview.state = [self.settingsHandler isShowPreviewEnabled];
    
}

- (IBAction)onCheckBoxSpeakerMute:(id)sender {
    isChanged = YES;
    bool muteSpeaker = [self.buttonSpeakerMute state];
    //SettingsHandler *settingsHandler = [SettingsHandler settingsHandler];
    [self.settingsHandler setMuteSpeaker:muteSpeaker];
}

- (IBAction)onCheckBoxMicMute:(id)sender {
    isChanged = YES;
    bool muteMicrophone = [self.buttonMicMute state];
    [self.settingsHandler setMuteMicrophone:muteMicrophone];
}

- (IBAction)onCheckBoxEchoCancel:(id)sender {
    isChanged = YES;
    bool enableEchoCancellation = [self.buttonEchoCancel state];
    [self.settingsHandler setEnableEchoCancellation:enableEchoCancellation];
}

- (IBAction)onCheckBoxShowSelfView:(id)sender {
    isChanged = YES;
    bool showSelfView = [self.buttonShowSelfView state];
    [self.settingsHandler setShowSelfView:showSelfView];
}

- (IBAction)onCheckBoxShowPreview:(id)sender {
    isChanged = YES;
}

- (void) save {
    if (!isChanged) {
        return;
    }
    // VATRP-2204: making it so that the interaction between the app and the settings occurs through the SettingsHandler.
    // also - so that the ui and the settings can be enforced while the settings dialog is open, where applicable, removing the need for a save button.
    // most items will be set when the button is toggled.
    [[NSUserDefaults standardUserDefaults] setBool:self.buttonShowPreview.state forKey:@"VIDEO_SHOW_PREVIEW"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark settings handler selectors
-(void)speakerWasMuted:(bool)mute
{
    if ([self isViewLoaded])
    {
        self.buttonSpeakerMute.state = mute;
    }
}
-(void)microphoneWasMuted:(bool)mute
{
    if ([self isViewLoaded])
    {
        self.buttonMicMute.state = mute;
    }
}

@end
