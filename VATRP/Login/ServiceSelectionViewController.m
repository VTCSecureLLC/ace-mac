//
//  ServiceSelectionViewController.m
//  VATRP
//
//  Created by Norayr Harutyunyan on 9/3/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import "ServiceSelectionViewController.h"
#import "LoginViewController.h"
#import "BFNavigationController.h"
#import "NSViewController+BFNavigationController.h"

@interface ServiceSelectionViewController ()

@end

@implementation ServiceSelectionViewController

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

- (IBAction)onButtonVideoRelayService:(id)sender {
    LoginViewController *controller = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"LoginViewController"];

    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)onButtonIPRelay:(id)sender {
    LoginViewController *controller = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"LoginViewController"];

    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)onButtonIPCTS:(id)sender {
    LoginViewController *controller = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"LoginViewController"];

    [self.navigationController pushViewController:controller animated:YES];
}

- (void) dealloc {
    NSLog(@"dealloc");
}

@end
