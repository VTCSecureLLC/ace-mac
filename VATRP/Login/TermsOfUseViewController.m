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
    LoginWindowController* parent;
}

@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSButton *buttonAccept;
@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property (weak) IBOutlet NSButton *acceptTermsCk;

@end

@implementation TermsOfUseViewController

-(id) init
{
    self = [super initWithNibName:@"TermsOfUseViewController" bundle:nil];
    if (self)
    {
        // init
    }
    return self;
    
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    // Do view setup here.
    // read the text from thr rtf as a formatted string and add the text to the text field
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"legal_release" ofType:@"rtf"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:filePath])
    {
        NSString *contents = [[[NSAttributedString alloc] initWithRTF:[NSData dataWithContentsOfFile:filePath] documentAttributes:NULL] string];
        if (contents != nil)
        {
            [self.textView setString:contents];
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrolling:) name:NSScrollViewDidLiveScrollNotification object:nil];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    // read the text from thr rtf as a formatted string and add the text to the text field
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"legal_release" ofType:@"rtf"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:filePath])
    {
        NSString *contents = [[[NSAttributedString alloc] initWithRTF:[NSData dataWithContentsOfFile:filePath] documentAttributes:NULL] string];
        if (contents != nil)
        {
            [self.textView setString:contents];
        }
    }
    
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
    loginViewController = [[LoginViewController alloc]init];
    [self.view.superview replaceSubview:self.view with:loginViewController.view ];
}

- (IBAction)onButtonDecline:(id)sender {
    [[NSApplication sharedApplication] terminate:self];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (IBAction)onAcceptTermsCheck:(NSButton *)sender
{
    if ([self.acceptTermsCk state] == NSOnState)
    {
        self.buttonAccept.enabled = true;
    }
    else
    {
        self.buttonAccept.enabled = false;
    }
}

@end
