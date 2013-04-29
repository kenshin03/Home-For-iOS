//
//  PSHMenuViewController.h
//  Home
//
//  Created by Kenny Tang on 4/22/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSInteger const kPSHMenuViewControllerMenuButtonViewTag = 1111;

@protocol PSHMenuViewControllerDelegate;

@interface PSHMenuViewController : UIViewController

@property (nonatomic, weak) id<PSHMenuViewControllerDelegate> delegate;

- (void) animateHideMenuButtons;


@end


@protocol PSHMenuViewControllerDelegate <NSObject>

- (void)menuViewController:(PSHMenuViewController*)vc menuViewTapped:(BOOL)tapped;
- (void)menuViewController:(PSHMenuViewController*)vc reloadButtonTapped:(BOOL)tapped;

- (void)menuViewController:(PSHMenuViewController*)vc viewSwipedToLeft:(BOOL)tapped;
- (void)menuViewController:(PSHMenuViewController*)vc viewSwipedToRight:(BOOL)tapped;


@end