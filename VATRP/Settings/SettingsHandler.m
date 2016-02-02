//
//  SettingsDelegate.m
//  ACE
//
//  Created by Lizann Epley on 2/1/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingsHandler.h"

@implementation SettingsHandler

#pragma mark singleton methods

+ (id)settingsHandler
{
    static SettingsHandler *sharedSettingsHandler = nil;
    @synchronized(self) {
        if (sharedSettingsHandler == nil)
            sharedSettingsHandler = [[self alloc] init];
    }
    return sharedSettingsHandler;
}


-(void)inCallSpeakerWasMuted:(bool)mute
{
    if ([self.delegate respondsToSelector:@selector(speakerWasMuted:)]) {
        [self.delegate speakerWasMuted:mute];
    }
}



-(void)setMuteSpeaker:(bool)mute
{
    if ([self.delegate respondsToSelector:@selector(muteSpeaker:)]) {
        [self.delegate muteSpeaker:mute];
    }
}
@end
