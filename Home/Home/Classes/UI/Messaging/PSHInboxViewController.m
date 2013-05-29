//
//  PSHInboxViewController.m
//  Home
//
//  Created by Kenny Tang on 5/28/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import "PSHInboxViewController.h"
#import "PSHFacebookDataService.h"


@interface PSHInboxViewController ()<UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray * inboxArray;
@property (nonatomic, weak) IBOutlet UITableView * inboxTableView;

@end

@implementation PSHInboxViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self fetchInboxMessages];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initInboxTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initInboxTableView {
    [self.inboxTableView registerNib:[UINib nibWithNibName:@"PSHNotificationsTableViewCell" bundle:nil] forCellReuseIdentifier:@"kPSHNotificationsTableViewCell"];
    self.inboxTableView.delegate = self;
    
}


- (void) fetchInboxMessages {
    
//    NSArray * notificationsArray = [Notification findAllSortedBy:@"createdTime" ascending:NO];
//    if ([notificationsArray count] > 0){
//        [self.notificationsArray removeAllObjects];
//        [self.notificationsArray addObjectsFromArray:notificationsArray];
//        [self.notificationsTableView reloadData];
//        
//    }else{
        PSHFacebookDataService * facebookDataService = [PSHFacebookDataService sharedService];
        [facebookDataService fetchInboxChats:^(NSArray *resultsArray, NSError *error) {
//            
//            [self.notificationsArray removeAllObjects];
//            [self.notificationsArray addObjectsFromArray:resultsArray];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.notificationsTableView reloadData];
//            });
        }];
//    }
    
}


#pragma mark - UITableViewDataSource methods
/*
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
        [dataService fetchSourceCoverImageURLFor:sourceGraphID success:^(NSString * coverImageURL, NSString * avartarImageURL) {
            
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

*/

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.inboxArray count];
}

@end
