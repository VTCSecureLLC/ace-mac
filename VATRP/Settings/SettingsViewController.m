//
//  SettingsViewController.m
//  ACE
//
//  Created by Ruben Semerjyan on 9/30/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize delegate = _delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)onButtonSave:(id)sender {    
    if ([_delegate respondsToSelector:@selector(didClickSettingsViewControllerSeve:)]) {
        [_delegate didClickSettingsViewControllerSeve:self];
    }
}

@end
