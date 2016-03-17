//
//  LoginViewController.h
//  VATRP
//
//  Created by Norayr Harutyunyan on 9/3/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LinphoneManager.h"
#import "BFViewController.h"
#import "AccountModel.h"

@interface LoginViewController : NSViewController <BFViewController>

- (void)registrationUpdate:(LinphoneRegistrationState)state message:(NSString*)message;

-(void)handleAutoLogin:(AccountModel*)accountModel;
@end
