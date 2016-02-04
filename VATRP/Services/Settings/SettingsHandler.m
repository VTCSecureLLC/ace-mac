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
#import "LinphoneManager.h"

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

// initialization of user settings
-(void)initializeUserDefaults
{
    // "{\"version\":1,\"expiration_time\":3600,\"configuration_auth_password\":\"\",\"configuration_auth_expiration\":-1,\"sip_registration_maximum_threshold\":10,\"sip_register_usernames\":[],\"sip_auth_username\":\"\",\"sip_auth_password\":\"\",\"sip_register_domain\":\"acetest-registrar.vatrp.net\",\"sip_register_port\":25060,\"sip_register_transport\":\"tcp\",\"enable_echo_cancellation\":true,\"enable_video\":true,\"enable_rtt\":true,\"enable_adaptive_rate\":true,\"enabled_codecs\":[\"H.264\",\"H.263\",\"VP8\",\"G.722\",\"G.711\"],\"bwLimit\":\"high-fps\",\"upload_bandwidth\":660,\"download_bandwidth\":660,\"enable_stun\":false,\"stun_server\":\"\",\"enable_ice\":false,\"logging\":\"info\",\"sip_mwi_uri\":\"\",\"sip_videomail_uri\":\"\",\"video_resolution_maximum\":\"cif\"}"

    
    // convert these over to use the generic methods for app versus user settings when there is a chance
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"version"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"version"];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"expiration_time"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:3600 forKey:@"expiration_time" ];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"version"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"configuration_auth_password"];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"version"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:-1 forKey:@"configuration_auth_expiration"];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sip_registration_maximum_threshold"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:10 forKey:@"sip_registration_maximum_threshold"];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sip_register_usernames"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[[NSArray alloc]init ] forKey:@"sip_register_usernames"];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sip_auth_username"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"sip_auth_username"];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sip_auth_password"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"sip_auth_password"];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sip_register_domain"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"acetest-registrar.vatrp.net" forKey:@"sip_register_domain"];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sip_register_port"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:5060 forKey:@"sip_register_port"];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sip_register_transport"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"tcp" forKey:@"sip_register_transport"];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"enable_echo_cancellation"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"true" forKey:@"enable_echo_cancellation"];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"enable_video_preference"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"true" forKey:@"enable_video_preference"];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"kREAL_TIME_TEXT_ENABLED"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"true" forKey:@"kREAL_TIME_TEXT_ENABLED"];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"enable_adaptive_rate_control"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"true" forKey:@"enable_adaptive_rate_control"];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"enabled_codecs"] == nil)
    {
        // enabled_codecs\":[\"H.264\",\"H.263\",\"VP8\",\"G.722\",\"G.711\"]
        NSArray *enabledCodecs = @[@"H.264", @"H.263", @"VP8", @"G.722", @"G.711"];
        [[NSUserDefaults standardUserDefaults] setObject:enabledCodecs forKey:@"enabled_codecs"];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"bwLimit"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"high-fps" forKey:@"bwLimit"];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"upload_bandwidth"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:660 forKey:@"upload_bandwidth" ];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"download_bandwidth"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:660 forKey:@"download_bandwidth" ];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"stun_preference"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"false" forKey:@"stun_preference"];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"stun_url_preference"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"acetest-regstrar.vatrp.net" forKey:@"stun_url_preference"];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"ice_preference"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"false" forKey:@"ice_preference"];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"logging"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"info" forKey:@"logging"];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sip_mwi_uri"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"sip_mwi_uri"];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sip_videomail_uri"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"sip_videomail_uri"];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"video_preferred_size_preference"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"cif" forKey:@"video_preferred_size_preference"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}


//==========================================================================================
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
-(void)inCallShowSelfView:(bool)shown
{
    [self setUserSettingBool:VIDEO_SHOW_SELF_VIEW withValue:shown];
//    if ([self.inCallSettingsDelegate respondsToSelector:@selector(selfViewShown:)]) {
//        [self.inCallSettingsDelegate selfViewShown:shown];
//    }
}

-(void)inCallVideoEnabled:(bool)enable
{
    [self setUserSettingBool:VIDEO_SHOW_SELF_VIEW withValue:enable];
}


//==========================================================================================
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


-(void)setEnableVideo:(bool)enable
{
    [self setUserSettingBool:ENABLE_VIDEO withValue:enable];
}


// TODO: not sure these need delegate methods - we may be able to just handle the settings here directly?
-(void)setShowSelfPreview:(bool)show
{
    // does call window respond to this, or do we just show/hide?
    [self setUserSettingBool:VIDEO_SHOW_SELF_VIEW withValue:show];
    
    LinphoneCore* lc = [LinphoneManager getLc];
    if (lc != nil)
    {
        linphone_core_enable_self_view(lc, show);
    }
    
    //    if ([self.settingsHandlerDelegate respondsToSelector:@selector(showSelfView:)]) {
    //        [self.settingsHandlerDelegate showSelfView:show];
    //    }
}

-(void)setEnableEchoCancellation:(bool)enable
{
    [self setUserSettingBool:ENABLE_ECHO_CANCELLATION withValue:enable];
    LinphoneCore* lc = [LinphoneManager getLc];
    if (lc != nil)
    {
        linphone_core_enable_echo_cancellation(lc, enable);
    }

//    if ([self.settingsHandlerDelegate respondsToSelector:@selector(enableEchoCancellation::)]) {
//        [self.settingsHandlerDelegate enableEchoCancellation:enable];
//    }
}

//==========================================================================================
// Accessors
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

-(bool)isVideoEnabled
{
    return [self getUserSettingBool:ENABLE_VIDEO];
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
// ToDo: these settings are currently all stored at the app level. I am initially getting everything hooked up
//   to the app level settings, then here we can manage changing over to user level settings.
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

-(NSInteger)getUserSettingInt:(NSString*)settingName
{
    return [[NSUserDefaults standardUserDefaults]integerForKey:settingName];
}
-(void)setUserSettingInt:(NSString*)settingName withValue:(NSInteger)value
{
    [[NSUserDefaults standardUserDefaults]setInteger:value forKey:settingName];
}

-(NSObject*)getUserSettingObject:(NSString*)settingName
{
    return [[NSUserDefaults standardUserDefaults]objectForKey:settingName];
}
-(void)setUserSettingObject:(NSString*)settingName withValue:(NSObject*)value
{
    [[NSUserDefaults standardUserDefaults]setObject:value forKey:settingName];
}

// App Level Settings - Generic accessors
-(bool)getAppSettingBool:(NSString*)settingName
{
    return [[NSUserDefaults standardUserDefaults]boolForKey:settingName];
}
-(void)setAppSettingBool:(NSString*)settingName withValue:(bool)value
{
    [[NSUserDefaults standardUserDefaults]setBool:value forKey:settingName];
}

-(NSString*)getAppSettingString:(NSString*)settingName
{
    return [[NSUserDefaults standardUserDefaults]stringForKey:settingName];
}
-(void)setAppSettingString:(NSString*)settingName withValue:(NSString*)value
{
    [[NSUserDefaults standardUserDefaults]setValue:value forKey:settingName];
}


@end
