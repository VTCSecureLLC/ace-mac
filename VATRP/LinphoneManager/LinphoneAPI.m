//
//  LinphoneAPI.m
//  ACE
//
//  Created by Lizann Epley on 2/12/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LinphoneAPI.h"
#import "LinphoneManager.h"

@implementation LinphoneAPI

#pragma mark singleton methods

+ (id)instance
{
    static LinphoneAPI *sharedInstance = nil;
    @synchronized(self) {
        if (sharedInstance == nil)
            sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

-(bool)callAppearsValid:(LinphoneCall*) call
{
    // 1. verify that the call pointer != nil
    if (call == nil)
    {
        return false;
    }
    // 2. verify that the linphone core exists and is running
    LinphoneCore* linphoneCore = [LinphoneManager getLc];
    if (linphoneCore == nil)
    {
        return false;
    }
    // 3. get the list of calls from the core
    const MSList* callList = linphone_core_get_calls(linphoneCore);
    int count = 0;
    if (callList != nil)
    {
        count = ms_list_size(callList);
    }
    
    // 4. if the call is part of the list, then we belive that this is a valid call.
    if (count > 0)
    {
        while (callList->data != nil)
        {
            if (call == callList->data)
            {
                return true;
            }
            callList = callList->next;
        }
    }
    return false;
}


#pragma mark accessors for in call diagnostics

-(const LinphoneCallStats*)linphoneCallGetAudioStats:(LinphoneCall*)call
{
    if ([self callAppearsValid:call])
    {
        return linphone_call_get_audio_stats(call);
    }
    return nil;
}

-(const LinphoneCallStats*)linphoneCallGetVideoStats:(LinphoneCall*)call
{
    if ([self callAppearsValid:call])
    {
        return linphone_call_get_video_stats(call);
    }
    return nil;
}


// uint64_t linphone_call_stats_get_late_packets_cumulative_number (const LinphoneCallStats* stats,
//                                                                 LinphoneCall* call)
// returning -1 if we are unable to resolve
-(uint64_t)linphoneCallStatsGetLateAudioPacketsCumulativeNumber:(const LinphoneCallStats*)callStats call:(LinphoneCall*)call
{
    if ([self callAppearsValid:call] && (callStats != nil))
    {
        return linphone_call_stats_get_late_packets_cumulative_number(callStats, call);
    }
    return -1;
}

// uint64_t linphone_call_stats_get_late_packets_cumulative_number (const LinphoneCallStats* stats,
//                                                                 LinphoneCall* call)
// returning -1 if we are unable to resolve
-(uint64_t)linphoneCallStatsGetLateVideoPacketsCumulativeNumber:(const LinphoneCallStats*)callStats call:(LinphoneCall*)call
{
    if ([self callAppearsValid:call] && (callStats != nil))
    {
        return linphone_call_stats_get_late_packets_cumulative_number(callStats, call);
    }
    return -1;
}

// float linphone_call_stats_get_receiver_interarrival_jitter	(const LinphoneCallStats* stats,
//                                                               LinphoneCall* call)
// returning -1 if we are unable to resolve
-(float)linphoneCallStatsGetReceiverInterarrivalAudioJitter:(const LinphoneCallStats*)callStats call:(LinphoneCall*)call
{
    if ([self callAppearsValid:call] && (callStats != nil))
    {
        return linphone_call_stats_get_receiver_interarrival_jitter(callStats, call);
    }
    return -1.0f;
}
// float linphone_call_stats_get_receiver_interarrival_jitter	(const LinphoneCallStats* stats,
//                                                               LinphoneCall* call)
// returning -1 if we are unable to resolve
-(float)linphoneCallStatsGetReceiverInterarrivalVideoJitter:(const LinphoneCallStats*)callStats call:(LinphoneCall*)call
{
    if ([self callAppearsValid:call] && (callStats != nil))
    {
        return linphone_call_stats_get_receiver_interarrival_jitter(callStats, call);
    }
    return -1.0f;
}

// float linphone_call_stats_get_sender_interarrival_jitter	(const LinphoneCallStats* stats,
//                                                               LinphoneCall* call)
// returning -1 if we are unable to resolve
-(float)linphoneCallStatsGetSenderInterarrivalAudioJitter:(const LinphoneCallStats*)callStats call:(LinphoneCall*)call
{
    if ([self callAppearsValid:call] && (callStats != nil))
    {
        return linphone_call_stats_get_sender_interarrival_jitter(callStats, call);
    }
    return -1.0f;
}

// float linphone_call_stats_get_sender_interarrival_jitter	(const LinphoneCallStats* stats,
//                                                               LinphoneCall* call)
// returning -1 if we are unable to resolve
-(float)linphoneCallStatsGetSenderInterarrivalVideoJitter:(const LinphoneCallStats*)callStats call:(LinphoneCall*)call
{
    if ([self callAppearsValid:call] && (callStats != nil))
    {
        return linphone_call_stats_get_sender_interarrival_jitter(callStats, call);
    }
    return -1.0f;
}


// float linphone_call_stats_get_receiver_loss_rate	(const LinphoneCallStats* stats)
// returning -1 if we are unable to resolve
-(float)linphoneCallStatsGetReceiverAudioLossRate:(const LinphoneCallStats*)audioStats
{
    if (audioStats != nil)
    {
        return linphone_call_stats_get_receiver_loss_rate(audioStats);
    }
    return -1.0f;
}
-(float)linphoneCallStatsGetReceiverVideoLossRate:(const LinphoneCallStats*)videoStats
{
    if (videoStats != nil)
    {
        return linphone_call_stats_get_receiver_loss_rate(videoStats);
    }
    return -1.0f;
}

// float linphone_call_stats_get_sender_loss_rate	(const LinphoneCallStats* stats)
// returning -1 if we are unable to resolve
-(float)linphoneCallStatsGetSenderAudioLossRate:(const LinphoneCallStats*)audioStats
{
    if (audioStats != nil)
    {
        return linphone_call_stats_get_sender_loss_rate(audioStats);
    }
    return -1.0f;
}
-(float)linphoneCallStatsGetSenderVideoLossRate:(const LinphoneCallStats*)videoStats
{
    if (videoStats != nil)
    {
        return linphone_call_stats_get_sender_loss_rate(videoStats);
    }
    return -1.0f;
}

// const char * linphone_call_params_get_rtp_profile (const LinphoneCallParams *cp)
-(NSString*)linphoneCallParamsGetRTPProfile:(const LinphoneCallParams*)callParams
{

    return @"ACE: NOT YET IMPLEMENTED";
}

// @return The RTP statistics that have been computed locally for the call.
// LINPHONE_PUBLIC const rtp_stats_t * 	linphone_call_log_get_local_stats (const LinphoneCallLog *cl)

// @return The RTP statistics that have been computed by the remote end for the call.
// LINPHONE_PUBLIC const rtp_stats_t * 	linphone_call_log_get_remote_stats (const LinphoneCallLog *cl)


@end