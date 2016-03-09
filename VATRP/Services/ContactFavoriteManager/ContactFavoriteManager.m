//
//  ContactFavoriteManager.m
//  ACE
//
//  Created by Karen Muradyan on 3/7/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import "ContactFavoriteManager.h"
#import "Utils.h"
#import <sqlite3.h>

@interface ContactFavoriteManager () {
}

@end

@implementation ContactFavoriteManager

+ (ContactFavoriteManager *)sharedInstance {
    
    static ContactFavoriteManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ContactFavoriteManager alloc] init];
    });
    
    return sharedInstance;
}

- (void)createFavoriteTablesInFriendListByPath {
    
    sqlite3* newDb;
    if (sqlite3_open([self.databasePath UTF8String], &newDb) == SQLITE_OK) {
        const char *sqlStatement = "CREATE TABLE IF NOT EXISTS friend_options (id INTEGER NOT NULL, is_favorite INTEGER NOT NULL DEFAULT 0, PRIMARY KEY (id))";
        char *error;
        sqlite3_exec(newDb, sqlStatement, NULL, NULL, &error);
        sqlite3_close(newDb);
    }
}

- (void)updateContactFavoriteOptionByName:(NSString*)name contactAddress:(NSString*)sipURI andFavoriteOptoin:(int)isFavorite {
    
    int contactID = [self findContactIDWithName:name andSipAddress:sipURI];
    if (contactID >= 0) {
        [self updateContactFavoriteOptionByID:contactID andOption:isFavorite];
    }
}

- (int)findContactIDWithName:(NSString*)name andSipAddress:(NSString*)sipAddress {
    
    sqlite3_stmt    *statement;
    sqlite3* contactDB;
    const char *dbpath = [self.databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK) {
        
        NSString *address = [NSString stringWithFormat:@"\"%@\" <%@>", name, sipAddress];
        NSString *querySQL = [NSString stringWithFormat: @"SELECT id FROM friends WHERE sip_uri='%@'", address];
        const char *insert_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL) == SQLITE_OK) {
            
            if (sqlite3_step(statement) == SQLITE_ROW) {
                int contactID = sqlite3_column_int(statement, 0);
                sqlite3_finalize(statement);
                sqlite3_close(contactDB);
                return contactID;
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(contactDB);
    }
    return -1;
}

- (void)updateContactFavoriteOptionByID:(int)contactID andOption:(int)isFavorite {
    
        NSString *querySQL = [NSString stringWithFormat: @"INSERT OR REPLACE INTO friend_options (id, is_favorite) VALUES ( %d, %d)", contactID, isFavorite];
        const char *insert_stmt = [querySQL UTF8String];
        
        sqlite3* newDb;
        if (sqlite3_open([self.databasePath UTF8String], &newDb) == SQLITE_OK) {
            char *error;
            sqlite3_exec(newDb, insert_stmt, NULL, NULL, &error);
            sqlite3_close(newDb);
        }
}

- (void)deleteContactFavoriteOptionWithName:(NSString*)name andAddress:(NSString*)sipURI {
    int deletedContactID = [self findContactIDWithName:name andSipAddress:sipURI];
    [self deleteContactWithID:deletedContactID];
}

- (void)deleteContactWithID:(int)contactID {
    
    NSString *querySQL = [NSString stringWithFormat: @"DELETE FROM friend_options WHERE id ='%d'", contactID];
    const char *insert_stmt = [querySQL UTF8String];
    
    sqlite3* newDb;
    if (sqlite3_open([self.databasePath UTF8String], &newDb) == SQLITE_OK) {
        char *error;
        sqlite3_exec(newDb, insert_stmt, NULL, NULL, &error);
        sqlite3_close(newDb);
    }
}

- (int)favoriteOptionWithID:(int)contactID {
    
    sqlite3_stmt    *statement;
    sqlite3* contactDB;
    const char *dbpath = [self.databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK) {
    
        NSString *querySQL = [NSString stringWithFormat: @"SELECT is_favorite FROM friend_options WHERE id='%d'", contactID];
        const char *insert_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL) == SQLITE_OK) {
            
            if (sqlite3_step(statement) == SQLITE_ROW) {
                int isFavorite = sqlite3_column_int(statement, 0);
                sqlite3_finalize(statement);
                sqlite3_close(contactDB);
                return isFavorite;
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(contactDB);
    }
    
    return -2;
}

- (BOOL)isContactFavoriteWithName:(NSString*)name andAddress:(NSString*)sipURI {
    
    int isFavorite = 0;
    int contactID = [self findContactIDWithName:name andSipAddress:sipURI];
    if (contactID >= 0) {
        isFavorite = [self favoriteOptionWithID:contactID];
    }
    
    return isFavorite;
}

@end
