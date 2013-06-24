//
//  PSHCoverFeedPageViewController.m
//  SocialHome
//
//  Created by Kenny Tang on 4/14/13.
//  Copyright (c) 2013 corgitoergosum.net. All rights reserved.
//

#import "PSHCoverFeedPageViewController.h"
#import "PSHCommentsViewController.h"
#import "PSHFacebookDataService.h"
#import "LEColorPicker.h"
#import <QuartzCore/QuartzCore.h>

@interface PSHCoverFeedPageViewController ()

// time
@property (nonatomic, weak) IBOutlet UIView * currentTimeView;
@property (nonatomic, weak) IBOutlet UILabel * currentTimeLabel;
@property (nonatomic, strong) NSDateFormatter * dateFormatter;


// action panel
@property (nonatomic, weak) IBOutlet UIView * actionsPanelView;
@property (nonatomic, weak) IBOutlet UILabel * likesCountLabel;
@property (nonatomic, weak) IBOutlet UILabel * commentsCountLabel;
@property (nonatomic, strong) NSString * commentsCountString;
@property (nonatomic, strong) NSString * likesCountString;

// photo comments
@property (nonatomic, weak) IBOutlet UIView * photosCommentsView;
@property (nonatomic, weak) IBOutlet UILabel * photosCommentsMessageLabel;
@property (nonatomic, weak) IBOutlet UILabel * photosCommentsUpdateInfoLabel;

// status updates
@property (nonatomic, weak) IBOutlet UIView * statusUpdateView;
@property (nonatomic, weak) IBOutlet UILabel * statusUpdateMessageLabel;
@property (nonatomic, weak) IBOutlet UILabel * statusUpdateUpdateInfoLabel;
@property (nonatomic, weak) IBOutlet UIImageView * sourceImageView;
@property (nonatomic, weak) IBOutlet UILabel * sourceNameLabel;

// comments
@property (nonatomic, strong) PSHCommentsViewController * commentsViewController;
@property (nonatomic, weak) IBOutlet UILabel * latestCommentatorsLabel;

// background
@property (nonatomic, weak) IBOutlet UIImageView * backgroundImageView;
@property (nonatomic, weak) IBOutlet UIView * backgroundOverlayImageView;

// like
@property (nonatomic, weak) IBOutlet UIImageView * likeImageView;



@property (nonatomic, strong) UIImageView * animatedLikeImageView;

-(IBAction)likeButtonTapped:(id)sender;
-(IBAction)commentButtonTapped:(id)sender;

@end

@implementation PSHCoverFeedPageViewController

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
    
    
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    self.view.frame = screenBounds;
    [self initViews];
    
    if (self.currentIndex == 0){
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.dateFormat = @"HH:mm";
        [self showFirstLaunchView];
    }else{
        self.currentTimeView.hidden = YES;
    }
    

    UILongPressGestureRecognizer * longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] init];
    [longPressGestureRecognizer addTarget:self action:@selector(longPressRecognized:)];
    [self.view addGestureRecognizer:longPressGestureRecognizer];
    
    UITapGestureRecognizer * doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [doubleTapGestureRecognizer addTarget:self action:@selector(doubleTapGestureRecognized:)];
    [self.view addGestureRecognizer:doubleTapGestureRecognizer];
    
    UITapGestureRecognizer * singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    [singleTapGestureRecognizer addTarget:self action:@selector(singleTapGestureRecognized:)];
    [self.view addGestureRecognizer:singleTapGestureRecognizer];
    
    [singleTapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [self animateBackground];

}

-(void)viewWillDisappear:(BOOL)animated {
    [UIView setAnimationsEnabled:YES];
    self.backgroundImageView.transform = CGAffineTransformIdentity;
}


- (void)viewDidAppear:(BOOL)animated {
}

- (void)stopAnimateBackground {
    self.backgroundImageView.transform = CGAffineTransformIdentity;
    [UIView setAnimationsEnabled:YES];
    
}

#pragma mark - views set up

