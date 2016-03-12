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
        
    }
    return self;
    
}


- (void)windowDidLoad {
    [super windowDidLoad];
    [AppDelegate sharedInstance].loginWindowController = self;
    
    if ([[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"IS_TERMS_OF_OSE_SHOWED"])
    {
       loginViewController = [[LoginViewController alloc]init];
       [self.window.contentView addSubview:loginViewController.view];
    }
    else
    {
       termsOfUseViewController = [[TermsOfUseViewController alloc]init];
       [self.window.contentView addSubview:termsOfUseViewController.view];
    }
    [self.window setTitle:@"ACE Login"];

}

@end
