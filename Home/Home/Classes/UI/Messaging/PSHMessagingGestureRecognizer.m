//
//  PSHMessagingGestureRecognizer.m
//  Home
//
//  Created by Kenny Tang on 5/15/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import "PSHMessagingGestureRecognizer.h"
#import "PSHMessagingViewController.h"
#import "PSHChatHead.h"
#import "PSHChatsButtonView.h"
#import <UIKit/UIGestureRecognizerSubclass.h>


@interface PSHMessagingGestureRecognizer()

@property (nonatomic, weak) UIView * viewBeingMoved;
@property (nonatomic) CGRect originalRect;

@property (nonatomic) CGRect topScreenLeftHalf;
@property (nonatomic) CGRect topScreenRightHalf;
@property (nonatomic) CGRect bottomScreenLeftHalf;
@property (nonatomic) CGRect bottomScreenRightHalf;


@end



@implementation PSHMessagingGestureRecognizer




- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    [self setState:UIGestureRecognizerStateBegan];
    
    PSHChatHead * chatHeadView = (PSHChatHead*)[self.view viewWithTag:kPSHMessagingViewControllerChatHeadTag];
    PSHChatsButtonView * chatButtonView = (PSHChatsButtonView*) [self.view viewWithTag:kPSHMessagingViewControllerInboxButtonTag];
    
    CGRect viewFrame = self.view.frame;
    self.topScreenLeftHalf = CGRectMake(viewFrame.origin.x, viewFrame.origin.y, viewFrame.size.width/2, viewFrame.size.height/2);
    self.topScreenRightHalf = CGRectMake(viewFrame.size.width/2, viewFrame.origin.y, viewFrame.size.width/2, viewFrame.size.height/2);
    
    self.bottomScreenLeftHalf = CGRectMake(viewFrame.origin.x, viewFrame.size.height/2, viewFrame.size.width/2, viewFrame.size.height/2);
    self.bottomScreenRightHalf = CGRectMake(viewFrame.size.width/2, viewFrame.size.height/2, viewFrame.size.width/2, viewFrame.size.height/2);
    
    if (CGRectContainsPoint(chatHeadView.frame, touchPoint)){
        [self setState:UIGestureRecognizerStateBegan];
        self.viewBeingMoved = chatHeadView;
        self.originalRect = self.viewBeingMoved.frame;
        
    }else if (CGRectContainsPoint(chatButtonView.frame, touchPoint)){
            [self setState:UIGestureRecognizerStateBegan];
            self.viewBeingMoved = chatButtonView;
            self.originalRect = self.viewBeingMoved.frame;
        
    }else{
        [self setState:UIGestureRecognizerStateFailed];
        self.viewBeingMoved = nil;
    }
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    CGRect menuViewFrame = self.viewBeingMoved.frame;
    
    menuViewFrame.origin = CGPointMake(touchPoint.x-44.0f, touchPoint.y-44.0f);
    
    [UIView animateWithDuration:0.1 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.viewBeingMoved.frame = menuViewFrame;
        
    } completion:^(BOOL finished) {
        // none
    }];
    [self setState:UIGestureRecognizerStateChanged];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setState:UIGestureRecognizerStateEnded];
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesCancelled");
    [self setState:UIGestureRecognizerStateEnded];
    [self snapChatHeadInPlace];
    
}


- (void) snapChatHeadInPlace {
    
    CGRect destFrame = self.viewBeingMoved.frame;
    
    if (CGRectContainsPoint(self.topScreenLeftHalf, self.viewBeingMoved.frame.origin)){
        
        destFrame.origin.x = 0.0f;
        destFrame.origin.y = 0.0f;
        
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.viewBeingMoved.frame = destFrame;
        } completion:^(BOOL finished) {
            //
        }];
        
    }else if (CGRectContainsPoint(self.topScreenRightHalf, self.viewBeingMoved.frame.origin)){
        
        destFrame.origin.x = self.view.frame.size.width-self.viewBeingMoved.frame.size.width;
        destFrame.origin.y = 0.0f;
        
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.viewBeingMoved.frame = destFrame;
        } completion:^(BOOL finished) {
            //
        }];
        
    }else if (CGRectContainsPoint(self.bottomScreenLeftHalf, self.viewBeingMoved.frame.origin)){
        
        destFrame.origin.x = 0.0;
        destFrame.origin.y = self.view.frame.size.height-self.viewBeingMoved.frame.size.height;
        
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.viewBeingMoved.frame = destFrame;
        } completion:^(BOOL finished) {
            //
        }];
        
    }else if (CGRectContainsPoint(self.bottomScreenRightHalf, self.viewBeingMoved.frame.origin)){
        
        destFrame.origin.x = self.view.frame.size.width-self.viewBeingMoved.frame.size.width;
        destFrame.origin.y = self.view.frame.size.height-self.viewBeingMoved.frame.size.height;
        
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.viewBeingMoved.frame = destFrame;
        } completion:^(BOOL finished) {
            //
        }];
    }else{
        
    }
}




@end
