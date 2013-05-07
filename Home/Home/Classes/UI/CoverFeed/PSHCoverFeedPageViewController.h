//
//  PSHCoverFeedPageViewController.h
//  SocialHome
//
//  Created by Kenny Tang on 4/14/13.
//  Copyright (c) 2013 corgitoergosum.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedItem.h"

@protocol PSHCoverFeedPageViewControllerDelegate;


@interface PSHCoverFeedPageViewController : UIViewController


@property (nonatomic, strong) NSString * feedType;
@property (nonatomic, strong) NSString * feedItemGraphID;
@property (nonatomic, strong) NSString * messageLabelString;
@property (nonatomic, strong) NSString * infoLabelString;
@property (nonatomic, strong) NSString * imageURLString;

@property (nonatomic) NSInteger likesCount;
@property (nonatomic) NSInteger commentsCount;
@property (nonatomic, strong) NSString * lastestCommentatorsString;
@property (nonatomic) BOOL likedByMe;


@property (nonatomic, strong) NSString * sourceName;
@property (nonatomic, strong) NSString * sourceAvartarImageURL;

@property (nonatomic) NSInteger currentIndex;

@property (nonatomic) id<PSHCoverFeedPageViewControllerDelegate> delegate;

- (void) animateShowActionsPanelView;

@end


@protocol PSHCoverFeedPageViewControllerDelegate <NSObject>

- (void)coverfeedPageViewController:(PSHCoverFeedPageViewController*)vc mainViewTapped:(BOOL)tapped;
- (void)coverfeedPageViewController:(PSHCoverFeedPageViewController*)vc feedID:(NSString*)feedID unliked:(BOOL)uniked;


@end

