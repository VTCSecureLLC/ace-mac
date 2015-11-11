//
//  DocView.h
//  ACE
//
//  Created by Norayr Harutyunyan on 11/10/15.
//  Copyright © 2015 Home. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BackgroundedView.h"

typedef enum : NSUInteger {
    DocViewItemRecents,
    DocViewItemContacts,
    DocViewItemDialpad,
    DocViewItemResources,
    DocViewItemSettings,
} DocViewItem;

@protocol DocViewDelegate;

@interface DocView : BackgroundedView

@property (nonatomic, assign) id<DocViewDelegate> delegate;

- (void) selectItemWithDocViewItem:(DocViewItem)docViewItem;

@end

@protocol DocViewDelegate <NSObject>

@optional

- (void) didClickDocViewRecents:(DocView*)docView_;
- (void) didClickDocViewContacts:(DocView*)docView_;
- (void) didClickDocViewDialpad:(DocView*)docView_;
- (void) didClickDocViewResources:(DocView*)docView_;
- (void) didClickDocViewSettings:(DocView*)docView_;


@end