//
//  TextMenuViewController
//  ACE
//
//  Created by Patrick Watson on 1/11/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import "TextMenuViewController.h"
#import "SettingsService.h"
#import "LinphoneManager.h"

@interface TextMenuViewController () {
    BOOL isChanged;
}

@property (weak) IBOutlet NSButton *enable_text;
@property (weak) IBOutlet NSComboBox *text_send_mode;

@end

@implementation TextMenuViewController

-(id) init
{
    self = [super initWithNibName:@"TextMenuViewController" bundle:nil];
    if (self)
    {
        // init
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do view setup here.
    self.enable_text.state = [SettingsService getRTTEnabled];
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"TEXT_SEND_MODE"]){
        [[NSUserDefaults standardUserDefaults] setObject:@"Real Time Text (RTT)" forKey:@"TEXT_SEND_MODE"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    self.text_send_mode.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"TEXT_SEND_MODE"];
    self.text_send_mode.enabled = NO;
    
    isChanged = NO;
}

- (IBAction)onCheckBoxEnableText:(id)sender {
    isChanged = YES;
    NSLog(@"CHECKED");
}

- (IBAction)onComboBoxTextSendMode:(id)sender {
    isChanged = YES;
     NSLog(@"SEND MODE");
}

- (void) save {
    if (!isChanged) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:self.enable_text.state forKey:kREAL_TIME_TEXT_ENABLED];
    //[[NSUserDefaults standardUserDefaults] setBool:self.enable_text.state forKey:@"ENABLE_TEXT"];
    [[NSUserDefaults standardUserDefaults] setObject:self.text_send_mode.stringValue forKey:@"TEXT_SEND_MODE"];
   
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* text_mode_string=[defaults stringForKey:@"TEXT_SEND_MODE"];
    NSLog(@"SEND MODE %@",text_mode_string);
    
}

@end
