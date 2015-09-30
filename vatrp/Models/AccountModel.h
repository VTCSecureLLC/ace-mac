//
//  AccountModel.h
//  ACE
//
//  Created by Edgar Sukiasyan on 9/28/15.
//  Copyright © 2015 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountModel : NSObject

- (void) loadByDictionary:(NSDictionary*)dict;
- (NSDictionary*) serializedDictionary;

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *domain;
@property (nonatomic, retain) NSString *transport;
@property (nonatomic, assign) int port;
@property (nonatomic, assign) BOOL isDefault;

@end
