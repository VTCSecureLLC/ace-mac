//
//  LoginWindowController.m
//  VATRP
//
//  Created by Norayr Harutyunyan on 9/3/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import "LoginWindowController.h"
#import "BFNavigationController.h"
#import "ServiceSelectionViewController.h"
#import "AppDelegate.h"
#import "AccountsService.h"
#import "RegistrationService.h"


@interface LoginWindowController () {
    BFNavigationController *navigationController;
    ServiceSelectionViewController *serviceSelectionViewController;
}

@end

@implementation LoginWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    [AppDelegate sharedInstance].loginWindowController = self;
    AccountModel *accountModel = [[AccountsService sharedInstance] getDefaultAccount];

    if (accountModel &&
        accountModel.username && accountModel.username.length &&
        accountModel.userID && accountModel.userID.length &&
        accountModel.password && accountModel.password.length &&
        accountModel.domain && accountModel.domain.length &&
        accountModel.transport && accountModel.transport.length &&
        accountModel.port) {
        
        [[RegistrationService sharedInstance] asyncRegisterWithAccountModel:accountModel];

        [[AppDelegate sharedInstance] performSelector:@selector(showTabWindow) withObject:nil afterDelay:0.001];
    } else {
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
        serviceSelectionViewController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"ServiceSelectionViewController"];
        
        // Init navigation controller and add to window
        navigationController = [[BFNavigationController alloc] initWithFrame:NSMakeRect(0, 0, self.window.frame.size.width, self.window.frame.size.height)
                                                          rootViewController:serviceSelectionViewController];
        
        [self.window.contentView addSubview:navigationController.view];
    }
}

@end
