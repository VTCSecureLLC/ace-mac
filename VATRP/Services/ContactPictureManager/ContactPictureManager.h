//
//  ContactPictureManager.h
//  ACE
//
//  Created by Karen Muradyan on 2/3/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactPictureManager : NSObject

+ (ContactPictureManager *)sharedInstance;

- (void)saveImage:(NSImage*)image withName:(NSString*)name andSipURI:(NSString*)sipURI;
- (void)deleteImageWithName:(NSString*)name andSipURI:(NSString*)sipURI;
- (NSString*)imagePathByName:(NSString*)name andSipURI:(NSString*)sipURI;

@end
