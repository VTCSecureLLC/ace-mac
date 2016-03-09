  //
//  RecentsView.m
//  ACE
//
//  Created by Norayr Harutyunyan on 11/11/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import "RecentsView.h"
#import "HistoryTableCellView.h"
#import "LinphoneManager.h"
#import "CallService.h"
#import "ViewManager.h"
#import "LinphoneContactService.h"
#import "AccountsService.h"
#import "AppDelegate.h"
#import "AddContactDialogBox.h"
#import "Utils.h"


@interface RecentsView () <HistoryTableCellViewViewDelegate> {
    NSMutableArray *callLogs;
    BOOL missedFilter;
    AddContactDialogBox *editContactDialogBox;
    NSString *dialPadFilter;
    LinphoneCallLog *selectedCallLog;
}

@property (weak) IBOutlet NSScrollView *scrollViewRecents;
@property (weak) IBOutlet NSTableView *tableViewRecents;

@end

@implementation RecentsView

-(id) init
{
    self = [super initWithNibName:@"RecentsView" bundle:nil];
    if (self)
    {
        // init
    }
    return self;
    
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    [self setBackgroundColor:[NSColor clearColor]];
    
    missedFilter = false;
    dialPadFilter = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callUpdate:)
                                                 name:kLinphoneCallUpdate
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dialpadTextUpdate:)
                                                 name:DIALPAD_TEXT_CHANGED
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contactEditDone:)
                                                 name:@"contactInfoEditDone"
                                               object:nil];
  
}

- (void) awakeFromNib {
    [super awakeFromNib];
    
//    [self setBackgroundColor:[NSColor clearColor]];
    
    missedFilter = false;
    dialPadFilter = nil;
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(callUpdate:)
//                                                 name:kLinphoneCallUpdate
//                                               object:nil];

//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(dialpadTextUpdate:)
//                                                 name:DIALPAD_TEXT_CHANGED
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(contactEditDone:)
//                                                 name:@"contactInfoEditDone"
//                                               object:nil];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)callUpdate:(NSNotification*)notif {
    LinphoneCallState state = [[notif.userInfo objectForKey: @"state"] intValue];
    
    switch (state) {
        case LinphoneCallError:
        case LinphoneCallEnd:
        case LinphoneCallReleased: {
            [self loadData];
        }
            break;
        default:
            break;
    }
    
    [self resignFirstResponder];
}

- (void)dialpadTextUpdate:(NSNotification*)notif {
    NSString *dialpadText = [notif object];

    if (dialpadText && dialpadText.length) {
        dialPadFilter = dialpadText;
    } else {
        dialPadFilter = nil;
    }
    
    [self loadData];
}

#pragma mark - Property Functions

- (void)setMissedFilter:(BOOL)amissedFilter {
    if (missedFilter == amissedFilter) {
        return;
    }
    missedFilter = amissedFilter;
    [self loadData];
}

#pragma mark - UITableViewDataSource Functions

- (void) reloadCallLogs {
    [self loadData];
}

- (void)loadData {
    @synchronized(self) {
        if (!callLogs) {
            callLogs = [[NSMutableArray alloc] init];
        } else {
            [callLogs removeAllObjects];
        }
        
        const MSList *logs = linphone_core_get_call_logs([LinphoneManager getLc]);
        while (logs != NULL) {
            LinphoneCallLog *log = (LinphoneCallLog *)logs->data;
            if (missedFilter) {
                if (linphone_call_log_get_status(log) == LinphoneCallMissed) {
                    [callLogs addObject:[NSValue valueWithPointer:log]];
                }
            } else {
                if (dialPadFilter) {
                    NSString *addr = [self addressFromCallLog:log];
                    
                    if (addr && [addr containsString:dialPadFilter]) {
                        [callLogs addObject:[NSValue valueWithPointer:log]];
                    }
                } else {
                    [callLogs addObject:[NSValue valueWithPointer:log]];
                }
            }
            logs = ms_list_next(logs);
        }
    }

    [self.tableViewRecents reloadData];
}

