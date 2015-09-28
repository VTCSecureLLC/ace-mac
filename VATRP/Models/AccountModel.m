//
//  AccountModel.m
//  ACE
//
//  Created by Edgar Sukiasyan on 9/28/15.
//  Copyright © 2015 Home. All rights reserved.
//

#import "AccountModel.h"
#import "Utils.h"

@implementation AccountModel

@synthesize username;
@synthesize password;
@synthesize domain;
@synthesize transport;
@synthesize port;
@synthesize isDefault;


- (id) init {
    self = [super init];
    
    if (self) {
        self.isDefault = NO;
    }
    
    return self;
}

- (void) loadByDictionary:(NSDictionary*)dict {
    self.username = [Utils stringValueDict:dict Key:@"username"];
    self.password = [Utils stringValueDict:dict Key:@"password"];
    self.domain = [Utils stringValueDict:dict Key:@"domain"];
    self.transport = [Utils stringValueDict:dict Key:@"transport"];
    self.port = [Utils intValueDict:dict Key:@"port"];
    self.isDefault = [Utils intValueDict:dict Key:@"isDefault"];
}

- (NSDictionary*) serializedDictionary {
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] init];
    
    [mDict setObject:self.username forKeyedSubscript:@"username"];
    [mDict setObject:self.password forKeyedSubscript:@"password"];
    [mDict setObject:self.domain forKeyedSubscript:@"domain"];
    [mDict setObject:self.transport forKeyedSubscript:@"transport"];
    [mDict setObject:[NSNumber numberWithInt:self.port] forKeyedSubscript:@"port"];
    [mDict setObject:[NSNumber numberWithBool:self.isDefault] forKeyedSubscript:@"isDefault"];
    
    return (NSDictionary*)mDict;
}

@end
