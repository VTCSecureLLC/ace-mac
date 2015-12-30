//
//  TermsOfUseViewController.m
//  ACE
//
//  Created by Norayr Harutyunyan on 12/30/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "TermsOfUseViewController.h"
#import "LoginViewController.h"
#import "BFNavigationController.h"
#import "NSViewController+BFNavigationController.h"

@interface TermsOfUseViewController () {
    LoginViewController *loginViewController;
}

@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSButton *buttonAccept;
@property (unsafe_unretained) IBOutlet NSTextView *textView;

@end

@implementation TermsOfUseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrolling:) name:NSScrollViewDidLiveScrollNotification object:nil];
}

- (void)scrolling:(NSNotification*)notif {
    if (notif.object == self.scrollView && !self.buttonAccept.enabled) {
        NSRect visibleRect = [[self.scrollView contentView] documentVisibleRect];
        NSRect contentRect = [[self.scrollView contentView] documentRect];
        
        if (visibleRect.origin.y + visibleRect.size.height > contentRect.size.height) {
            self.buttonAccept.enabled = YES;
        }
    }
}

- (IBAction)onButtonAccept:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IS_TERMS_OF_OSE_SHOWED"];
    loginViewController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"LoginViewController"];
    [self.navigationController pushViewController:loginViewController animated:YES];
}

- (IBAction)onButtonDecline:(id)sender {
    [[NSApplication sharedApplication] terminate:self];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