- (IBAction)onSegmentCallType:(id)sender {
    NSSegmentedControl *segmentedControl = (NSSegmentedControl*)sender;
    
    [self setMissedFilter:segmentedControl.selectedSegment];
    NSLog(@"segmentedControl.selectedSegment: %ld", (long)segmentedControl.selectedSegment);
}

- (void)didClickPlusButton:(HistoryTableCellView *)contactCellView withInfo:(NSDictionary *)info {
    
//    editContactDialogBox = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"AddContactDialogBox"];
    editContactDialogBox = [[AddContactDialogBox alloc] init];
    editContactDialogBox.isEditing = YES;
    editContactDialogBox.oldName = [info objectForKey:@"name"];
    editContactDialogBox.oldPhone = [info objectForKey:@"sipUri"];
    editContactDialogBox.oldProviderName = [Utils providerNameFromSipURI:[info objectForKey:@"sipUri"]];
    [[AppDelegate sharedInstance].homeWindowController.contentViewController presentViewControllerAsModalWindow:editContactDialogBox];
}

- (void)contactEditDone:(NSNotification*)notif {
    [self.tableViewRecents reloadData];
}

#pragma mark - UITableViewDataSource Functions

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (callLogs) {
        return callLogs.count;
    }
    
    return 0;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    HistoryTableCellView *cellView = [tableView makeViewWithIdentifier:@"CallLog" owner:self];
    cellView.delegate = self;
    LinphoneCallLog *log = [[callLogs objectAtIndex:row] pointerValue];
    [cellView setCallLog:log];
    
    return cellView;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 55;
}



- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    //    selectedRow = marrayLoad[row];
    if(tableView.clickedRow != row){
        return NO;
    }
    LinphoneCallLog *callLog = [[callLogs objectAtIndex:row] pointerValue];
    LinphoneAddress *addr;
    if (linphone_call_log_get_dir(callLog) == LinphoneCallIncoming) {
        addr = linphone_call_log_get_from(callLog);
    } else {
        addr = linphone_call_log_get_to(callLog);
    }
    
    NSString *address = nil;
    if (addr != NULL) {
        BOOL useLinphoneAddress = true;
        // contact name
        if (useLinphoneAddress) {
            const char *lDisplayName = linphone_address_get_display_name(addr);
            const char *lUserName = linphone_address_get_username(addr);
            if (lDisplayName)
                address = [NSString stringWithUTF8String:lDisplayName];
            else if (lUserName)
                address = [NSString stringWithUTF8String:lUserName];
        }
    }
    
    if (address != nil) {
        // Go to dialer view
        [CallService callTo:address];
    }
    
    return YES;
}

- (NSString*) addressFromCallLog:(LinphoneCallLog*)callLog {
    LinphoneAddress *addr;
    if (linphone_call_log_get_dir(callLog) == LinphoneCallIncoming) {
        addr = linphone_call_log_get_from(callLog);
    } else {
        addr = linphone_call_log_get_to(callLog);
    }
    
    NSString *address = nil;
    if (addr != NULL) {
        BOOL useLinphoneAddress = true;
        // contact name
        if (useLinphoneAddress) {
            const char *lDisplayName = linphone_address_get_display_name(addr);
            const char *lUserName = linphone_address_get_username(addr);
            if (lDisplayName)
                address = [NSString stringWithUTF8String:lDisplayName];
            else if (lUserName)
                address = [NSString stringWithUTF8String:lUserName];
        }
    }
    
    if (address != nil) {
        return address;
    }
    
    return nil;
}

- (void) setFrame:(NSRect)frame {
    [self.view setFrame:frame];
    
    [self.scrollViewRecents setFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height - 40)];
    
    [self.callsSegmentControll setFrame:NSMakeRect((frame.size.width - self.callsSegmentControll.frame.size.width)/2, frame.size.height - 30, self.callsSegmentControll.frame.size.width, self.callsSegmentControll.frame.size.height)];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DIALPAD_TEXT_CHANGED" object: nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLinphoneCallUpdate object:nil];
}

@end
