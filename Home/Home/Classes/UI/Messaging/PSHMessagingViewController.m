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
#import "PSHChatHead.h"
#import "ChatMessage.h"
#import <QuartzCore/QuartzCore.h>

@interface PSHMessagingViewController ()

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
    
    PSHMessagingGestureRecognizer * recognizer = [[PSHMessagingGestureRecognizer alloc] init];
    [self.view addGestureRecognizer:recognizer];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI elements

- (void) initChatHeads {
    
    NSArray * chatsArray = [ChatMessage findAllSortedBy:@"createdDate" ascending:NO];
    if ([chatsArray count] > 0){
        
        // get latest message
        ChatMessage * firstMessage = chatsArray[0];
        
        PSHChatHead * chatHead = [[PSHChatHead alloc] init];
        chatHead.badgeLabel.text = @"1";
        chatHead.badgeLabel.hidden = YES;
        chatHead.badgeImageView.hidden = YES;
        chatHead.tag = kPSHMessagingViewControllerChatHeadTag;
        
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


@end
