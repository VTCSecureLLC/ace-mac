//
//  AboutViewController.m
//  ACE
//
//  Created by Edgar Sukiasyan on 10/26/15.
//  Copyright © 2015 Home. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@property (weak) IBOutlet NSTextField *labelVersion;
@property (unsafe_unretained) IBOutlet NSTextView *textViewCopyright;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void) viewWillAppear {
    [super viewWillAppear];

    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* version = [infoDict objectForKey:@"CFBundleShortVersionString"];
    self.labelVersion.stringValue = [NSString stringWithFormat:@"Version %@", version];

    NSString* Copyright = [infoDict objectForKey:@"NSHumanReadableCopyright"];
//    [self.textViewCopyright setBackgroundColor:[NSColor clearColor]];
    self.textViewCopyright.string = Copyright;
}

@end
