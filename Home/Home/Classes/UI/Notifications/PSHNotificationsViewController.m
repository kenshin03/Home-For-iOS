//
//  PSHNotificationsViewController.m
//  Home
//
//  Created by Kenny Tang on 5/12/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import "PSHNotificationsViewController.h"
#import "PSHFacebookDataService.h"
#import "Notification.h"
#import "PSHNotificationsTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@interface PSHNotificationsViewController ()<UIGestureRecognizerDelegate, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray * notificationsArray;
@property (nonatomic, weak) IBOutlet UITableView * notificationsTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end

@implementation PSHNotificationsViewController

static dispatch_once_t pullToDismissLock;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.notificationsArray = [@[] mutableCopy];
        
        
        [self fetchNotifications];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initNotificationsTableView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) initNotificationsTableView {
    [self.notificationsTableView registerNib:[UINib nibWithNibName:@"PSHNotificationsTableViewCell" bundle:nil] forCellReuseIdentifier:@"kPSHNotificationsTableViewCell"];
    self.notificationsTableView.delegate = self;
    
}


- (void) fetchNotifications {
    
    NSArray * notificationsArray = [Notification findAllSortedBy:@"createdTime" ascending:NO];
    if ([notificationsArray count] > 0){
        [self.notificationsArray removeAllObjects];
        [self.notificationsArray addObjectsFromArray:notificationsArray];
        [self.notificationsTableView reloadData];
        
    }else{
        PSHFacebookDataService * facebookDataService = [PSHFacebookDataService sharedService];
        [facebookDataService fetchNotifications:^(NSArray *resultsArray, NSError *error) {
            
            [self.notificationsArray removeAllObjects];
            [self.notificationsArray addObjectsFromArray:resultsArray];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.notificationsTableView reloadData];
            });
        }];
    }
    
}


#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    PSHNotificationsTableViewCell * cell = (PSHNotificationsTableViewCell*)[self.notificationsTableView dequeueReusableCellWithIdentifier:@"kPSHNotificationsTableViewCell"];
    cell.clipsToBounds = NO;
    cell.sourceImageView.image = nil;
    
    Notification * notification = self.notificationsArray[indexPath.row];
    
    cell.notificationLabel.text = notification.title;

    NSString * sourceGraphID = notification.fromGraphID;
    UIImageView * sourceImageView = cell.sourceImageView;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        PSHFacebookDataService * dataService = [PSHFacebookDataService sharedService];
        [dataService fetchSourceCoverImageURLFor:sourceGraphID success:^(NSString * coverImageURL, NSString * avartarImageURL, NSString* name) {
            
            UIImage * sourceAppImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avartarImageURL]]];
                dispatch_async(dispatch_get_main_queue(), ^{
                if (sourceImageView){
                    sourceImageView.image = sourceAppImage;
                }
            });
        }];
    });
    
    cell.hidden = YES;
    double delayInSeconds = .05*indexPath.row+1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        cell.hidden = NO;
        cell.layer.anchorPoint = CGPointMake(0.50, .5);
        CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        bounceAnimation.values = [NSArray arrayWithObjects:
                                  [NSNumber numberWithFloat:0.8],
                                  [NSNumber numberWithFloat:1.2],
                                  [NSNumber numberWithFloat:1.0],
                                  nil];
        
        bounceAnimation.duration = 0.4;
        [bounceAnimation setTimingFunctions:[NSArray arrayWithObjects:
                                             [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                             [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                             [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                             nil]];
        bounceAnimation.fillMode = kCAFillModeForwards;
        bounceAnimation.removedOnCompletion = NO;
        [cell.layer addAnimation:bounceAnimation forKey:@"bounce"];
        self.activityIndicatorView.hidden = YES;
    });
    
    
    return cell;
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.notificationsArray count];
}

#pragma mark - UITableViewDelegate delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < -160.0f){
        dispatch_once(&pullToDismissLock, ^{
            
            CGRect destFrame = self.notificationsTableView.frame;
            destFrame.origin.y = destFrame.size.height;
            
            [UIView animateWithDuration:0.4f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.notificationsTableView.frame = destFrame;
                self.notificationsTableView.alpha = 0.0f;
                
            } completion:^(BOOL finished) {
                if ([self.delegate respondsToSelector:@selector(notificationsViewController:shouldDismissView:)]){
                    [self.delegate notificationsViewController:self shouldDismissView:YES];
                }
            }];
            
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

- (IBAction)reloadButtonTapped:(id)sender {
    
    PSHFacebookDataService * facebookDataService = [PSHFacebookDataService sharedService];
    [facebookDataService removeAllCachedNotifications:^{
        self.activityIndicatorView.hidden = NO;
        [self fetchNotifications];
    }];
    
}


#pragma mark - UITableViewDelegate method

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Notification * notification = self.notificationsArray[indexPath.row];
    NSString * openURL = notification.link;
    NSURL *url = [NSURL URLWithString:openURL];
    [[UIApplication sharedApplication] openURL:url];
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}

@end
