//
//  PSHMessagingViewController.h
//  Home
//
//  Created by Kenny Tang on 5/14/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSInteger const kPSHMessagingViewControllerChatHeadTag = 1111;
static NSInteger const kPSHMessagingViewControllerInboxButtonTag = 2222;

@protocol PSHMessagingViewControllerDelegate;


@interface PSHMessagingViewController : UIViewController

@property (nonatomic, weak) id<PSHMessagingViewControllerDelegate> delegate;

@end


@protocol PSHMessagingViewControllerDelegate <NSObject>

- (void)messagingViewController:(PSHMessagingViewController*)vc messagingDissmissed:(BOOL)dismissed;

@end