- (void)initViews {
    
    self.likesCountString = [NSString stringWithFormat:@"%i likes", self.likesCount];
    
    self.commentsCountString = [NSString stringWithFormat:@"%i comments", self.commentsCount];
    
    self.likesCountLabel.text = self.likesCountString;
    self.likesCountLabel.textColor = [UIColor whiteColor];
    self.likesCountLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0f];
    
    self.commentsCountLabel.text = self.commentsCountString;
    self.commentsCountLabel.textColor = [UIColor whiteColor];
    self.commentsCountLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0f];
    
    self.latestCommentatorsLabel.text = self.lastestCommentatorsString;
    self.latestCommentatorsLabel.textColor = [UIColor whiteColor];
    self.latestCommentatorsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:11.0f];
    
    if (self.likesCount == 0){
        self.likesCountLabel.hidden = YES;
    }
    if (self.commentsCount == 0){
        self.commentsCountLabel.hidden = YES;
        self.latestCommentatorsLabel.hidden = YES;
    }
    
    if ([self.feedType isEqualToString:@"photo"]){
        self.photosCommentsView.hidden = NO;
        self.backgroundOverlayImageView.hidden = YES;
        self.statusUpdateView.hidden = YES;
        
        self.photosCommentsMessageLabel.text = self.messageLabelString;
        self.photosCommentsMessageLabel.textColor = [UIColor whiteColor];
        self.photosCommentsUpdateInfoLabel.text = self.infoLabelString;
        self.photosCommentsUpdateInfoLabel.textColor = [UIColor whiteColor];
        
    }else if ([self.feedType isEqualToString:@"status"]){
        self.photosCommentsView.hidden = YES;
        self.backgroundOverlayImageView.hidden = NO;
        self.statusUpdateView.hidden = NO;
        self.statusUpdateMessageLabel.text = self.messageLabelString;
        self.statusUpdateMessageLabel.textColor = [UIColor whiteColor];
        self.statusUpdateUpdateInfoLabel.text = self.infoLabelString;
        self.statusUpdateUpdateInfoLabel.textColor = [UIColor whiteColor];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage * sourceImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.sourceAvartarImageURL]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.sourceImageView.image = sourceImage;
                [self.sourceImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
                [self.sourceImageView.layer setBorderWidth: .5];
            });
        });
        self.sourceNameLabel.text = self.sourceName;
        self.sourceNameLabel.textColor = [UIColor whiteColor];
    }
    
    if (self.likedByMe){
        self.likeImageView.image = [UIImage imageNamed:@"coverfeed-liked_by_me_button"];
    }else{
        self.likeImageView.image = [UIImage imageNamed:@"coverfeed-like_button"];
        
    }
    
    CGRect originalFrame = self.actionsPanelView.frame;
    originalFrame.origin.y = self.view.frame.size.height - self.actionsPanelView.frame.size.height;
    self.actionsPanelView.frame = originalFrame;
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (!self.imageURLString){
            self.imageURLString = self.sourceAvartarImageURL;
            self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        }
        
        UIImage * feedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.imageURLString]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.backgroundImageView.alpha = 0.0f;
            self.backgroundImageView.image = feedImage;
            
            [LEColorPicker pickColorFromImage:feedImage onComplete:^(NSDictionary *colorsPickedDictionary) {
                [UIView beginAnimations:@"ColorChange" context:nil];
                [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
                [UIView setAnimationDuration:0.5];
                self.view.backgroundColor = colorsPickedDictionary[@"BackgroundColor"];
                [UIView commitAnimations];
            }];
            
            [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.backgroundImageView.alpha = 1.0f;
            } completion:^(BOOL finished) {
            }];
        });
    });
}

- (void) setLikedByMe:(BOOL)likedByMe {
    _likedByMe = likedByMe;
    if (likedByMe){
        self.likeImageView.image = [UIImage imageNamed:@"coverfeed-liked_by_me_button"];
    }else{
        self.likeImageView.image = [UIImage imageNamed:@"coverfeed-like_button"];
        
    }
}

- (void) showCurrentTimeView {
    self.currentTimeLabel.text = [self.dateFormatter stringFromDate:[NSDate date]];
}

- (void) hideCurrentTimeView {
    
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        self.currentTimeLabel.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        // nothing
    }];
}


- (void) showFirstLaunchView {
    
    [self showCurrentTimeView];
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self hideCurrentTimeView];
    });
    [self animateActionsPanelView];
    if ([self.feedType isEqualToString:@"status"]){
        [self animateStatusUpdateView];
        
    }else if ([self.feedType isEqualToString:@"photo"]){
        [self animatePhotoCommentsView];
    }
    
}

- (void) animateActionsPanelView {
    
    CGRect originalFrame = self.actionsPanelView.frame;
    originalFrame.origin.y = self.view.frame.size.height - self.actionsPanelView.frame.size.height;
    
    CGRect destFrame = originalFrame;
    destFrame.origin.y = self.actionsPanelView.frame.origin.y + self.actionsPanelView.frame.size.height;
    self.actionsPanelView.frame = destFrame;
    
    [UIView animateWithDuration:0.3 delay:2.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.actionsPanelView.frame = originalFrame;
        
    } completion:^(BOOL finished) {
        // nothing
    }];
}


