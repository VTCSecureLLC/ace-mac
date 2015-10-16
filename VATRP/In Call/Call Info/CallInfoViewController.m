//
//  CallInfoViewController.m
//  ACE
//
//  Created by Edgar Sukiasyan on 10/12/15.
//  Copyright © 2015 Home. All rights reserved.
//

#import "CallInfoViewController.h"
#import "LinphoneManager.h"

@interface CallInfoViewController () {
    NSTimer *timerCallInfoUpdate;
}

- (void) callInfoUpdateTimer;

@property (weak) IBOutlet NSTextField *labelAudioCodec;
@property (weak) IBOutlet NSTextField *labelVideoCodec;
@property (weak) IBOutlet NSTextField *labelSIPPort;
@property (weak) IBOutlet NSTextField *labelRTPPort;
@property (weak) IBOutlet NSTextField *labelSendingVideoResolution;
@property (weak) IBOutlet NSTextField *labelReceivingVideoResolution;
@property (weak) IBOutlet NSTextField *labelSendingVideoFPS;
@property (weak) IBOutlet NSTextField *labelReceivingVideoFPS;

@property (weak) IBOutlet NSTextField *labelTotalUploadBandwidth;
@property (weak) IBOutlet NSTextField *labelAudioUploadBandwidth;
@property (weak) IBOutlet NSTextField *labelVideoUploadBandwidth;

@property (weak) IBOutlet NSTextField *labelTotalDownloadBandwidth;
@property (weak) IBOutlet NSTextField *labelAudioDownloadBandwidth;
@property (weak) IBOutlet NSTextField *labelVideoDownloadBandwidth;

@property (weak) IBOutlet NSTextField *labelIceConnectivity;
@property (weak) IBOutlet NSTextField *labelEncryption;
@property (weak) IBOutlet NSTextField *labelAVPF;

@end

@implementation CallInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self callInfoUpdateTimer];
    timerCallInfoUpdate = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                           target:self
                                                         selector:@selector(callInfoUpdateTimer)
                                                         userInfo:nil
                                                          repeats:YES];
}

