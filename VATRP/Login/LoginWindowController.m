//
//  LoginWindowController.m
//  VATRP
//
//  Created by Norayr Harutyunyan on 9/3/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import "LoginWindowController.h"
#import "BFNavigationController.h"
#import "LoginViewController.h"
#import "TermsOfUseViewController.h"
#import "AppDelegate.h"
#import "AccountsService.h"
#import "RegistrationService.h"
#import "SettingsHandler.h"

@interface LoginWindowController () {
    BFNavigationController *navigationController;
    LoginViewController *loginViewController;
    TermsOfUseViewController *termsOfUseViewController;
    BOOL shouldAutoLogin;
}

@end

@implementation LoginWindowController

-(id) init
{
    self = [super initWithWindowNibName:@"LoginWindow"];
    if (self)
    {
        // init
        self.contentViewController = navigationController;
    }
    return self;
    
}


- (void)windowDidLoad {
    [super windowDidLoad];
    [AppDelegate sharedInstance].loginWindowController = self;
    AccountModel *accountModel = [[AccountsService sharedInstance] getDefaultAccount];
    shouldAutoLogin = false;//[[NSUserDefaults standardUserDefaults] boolForKey:@"auto_login"];
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"auto_login"]){
        shouldAutoLogin = NO;
    }
    if (shouldAutoLogin && accountModel &&
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
        
        if ([[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"IS_TERMS_OF_OSE_SHOWED"]) {
            loginViewController = [[LoginViewController alloc]init];
            
            // Init navigation controller and add to window
            navigationController = [[BFNavigationController alloc] initWithFrame:NSMakeRect(0, 0, self.window.frame.size.width, self.window.frame.size.height)
                                                              rootViewController:loginViewController];
        } else {
            termsOfUseViewController = [[TermsOfUseViewController alloc]init];
//            termsOfUseViewController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"TermsOfUseViewController"];
            
            // Init navigation controller and add to window
            navigationController = [[BFNavigationController alloc] initWithFrame:NSMakeRect(0, 0, self.window.frame.size.width, self.window.frame.size.height)
                                                              rootViewController:termsOfUseViewController];
            //[SettingsHandler.settingsHandler initializeUserDefaults:true];
        }
        
        [self.window.contentView addSubview:navigationController.view];
    }
}

@end
