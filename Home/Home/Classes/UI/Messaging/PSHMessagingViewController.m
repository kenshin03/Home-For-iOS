//
//  PSHMessagingViewController.m
//  Home
//
//  Created by Kenny Tang on 5/14/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import "PSHMessagingViewController.h"
#import "PSHMessagingGestureRecognizer.h"
#import "PSHFacebookDataService.h"
#import "PSHFacebookXMPPService.h"
#import "PSHChatHeadDismissButton.h"
#import "PSHChatHead.h"
#import "ChatMessage.h"
#import <QuartzCore/QuartzCore.h>

@interface PSHMessagingViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic) BOOL isDismissButtonShown;
@property (nonatomic, weak) PSHChatHeadDismissButton * dismissButton;
@property (nonatomic) CGRect dismissButtonBackgroundImageOriginalRect;
@property (nonatomic, strong) PSHMessagingGestureRecognizer * recognizer;
@property (nonatomic, strong) PSHChatHead * chatHead;
@end

@implementation PSHMessagingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initChatHeads];
    [self initDismissButton];
    self.isDismissButtonShown = NO;
    
    self.recognizer = [[PSHMessagingGestureRecognizer alloc] init];
    self.recognizer.delegate = self;
    [self.recognizer addTarget:self action:@selector(menuGestureRecognizerAction:)];
    [self.view addGestureRecognizer:self.recognizer];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
//    [self removeObserver:self forKeyPath:@"frame.origin.x"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI elements

- (void) initDismissButton {
    PSHChatHeadDismissButton * dismissButton = [[PSHChatHeadDismissButton alloc] init];
    dismissButton.frame = CGRectMake(100.0f, self.view.frame.size.height, dismissButton.frame.size.width, dismissButton.frame.size.height);
    [self.view addSubview:dismissButton];
    
    self.dismissButton = dismissButton;
    self.dismissButtonBackgroundImageOriginalRect = dismissButton.backgroundImageView.frame;
}

- (void) initChatHeads {
    
    NSSortDescriptor * createdDateSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdDate" ascending:YES];
    
    NSPredicate * nonHiddenFilter = [NSPredicate predicateWithFormat:@"hideFromView = %@", @(0)];
    NSFetchRequest * chatsRequest = [ChatMessage requestAllWithPredicate:nonHiddenFilter];
    chatsRequest.sortDescriptors = @[createdDateSortDescriptor];
    
    NSArray * chatsArray = [ChatMessage executeFetchRequest:chatsRequest];
    if ([chatsArray count] > 0){
        
        // get latest message
        ChatMessage * firstMessage = chatsArray[0];
        
        PSHChatHead * chatHead = [[PSHChatHead alloc] init];
        chatHead.badgeLabel.text = @"1";
        chatHead.badgeLabel.hidden = YES;
        chatHead.badgeImageView.hidden = YES;
        chatHead.tag = kPSHMessagingViewControllerChatHeadTag;
        [chatHead addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        self.chatHead = chatHead;
        
        NSString * fromGraphID = firstMessage.fromGraphID;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            PSHFacebookDataService * dataService = [PSHFacebookDataService sharedService];
            [dataService fetchSourceCoverImageURLFor:fromGraphID success:^(NSString * coverImageURL, NSString * avartarImageURL) {
                
                UIImage * fromImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avartarImageURL]]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    chatHead.profileImageView.clipsToBounds = YES;
                    chatHead.profileImageView.autoresizesSubviews = YES;
                    [chatHead.profileImageView.layer setCornerRadius:40.0f];
                    [chatHead.profileImageView.layer setMasksToBounds:YES];
                    
                    chatHead.profileImageView.image = fromImage;
//
                    // http://developer.apple.com/library/ios/#documentation/2ddrawing/conceptual/drawingprintingios/BezierPaths/BezierPaths.html
                    
                    CGPoint startPosPoint = CGPointMake(300.0f, 100.0f);
                    CGPoint endPosPoint = CGPointMake(startPosPoint.x, startPosPoint.y+80.0f);
                    chatHead.frame = CGRectMake(startPosPoint.x-40.0f, endPosPoint.y-40.0f, 80.0f, 80.0f);
                    [self.view addSubview:chatHead];
                    
                    UIBezierPath *movePath = [UIBezierPath bezierPath];
                    CGPoint ctlPoint = CGPointMake(100.0f, 150.0f);
                    [movePath moveToPoint:startPosPoint];
                    [movePath addQuadCurveToPoint:endPosPoint
                                     controlPoint:ctlPoint];
                    
                    CAKeyframeAnimation *moveAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
                    moveAnim.path = movePath.CGPath;
                    moveAnim.duration = .5f;
                    moveAnim.fillMode = kCAFillModeForwards;
                    moveAnim.removedOnCompletion = YES;
                    moveAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                    [chatHead.layer addAnimation:moveAnim forKey:@"appear"];
                    
                    
                    double delayInSeconds = 0.5;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        chatHead.badgeLabel.hidden = NO;
                        chatHead.badgeImageView.hidden = NO;
                        [chatHead.layer removeAllAnimations];
                    });
                });
            }];
        });
    }
}

