//
//  SummaryMenuViewController.m
//  ACE
//
//  Created by Norayr Harutyunyan on 1/11/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import "SummaryMenuViewController.h"
#import "AppDelegate.h"
#import "SystemInfo.h"
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
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [NSString stringWithFormat:@"%@/tss.txt",[paths objectAtIndex:0]];
    [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    
    NSString *tssContents = [SystemInfo formatedSystemInformation];
    NSError *error = nil;
    [tssContents writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if(!error){
        [[NSWorkspace sharedWorkspace] selectFile:path
                         inFileViewerRootedAtPath:path];
    }
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
