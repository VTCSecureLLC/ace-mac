//
//  LoginViewController.m
//  VATRP
//
//  Created by Norayr Harutyunyan on 9/3/15.
//  Copyright (c) 2015 Home. All rights reserved.
//

#import "LoginViewController.h"
#import "BFNavigationController.h"
#import "NSViewController+BFNavigationController.h"
#import "AppDelegate.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)loadView {
    [super loadView];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"%@ - viewWillAppear: %i", self.title, animated);
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"%@ - viewDidAppear: %i", self.title, animated);
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"%@ - viewWillDisappear: %i", self.title, animated);
}

- (void)viewDidDisappear:(BOOL)animated {
    NSLog(@"%@ - viewDidDisappear: %i", self.title, animated);
}

- (IBAction)onButtonLogin:(id)sender {
    [[AppDelegate sharedInstance] showTabWindow];
    [[AppDelegate sharedInstance].loginWindowController close];
}

@end
