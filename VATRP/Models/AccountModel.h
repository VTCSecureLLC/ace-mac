//
//  AccountModel.h
//  ACE
//
//  Created by Ruben Semerjyan on 9/28/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountModel : NSObject

- (void) loadByDictionary:(NSDictionary*)dict;
- (NSDictionary*) serializedDictionary;

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *domain;
@property (nonatomic, retain) NSString *transport;
@property (nonatomic, assign) int port;
@property (nonatomic, assign) BOOL isDefault;


// items that will need to be added to the account model:
// enableVideo
// muteSpeaker
// muteMicrophone
// enableEchoCancellation

@end
