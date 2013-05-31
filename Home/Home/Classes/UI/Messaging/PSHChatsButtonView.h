//
//  PSHChatsButtonView.h
//  Home
//
//  Created by Kenny Tang on 5/28/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PSHChatsButtonViewDelegate;

@interface PSHChatsButtonView : UIView

@property (nonatomic, weak) id<PSHChatsButtonViewDelegate> delegate;

-(void)expandChatHead;
-(void)restoreChatHead;

@end


@protocol PSHChatsButtonViewDelegate <NSObject>

-(void)chatsButton:(PSHChatsButtonView*)buttonView buttonTapped:(BOOL)tapped;

@end
