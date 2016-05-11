//
//  LoginViewController.h
//  VATRP
//
//  Created by Norayr Harutyunyan on 9/3/15.
//  Developed pursuant to contract FCC15C0008 as open source software under GNU General Public License version 2.. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LinphoneManager.h"
#import "BFViewController.h"
#import "AccountModel.h"

@interface LoginViewController : NSViewController <BFViewController>

- (void)registrationUpdate:(LinphoneRegistrationState)state message:(NSString*)message;

-(void)handleAutoLogin:(AccountModel*)accountModel;
@end
