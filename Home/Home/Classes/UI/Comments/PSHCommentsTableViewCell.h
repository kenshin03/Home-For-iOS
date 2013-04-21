//
//  PSHCommentsTableViewCell.h
//  SocialHome
//
//  Created by Kenny Tang on 4/18/13.
//  Copyright (c) 2013 corgitoergosum.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSHCommentsTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel * commentsLabel;
@property (nonatomic, strong) NSString * commentorImageURL;
@property (nonatomic, weak) IBOutlet UIImageView * commentorImageView;
@property (nonatomic, weak) IBOutlet UILabel * timeLabel;
@property (nonatomic, weak) IBOutlet UILabel * likesLabel;
@property (nonatomic, weak) IBOutlet UILabel * commentorNameLabel;


@end
