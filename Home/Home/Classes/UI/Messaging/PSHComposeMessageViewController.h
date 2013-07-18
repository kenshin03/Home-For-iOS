//
//  PSHComposeMessageViewController.h
//  Home
//
//  Created by Kenny Tang on 6/5/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PSHComposeMessageViewControllerDelegate;


@interface PSHComposeMessageViewController : UIViewController

@property (nonatomic, weak) id<PSHComposeMessageViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString * ownGraphID;

@end



@protocol PSHComposeMessageViewControllerDelegate <NSObject>

- (void)composeMessageViewController:(PSHComposeMessageViewController*)vc dismissComposeMessage:(BOOL)dismiss;

@end