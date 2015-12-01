//
//  ContactTableCellView.m
//  ACE
//
//  Created by User on 24/11/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "ContactTableCellView.h"

@interface ContactTableCellView () {
    NSTrackingArea *_trackingArea;
    NSEvent *event;
}

@end

@implementation ContactTableCellView

- (void)awakeFromNib {
    [self createTrackingArea];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

#pragma mark - buttons actions

- (IBAction)onEditClick:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickEditButton:)]) {
        [_delegate didClickEditButton:self];
    }
}

- (IBAction)onDeleteClick:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickDeleteButton:)]) {
        [_delegate didClickDeleteButton:self];
    }
}

- (void)hideButtons:(BOOL)yesNo {
    self.editButton.hidden = yesNo;
    self.deleteButton.hidden = yesNo;
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
    [self hideButtons:NO];
}

- (void)mouseExited:(NSEvent *)theEvent {
    [self hideButtons:YES];
}

@end