- (void) callInfoUpdateTimer {
    LinphoneCall *call = linphone_core_get_current_call([LinphoneManager getLc]);
    
    if (call) {
        const LinphoneCallParams* current = linphone_call_get_current_params(call);
        
        if (current) {
            const LinphonePayloadType *audio_pt = linphone_call_params_get_used_audio_codec(current);
            if (audio_pt != NULL) self.labelAudioCodec.stringValue = [NSString stringWithUTF8String:audio_pt->mime_type];
            
            const LinphonePayloadType *video_pt = linphone_call_params_get_used_video_codec(current);
            if (video_pt != NULL) self.labelVideoCodec.stringValue = [NSString stringWithUTF8String:video_pt->mime_type];
            
            int sip_port = linphone_core_get_sip_port ([LinphoneManager getLc]);
            self.labelSIPPort.stringValue = [NSString stringWithFormat:@"%d", sip_port];
            
            int minPort, maxPort;
            linphone_core_get_audio_port_range([LinphoneManager getLc], &minPort, &maxPort);
            if (minPort != maxPort)
                self.labelRTPPort.stringValue = [NSString stringWithFormat:@"%d-%d", minPort, maxPort];
            else
                self.labelRTPPort.stringValue = [NSString stringWithFormat:@"%d", minPort];

            MSVideoSize sendVideoSize = linphone_call_params_get_sent_video_size(current);
            self.labelSendingVideoResolution.stringValue = [NSString stringWithFormat:@"%dx%d", sendVideoSize.width, sendVideoSize.height];
            
            MSVideoSize receivedVideoSize = linphone_call_params_get_received_video_size(current);
            self.labelReceivingVideoResolution.stringValue = [NSString stringWithFormat:@"%dx%d", receivedVideoSize.width, receivedVideoSize.height];
            
            float sentFPS = linphone_call_params_get_sent_framerate(current);
            self.labelSendingVideoFPS.stringValue = [NSString stringWithFormat:@"%.1fFPS", sentFPS];
            
            float recvFPS = linphone_call_params_get_received_framerate(current);
            self.labelReceivingVideoFPS.stringValue = [NSString stringWithFormat:@"%.1fFPS", recvFPS];
            
            LinphoneAVPFMode avpfMode = linphone_core_get_avpf_mode([LinphoneManager getLc]);
            if(avpfMode == LinphoneAVPFEnabled){
                self.labelAVPF.stringValue = @"ON";
            }
            else {
                self.labelAVPF.stringValue = @"OFF";
            }

            const LinphoneCallStats *audio_stats = linphone_call_get_audio_stats(call);
            const LinphoneCallStats *video_stats = linphone_call_get_video_stats(call);
            
            if (audio_stats != NULL && video_stats != NULL) {
                float upload_total = audio_stats->upload_bandwidth + video_stats->upload_bandwidth;
                self.labelTotalUploadBandwidth.stringValue = [NSString stringWithFormat:@"%1.1f kbits/s", upload_total];
                self.labelAudioUploadBandwidth.stringValue = [NSString stringWithFormat:@"a %1.1f kbits/s", audio_stats->upload_bandwidth];
                self.labelVideoUploadBandwidth.stringValue = [NSString stringWithFormat:@"v %1.1f kbits/s", video_stats->upload_bandwidth];
                
                float download_total = audio_stats->download_bandwidth + video_stats->download_bandwidth;
                self.labelTotalDownloadBandwidth.stringValue = [NSString stringWithFormat:@"%1.1f kbits/s", download_total];
                self.labelAudioDownloadBandwidth.stringValue = [NSString stringWithFormat:@"a %1.1f kbits/s", audio_stats->download_bandwidth];
                self.labelVideoDownloadBandwidth.stringValue = [NSString stringWithFormat:@"v %1.1f kbits/s", video_stats->download_bandwidth];
                
                self.labelIceConnectivity.stringValue = [self iceToString:audio_stats->ice_state];
            }
            
            LinphoneMediaEncryption enc = linphone_call_params_get_media_encryption(current);
            self.labelEncryption.stringValue = [self encryptionToString:enc];
        }
    }
}

- (NSString *)iceToString:(LinphoneIceState)state {
    switch (state) {
        case LinphoneIceStateNotActivated:
            return NSLocalizedString(@"Not activated", @"ICE has not been activated for this call");
            break;
        case LinphoneIceStateFailed:
            return NSLocalizedString(@"Failed", @"ICE processing has failed");
            break;
        case LinphoneIceStateInProgress:
            return NSLocalizedString(@"In progress", @"ICE process is in progress");
            break;
        case LinphoneIceStateHostConnection:
            return NSLocalizedString(@"Direct connection", @"ICE has established a direct connection to the remote host");
            break;
        case LinphoneIceStateReflexiveConnection:
            return NSLocalizedString(@"NAT(s) connection",
                                     @"ICE has established a connection to the remote host through one or several NATs");
            break;
        case LinphoneIceStateRelayConnection:
            return NSLocalizedString(@"Relay connection", @"ICE has established a connection through a relay");
            break;
    }
}

- (NSString *)encryptionToString:(LinphoneMediaEncryption)state {
    switch (state) {
        case LinphoneMediaEncryptionNone:
            return @"Encryption type None";
            break;
        case LinphoneMediaEncryptionDTLS:
            return @"Encryption type DTLS";
            break;
        case LinphoneMediaEncryptionSRTP:
            return @"Encryption type SRTP";
            break;
        case LinphoneMediaEncryptionZRTP:
            return @"Encryption type ZRTP";
            break;
    }
}

- (void) dealloc {
    if (timerCallInfoUpdate && [timerCallInfoUpdate isValid]) {
        [timerCallInfoUpdate invalidate];
        timerCallInfoUpdate = nil;
    }
}

@end
