//
//  LinphoneAPI.h
//  ACE
//
//  Created by Lizann Epley on 2/12/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

// this file is the starting point for consolidating the entry point for Linphone.
//   This will mimick how Windows is set up. Any linphone api call
//   should be made here. New accessors used shuld be made here as well.
//   Ideally we will use one class (this one) to provide our linphone accessors, also providing us
//   one location for verification points.
//   Ultimately items more complicated should be placed into LinphoneManager or its successor.

#ifndef LinphoneAPI_h
#define LinphoneAPI_h

#include "linphone/linphonecore.h"
#include "linphone/linphone_tunnel.h"

@interface LinphoneAPI : NSObject
+ (id)instance;


-(NSString*)linphoneCoreGetAdaptiveRate:(LinphoneCore*)linphoneCore;
-(void)linphoneCoreSetAdaptiveRate:(LinphoneCore*)linphoneCore adaptiveRateAlgorithm:(NSString*)adaptiveRateAlgorithm;

#pragma mark utility methods to use for validation
-(bool)callAppearsValid:(LinphoneCall*) call;

#pragma mark accessors for in call values


#pragma mark accessors for in call diagnostics
-(const LinphoneCallStats*)linphoneCallGetAudioStats:(LinphoneCall*)call;
-(const LinphoneCallStats*)linphoneCallGetVideoStats:(LinphoneCall*)call;

-(uint64_t)linphoneCallStatsGetLateAudioPacketsCumulativeNumber:(const LinphoneCallStats*)callStats call:(LinphoneCall*)call;
-(uint64_t)linphoneCallStatsGetLateVideoPacketsCumulativeNumber:(const LinphoneCallStats*)callStats call:(LinphoneCall*)call;

-(float)linphoneCallStatsGetReceiverInterarrivalAudioJitter:(const LinphoneCallStats*)callStats call:(LinphoneCall*)call;
-(float)linphoneCallStatsGetReceiverInterarrivalVideoJitter:(const LinphoneCallStats*)callStats call:(LinphoneCall*)call;

-(float)linphoneCallStatsGetSenderInterarrivalAudioJitter:(const LinphoneCallStats*)callStats call:(LinphoneCall*)call;
-(float)linphoneCallStatsGetSenderInterarrivalVideoJitter:(const LinphoneCallStats*)callStats call:(LinphoneCall*)call;

-(float)linphoneCallStatsGetReceiverAudioLossRate:(const LinphoneCallStats*)audioStats;
-(float)linphoneCallStatsGetReceiverVideoLossRate:(const LinphoneCallStats*)videoStats;

-(float)linphoneCallStatsGetSenderAudioLossRate:(const LinphoneCallStats*)audioStats;
-(float)linphoneCallStatsGetSenderVideoLossRate:(const LinphoneCallStats*)videoStats;


@end

#endif /* LinphoneAPI_h */
