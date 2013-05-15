//
//  PSHMenuGestureRecognizer.m
//  Home
//
//  Created by Kenny Tang on 4/22/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import "PSHMenuGestureRecognizer.h"
#import "PSHMenuViewController.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface PSHMenuGestureRecognizer()

@property (nonatomic, strong) UIView * menuViewBeingMoved;
@property (nonatomic) CGRect originalRect;
@property (nonatomic) CGRect originalProfileImageRect;

@end


@implementation PSHMenuGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    
    UIView * menuView = [self.view viewWithTag:kPSHMenuViewControllerMenuButtonViewTag];
    UIView * menuProfileImageView = [self.view viewWithTag:kPSHMenuViewControllerMenuButtonProfileImageViewTag];
    if (CGRectContainsPoint(menuView.frame, touchPoint)){
        [self setState:UIGestureRecognizerStateBegan];
        self.menuViewBeingMoved = menuView;
        self.originalRect = self.menuViewBeingMoved.frame;
        self.originalProfileImageRect = menuProfileImageView.frame;
        
        CGRect destRect = self.menuViewBeingMoved.frame;
        destRect.origin.x += -5.0f;
        destRect.origin.y += -5.0f;
        destRect.size.height = destRect.size.height * 1.1;
        destRect.size.width = destRect.size.width * 1.1;
        
        CGRect profileImageDestRect = menuProfileImageView.frame;
        profileImageDestRect.origin.x += 5.0f;
        profileImageDestRect.origin.y += 5.0f;
        
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            self.menuViewBeingMoved.frame = destRect;
            menuProfileImageView.frame = profileImageDestRect;
            
        } completion:^(BOOL finished) {
            //
        }];
        
        
    }else{
        [self setState:UIGestureRecognizerStateFailed];
        self.menuViewBeingMoved = nil;
    }
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    CGRect menuViewFrame = self.menuViewBeingMoved.frame;
    
    menuViewFrame.origin = CGPointMake(touchPoint.x-44.0f, touchPoint.y-44.0f);
    
    [UIView animateWithDuration:0.1 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.menuViewBeingMoved.frame = menuViewFrame;
        
    } completion:^(BOOL finished) {
        // none
    }];
    [self setState:UIGestureRecognizerStateChanged];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setState:UIGestureRecognizerStateEnded];
    UIView * menuProfileImageView = [self.view viewWithTag:kPSHMenuViewControllerMenuButtonProfileImageViewTag];
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.menuViewBeingMoved.frame = self.originalRect;
        menuProfileImageView.frame = self.originalProfileImageRect;
    } completion:^(BOOL finished) {
        //
    }];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setState:UIGestureRecognizerStateEnded];
    UIView * menuProfileImageView = [self.view viewWithTag:kPSHMenuViewControllerMenuButtonProfileImageViewTag];
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.menuViewBeingMoved.frame = self.originalRect;
        menuProfileImageView.frame = self.originalProfileImageRect;
    } completion:^(BOOL finished) {
        //
    }];
    
}



@end
