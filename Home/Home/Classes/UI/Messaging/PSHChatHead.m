//
//  PSHChatHead.m
//  Home
//
//  Created by Kenny Tang on 5/14/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import "PSHChatHead.h"

@interface PSHChatHead()

@property (nonatomic) CGRect originRect;
@property (nonatomic) CGRect originalProfileImageRect;

@end

@implementation PSHChatHead

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)init{
    self = [super init];
    if (self){
        
        UINib *nib = [UINib nibWithNibName:@"PSHChatHead" bundle:nil];
        NSArray *nibArray = [nib instantiateWithOwner:self options:nil];
        self = nibArray[0];
        self.originRect = self.frame;
        self.originalProfileImageRect = self.profileImageView.frame;
    }
    return self;
}



-(void)expandChatHead {
    
    
    CGRect destRect = self.originRect;
    destRect.origin.x += -5.0f;
    destRect.origin.y += -5.0f;
    destRect.size.height = destRect.size.height * 1.1;
    destRect.size.width = destRect.size.width * 1.1;
    
    CGRect profileImageDestRect = self.originalProfileImageRect;
    profileImageDestRect.origin.x += 5.0f;
    profileImageDestRect.origin.y += 5.0f;
    
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.frame = destRect;
        self.profileImageView.frame = profileImageDestRect;
        
    } completion:^(BOOL finished) {
        //
    }];
}

-(void)restoreChatHead {
    
    CGRect destFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.originRect.size.width, self.originRect.size.height);
    destFrame.origin.x += 5.0f;
    destFrame.origin.y += 5.0f;
    destFrame.size.height = self.originRect.size.height;
    destFrame.size.width = self.originRect.size.width;
    
    CGRect profileFrame = CGRectMake(self.profileImageView.frame.origin.x, self.profileImageView.frame.origin.y, self.originalProfileImageRect.size.width, self.originalProfileImageRect.size.height);
    
    CGRect profileImageDestRect = self.originalProfileImageRect;
    profileImageDestRect.origin.x -= 10.0f;
    profileImageDestRect.origin.y -= 10.0f;
    
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.frame = destFrame;
        self.profileImageView.frame = profileFrame;
        
    } completion:^(BOOL finished) {
        //
    }];
    
}


@end
