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
-(void)initializeUserDefaults:(bool)force
{
    // "{\"version\":1,\"expiration_time\":3600,\"configuration_auth_password\":\"\",\"configuration_auth_expiration\":-1,\"sip_registration_maximum_threshold\":10,\"sip_register_usernames\":[],\"sip_auth_username\":\"\",\"sip_auth_password\":\"\",\"sip_register_domain\":\"acetest-registrar.vatrp.net\",\"sip_register_port\":25060,\"sip_register_transport\":\"tcp\",\"enable_echo_cancellation\":true,\"enable_video\":true,\"enable_rtt\":true,\"enable_adaptive_rate\":true,\"enabled_codecs\":[\"H.264\",\"H.263\",\"VP8\",\"G.722\",\"G.711\"],\"bwLimit\":\"high-fps\",\"upload_bandwidth\":660,\"download_bandwidth\":660,\"enable_stun\":false,\"stun_server\":\"\",\"enable_ice\":false,\"logging\":\"info\",\"sip_mwi_uri\":\"\",\"sip_videomail_uri\":\"\",\"video_resolution_maximum\":\"cif\"}"

    
    // convert these over to use the generic methods for app versus user settings when there is a chance
    
    if (force || [[NSUserDefaults standardUserDefaults]objectForKey:@"version"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"version"];
    }
    if (force || [[NSUserDefaults standardUserDefaults]objectForKey:@"expiration_time"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:280 forKey:@"expiration_time" ];
    }
    if (force || [[NSUserDefaults standardUserDefaults]objectForKey:@"configuration_auth_password"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"configuration_auth_password"];
    }
    if (force || [[NSUserDefaults standardUserDefaults]objectForKey:@"configuration_auth_expiration"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:-1 forKey:@"configuration_auth_expiration"];
    }
    if (force || [[NSUserDefaults standardUserDefaults]objectForKey:@"sip_registration_maximum_threshold"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:10 forKey:@"sip_registration_maximum_threshold"];
    }
    if (force || [[NSUserDefaults standardUserDefaults]objectForKey:@"sip_register_usernames"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[[NSArray alloc]init ] forKey:@"sip_register_usernames"];
    }
    if (force || [[NSUserDefaults standardUserDefaults]objectForKey:@"sip_auth_username"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"sip_auth_username"];
    }
    if (force || [[NSUserDefaults standardUserDefaults]objectForKey:@"sip_auth_password"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"sip_auth_password"];
    }
    if (force || [[NSUserDefaults standardUserDefaults]objectForKey:@"sip_register_domain"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"acetest-registrar.vatrp.net" forKey:@"sip_register_domain"];
    }
    if (force || [[NSUserDefaults standardUserDefaults]objectForKey:@"sip_register_port"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:25060 forKey:@"sip_register_port"];
    }
    if (force || [[NSUserDefaults standardUserDefaults]objectForKey:@"sip_register_transport"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"tcp" forKey:@"sip_register_transport"];
    }
    if (force || [[NSUserDefaults standardUserDefaults]objectForKey:@"enable_echo_cancellation"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"true" forKey:@"enable_echo_cancellation"];
    }
    if (force || [[NSUserDefaults standardUserDefaults]objectForKey:@"enable_video_preference"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"true" forKey:@"enable_video_preference"];
    }
    if (force || [[NSUserDefaults standardUserDefaults]objectForKey:@"kREAL_TIME_TEXT_ENABLED"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"true" forKey:@"kREAL_TIME_TEXT_ENABLED"];
    }
    if (force || [[NSUserDefaults standardUserDefaults]objectForKey:@"enable_adaptive_rate_control"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"true" forKey:@"enable_adaptive_rate_control"];
    }
    if (force || [[NSUserDefaults standardUserDefaults]objectForKey:@"enabled_codecs"] == nil)
    {
        // enabled_codecs\":[\"H.264\",\"H.263\",\"VP8\",\"G.722\",\"G.711\"]
        NSArray *enabledCodecs = @[@"H.264", @"H.263", @"VP8", @"G.722", @"G.711"];
        [[NSUserDefaults standardUserDefaults] setObject:enabledCodecs forKey:@"enabled_codecs"];
    }
    if (force || [[NSUserDefaults standardUserDefaults]objectForKey:@"bwLimit"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"high-fps" forKey:@"bwLimit"];
    }
    if (force ||[[NSUserDefaults standardUserDefaults]objectForKey:@"upload_bandwidth"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:500 forKey:@"upload_bandwidth" ];
        linphone_core_set_upload_bandwidth([LinphoneManager getLc], 500);
    }
    if (force || [[NSUserDefaults standardUserDefaults]objectForKey:@"download_bandwidth"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:500 forKey:@"download_bandwidth" ];
                linphone_core_set_download_bandwidth([LinphoneManager getLc], 500);
    }
    if (force || [[NSUserDefaults standardUserDefaults]objectForKey:@"stun_preference"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"false" forKey:@"stun_preference"];
    }
    if (force || [[NSUserDefaults standardUserDefaults]objectForKey:@"stun_url_preference"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"acetest-regstrar.vatrp.net" forKey:@"stun_url_preference"];
    }
    if (force || [[NSUserDefaults standardUserDefaults]objectForKey:@"ice_preference"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"false" forKey:@"ice_preference"];
    }
    if (force || [[NSUserDefaults standardUserDefaults]objectForKey:@"logging"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"info" forKey:@"logging"];
    }
    if (force || [[NSUserDefaults standardUserDefaults]objectForKey:@"sip_mwi_uri"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"sip_mwi_uri"];
    }
    if (force || [[NSUserDefaults standardUserDefaults]objectForKey:@"sip_videomail_uri"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"sip_videomail_uri"];
    }
    if (force || [[NSUserDefaults standardUserDefaults]objectForKey:@"video_preferred_size_preference"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"cif (352x288)" forKey:@"video_preferred_size_preference"];
    }

    if (force || [[NSUserDefaults standardUserDefaults]objectForKey:MUTE_MICROPHONE] == nil)
    {
        [self setUserSettingBool:MUTE_MICROPHONE withValue:false];
    }
    if (force || [[NSUserDefaults standardUserDefaults]objectForKey:MUTE_SPEAKER] == nil)
    {
        [self setUserSettingBool:MUTE_SPEAKER withValue:false];
    }
    if (force || [[NSUserDefaults standardUserDefaults]objectForKey:VIDEO_SHOW_SELF_VIEW] == nil)
    {
        [self setUserSettingBool:VIDEO_SHOW_SELF_VIEW withValue:true];
    }
    if (force || [[NSUserDefaults standardUserDefaults]objectForKey:RTCP_FB_MODE] == nil){
        [self setUserSettingString:RTCP_FB_MODE withValue:@"Off"];
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
-(void)inCallCameraWasMuted:(bool)mute
{
    [self setUserSettingBool:MUTE_CAMERA withValue:mute];
    if ([self.inCallPreferencessHandlerDelegate respondsToSelector:@selector(cameraWasMuted:)]) {
        [self.inCallPreferencessHandlerDelegate cameraWasMuted:mute];
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

-(void)setMuteCamera:(bool)mute
{
    [self setUserSettingBool:MUTE_SPEAKER withValue:mute];
    if ([self.preferencessHandlerDelegate respondsToSelector:@selector(muteCamera:)]) {
        [self.preferencessHandlerDelegate muteCamera:mute];
    }
}


-(void)setEnableVideo:(bool)enable
{
    [self setUserSettingBool:ENABLE_VIDEO withValue:enable];
}



// TODO: not sure these need delegate methods - we may be able to just handle the settings here directly?
-(void)setShowSelfView:(bool)show
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

#pragma mark Preferences Settings

-(void)setRtcpFbMode:(NSString*) rtcpFbMode{
    [self setUserSettingString:RTCP_FB_MODE withValue:rtcpFbMode];
}
-(NSString*)getRtcpFbMode{
    return [self getUserSettingString:RTCP_FB_MODE];
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
