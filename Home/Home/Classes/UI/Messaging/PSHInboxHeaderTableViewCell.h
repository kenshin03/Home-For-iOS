//
//  PSHInboxHeaderTableViewCell.h
//  Home
//
//  Created by Kenny Tang on 6/5/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PSHInboxHeaderTableViewCellDelegate;


@interface PSHInboxHeaderTableViewCell : UITableViewCell

@property (nonatomic, weak) id<PSHInboxHeaderTableViewCellDelegate> delegate;


@end


@protocol PSHInboxHeaderTableViewCellDelegate <NSObject>

- (void)inboxHeaderTableViewCell:(PSHInboxHeaderTableViewCell*)cell didTapOnWritePostButton:(BOOL)tapped;

@end