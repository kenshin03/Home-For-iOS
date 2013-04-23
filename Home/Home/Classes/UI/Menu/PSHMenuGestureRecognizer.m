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

@end


@implementation PSHMenuGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    
    UIView * menuView = [self.view viewWithTag:kPSHMenuViewControllerMenuButtonViewTag];
    if (CGRectContainsPoint(menuView.frame, touchPoint)){
        [self setState:UIGestureRecognizerStateBegan];
        self.menuViewBeingMoved = menuView;
        
    }else{
        [self setState:UIGestureRecognizerStateFailed];
        self.menuViewBeingMoved = nil;
    }
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    CGRect menuViewFrame = self.menuViewBeingMoved.frame;
    
    menuViewFrame.origin = CGPointMake(touchPoint.x-self.menuViewBeingMoved.frame.size.width/1.1, touchPoint.y-self.menuViewBeingMoved.frame.size.height/1.1);
    
    [UIView animateWithDuration:0.1 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.menuViewBeingMoved.frame = menuViewFrame;
        
    } completion:^(BOOL finished) {
        // none
    }];
    [self setState:UIGestureRecognizerStateChanged];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setState:UIGestureRecognizerStateEnded];
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setState:UIGestureRecognizerStateEnded];
    
}



@end
