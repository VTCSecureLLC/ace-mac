//
//  SettingsService.h
//  ACE
//
//  Created by Norayr Harutyunyan on 12/11/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsService : NSObject

+ (SettingsService *)sharedInstance;

+ (void) setSIPEncryption:(BOOL)encrypt;
+ (void)setStartAppOnBoot:(BOOL)start;

@end
