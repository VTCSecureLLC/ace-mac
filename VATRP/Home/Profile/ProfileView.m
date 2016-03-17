//
//  ProfileView.m
//  ACE
//
//  Created by Norayr Harutyunyan on 11/11/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import "ProfileView.h"
#import "LinphoneManager.h"
#import "AppDelegate.h"
#import "Utils.h"


@interface ProfileView () {
    
}

@property (weak) IBOutlet NSImageView *imageViewProfile;
@property (weak) IBOutlet NSTextField *labelProfileName;
@property (weak) IBOutlet NSImageView *imageViewRegStatus;

@end


@implementation ProfileView

-(id) init
{
    self = [super initWithNibName:@"ProfileView" bundle:nil];
    if (self)
    {
        // init
    }
    return self;
    
}

- (void) awakeFromNib {
    [super awakeFromNib];
    
    [self setBackgroundColor:[NSColor colorWithRed:44.0/255.0 green:55.0/255.0 blue:61.0/255.0 alpha:1.0]];
    [Utils setUIBorderColor:[NSColor whiteColor] CornerRadius:self.imageViewProfile.frame.size.width/2.0 Width:2 Control:self.imageViewProfile];
    [self.imageViewProfile setImage:[NSImage imageNamed:@"whiteMale"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(registrationUpdateEvent:)
                                                 name:kLinphoneRegistrationUpdate
                                               object:nil];
    
    [self updateUI];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kLinphoneRegistrationUpdate
                                                  object:nil];
}
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)registrationUpdateEvent:(NSNotification*)notif {
    NSString* message = [notif.userInfo objectForKey:@"message"];
    [self registrationUpdate:[[notif.userInfo objectForKey: @"state"] intValue] message:message];

    [self updateUI];
}

- (void)registrationUpdate:(LinphoneRegistrationState)state message:(NSString*)message{
    switch (state) {
        case LinphoneRegistrationOk: {
            [Utils setUIBorderColor:[NSColor greenColor]
                       CornerRadius:self.imageViewRegStatus.frame.size.width/2.0
                              Width:self.imageViewRegStatus.frame.size.width/2.0
                            Control:self.imageViewRegStatus];
            
            [[NSNotificationCenter defaultCenter] removeObserver:[AppDelegate sharedInstance].loginViewController
                                                            name:kLinphoneConfiguringStateUpdate
                                                          object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:[AppDelegate sharedInstance].loginViewController
                                                            name:kLinphoneRegistrationUpdate
                                                          object:nil];
            
            break;
        }
        case LinphoneRegistrationNone:
        case LinphoneRegistrationCleared:  {
            [Utils setUIBorderColor:[NSColor whiteColor]
                       CornerRadius:self.imageViewRegStatus.frame.size.width/2.0
                              Width:self.imageViewRegStatus.frame.size.width/2.0
                            Control:self.imageViewRegStatus];
            break;
        }
        case LinphoneRegistrationFailed: {
            [Utils setUIBorderColor:[NSColor redColor]
                       CornerRadius:self.imageViewRegStatus.frame.size.width/2.0
                              Width:self.imageViewRegStatus.frame.size.width/2.0
                            Control:self.imageViewRegStatus];

            break;
        }
        case LinphoneRegistrationProgress: {
            [Utils setUIBorderColor:[NSColor yellowColor]
                       CornerRadius:self.imageViewRegStatus.frame.size.width/2.0
                              Width:self.imageViewRegStatus.frame.size.width/2.0
                            Control:self.imageViewRegStatus];

            break;
        }
        default:
            break;
    }
}

- (void) updateUI {
    LinphoneCore *lc = [LinphoneManager getLc];
    LinphoneProxyConfig *cfg=NULL;
    linphone_core_get_default_proxy(lc,&cfg);
    
    if (cfg) {
        const char *identity=linphone_proxy_config_get_identity(cfg);
        LinphoneAddress *addr=linphone_address_new(identity);
        const char* user = linphone_address_get_username(addr);
        NSString *username = [NSString stringWithUTF8String:user];
        
        self.labelProfileName.stringValue = username;
        
        LinphoneRegistrationState state = linphone_proxy_config_get_state(cfg);
        [self registrationUpdate:state message:nil];
    }
}

@end
