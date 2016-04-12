//
//  MoreSection.h
//  ACE
//
//  Created by Karen Muradyan on 4/7/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import "BackgroundedViewController.h"

typedef NS_ENUM (NSUInteger, SelectedSection)
{
    eSettings = 0,
    eResources,
    eVideomail,
    eSelfPreview
};

@protocol MoreSectionViewControllerDelegate <NSObject>

- (void)didPressSection:(SelectedSection)section;

@end


@interface MoreSectionViewController : BackgroundedViewController

@property (weak, nonatomic) id <MoreSectionViewControllerDelegate> delegate;

@end
