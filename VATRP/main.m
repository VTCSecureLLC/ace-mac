//
//  main.m
//  VATRP
//
//  Created by Ruben Semerjyan on 8/27/15.
//  Developed pursuant to contract FCC15C0008 as open source software under GNU General Public License version 2.. All rights reserved.
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