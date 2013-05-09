//
//  PSHCommentsViewController.h
//  SocialHome
//
//  Created by Kenny Tang on 4/18/13.
//  Copyright (c) 2013 corgitoergosum.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PSHCommentsViewControllerDelegate;

@interface PSHCommentsViewController : UIViewController

@property (nonatomic, strong) NSString * feedItemGraphID;
@property (nonatomic, weak) id<PSHCommentsViewControllerDelegate> delegate;

@end
