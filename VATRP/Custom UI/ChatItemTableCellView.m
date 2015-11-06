//
//  ChatItemTableCellView.m
//  ACE
//
//  Created by Norayr Harutyunyan on 10/22/15.
//  Copyright © 2015 Home. All rights reserved.
//

#import "ChatItemTableCellView.h"
#import "NSImage+Merge.h"

@interface ChatItemTableCellView () {
    LinphoneChatMessage* chat;
    NSImageView *messageImageView;
    NSImageView *imageViewBubble;
    NSImageView *imageViewStatus;
    NSTextView *labelChat;
    NSTextField *labelDate;
}

@end

@implementation ChatItemTableCellView


static const CGFloat CELL_MIN_HEIGHT = 50.0f;
static const CGFloat CELL_MIN_WIDTH = 150.0f;
// static const CGFloat CELL_MAX_WIDTH = 320.0f;
static const CGFloat CELL_MESSAGE_X_MARGIN = 26.0f + 10.0f;
static const CGFloat CELL_MESSAGE_Y_MARGIN = 36.0f;
static const CGFloat CELL_FONT_SIZE = 17.0f;
static const CGFloat CELL_IMAGE_HEIGHT = 100.0f;
static const CGFloat CELL_IMAGE_WIDTH = 100.0f;
static NSFont *CELL_FONT = nil;

- (void) awakeFromNib {
    [super awakeFromNib];

    messageImageView = nil;
    imageViewBubble = nil;
    imageViewStatus = nil;
    labelChat = nil;
    
    [self.layer setBackgroundColor:[NSColor greenColor].CGColor];
}

- (id) initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    
    if (self) {
        messageImageView = nil;
        imageViewBubble = nil;
    }
    
    return self;
}

- (void)setChatMessage:(LinphoneChatMessage *)message {
    if (message != self->chat) {
        if (self->chat) {
            linphone_chat_message_unref(self->chat);
            linphone_chat_message_set_user_data(self->chat, NULL);
            linphone_chat_message_cbs_set_msg_state_changed(linphone_chat_message_get_callbacks(self->chat), NULL);
        }
        
        self->chat = message;
        
        BOOL outgoing = linphone_chat_message_is_outgoing(chat);

        NSString *str_outgoing = [NSString stringWithFormat:@"%@", outgoing ? @"Outgoing" : @"Incoming"];
        
        NSImage *image1 = [NSImage imageNamed:[NSString stringWithFormat:@"message%@BubbleTop.png", str_outgoing]];
        NSImage *image2 = [NSImage imageNamed:[NSString stringWithFormat:@"message%@BubbleMiddle.png", str_outgoing]];
        image2 = [image2 resizableImageWithTopCap:1 bottomCap:0];
        NSImage *image3 = [NSImage imageNamed:[NSString stringWithFormat:@"message%@BubbleBottom.png", str_outgoing]];
        
        CGImageRef maskRef = [self nsImageToCGImageRef:image2];
        
        CGFloat height = [ChatItemTableCellView height:self->chat width:220];
        height -= CELL_MESSAGE_Y_MARGIN;
        
        image2 = [[NSImage alloc] initWithCGImage:maskRef size:CGSizeMake(267, height > 1 ? height : 1)];
        
        NSImage *image = [NSImage imageByTilingImages:@[image1, image2, image3]
                                             spacingX:0
                                             spacingY:0
                                           vertically:YES];

        if (!imageViewBubble) {
            imageViewBubble = [[NSImageView alloc] initWithFrame:CGRectMake(0, 0, 267, height)];
            [self addSubview:imageViewBubble];

            labelChat = [[NSTextView alloc] initWithFrame:CGRectMake(0, 0, 220, height)];
            [labelChat setEditable:NO];
            [labelChat setWantsLayer:YES];
            [labelChat setDrawsBackground:YES];
            [labelChat setBackgroundColor:[NSColor clearColor]];
            [imageViewBubble addSubview:labelChat];

            labelDate = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, 220, height)];
            [labelDate setWantsLayer:YES];
            [labelDate setDrawsBackground:YES];
            [labelDate setBackgroundColor:[NSColor clearColor]];
            [labelDate setBordered:NO];
            [labelDate setFont:[NSFont fontWithName:@"Helvetica Neue" size:10]];
            [labelDate setTextColor:[NSColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0]];
            
            [imageViewBubble addSubview:labelDate];
            
            imageViewStatus = [[NSImageView alloc] initWithFrame:CGRectMake(0, 0, 267, 10)];
            [imageViewBubble addSubview:imageViewStatus];
        }

        imageViewBubble.frame = CGRectMake(outgoing ? self.frame.size.width - 270 : 5, 0, 267, image.size.height);
        labelChat.frame = CGRectMake(outgoing ? 5 : 15, image.size.height - height, 220, height);
        labelDate.frame = CGRectMake(outgoing ? 5 : 40, 5, 220, 12);
        [labelDate.cell setAlignment:outgoing ? NSTextAlignmentLeft : NSTextAlignmentRight];
        imageViewStatus.frame = CGRectMake(outgoing ? 230 : 245, 5, 18.0/1.5, 17.0/1.5);
        
        [imageViewBubble setWantsLayer:YES];
        [imageViewBubble.layer setBackgroundColor:[NSColor clearColor].CGColor];
        [imageViewBubble setImage:image];
        
        if (self->chat) {
            linphone_chat_message_ref(self->chat);
            linphone_chat_message_set_user_data(self->chat, (void *)CFBridgingRetain(self));
            linphone_chat_message_cbs_set_msg_state_changed(linphone_chat_message_get_callbacks(self->chat),
                                                            message_status);
        }
        
        [self update];
    }
}

