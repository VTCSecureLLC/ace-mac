//
//  GeneralViewController.m
//  ACE
//
//  Created by Norayr Harutyunyan on 2/2/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import "GeneralViewController.h"
#import "SettingsService.h"

@interface GeneralViewController () {
    BOOL isChanged;
}

@property (weak) IBOutlet NSButton *checkBoxStartOnBoot;
@property (weak) IBOutlet NSButton *checkBoxAutoAnswerCall;
@property (weak) IBOutlet NSTextField *textFieldVideoMailWaitingURI;

@end

@implementation GeneralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do view setup here.

    self.checkBoxAutoAnswerCall.state = [[NSUserDefaults standardUserDefaults] boolForKey:@"ACE_AUTO_ANSWER_CALL"];
    self.checkBoxStartOnBoot.state = [[NSUserDefaults standardUserDefaults] boolForKey:@"start_at_boot_preference"];
    
    if([[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"video_mail_uri"]){
        self.textFieldVideoMailWaitingURI.stringValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"video_mail_uri"];
    }

    isChanged = NO;
}

- (IBAction)onCheckBox:(id)sender {
    isChanged = YES;
}

- (void) save {
    if (!isChanged) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:self.checkBoxStartOnBoot.state forKey:@"start_at_boot_preference"];
    [[NSUserDefaults standardUserDefaults] setBool:self.checkBoxAutoAnswerCall.state forKey:@"ACE_AUTO_ANSWER_CALL"];
    [[NSUserDefaults standardUserDefaults] setObject:self.textFieldVideoMailWaitingURI.stringValue forKey:@"video_mail_uri"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [SettingsService setStartAppOnBoot:self.checkBoxStartOnBoot.state];
}

@end
