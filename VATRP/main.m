//
//  main.m
//  VATRP
//
//  Created by Edgar Sukiasyan on 8/27/15.
//  Copyright (c) 2015 Home. All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main(int argc, const char * argv[]) {
    @try {
        return NSApplicationMain(argc, argv);
    }
    @catch (NSException *exception) {
        NSLog(@"@catch exception: %@", exception);
    }
    @finally {
        NSLog(@"@@finally exception");
    }
}
