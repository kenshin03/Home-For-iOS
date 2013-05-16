//
//  PSHMenuViewController.h
//  Home
//
//  Created by Kenny Tang on 4/22/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSInteger const kPSHMenuViewControllerMenuButtonViewTag = 1111;
static NSInteger const kPSHMenuViewControllerMenuButtonProfileImageViewTag = 2222;

@protocol PSHMenuViewControllerDelegate;

@interface PSHMenuViewController : UIViewController

@property (nonatomic, weak) id<PSHMenuViewControllerDelegate> delegate;

- (void) animateHideMenuButtons;
- (void) animateHideLauncher;

@end


@protocol PSHMenuViewControllerDelegate <NSObject>

- (void)menuViewController:(PSHMenuViewController*)vc messagesButtonTapped:(BOOL)tapped;
- (void)menuViewController:(PSHMenuViewController*)vc menuViewTapped:(BOOL)tapped;
- (void)menuViewController:(PSHMenuViewController*)vc reloadButtonTapped:(BOOL)tapped;

- (void)menuViewController:(PSHMenuViewController*)vc viewSwipedToLeft:(BOOL)tapped;
- (void)menuViewController:(PSHMenuViewController*)vc viewSwipedToRight:(BOOL)tapped;


@end