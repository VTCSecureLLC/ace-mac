//
//  AccountsService.m
//  ACE
//
//  Created by Ruben Semerjyan on 9/28/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "AccountsService.h"
#import "AccountModel.h"

#define USER_DEFAULTS_ACCOUNT_LIST @"USER_DEFAULTS_ACCOUNT_LIST"


@interface AccountsService () {
    NSMutableDictionary *accountsMap;
}

- (void) applyAccountsDefault:(BOOL)def;

@end


@implementation AccountsService

+ (AccountsService *)sharedInstance
{
    static AccountsService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AccountsService alloc] init];
    });
    
    return sharedInstance;
}

- (id) init {
    self = [super init];
    
    if (self) {
        accountsMap = [[NSMutableDictionary alloc] init];
        
        [self load];
    }
    
    return self;
}

- (void) load {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_ACCOUNT_LIST];
    NSString* linphoneVersion = [NSString stringWithUTF8String:linphone_core_get_version()];

    NSLog(@"Linphone Version: %@, NSUserDefaults dump: %@", linphoneVersion, [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    for (NSString *key in dict) {
        NSDictionary *accountDict = [dict objectForKey:key];
        AccountModel *accountModel = [[AccountModel alloc] init];
        [accountModel loadByDictionary:accountDict];
        
        [accountsMap setObject:accountModel forKeyedSubscript:accountModel.username];
    }
}

- (void) addAccountWithUsername:(NSString*)username
                         UserID:(NSString*)userID
                       Password:(NSString*)password
                         Domain:(NSString*)domain
                      Transport:(NSString*)transport
                           Port:(int)port
                      isDefault:(BOOL)isDefault
{
    AccountModel *accountModel = [[AccountModel alloc] init];
    accountModel.username = username;
    accountModel.userID = userID;
    accountModel.password = password;
    accountModel.domain = domain;
    accountModel.transport = transport;
    accountModel.port = port;
    accountModel.isDefault = isDefault;
    
    if (isDefault) {
        [self applyAccountsDefault:NO];
    }

    [accountsMap setObject:accountModel forKeyedSubscript:accountModel.username];

    [self save];
}

- (void) removeAccountWithUsername:(NSString*)username {
    [accountsMap removeObjectForKey:username];
}

- (void) save {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    
    for (NSString *key in accountsMap) {
        AccountModel *accountModel = [accountsMap objectForKey:key];
        
        NSDictionary *accountDict = [accountModel serializedDictionary];
        [tempDict setObject:accountDict forKeyedSubscript:accountModel.username];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:tempDict forKey:USER_DEFAULTS_ACCOUNT_LIST];
}

- (AccountModel*) getDefaultAccount {
    for (NSString *key in accountsMap) {
        AccountModel *accountModel = [accountsMap objectForKey:key];
        
        if (accountModel.isDefault) {
            return accountModel;
        }
    }
    
    return nil;
}

- (void) applyAccountsDefault:(BOOL)def {
    for (NSString *key in accountsMap) {
        AccountModel *accountModel = [accountsMap objectForKey:key];
        accountModel.isDefault = NO;
    }
    
    [self save];
}

@end