#pragma mark - UIGestureRecognizer

- (void) menuGestureRecognizerAction:(PSHMessagingGestureRecognizer*)recognizer {
    
//    CGRect chatHeadFrame = [self.view convertRect:self.chatHead.frame fromView:self.chatHead.superview];
    
    if (recognizer.state == UIGestureRecognizerStateBegan){
        
        if (!self.isDismissButtonShown){
            [self animateShowDismissButton];
        }
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged){
        
        if (!self.isDismissButtonShown){
            [self animateShowDismissButton];
        }
        
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        
        if (CGRectContainsRect(self.dismissButton.frame, self.chatHead.frame)){
            [self removeChatFromMessagingView];
        }else{
            [recognizer snapChatHeadInPlace];
        }

        if (self.isDismissButtonShown){
            [self animateHideDismissButton];
        }
        
    } else if (recognizer.state == UIGestureRecognizerStateFailed){
        
        if (self.isDismissButtonShown){
            [self animateHideDismissButton];
        }
        
    }
}

#pragma mark - Dismiss Button handling

- (void) animateShowDismissButton {
    
    self.isDismissButtonShown = YES;
    CGRect destFrame = self.dismissButton.frame;
    destFrame.origin.y = self.view.frame.size.height - self.dismissButton.frame.size.height*1.2;
    
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.dismissButton.frame = destFrame;
        
    } completion:^(BOOL finished) {
        //
    }];
    
}

- (void) animateHideDismissButton {
    
    CGRect destFrame = self.dismissButton.frame;
    destFrame.origin.y = self.view.frame.size.height;
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.dismissButton.frame = destFrame;
        
    } completion:^(BOOL finished) {
        //
        self.isDismissButtonShown = NO;
    }];
    
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    CGRect newFrame = [[object valueForKeyPath:keyPath] CGRectValue];
    
    float diffXFromDismissButton = abs(newFrame.origin.x - self.dismissButton.frame.origin.x);
    float diffYFromDismissButton = abs(newFrame.origin.y - self.dismissButton.frame.origin.y);
    float diffTotal = diffXFromDismissButton + diffYFromDismissButton;
    
    // distance from dismiss button small than 300px, start taking notice
    float invertDiff = 300 - diffTotal;
    double proximity = (0) + (invertDiff-0.0f)*(10-(0))/(30.0f-0.0f);
    
    if ((proximity > 0.0f) && (proximity < 30.0f)){
        
        double widthHeightGrowth = (0) + (proximity-0.0f)*(35-(0))/(30.0f-0.0f);
//        NSLog(@"widthHeightGrowth: %f", widthHeightGrowth);
        
        double posAdjustment = (0) + (proximity-0.0f)*(17-(0))/(30.0f-0.0f);
//        NSLog(@"posAdjustment: %f", posAdjustment);
        
        CGRect dismissDestFrame = self.dismissButton.backgroundImageView.frame;
        dismissDestFrame.origin.x = self.dismissButtonBackgroundImageOriginalRect.origin.x - posAdjustment;
        dismissDestFrame.origin.y = self.dismissButtonBackgroundImageOriginalRect.origin.y - posAdjustment;
        dismissDestFrame.size.width = self.dismissButtonBackgroundImageOriginalRect.size.width + widthHeightGrowth;
        dismissDestFrame.size.height = self.dismissButtonBackgroundImageOriginalRect.size.height + widthHeightGrowth;
        
        self.dismissButton.backgroundImageView.frame = dismissDestFrame;
        
        
    }else if (proximity < 0.0f){
        self.dismissButton.backgroundImageView.frame = self.dismissButtonBackgroundImageOriginalRect;
    }
}


- (void) removeChatFromMessagingView {
    // hide chathead
    CGRect destFrame = self.chatHead.frame;
    destFrame.origin.y = destFrame.origin.y + 100.0f;
    
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.chatHead.alpha = 0.0f;
        self.chatHead.frame = destFrame;
        
    } completion:^(BOOL finished) {
        [self.chatHead removeFromSuperview];
        
        // reload this page
        if ([self.delegate respondsToSelector:@selector(messagingViewController:messagingDissmissed:)]){
            [self.delegate messagingViewController:self messagingDissmissed:YES];
        }
    }];
    
}

@end