- (void) animateStatusUpdateView {
    
    CGRect originalFrame = self.statusUpdateView.frame;
    CGRect destFrame = originalFrame;
    destFrame.origin.y = self.statusUpdateView.frame.origin.y - self.statusUpdateView.frame.size.height;
    self.statusUpdateView.frame = destFrame;
    
    [UIView animateWithDuration:0.3 delay:2.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.statusUpdateView.frame = originalFrame;
        
    } completion:^(BOOL finished) {
        // nothing
    }];
}

- (void) animatePhotoCommentsView {
    
    CGRect originalFrame = self.photosCommentsView.frame;
    CGRect destFrame = originalFrame;
    destFrame.origin.y = self.photosCommentsView.frame.origin.y - self.photosCommentsView.frame.size.height;
    self.photosCommentsView.frame = destFrame;
    
    [UIView animateWithDuration:0.3 delay:2.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.photosCommentsView.frame = originalFrame;
        
    } completion:^(BOOL finished) {
        // nothing
    }];
}



- (void)animateBackground {
    
    NSInteger randInt = arc4random()%3;
    
    NSInteger translationX = 0;
    NSInteger translationY = 0;
    NSInteger scaleX = 0;
    NSInteger scaleY = 0;
    
    switch (randInt) {
        case 0:
            translationX = 90;
            translationY = -100;
            scaleX = 2.5;
            scaleY = 2.5;
            break;
            
        case 1:
            translationX = 20;
            translationY = -70;
            scaleX = 2.7;
            scaleY = 2.7;
            break;
            
        case 2:
            translationX = 40;
            translationY = -50;
            scaleX = 2.0;
            scaleY = 2.0;
            break;
            
        default:
            break;
    }
        
    // re-animate image background
    [UIView animateWithDuration:50.0f
                          delay:0.0f
                        options:
     UIViewAnimationOptionCurveLinear |
     UIViewAnimationOptionAutoreverse |
     UIViewAnimationOptionRepeat
                     animations:^{
                         [UIView setAnimationRepeatCount:10];
                         CGAffineTransform moveRight = CGAffineTransformMakeTranslation(translationX, translationY);
                         CGAffineTransform zoomIn = CGAffineTransformMakeScale(scaleX, scaleY);
                         CGAffineTransform transform = CGAffineTransformConcat(zoomIn, moveRight);
                         self.backgroundImageView.transform = transform;
                     } completion:nil];
}

- (void)longPressRecognized:(UILongPressGestureRecognizer*)gestureRecognizer {
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        self.backgroundImageView.contentMode = UIViewContentModeCenter;
        [self animateBackground];
        
        if ([self.feedType isEqualToString:@"photo"]){
            [self showPhotosCommentsView];
        }else{
            [self showStatusUpdateView];
        }
        [self showActionsPanelView];
        
        
    }else{
        [self hidePhotosCommentsView];
        [self hideStatusUpdateView];
        [self hideActionsPanelView];
        
        [self stopAnimateBackground];
        self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
}

-(void)doubleTapGestureRecognized:(UITapGestureRecognizer*)gestureRecognizer {
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        if (self.likedByMe){
            [self unlikeFeed];
            
        }else{
            [self likeFeed];
        }
    }
}

-(void) singleTapGestureRecognized:(UITapGestureRecognizer*)gestureRecognizer {
    
    if ([self.delegate respondsToSelector:@selector(coverfeedPageViewController:mainViewTapped:)]){
        [self animateHideActionsPanelView];
        
        [self.delegate coverfeedPageViewController:self mainViewTapped:YES];
    }
    
}


#pragma mark - Like and Comments

-(IBAction)likeButtonTapped:(id)sender {
    if (self.likedByMe){
        [self unlikeFeed];
        
    }else{
        [self likeFeed];
    }
}

-(IBAction)commentButtonTapped:(id)sender {

    NSLog(@"commentButtonTapped...");
    if (self.commentsViewController != nil){
        self.commentsViewController = nil;
        [self.commentsViewController.view removeFromSuperview];
        [self.commentsViewController removeFromParentViewController];
    }
    self.commentsViewController = [[PSHCommentsViewController alloc] init];
    self.commentsViewController.feedItemGraphID = self.feedItemGraphID;
    [self addChildViewController:self.commentsViewController];
    [self.navigationController pushViewController:self.commentsViewController animated:NO];
}

- (void) unlikeFeed {
    self.likeImageView.image = [UIImage imageNamed:@"coverfeed-like_button"];
    if ([self.delegate respondsToSelector:@selector(coverfeedPageViewController:feedID:unliked:)]){
        
        PSHFacebookDataService * facebookDataService = [PSHFacebookDataService sharedService];
        [facebookDataService unlikeFeed:self.feedItemGraphID];
        [self.delegate coverfeedPageViewController:self feedID:self.feedItemGraphID unliked:YES];
        self.likedByMe = NO;
    }
}



