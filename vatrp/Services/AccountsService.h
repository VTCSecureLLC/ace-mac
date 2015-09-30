//
//  AccountsService.h
//  ACE
//
//  Created by Edgar Sukiasyan on 9/28/15.
//  Copyright © 2015 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccountModel.h"

@interface AccountsService : NSObject

+ (AccountsService *)sharedInstance;
- (void) addAccountWithUsername:(NSString*)username Password:(NSString*)password Domain:(NSString*)domain Transport:(NSString*)transport Port:(int)port isDefault:(BOOL)isDefault;
- (void) removeAccountWithUsername:(NSString*)username;
- (AccountModel*) getDefaultAccount;

@end
