//
//  DialpadViewController.m
//  MacApp
//
//  Created by Norayr Harutyunyan on 8/27/15.
//  Copyright (c) 2015 Cinehost. All rights reserved.
//

#import "DialpadViewController.h"

@interface DialpadViewController ()

@property (weak) IBOutlet NSTextField *textFieldNumber;

- (IBAction)onButtonNumber:(id)sender;
- (IBAction)onButtonVideo:(id)sender;


@end

@implementation DialpadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)onButtonNumber:(id)sender {
    NSButton *button = (NSButton*)sender;
    
    switch (button.tag) {
        case 10: {
            self.textFieldNumber.stringValue = [self.textFieldNumber.stringValue stringByAppendingString:@"*"];
        }
            break;
        case 11: {
            self.textFieldNumber.stringValue = [self.textFieldNumber.stringValue stringByAppendingString:@"#"];
        }
            break;
        default: {
            self.textFieldNumber.stringValue = [self.textFieldNumber.stringValue stringByAppendingString:[NSString stringWithFormat:@"%ld", (long)button.tag]];
        }
            break;
    }
}

- (IBAction)onButtonVideo:(id)sender {
}

@end
