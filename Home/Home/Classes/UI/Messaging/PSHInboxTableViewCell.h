//
//  PSHInboxTableViewCell.h
//  Home
//
//  Created by Kenny Tang on 5/30/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSHInboxTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView * chatImageView;
@property (nonatomic, weak) IBOutlet UILabel * namesLabel;
@property (nonatomic, weak) IBOutlet UILabel * messageLabel;
@property (nonatomic, weak) IBOutlet UILabel * dateLabel;

@end
