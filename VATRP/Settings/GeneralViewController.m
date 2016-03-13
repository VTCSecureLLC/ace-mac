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
    self.checkBoxAutoAnswerCall.state = [[NSUserDefaults standardUserDefaults] boolForKey:@"ACE_AUTO_ANSWER_CALL"];
    self.checkBoxStartOnBoot.state = [[NSUserDefaults standardUserDefaults] boolForKey:@"start_at_boot_preference"];
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
    [[NSUserDefaults standardUserDefaults] synchronize];

    [SettingsService setStartAppOnBoot:self.checkBoxStartOnBoot.state];
}

@end
