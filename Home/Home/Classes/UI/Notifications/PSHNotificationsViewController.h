//
//  PSHNotificationsViewController.h
//  Home
//
//  Created by Kenny Tang on 5/12/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PSHNotificationsViewControllerDelegate;

@interface PSHNotificationsViewController : UIViewController

@property (nonatomic, weak) id<PSHNotificationsViewControllerDelegate> delegate;

@end

@protocol PSHNotificationsViewControllerDelegate <NSObject>

- (void) notificationsViewController:(PSHNotificationsViewController*)vc shouldDismissView:(BOOL)dismiss;

@end
