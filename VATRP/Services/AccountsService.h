//
//  AccountsService.h
//  ACE
//
//  Created by Ruben Semerjyan on 9/28/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccountModel.h"

#define USER_DEFAULTS_ACCOUNT_LIST @"ACE User Account"

@interface AccountsService : NSObject

+ (AccountsService *)sharedInstance;
- (void) addAccountWithUsername:(NSString*)username
                         UserID:(NSString*)userID
                       Password:(NSString*)password
                         Domain:(NSString*)domain
                      Transport:(NSString*)transport
                           Port:(int)port
                      isDefault:(BOOL)isDefault;
- (void) removeAccountWithUsername:(NSString*)username;
- (AccountModel*) getDefaultAccount;

@end
