//
//  ContactFavoriteManager.h
//  ACE
//
//  Created by Karen Muradyan on 3/7/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactFavoriteManager : NSObject


@property (strong, nonatomic) NSString* databasePath;

+ (ContactFavoriteManager *)sharedInstance;

- (void)createFavoriteTablesInFriendListByPath;
- (void)updateContactFavoriteOptionByName:(NSString*)name contactAddress:(NSString*)sipURI andFavoriteOptoin:(int)isFavorite;
- (BOOL)isContactFavoriteWithName:(NSString*)name andAddress:(NSString*)sipURI;
- (void)deleteContactFavoriteOptionWithName:(NSString*)name andAddress:(NSString*)sipURI;

@end
