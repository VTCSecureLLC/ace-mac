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
        }
        
        const char* uri = linphone_address_as_string_uri_only(NULL);
        self.textFieldSipURI.stringValue = [NSString stringWithUTF8String:uri];
    }
    
    if (address == nil) {
        address = NSLocalizedString(@"Unknown", nil);
    }
    
    time_t start_date = linphone_call_log_get_start_date(callLog);

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];

    int duration = linphone_call_log_get_duration(callLog);
    
    [self.textFieldRemoteName setStringValue:address];
    [statusImageView removeFromSuperview];
    statusImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(8, 4, 26, 26)];
    [statusImageView setImage:image];
    [self addSubview:statusImageView];
    
    NSDate *date1 = [NSDate dateWithTimeIntervalSince1970:start_date];
    [self.textFieldCallDate setStringValue:[self makeStringFromDate:date1]];
    
    [self.textFieldCallDuration setStringValue:[HistoryTableCellView timeFormatConvertToSeconds:duration]];
    
    if ((linphone_call_log_get_dir(callLog) == LinphoneCallIncoming) &&
        (linphone_call_log_get_status(callLog) == LinphoneCallMissed)) {
            [self.textFieldCallDuration setStringValue:@""];
    }
}

+ (NSString *)timeFormatConvertToSeconds:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    
    return [NSString stringWithFormat:@"%02dm %02ds", minutes, seconds];
}

- (NSString*)makeStringFromDate:(NSDate*)date {
    NSString *dateString = @"";
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    NSDate *otherDate = [cal dateFromComponents:components];
    
    NSDateFormatter *formatterAMPM = [[NSDateFormatter alloc] init];
    [formatterAMPM setDateFormat:@"hh:mm a"];
    NSString *amPmFormatString = [formatterAMPM stringFromDate:date];
    
    // Today part checking
    if([today isEqualToDate:otherDate]) {
        dateString = [formatterAMPM stringFromDate:date];
        return dateString;
    }
    
    // This Week part checking
    NSDateComponents *components1 = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit) fromDate:[NSDate new]];
    NSDateComponents *components2 = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit) fromDate:date];
    
    
    NSDateFormatter *formatterWeekDay = [[NSDateFormatter alloc] init];
    [formatterWeekDay setDateFormat:@"EE"];
    NSString *weekDayShort = [formatterWeekDay stringFromDate:date];
    
    if ([components1 week] == [components2 week]) {
        dateString = [[weekDayShort stringByAppendingString:@" "] stringByAppendingString:amPmFormatString];
        return dateString;
    }
    
    // This Month part checking
    NSDateFormatter *formatterMonth = [[NSDateFormatter alloc] init];
    [formatterMonth setDateFormat:@"MMM"];

    NSString *monthDayShort = [formatterMonth stringFromDate:date];
    
    NSDateFormatter *formatterDay = [[NSDateFormatter alloc] init];
    [formatterDay setDateFormat:@"dd"];

    NSString *dayShort = [formatterDay stringFromDate:date];
    
    dateString = [[[[dayShort stringByAppendingString:@" "] stringByAppendingString:monthDayShort] stringByAppendingString:@" "] stringByAppendingString:amPmFormatString];
    
    
    return dateString;
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
