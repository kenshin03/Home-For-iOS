//
//  PSHNotificationsTableViewCell.h
//  Home
//
//  Created by Kenny Tang on 5/13/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSHNotificationsTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView * sourceImageView;
@property (nonatomic, weak) IBOutlet UILabel * sourceNameLabel;
@property (nonatomic, weak) IBOutlet UILabel * notificationLabel;

@end
