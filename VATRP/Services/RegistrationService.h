//
//  RegistrationService.h
//  ACE
//
//  Created by Edgar Sukiasyan on 10/7/15.
//  Copyright © 2015 Home. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "AccountModel.h"

@interface RegistrationService : NSObject

+ (RegistrationService *)sharedInstance;
- (void) registerWithAccountModel:(AccountModel*)accountModel;
- (void) registerWithUsername:(NSString*)username password:(NSString*)password domain:(NSString*)domain transport:(NSString*)transport port:(int)port;
- (void) asyncRegisterWithAccountModel:(AccountModel*)accountModel;

@end
