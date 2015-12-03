//
//  main.m
//  VATRP
//
//  Created by Ruben Semerjyan on 8/27/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>

void Triger(int x)
{
    NSLog(@"SIGABRT");
}

int main(int argc, const char * argv[]) {
    signal(SIGABRT, Triger);

    return NSApplicationMain(argc, argv);
}