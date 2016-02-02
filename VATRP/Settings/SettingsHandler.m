//
//  SettingsDelegate.m
//  ACE
//
//  Created by Lizann Epley on 2/1/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingsHandler.h"
#import "SettingsConstants.h"

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

#pragma mark items for inCallSettingsDelegate - setting from call window to settings dialog
-(void)inCallSpeakerWasMuted:(bool)mute
{
    [self setUserSettingBool:MUTE_SPEAKER withValue:mute];
    if ([self.inCallSettingsDelegate respondsToSelector:@selector(speakerWasMuted:)]) {
        [self.inCallSettingsDelegate speakerWasMuted:mute];
    }
}
-(void)inCallMicrophoneWasMuted:(bool)mute
{
    [self setUserSettingBool:MUTE_MICROPHONE withValue:mute];
    if ([self.inCallSettingsDelegate respondsToSelector:@selector(microphoneWasMuted:)]) {
        [self.inCallSettingsDelegate microphoneWasMuted:mute];
    }
}
-(void)inCallShowSelfPreview:(bool)shown
{
    [self setUserSettingBool:VIDEO_SHOW_SELF_VIEW withValue:shown];
    if ([self.inCallSettingsDelegate respondsToSelector:@selector(selfPreviewShown::)]) {
        [self.inCallSettingsDelegate selfPreviewShown:shown];
    }
}



#pragma mark items for settingsHandlerDelegate - setting from settings dialog to responders

-(void)setMuteSpeaker:(bool)mute
{
    [self setUserSettingBool:MUTE_SPEAKER withValue:mute];
    if ([self.settingsHandlerDelegate respondsToSelector:@selector(muteSpeaker:)]) {
        [self.settingsHandlerDelegate muteSpeaker:mute];
    }
}
-(void)setMuteMicrophone:(bool)mute
{
    [self setUserSettingBool:MUTE_MICROPHONE withValue:mute];
    if ([self.settingsHandlerDelegate respondsToSelector:@selector(muteMicrophone:)]) {
        [self.settingsHandlerDelegate muteMicrophone:mute];
    }
}

-(void)setShowSelfPreview:(bool)show
{
    // does call window respond to this, or do we just show/hide?
    [self setUserSettingBool:VIDEO_SHOW_SELF_VIEW withValue:show];
    if ([self.settingsHandlerDelegate respondsToSelector:@selector(showSelfView::)]) {
        [self.settingsHandlerDelegate muteMicrophone:show];
    }
}

// TODO: not sure these need deelgate methods - we may be able to just handle the settings here directly?
-(void)setEnableEchoCancellation:(bool)enable
{
    [self setUserSettingBool:ENABLE_ECHO_CANCELLATION withValue:enable];
//    if ([self.settingsHandlerDelegate respondsToSelector:@selector(enableEchoCancellation::)]) {
//        [self.settingsHandlerDelegate enableEchoCancellation:enable];
//    }
}

#pragma mark settings accessors
-(bool)isSpeakerMuted
{
    return [self getUserSettingBool:MUTE_SPEAKER];
}
-(bool)isMicrophoneMuted
{
    return [self getUserSettingBool:MUTE_MICROPHONE];
}
-(bool)isEchoCancellationEnabled
{
    return [self getUserSettingBool:ENABLE_ECHO_CANCELLATION];
}
-(bool)isShowSelfViewEnabled
{
    return [self getUserSettingBool:VIDEO_SHOW_SELF_VIEW];
}
-(bool)isShowPreviewEnabled
{
    return [self getUserSettingBool:VIDEO_SHOW_PREVIEW];
}

#pragma mark Media Settings
-(NSString*)getSelectedCamera
{
    return [self getUserSettingString:SELECTED_CAPTURE_DEVICE];
}
-(NSString*)getSelectedMicrophone
{
    return [self getUserSettingString:SELECTED_MICROPHONE];
}
-(NSString*)getSelectedSpeaker
{
    return [self getUserSettingString:SELECTED_SPEAKER];
}


-(void)setSelectedCamera:(NSString*)cameraName
{
    [self setUserSettingString:SELECTED_CAPTURE_DEVICE withValue:cameraName];
}
-(void)setSelectedMicrophone:(NSString*)microphoneName
{
    [self setUserSettingString:SELECTED_MICROPHONE withValue:microphoneName];
}
-(void)setSelectedSpeaker:(NSString*)speakerName
{
    [self setUserSettingString:SELECTED_SPEAKER withValue:speakerName];
}


//=================================================================================================================
// Generic Settings Accessors
#pragma mark - this will give the singular place to changeover from app level settings to user level settings.
// ToDo: these settings are currently all stored at the app level. initially get everything hooked up to the app level settings, then here we can manage
//   changing over to user level settings.
-(bool)getUserSettingBool:(NSString*)settingName
{
    return [[NSUserDefaults standardUserDefaults]boolForKey:settingName];
}
-(void)setUserSettingBool:(NSString*)settingName withValue:(bool)value
{
    [[NSUserDefaults standardUserDefaults]setBool:value forKey:settingName];
}

-(NSString*)getUserSettingString:(NSString*)settingName
{
    return [[NSUserDefaults standardUserDefaults]stringForKey:settingName];
}
-(void)setUserSettingString:(NSString*)settingName withValue:(NSString*)value
{
    [[NSUserDefaults standardUserDefaults]setValue:value forKey:settingName];
}
                         
                         
                         
@end
