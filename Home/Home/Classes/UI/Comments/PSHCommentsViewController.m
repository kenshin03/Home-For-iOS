//
//  PSHCommentsViewController.m
//  SocialHome
//
//  Created by Kenny Tang on 4/18/13.
//  Copyright (c) 2013 corgitoergosum.net. All rights reserved.
//

#import "PSHCommentsViewController.h"
#import "PSHFacebookDataService.h"
#import "PSHCommentsTableViewCell.h"
#import "FeedItem.h"
#import "PSHFeedComment.h"
#import "AsyncImageView.h"
#import <QuartzCore/QuartzCore.h>

@interface PSHCommentsViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *commentsView;
@property (nonatomic, weak) IBOutlet UITableView * commentsTableView;
@property (nonatomic, weak) IBOutlet UIView * contentsView;
@property (nonatomic, weak) IBOutlet UITextField * commentsTextField;

@property (nonatomic, strong) NSMutableArray * commentsArray;
@property (nonatomic, strong) NSDateFormatter * dateFormatter;



@end

@implementation PSHCommentsViewController

static dispatch_once_t pullToDismissLock;

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
    self.commentsArray = [@[] mutableCopy];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"MM:dd";
    
//    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentsTableViewTapped:)];
//    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initCommentsTableView];
    [self fetchCommentsForItem:self.feedItemGraphID];
    [self.commentsTextField becomeFirstResponder];
    
    [self animateShowCommentsPostingView];

}


#pragma mark - UI

- (void)initCommentsTableView {
    [self.commentsTableView registerNib:[UINib nibWithNibName:@"PSHCommentsTableViewCell" bundle:nil] forCellReuseIdentifier:@"kPSHCommentsTableViewCell"];
}

#pragma mark - fetch comments

- (void) fetchCommentsForItem:(NSString*)feedGraphID {
    PSHFacebookDataService * facebookDataService = [PSHFacebookDataService sharedService];
    [facebookDataService fetchComments:self.feedItemGraphID success:^(NSArray *resultsArray, NSError *error) {
        
        [self.commentsArray removeAllObjects];
        [self.commentsArray addObjectsFromArray:resultsArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.commentsTableView reloadData];
            if ([self.commentsArray count] > 0){
                [self.commentsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([self.commentsArray count]-1) inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
        });
    }];
    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120.0f;
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PSHCommentsTableViewCell * cell = (PSHCommentsTableViewCell*)[self.commentsTableView dequeueReusableCellWithIdentifier:@"kPSHCommentsTableViewCell"];
    
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:cell.commentorImageView];
    cell.commentorImageView.image = nil;
    
    PSHFeedComment * comment = self.commentsArray[indexPath.row];
    
    cell.commentorNameLabel.text = comment.commentorName;
    if (comment.likesCount > 0){
        cell.likesLabel.hidden = NO;
        cell.likesLabel.text = [NSString stringWithFormat:@"%i likes", comment.likesCount];
    }else{
        cell.likesLabel.hidden = YES;
    }
    NSString * commentorGraphID = comment.commentorGraphID;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        PSHFacebookDataService * dataService = [PSHFacebookDataService sharedService];
        [dataService fetchSourceCoverImageURLFor:commentorGraphID success:^(NSString * coverImageURL, NSString * avartarImageURL, NSString* name) {
            
            cell.commentorImageView.imageURL = [NSURL URLWithString:avartarImageURL];
            
            
            /*
            UIImage * commentorImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avartarImageURL]]];
            cell.commentorImageURL = avartarImageURL;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (commentorImageView){
                    commentorImageView.image = commentorImage;
                }
            });
             */
        }];
    });
    cell.commentsLabel.text = comment.comment;
    cell.timeLabel.text = [self.dateFormatter stringFromDate:comment.createdTime];
    return cell;
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.commentsArray count];
}


#pragma mark - UITextFieldDelegate methods


- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.commentsTextField resignFirstResponder];
    self.commentsTextField.text = @"";
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

#pragma mark - Post Comment

- (IBAction)doneButtonTapped:(id)sender {
    [self animateHideCommentsPostingView];
    
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:NO];
        });
    });
}

- (IBAction)postButtonTapped:(id)sender {
    if ([self.commentsTextField.text length] > 0){
        [self postComment:self.commentsTextField.text];
    }
}

- (void)commentsTableViewTapped:(id)sender{
    if (![self.commentsTextField isFirstResponder]){
        [self.commentsTextField becomeFirstResponder];
    }else{
        [self.commentsTextField resignFirstResponder];
    }
    
}

- (void) postComment: (NSString*) commentString {
    PSHFacebookDataService * dataService = [PSHFacebookDataService sharedService];
    [dataService postComment:commentString forItem:self.feedItemGraphID success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self fetchCommentsForItem:self.feedItemGraphID];
        });
    }];
    
}

- (void) animateShowCommentsPostingView {
    self.commentsView.layer.anchorPoint = CGPointMake(0.50, 0.5);
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    bounceAnimation.values = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:0.9],
                              [NSNumber numberWithFloat:1.2],
                              [NSNumber numberWithFloat:0.9],
                              [NSNumber numberWithFloat:1.0],
                              nil];
    
    bounceAnimation.duration = 0.4;
    [bounceAnimation setTimingFunctions:[NSArray arrayWithObjects:
                                         [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                         [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                         [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                         [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                         [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                         nil]];
    bounceAnimation.removedOnCompletion = YES;
    
    [self.commentsView.layer addAnimation:bounceAnimation forKey:@"bounce"];
}

- (void) animateHideCommentsPostingView {
    
    self.commentsView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    bounceAnimation.values = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:1.0],
                              [NSNumber numberWithFloat:0.5],
                              [NSNumber numberWithFloat:0.0],
                              nil];
    
    bounceAnimation.duration = 0.4;
    [bounceAnimation setTimingFunctions:[NSArray arrayWithObjects:
                                         [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                         [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                         [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                         nil]];
    bounceAnimation.removedOnCompletion = NO;
    bounceAnimation.fillMode = kCAFillModeForwards;
    
    
    CABasicAnimation * positionAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    positionAnim.fromValue = @(1.0);
    positionAnim.toValue = @(0.0);
    positionAnim.duration = 0.2;
    
    CAAnimationGroup* group = [CAAnimationGroup animation];
    group.animations = @[bounceAnimation, positionAnim];
    group.duration = positionAnim.duration;
    group.removedOnCompletion = YES;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    group.fillMode = kCAFillModeForwards;
    [self.commentsView.layer addAnimation:group forKey:@"scale-down"];
    
    double delayInSeconds = .15;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.commentsView.hidden = YES;
    });
    
}


#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < -120.0f){
        dispatch_once(&pullToDismissLock, ^{
            [self doneButtonTapped:nil];

            double delayInSeconds = 1.2;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                dispatch_async(dispatch_get_main_queue(), ^{
                    pullToDismissLock = 0;
                });
            });
            
        });
    }
}




@end
