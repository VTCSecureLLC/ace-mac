//
//  NSImage+SaveInFile.m
//  ACE
//
//  Created by Karen Muradyan on 2/3/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import "NSImage+SaveInFile.h"

@implementation NSImage (SaveInFile)

- (void)saveAsPNGWithName:(NSString*) fileName
{
    // Delete the file if it exist previously
    NSError *error;
    if ([[NSFileManager defaultManager] isDeletableFileAtPath:fileName]) {
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:fileName error:&error];
        if (!success) {
            NSLog(@"Error removing file at path: %@", error.localizedDescription);
        }
    }
    NSData *imageData = [self TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    imageData = [imageRep representationUsingType:NSPNGFileType properties:imageProps];
    [imageData writeToFile:fileName atomically:NO];
}

@end
