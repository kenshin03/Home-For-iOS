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
        CGRect backgroundImageViewFrame = self.conversationBackgroundImageView.frame;
        backgroundImageViewFrame.size = CGSizeMake(310.0f, 60.0f);
        backgroundImageViewFrame.origin.x = 20.0f;
        self.conversationBackgroundImageView.frame = backgroundImageViewFrame;
        
        
        CGRect messageLabelRect = self.messageLabel.frame;
        self.messageLabel.textAlignment = NSTextAlignmentRight;
        self.messageLabel.frame = messageLabelRect;
        
//        CGRect backgroundImageViewRect = self.conversationBackgroundImageView.frame;
//        backgroundImageViewRect.origin.x = 10.0f;
//        backgroundImageViewRect.size.height = self.messageLabel.frame.size.height + 20.0f;
//        backgroundImageViewRect.size.width = self.messageLabel.frame.size.width + 20.0f;
//        self.conversationBackgroundImageView.frame = backgroundImageViewRect;
        
        
    }else{
        // align to left, use white bubble
        self.conversationBackgroundImageView.image = [[UIImage imageNamed:@"conversation_bubble_white"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f) resizingMode:UIImageResizingModeStretch];
        CGRect backgroundImageViewFrame = self.conversationBackgroundImageView.frame;
        backgroundImageViewFrame.size = CGSizeMake(310.0f, 60.0f);
        backgroundImageViewFrame.origin.x = 10.0f;
        self.conversationBackgroundImageView.frame = backgroundImageViewFrame;
        
        CGRect messageLabelRect = self.messageLabel.frame;
        self.messageLabel.textAlignment = NSTextAlignmentLeft;
        self.messageLabel.frame = messageLabelRect;
        
        
//        CGRect backgroundImageViewRect = self.conversationBackgroundImageView.frame;
//        backgroundImageViewRect.origin.x = 0.0f;
//        backgroundImageViewRect.size.height = self.messageLabel.frame.size.height + 20.0f;
//        backgroundImageViewRect.size.width = self.messageLabel.frame.size.width + 20.0f;
//        self.conversationBackgroundImageView.frame = backgroundImageViewRect;
        
        
    }
    
}

@end
