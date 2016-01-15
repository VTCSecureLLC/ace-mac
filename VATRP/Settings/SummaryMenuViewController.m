//
//  SummaryMenuViewController.m
//  ACE
//
//  Created by Norayr Harutyunyan on 1/11/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import "SummaryMenuViewController.h"
#import "AppDelegate.h"

@interface SummaryMenuViewController () {
    BOOL isChanged;
}

@end

@implementation SummaryMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    isChanged = NO;
}

- (IBAction)onButtonViewTSS:(id)sender {
}

- (IBAction)onButtonSendTSS:(id)sender {
}

- (IBAction)onButtonShowAdvanced:(id)sender {
    [[AppDelegate sharedInstance].settingsWindowController addPreferencesToolbarItem];
}

- (void) save {
    if (!isChanged) {
        return;
    }
    
}

@end
