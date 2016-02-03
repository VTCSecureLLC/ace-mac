//
//  NSImage+SaveInFile.h
//  ACE
//
//  Created by Karen Muradyan on 2/3/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (SaveInFile)

- (void) saveAsPNGWithName:(NSString*) fileName;

@end
