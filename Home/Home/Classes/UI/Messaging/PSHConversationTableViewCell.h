//
//  PSHConverstationTableViewCell.h
//  Home
//
//  Created by Kenny Tang on 6/24/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSHConversationTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *conversationBackgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (nonatomic) BOOL isFromSelf;


@end
