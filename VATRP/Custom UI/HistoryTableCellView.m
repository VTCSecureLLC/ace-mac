//
//  ContactTableCellView.m
//  ACE
//
//  Created by Ruben Semerjyan on 10/14/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "HistoryTableCellView.h"
#import "LinphoneContactService.h"

@interface HistoryTableCellView () {
    NSImageView *statusImageView;
    NSTrackingArea *_trackingArea;
    NSImage *image;
    LinphoneAddress *userAddress;
}

@end

@implementation HistoryTableCellView

- (void)awakeFromNib {
    [self createTrackingArea];
}

- (void) setCallLog:(LinphoneCallLog*)callLog {
    // Set up the cell...
    LinphoneAddress *addr;
   
    image = nil;
    if (linphone_call_log_get_dir(callLog) == LinphoneCallIncoming) {
        if (linphone_call_log_get_status(callLog) != LinphoneCallMissed) {
            image = [NSImage imageNamed:@"icon_call_dir_incoming.png"];
        } else {
            image = [NSImage imageNamed:@"icon_call_dir_missed.png"];
        }
        addr = linphone_call_log_get_from(callLog);
        userAddress = addr;
    } else {
        image = [NSImage imageNamed:@"icon_call_dir_outgoing.png"];
        addr = linphone_call_log_get_to(callLog);
        userAddress = addr;
    }
    
    NSString *address = nil;
    if (addr != NULL) {
        NSString *contactName = [[LinphoneContactService sharedInstance] contactNameFromAddress:addr];
        if (![contactName isEqualToString:@""]) {
            address = contactName;
        } else {
            const char *lDisplayName = linphone_address_get_display_name(addr);
            const char *lUserName = linphone_address_get_username(addr);
            if (lDisplayName)
                address = [NSString stringWithUTF8String:lDisplayName];
            else if (lUserName)
                address = [NSString stringWithUTF8String:lUserName];
        }    }
    
    if (address == nil) {
        address = NSLocalizedString(@"Unknown", nil);
    }
    
    
    time_t start_date = linphone_call_log_get_start_date(callLog);

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:start_date];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    
    int duration = linphone_call_log_get_duration(callLog);
    
    [self.textFieldRemoteName setStringValue:address];
    [statusImageView removeFromSuperview];
    statusImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(8, 4, 26, 26)];
    [statusImageView setImage:image];
    [self addSubview:statusImageView];
    [self.textFieldCallDate setStringValue:formattedDateString];
    [self.textFieldCallDuration setStringValue:[HistoryTableCellView timeFormatConvertToSeconds:duration]];
}

+ (NSString *)timeFormatConvertToSeconds:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

- (void)hidePlusButton:(BOOL)yesNo {
    if (userAddress != nil) {
        LinphoneFriend *friend  = linphone_core_find_friend([LinphoneManager getLc], userAddress);
        if (!friend) {
            self.imageContactView.hidden = !yesNo;
            statusImageView.hidden = !yesNo;
            self.plusButton.hidden = yesNo;
        }
    }
}

#pragma mark - mouse overall methods

- (void)createTrackingArea {
    _trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:NSTrackingMouseEnteredAndExited|NSTrackingActiveInActiveApp owner:self userInfo:nil];
    [self addTrackingArea:_trackingArea];
    
    NSPoint mouseLocation = [[self window] mouseLocationOutsideOfEventStream];
    mouseLocation = [self convertPoint:mouseLocation fromView:nil];
    
    if (NSPointInRect(mouseLocation, [self bounds])) {
        [self mouseEntered:nil];
    } else {
        [self mouseExited:nil];
    }
}

- (void)mouseEntered:(NSEvent *)theEvent {
    [self hidePlusButton:NO];
}

- (void)mouseExited:(NSEvent *)theEvent {
    [self hidePlusButton:YES];
}

#pragma mark - Buttons actions

- (IBAction)onPlusClick:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickPlusButton:withInfo:)]) {
        NSString *name = nil;
        const char *lDisplayName = linphone_address_get_display_name(userAddress);
        if (lDisplayName) {
            name = [NSString stringWithUTF8String:lDisplayName];
        } else {
            name = @"";
        }
        const char* uri = linphone_address_as_string_uri_only(userAddress);
        NSDictionary *dict = @{@"name" : name,
                               @"sipUri" : [NSString stringWithUTF8String:uri] };
    
        [_delegate didClickPlusButton:self withInfo:dict];
    }
}

@end
