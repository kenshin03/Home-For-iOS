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

@interface PSHCommentsViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITableView * commentsTableView;
@property (nonatomic, weak) IBOutlet UIView * contentsView;
@property (nonatomic, weak) IBOutlet UITextField * commentsTextField;

@property (nonatomic, strong) NSMutableArray * commentsArray;
@property (nonatomic, strong) NSDateFormatter * dateFormatter;



@end

@implementation PSHCommentsViewController

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
    [self initCommentsTableView];
    self.commentsArray = [@[] mutableCopy];
    [self fetchCommentsForItem:self.feedItemGraphID];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"MM:dd";
    
    UISwipeGestureRecognizer * swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] init];
    [swipeGestureRecognizer addTarget:self action:@selector(viewDidSwipeDown:)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    swipeGestureRecognizer.delaysTouchesBegan = YES;
    [self.commentsTableView addGestureRecognizer:swipeGestureRecognizer];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI

- (void)initCommentsTableView {
    [self.commentsTableView registerNib:[UINib nibWithNibName:@"PSHCommentsTableViewCell" bundle:nil] forCellReuseIdentifier:@"kPSHCommentsTableViewCell"];
    self.commentsTableView.multipleTouchEnabled = YES;
}

#pragma mark - fetch comments

- (void) fetchCommentsForItem:(NSString*)feedGraphID {
    PSHFacebookDataService * facebookDataService = [PSHFacebookDataService sharedService];
    [facebookDataService fetchComments:self.feedItemGraphID success:^(NSArray *resultsArray, NSError *error) {
        
        [self.commentsArray removeAllObjects];
        [self.commentsArray addObjectsFromArray:resultsArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.commentsTableView reloadData];
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
    UIImageView * commentorImageView = cell.commentorImageView;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        PSHFacebookDataService * dataService = [PSHFacebookDataService sharedService];
        [dataService fetchSourceCoverImageURLFor:commentorGraphID success:^(NSString * coverImageURL, NSString * avartarImageURL) {
            
            UIImage * commentorImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avartarImageURL]]];
            cell.commentorImageURL = avartarImageURL;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (commentorImageView){
                    commentorImageView.image = commentorImage;
                }
            });
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

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGRect destFrame = self.contentsView.frame;
    destFrame.origin.y = destFrame.origin.y - destFrame.size.height/3;
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.contentsView.frame = destFrame;
    } completion:^(BOOL finished) {
        // none
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.commentsTextField resignFirstResponder];
    self.commentsTextField.text = @"";
    CGRect destFrame = self.contentsView.frame;
    destFrame.origin.y = 0.0f;
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.contentsView.frame = destFrame;
    } completion:^(BOOL finished) {
        // nil
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField.text length] > 0){
        [self postComment:textField.text];
    }
    [self textFieldDidEndEditing:textField];
    return YES;
}

#pragma mark - Post Comment

- (void) postComment: (NSString*) commentString {
    PSHFacebookDataService * dataService = [PSHFacebookDataService sharedService];
    [dataService postComment:commentString forItem:self.feedItemGraphID success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self fetchCommentsForItem:self.feedItemGraphID];
        });
    }];
    
}

#pragma mark - UISwipeGestureRecognizer

- (void)viewDidSwipeDown: (id)sender {
    
    if ([self.delegate respondsToSelector:@selector(commentsViewController:viewDidSwipeDown:)]){
        [self.delegate commentsViewController:self viewDidSwipeDown:YES];
    }
    
    
    
}

@end
