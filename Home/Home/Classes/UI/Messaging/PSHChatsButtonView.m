//
//  PSHChatsButtonView.m
//  Home
//
//  Created by Kenny Tang on 5/28/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import "PSHChatsButtonView.h"

@interface PSHChatsButtonView()

@property (nonatomic) CGRect originRect;


@end

@implementation PSHChatsButtonView

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
        UINib *nib = [UINib nibWithNibName:@"PSHChatsButtonView" bundle:nil];
        NSArray *nibArray = [nib instantiateWithOwner:self options:nil];
        self = nibArray[0];
        
        UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        [tapGestureRecognizer addTarget:self action:@selector(inboxButtonTapped:)];
        [self addGestureRecognizer:tapGestureRecognizer];
        
    }
    return self;
}

-(void)chatsButton:(PSHChatsButtonView*)buttonView buttonTapped:(BOOL)tapped {
    if ([self.delegate respondsToSelector:@selector(chatsButton:buttonTapped:)]){
        [self.delegate chatsButton:self buttonTapped:YES];
    }
}


-(void)expandChatHead {
    
    
    CGRect destRect = self.originRect;
    destRect.origin.x += -5.0f;
    destRect.origin.y += -5.0f;
    destRect.size.height = destRect.size.height * 1.1;
    destRect.size.width = destRect.size.width * 1.1;
    
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.frame = destRect;
        
    } completion:^(BOOL finished) {
        [self restoreChatHead];
        [self chatsButton:self buttonTapped:YES];
    }];
}

-(void)restoreChatHead {
    
    CGRect destFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.originRect.size.width, self.originRect.size.height);
    destFrame.origin.x += 5.0f;
    destFrame.origin.y += 5.0f;
    destFrame.size.height = self.originRect.size.height;
    destFrame.size.width = self.originRect.size.width;
    
    
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.frame = destFrame;
        
    } completion:^(BOOL finished) {
        //
    }];
}



- (IBAction)inboxButtonTapped:(id)sender {
    self.originRect = self.frame;
    [self expandChatHead];
}



@end
