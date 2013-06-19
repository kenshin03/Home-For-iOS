//
//  PSHInboxViewController.m
//  Home
//
//  Created by Kenny Tang on 5/28/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import "PSHInboxViewController.h"
#import "PSHFacebookDataService.h"
#import "PSHComposeMessageViewController.h"
#import "PSHInboxTableViewCell.h"
#import "PSHInboxHeaderTableViewCell.h"
#import "AsyncImageView.h"
#import <QuartzCore/QuartzCore.h>


@interface PSHInboxViewController ()<UITableViewDelegate, UITableViewDataSource, PSHInboxHeaderTableViewCellDelegate, PSHComposeMessageViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray * inboxArray;
@property (nonatomic, weak) IBOutlet UITableView * inboxTableView;
@property (nonatomic, strong) NSDateFormatter * dateFormatter;
@property (nonatomic, strong) UIRefreshControl * refreshControl;
@property (nonatomic, strong) PSHComposeMessageViewController * composeMessageViewController;

@end

@implementation PSHInboxViewController

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
    self.inboxArray = [@[] mutableCopy];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"HH:mm";
    self.inboxTableView.dataSource = self;
    self.inboxTableView.delegate = self;
    self.inboxTableView.hidden = YES;
    [self fetchInboxMessages];
    [self initInboxTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initInboxTableView {
    [self.inboxTableView registerNib:[UINib nibWithNibName:@"PSHInboxTableViewCell" bundle:nil] forCellReuseIdentifier:@"kPSHInboxTableViewCell"];
    [self.inboxTableView registerNib:[UINib nibWithNibName:@"PSHInboxHeaderTableViewCell" bundle:nil] forCellReuseIdentifier:@"kPSHInboxHeaderTableViewCell"];
    
    self.inboxTableView.delegate = self;
    
    UIRefreshControl * refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl = refreshControl;
    [self.refreshControl addTarget:self action:@selector(fetchInboxMessages) forControlEvents:UIControlEventValueChanged];
    [self.inboxTableView addSubview:self.refreshControl];
    
}


- (void) fetchInboxMessages {
    
        PSHFacebookDataService * facebookDataService = [PSHFacebookDataService sharedService];
        [facebookDataService fetchInboxChats:^(NSArray *resultsArray, NSError *error) {
            
            [self.inboxArray removeAllObjects];
            [self.inboxArray addObjectsFromArray:resultsArray];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.inboxTableView.hidden){
                    self.inboxTableView.hidden = NO;
                    [self animateShowInboxView];
                }
                [self.inboxTableView reloadData];
                [self.refreshControl endRefreshing];
            });
        }];
}

- (void) animateShowInboxView {
    self.inboxTableView.layer.anchorPoint = CGPointMake(0.50, 0.5);
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    bounceAnimation.values = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:1.1],
                              [NSNumber numberWithFloat:0.9],
                              [NSNumber numberWithFloat:1.0],
                              nil];
    
    bounceAnimation.duration = 0.3;
    [bounceAnimation setTimingFunctions:[NSArray arrayWithObjects:
                                         [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                         [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                         [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                         nil]];
    bounceAnimation.removedOnCompletion = YES;
    
    [self.inboxTableView.layer addAnimation:bounceAnimation forKey:@"bounce"];
}

- (void) animateHideInboxView {
    
    self.inboxTableView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    bounceAnimation.values = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:1.0],
                              [NSNumber numberWithFloat:0.5],
                              [NSNumber numberWithFloat:0.0],
                              nil];
    
    bounceAnimation.duration = 0.3;
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
    [self.inboxTableView.layer addAnimation:group forKey:@"scale-down"];
    
    double delayInSeconds = .15;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.inboxTableView.hidden = YES;
    });
    
}


#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0){
        
        PSHInboxHeaderTableViewCell * headerCell = (PSHInboxHeaderTableViewCell*)[self.inboxTableView dequeueReusableCellWithIdentifier:@"kPSHInboxHeaderTableViewCell"];
        headerCell.backgroundColor = [UIColor clearColor];
        headerCell.delegate = self;
        return headerCell;
        
    }else{
        
        PSHInboxTableViewCell * cell = (PSHInboxTableViewCell*)[self.inboxTableView dequeueReusableCellWithIdentifier:@"kPSHInboxTableViewCell"];
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:cell.chatImageView];
        cell.chatImageView.image = nil;
        cell.namesLabel.text = @"";
        
        cell.contentView.backgroundColor = [UIColor whiteColor];
        
        ChatMessage * chatMessage = self.inboxArray[indexPath.row];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            PSHFacebookDataService * dataService = [PSHFacebookDataService sharedService];
            [dataService fetchSourceCoverImageURLFor:chatMessage.fromGraphID success:^(NSString * coverImageURL, NSString * avartarImageURL, NSString* name) {
                cell.namesLabel.text = name;
                cell.chatImageView.imageURL = [NSURL URLWithString:avartarImageURL];
            }];
        });
        
        cell.dateLabel.text = [self.dateFormatter stringFromDate:chatMessage.createdDate];
        cell.messageLabel.text = chatMessage.messageBody;
        return cell;
    }
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.inboxArray count]+1; // add 1 for header
}

#pragma mark - PSHInboxHeaderTableViewCellDelegate methods

- (void)inboxHeaderTableViewCell:(PSHInboxHeaderTableViewCell*)cell didTapOnWritePostButton:(BOOL)tapped {
    PSHComposeMessageViewController * composeMessageViewController = [[PSHComposeMessageViewController alloc] init];
    composeMessageViewController.delegate = self;
    self.composeMessageViewController = composeMessageViewController;
    
    [self presentViewController:composeMessageViewController animated:YES completion:^{
        // 
    }];
}

#pragma mark - PSHComposeMessageViewControllerDelegate methods

- (void)composeMessageViewController:(PSHComposeMessageViewController *)vc dismissComposeMessage:(BOOL)dismiss {
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

@end