- (void) likeFeed {
    
    UIImageView * animatedLikeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"coverfeed-like_button"]];
    animatedLikeImageView.frame = CGRectMake(80.0f, 210.0f, 160.0f, 160.0f);
    animatedLikeImageView.contentMode = UIViewContentModeScaleToFill;
    self.animatedLikeImageView = animatedLikeImageView;
    self.animatedLikeImageView.hidden = YES;
    [self.view addSubview:self.animatedLikeImageView];
    
    double delayInSeconds = .3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.animatedLikeImageView.hidden = NO;
        self.animatedLikeImageView.layer.anchorPoint = CGPointMake(0.50, .5);
        CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        bounceAnimation.values = [NSArray arrayWithObjects:
                                  [NSNumber numberWithFloat:0.8],
                                  [NSNumber numberWithFloat:1.5],
                                  [NSNumber numberWithFloat:0.0],
                                  nil];
        
        bounceAnimation.duration = 0.6;
        [bounceAnimation setTimingFunctions:[NSArray arrayWithObjects:
                                             [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault],
                                             [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault],
                                             [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                             nil]];
        bounceAnimation.fillMode = kCAFillModeForwards;
        bounceAnimation.removedOnCompletion = NO;
        [self.animatedLikeImageView.layer addAnimation:bounceAnimation forKey:@"bounce"];
    });
    
    PSHFacebookDataService * facebookDataService = [PSHFacebookDataService sharedService];
    [facebookDataService likeFeed:self.feedItemGraphID];
    
    delayInSeconds = .7;
    popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.likesCountLabel.text = [NSString stringWithFormat:@"%i likes", self.likesCount+1];
        self.likesCountLabel.layer.anchorPoint = CGPointMake(0.50, .5);
        CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        bounceAnimation.values = [NSArray arrayWithObjects:
                                  [NSNumber numberWithFloat:1.0],
                                  [NSNumber numberWithFloat:1.2],
                                  [NSNumber numberWithFloat:0.8],
                                  [NSNumber numberWithFloat:1.0],
                                  nil];
        
        bounceAnimation.duration = 0.3;
        [bounceAnimation setTimingFunctions:[NSArray arrayWithObjects:
                                             [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                             [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                             [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                             [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                             nil]];
        bounceAnimation.fillMode = kCAFillModeForwards;
        bounceAnimation.removedOnCompletion = NO;
        [self.likesCountLabel.layer addAnimation:bounceAnimation forKey:@"bounce"];
    });
    self.likeImageView.image = [UIImage imageNamed:@"coverfeed-liked_by_me_button"];
    self.likedByMe = YES;
    
    // clean up
    double delayInSeconds2 = 2.0;
    dispatch_time_t popTime2 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds2 * NSEC_PER_SEC));
    dispatch_after(popTime2, dispatch_get_main_queue(), ^(void){
        [self.animatedLikeImageView removeFromSuperview];
        
        if ([self.delegate respondsToSelector:@selector(coverfeedPageViewController:feedID:unliked:)]){
            [self.delegate coverfeedPageViewController:self feedID:self.feedItemGraphID unliked:NO];
        }
    });
}



- (void) hideStatusUpdateView {
    self.statusUpdateView.hidden = YES;
    self.backgroundOverlayImageView.hidden = YES;
}

- (void) hidePhotosCommentsView {
    self.photosCommentsView.hidden = YES;
}

- (void) hideActionsPanelView {
    self.actionsPanelView.hidden = YES;
}

- (void) showStatusUpdateView {
    self.statusUpdateView.hidden = NO;
    self.backgroundOverlayImageView.hidden = NO;
}

- (void) showActionsPanelView {
    self.actionsPanelView.hidden = NO;
}

- (void) showPhotosCommentsView {
    self.photosCommentsView.hidden = NO;
}


- (void) animateShowActionsPanelView {
    CGRect destFrame = self.actionsPanelView.frame;
    
    destFrame.origin.y = destFrame.origin.y - destFrame.size.height;
    
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.actionsPanelView.frame = destFrame;
        
    } completion:^(BOOL finished) {
        //
        self.actionsPanelView.hidden = NO;
    }];
}

- (void) animateHideActionsPanelView {
    CGRect destFrame = self.actionsPanelView.frame;
    destFrame.origin.y = self.view.frame.size.height;
    
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.actionsPanelView.frame = destFrame;
        
    } completion:^(BOOL finished) {
        //
        self.actionsPanelView.hidden = YES;
    }];
}




@end