+ (NSString *)decodeTextMessage:(const char *)text {
    NSString *decoded = [NSString stringWithUTF8String:text];
    if (decoded == nil) {
        // couldn't decode the string as UTF8, do a lossy conversion
        decoded = [NSString stringWithCString:text encoding:NSASCIIStringEncoding];
        if (decoded == nil) {
            decoded = @"(invalid string)";
        }
    }
    return decoded;
}

- (void)update {
    if (chat == nil) {
        NSLog(@"Cannot update chat room cell: null chat");
        return;
    }
    
    const char *url = linphone_chat_message_get_external_body_url(chat);
    const char *text = linphone_chat_message_get_text(chat);
    BOOL is_external =
    (url && (strstr(url, "http") == url)) || linphone_chat_message_get_file_transfer_information(chat);
    NSString *localImage = [LinphoneManager getMessageAppDataForKey:@"localimage" inMessage:chat];
    
    // this is an image (either to download or already downloaded)
    if (is_external || localImage) {
        if (localImage) {
            if (messageImageView.image == nil) {
                NSURL *imageUrl = [NSURL URLWithString:localImage];
                labelChat.hidden = YES;
                __block LinphoneChatMessage *achat = chat;
            }
        } else {
            labelChat.hidden = YES;
        }
        // simple text message
    } else {
        [labelChat setHidden:FALSE];
        if (text) {
            NSString *nstext = [ChatItemTableCellView decodeTextMessage:text];
            
            /* We need to use an attributed string here so that data detector don't mess
             * with the text style. See http://stackoverflow.com/a/20669356 */
            
            [labelChat setTextColor:[NSColor colorWithDeviceRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0]];
            [labelChat setFont:CELL_FONT];
            labelChat.string = nstext;;
        } else {
            labelChat.string = @"";
        }
        messageImageView.hidden = YES;
    }
    
    // Date
    time_t chattime = linphone_chat_message_get_time(chat);
    NSDate *message_date = (chattime == 0) ? [[NSDate alloc] init] : [NSDate dateWithTimeIntervalSince1970:chattime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSLocale *locale = [NSLocale currentLocale];
    [dateFormatter setLocale:locale];
    [labelDate setStringValue:[dateFormatter stringFromDate:message_date]];
    
    LinphoneChatMessageState state = linphone_chat_message_get_state(chat);
    BOOL outgoing = linphone_chat_message_is_outgoing(chat);
    
    if (!outgoing) {
//        [imageViewStatus setAccessibilityValue:@"incoming"];
        imageViewStatus.hidden = TRUE; // not useful for incoming chats..
    } else if (state == LinphoneChatMessageStateInProgress) {
        [imageViewStatus setImage:[NSImage imageNamed:@"chat_message_inprogress.png"]];
//        [statusImage setAccessibilityValue:@"in progress"];
        imageViewStatus.hidden = FALSE;
    } else if (state == LinphoneChatMessageStateDelivered || state == LinphoneChatMessageStateFileTransferDone) {
        [imageViewStatus setImage:[NSImage imageNamed:@"chat_message_delivered.png"]];
        [imageViewStatus setAccessibilityValue:@"delivered"];
        imageViewStatus.hidden = FALSE;
    } else {
        [imageViewStatus setImage:[NSImage imageNamed:@"chat_message_not_delivered.png"]];
        [imageViewStatus setAccessibilityValue:@"not delivered"];
        imageViewStatus.hidden = FALSE;
        
//        NSAttributedString *resend_text =
//        [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Resend", @"Resend")
//                                        attributes:@{NSForegroundColorAttributeName : [UIColor redColor]}];
//        [dateLabel setAttributedText:resend_text];
    }

//    if (outgoing) {
//        [messageText setAccessibilityLabel:@"Outgoing message"];
//    } else {
//        [messageText setAccessibilityLabel:@"Incoming message"];
//    }
}



#pragma mark - State changed handling
static void message_status(LinphoneChatMessage *msg, LinphoneChatMessageState state) {
    ChatItemTableCellView *thiz = (__bridge ChatItemTableCellView *)linphone_chat_message_get_user_data(msg);
    NSLog(@"State for message [%p] changed to %s", msg, linphone_chat_message_state_to_string(state));
    if (linphone_chat_message_get_file_transfer_information(msg) != NULL) {
        if (state == LinphoneChatMessageStateDelivered || state == LinphoneChatMessageStateNotDelivered) {
            // we need to refresh the tableview because the filetransfer delegate unreffed
            // the chat message before state was LinphoneChatMessageStateFileTransferDone -
            // if we are coming back from another view between unreffing and change of state,
            // the transient message will not be found and it will not appear in the list of
            // message, so we must refresh the table when we change to this state to ensure that
            // all transient messages apppear
            //		ChatRoomViewController *controller = DYNAMIC_CAST(
            //			[[PhoneMainView instance] changeCurrentView:[ChatRoomViewController compositeViewDescription]
            // push:TRUE],
            //			ChatRoomViewController);
            //		[controller.tableController setChatRoom:linphone_chat_message_get_chat_room(msg)];
            // This is breaking interface too much, it must be fixed in file transfer cb.. meanwhile, disabling it.
        }
    }
    
    [thiz update];
}

+ (CGSize)viewSize:(LinphoneChatMessage *)chat width:(int)width {
    CGSize messageSize;
    const char *url = linphone_chat_message_get_external_body_url(chat);
    const char *text = linphone_chat_message_get_text(chat);
    NSString *messageText = text ? [ChatItemTableCellView decodeTextMessage:text] : @"";
    if (url == nil && linphone_chat_message_get_file_transfer_information(chat) == NULL) {
        if (CELL_FONT == nil) {
            CELL_FONT = [NSFont systemFontOfSize:CELL_FONT_SIZE];
        }
        
        
        
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:CELL_FONT, NSFontAttributeName, nil];
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:messageText attributes:attributes];
        
        CGFloat width = 220; // whatever your desired width is
        CGRect rect = [attributedString boundingRectWithSize:CGSizeMake(width, 10000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
        messageSize = rect.size;
    } else {
        messageSize = CGSizeMake(CELL_IMAGE_WIDTH, CELL_IMAGE_HEIGHT);
    }
    messageSize.height += CELL_MESSAGE_Y_MARGIN;
    if (messageSize.height < CELL_MIN_HEIGHT)
        messageSize.height = CELL_MIN_HEIGHT;
    messageSize.width += CELL_MESSAGE_X_MARGIN;
    if (messageSize.width < CELL_MIN_WIDTH)
        messageSize.width = CELL_MIN_WIDTH;
    return messageSize;
}

+ (CGFloat)height:(LinphoneChatMessage *)chatMessage width:(int)width {
    return [ChatItemTableCellView viewSize:chatMessage width:width].height;
}

- (CGImageRef)nsImageToCGImageRef:(NSImage*)image;
{
    NSSize imageSize = [image size];
    
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL, imageSize.width, imageSize.height, 8, 0, [[NSColorSpace genericRGBColorSpace] CGColorSpace], kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:bitmapContext flipped:NO]];
    [image drawInRect:NSMakeRect(0, 0, imageSize.width, imageSize.height) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
    [NSGraphicsContext restoreGraphicsState];
    
    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
    CGContextRelease(bitmapContext);
    return cgImage;
}

@end
