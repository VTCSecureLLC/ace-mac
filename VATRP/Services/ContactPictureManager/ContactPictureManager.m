//
//  ContactPictureManager.m
//  ACE
//
//  Created by Karen Muradyan on 2/3/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import "ContactPictureManager.h"
#import "NSImage+SaveInFile.h"
#import "Utils.h"

@implementation ContactPictureManager

+ (ContactPictureManager *)sharedInstance
{
    static ContactPictureManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ContactPictureManager alloc] init];
        [self createBundleFolderInAppSupportDirectory];
    });
    
    return sharedInstance;
}

- (void)saveImage:(NSImage*)image withName:(NSString*)name andSipURI:(NSString*)sipURI {
    NSString *pictureFileName = [[[name stringByAppendingString:@"_"] stringByAppendingString:sipURI] stringByAppendingString:@".png"];
    NSString *pictureFilePath = [self applicationDirectoryFile:pictureFileName];
    [image saveAsPNGWithName:pictureFilePath];
}

- (void)deleteImageWithName:(NSString*)name andSipURI:(NSString*)sipURI {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *filePath = [self imagePathByName:name andSipURI:sipURI];
    NSError* anError;
    if ([fm fileExistsAtPath:filePath]) {
        if ([fm removeItemAtPath:filePath error:&anError]) {
            NSLog(@"Unexpected Error occured = %@", anError);
        }
    }
}

- (NSString*)imagePathByName:(NSString*)name andSipURI:(NSString*)sipURI {
    NSString *pictureFileName = [[[name stringByAppendingString:@"_"] stringByAppendingString:[Utils makeSipURIWithAccountName:name andProviderAddress:sipURI]] stringByAppendingString:@".png"];
    NSString *pictureFilePath = [self applicationDirectoryFile:pictureFileName];
    return pictureFilePath;
}

#pragma mark - File and folder creation methods

+ (NSURL*)createBundleFolderInAppSupportDirectory {
    NSString* bundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSFileManager*fm = [NSFileManager defaultManager];
    NSURL*    dirPath = nil;
    
    // Find the application support directory in the home directory.
    NSArray* appSupportDir = [fm URLsForDirectory:NSApplicationSupportDirectory
                                        inDomains:NSUserDomainMask];
    if ([appSupportDir count] > 0) {
        // Append the bundle ID to the URL for the
        // Application Support directory
        dirPath = [[appSupportDir objectAtIndex:0] URLByAppendingPathComponent:bundleID];
        
        // If the directory does not exist, this method creates it.
        // This method is only available in OS X v10.7 and iOS 5.0 or later.
        NSError*    theError = nil;
        if (![fm createDirectoryAtURL:dirPath withIntermediateDirectories:YES
                           attributes:nil error:&theError]) {
            // Handle the error.
            return nil;
        }
    }
    
    return dirPath;
}

- (NSString*)applicationDirectoryFile:(NSString*)file {
    NSString* bundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *makePath = [[[[documentsPath stringByAppendingString:@"/"] stringByAppendingString:bundleID] stringByAppendingString:@"/"] stringByAppendingString:file];
    return makePath;
}

@end
