//
//  PSHConverstationTableViewCell.m
//  Home
//
//  Created by Kenny Tang on 6/24/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import "PSHConversationTableViewCell.h"

@implementation PSHConversationTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setIsFromSelf:(BOOL)isFromSelf{
    _isFromSelf = isFromSelf;
    if (isFromSelf){
        // align to right, use blue bubble
        self.conversationBackgroundImageView.image = [[UIImage imageNamed:@"conversation_bubble_blue"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f) resizingMode:UIImageResizingModeStretch];
        
        CGRect backgroundImageViewRect = self.conversationBackgroundImageView.frame;
        backgroundImageViewRect.origin.x = 40.0f;
        self.conversationBackgroundImageView.frame = backgroundImageViewRect;
        
        CGRect messageLabelRect = self.messageLabel.frame;
        messageLabelRect.origin.x = 40.0f;
        self.messageLabel.frame = messageLabelRect;
        
    }else{
        // align to left, use white bubble
        self.conversationBackgroundImageView.image = [[UIImage imageNamed:@"conversation_bubble_white"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f) resizingMode:UIImageResizingModeStretch];
        
        CGRect backgroundImageViewRect = self.conversationBackgroundImageView.frame;
        backgroundImageViewRect.origin.x = 0.0f;
        self.conversationBackgroundImageView.frame = backgroundImageViewRect;
        
        CGRect messageLabelRect = self.messageLabel.frame;
        messageLabelRect.origin.x = 0.0f;
        self.messageLabel.frame = messageLabelRect;
        
    }
    
}

@end
