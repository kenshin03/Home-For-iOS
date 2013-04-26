//
//  PSHCoverFeedViewController.m
//  SocialHome
//
//  Created by Kenny Tang on 4/14/13.
//  Copyright (c) 2013 corgitoergosum.net. All rights reserved.
//

#import "PSHCoverFeedViewController.h"
#import "PSHFacebookDataService.h"
#import "PSHCoverFeedPageViewController.h"
#import "PSHMenuViewController.h"
#import "FeedItem.h"
#import "ItemSource.h"

@interface PSHCoverFeedViewController ()<UIPageViewControllerDataSource, PSHMenuViewControllerDelegate, PSHCoverFeedPageViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray * feedItemsArray;
@property (nonatomic, strong) UIPageViewController * feedsPageViewController;
@property (nonatomic, strong) NSDateFormatter * dateFormatter;

@property (nonatomic, strong) PSHCoverFeedPageViewController * currentPagePageViewController;
@property (nonatomic, strong) PSHMenuViewController * menuViewController;
@property (nonatomic) BOOL isMenuHidden;

@property (nonatomic, strong) PSHFacebookDataService * facebookDataService;



@end

@implementation PSHCoverFeedViewController

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
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationItem.hidesBackButton = YES;
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"MMMM d"];
    self.feedItemsArray = [@[] mutableCopy];
    
    NSArray * feedItemsArray = [FeedItem findAllSortedBy:@"createdTime" ascending:NO];
    if ([feedItemsArray count] > 0){
        [self.feedItemsArray removeAllObjects];
        [self.feedItemsArray addObjectsFromArray:feedItemsArray];
        [self initFeedsPageViewController];
        
        // reload
    }else{
        self.facebookDataService = [PSHFacebookDataService sharedService];
        [self.facebookDataService fetchFeed:^(NSArray *resultsArray, NSError *error) {
            NSLog(@"done...");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.feedItemsArray removeAllObjects];
                [self.feedItemsArray addObjectsFromArray:resultsArray];
                // reload page view controller
                [self initFeedsPageViewController];
            });
        }];
    }
    
    [self initMenuViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init methods

- (void) initFeedsPageViewController {
    
    if (self.feedsPageViewController == nil){
        self.feedsPageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        self.feedsPageViewController.dataSource = self;
        [self addChildViewController:self.feedsPageViewController];
        [self.view addSubview:self.feedsPageViewController.view];
        [self.feedsPageViewController didMoveToParentViewController:self];
    }
    
    FeedItem * firstFeedItem = self.feedItemsArray[0];
    PSHCoverFeedPageViewController * currentPagePageViewController = [[PSHCoverFeedPageViewController alloc] init];
    currentPagePageViewController.feedType = firstFeedItem.type;
    currentPagePageViewController.messageLabelString = firstFeedItem.message;
    currentPagePageViewController.infoLabelString = [NSString stringWithFormat:@"%@ - %@", [self.dateFormatter stringFromDate:firstFeedItem.updatedTime], firstFeedItem.source.name];
    currentPagePageViewController.likesCount = [firstFeedItem.likesCount integerValue];
    currentPagePageViewController.commentsCount = [firstFeedItem.commentsCount integerValue];
    currentPagePageViewController.feedItemGraphID = firstFeedItem.graphID;
    currentPagePageViewController.feedType = firstFeedItem.type;
    currentPagePageViewController.currentIndex = 0;
    if (firstFeedItem.imageURL != nil){
        currentPagePageViewController.imageURLString = firstFeedItem.imageURL;
    }
    currentPagePageViewController.sourceName = firstFeedItem.source.name;
    currentPagePageViewController.sourceAvartarImageURL = firstFeedItem.source.imageURL;
    currentPagePageViewController.delegate = self;
    
    [self.feedsPageViewController setViewControllers:@[currentPagePageViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
    }];
    
    CGRect pageViewRect = self.view.bounds;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        pageViewRect = CGRectInset(pageViewRect, 40.0, 40.0);
    }
    self.feedsPageViewController.view.frame = pageViewRect;
    
    self.view.gestureRecognizers = self.feedsPageViewController.gestureRecognizers;
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self animateHideMenu];
    });
}

#pragma mark - UIPageViewController dataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    PSHCoverFeedPageViewController *currentViewController = (PSHCoverFeedPageViewController*) viewController;
    NSInteger currentIndex = currentViewController.currentIndex;
    
    // prev page
    if (currentIndex == 0){
        return nil;
    }else{
        NSInteger previousIndex = currentIndex - 1;
        FeedItem * previousFeedItem = self.feedItemsArray[previousIndex];
        PSHCoverFeedPageViewController * prevPageViewController = [[PSHCoverFeedPageViewController alloc] init];
        prevPageViewController.feedType = previousFeedItem.type;
        prevPageViewController.messageLabelString = previousFeedItem.message;
        prevPageViewController.infoLabelString = [NSString stringWithFormat:@"%@ - %@", [self.dateFormatter stringFromDate:previousFeedItem.updatedTime], previousFeedItem.source.name];
        prevPageViewController.likesCount = [previousFeedItem.likesCount integerValue];
        prevPageViewController.commentsCount = [previousFeedItem.commentsCount integerValue];
        prevPageViewController.feedItemGraphID = previousFeedItem.graphID;
        prevPageViewController.feedType = previousFeedItem.type;
        prevPageViewController.currentIndex = previousIndex;
        if (previousFeedItem.imageURL != nil){
            prevPageViewController.imageURLString = previousFeedItem.imageURL;
        }
        prevPageViewController.sourceName = previousFeedItem.source.name;
        prevPageViewController.sourceAvartarImageURL = previousFeedItem.source.imageURL;
        prevPageViewController.delegate = self;
        return prevPageViewController;
    }
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    PSHCoverFeedPageViewController *currentViewController = (PSHCoverFeedPageViewController*) viewController;
    NSInteger currentIndex = currentViewController.currentIndex;
    NSInteger nextIndex = currentIndex+1;
    
    if (currentIndex < [self.feedItemsArray count]-1){
        
        FeedItem * nextFeedItem = self.feedItemsArray[nextIndex];
        
        PSHCoverFeedPageViewController * nextPageViewController = [[PSHCoverFeedPageViewController alloc] init];
        nextPageViewController.feedType = nextFeedItem.type;
        nextPageViewController.messageLabelString = nextFeedItem.message;
        nextPageViewController.infoLabelString = [NSString stringWithFormat:@"%@ - %@", [self.dateFormatter stringFromDate:nextFeedItem.updatedTime], nextFeedItem.source.name];
        nextPageViewController.likesCount = [nextFeedItem.likesCount integerValue];
        nextPageViewController.commentsCount = [nextFeedItem.commentsCount integerValue];
        nextPageViewController.feedItemGraphID = nextFeedItem.graphID;
        nextPageViewController.feedType = nextFeedItem.type;
        nextPageViewController.currentIndex = nextIndex;
        if (nextFeedItem.imageURL != nil){
            nextPageViewController.imageURLString = nextFeedItem.imageURL;
        }
        nextPageViewController.sourceName = nextFeedItem.source.name;
        nextPageViewController.sourceAvartarImageURL = nextFeedItem.source.imageURL;
        nextPageViewController.delegate = self;
        return nextPageViewController;
        
        
    }else{
        return nil;
    }
}

#pragma mark - Menu related

- (void) initMenuViewController {
    PSHMenuViewController * menuViewController = [[PSHMenuViewController alloc] init];
    menuViewController.delegate = self;
    self.menuViewController = menuViewController;
    
    
    // move it down
    CGRect destFrame = self.menuViewController.view.frame;
    self.menuViewController.view.frame = destFrame;
    
    [self addChildViewController:self.menuViewController];
    [self.view addSubview:self.menuViewController.view];
    [self.menuViewController didMoveToParentViewController:self];
    [self.view bringSubviewToFront:self.menuViewController.view];
    
}

- (void) animateHideMenu {
    
    CGRect destFrame = self.menuViewController.view.frame;
    destFrame.origin.y = destFrame.size.height;
    
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.menuViewController.view.frame = destFrame;
        
    } completion:^(BOOL finished) {
//        [self.menuViewController.view removeFromSuperview];
//        [self.menuViewController removeFromParentViewController];
    }];
    
}

- (void) animateShowMenu {
    
    CGRect originFrame = self.menuViewController.view.frame;
    originFrame.origin.y = 0.0f;
    CGRect destFrame = self.menuViewController.view.frame;
    destFrame.origin.y = destFrame.size.height;
    self.menuViewController.view.frame = destFrame;
    [self.view bringSubviewToFront:self.menuViewController.view];
    
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.menuViewController.view.frame = originFrame;
        
    } completion:^(BOOL finished) {
        NSLog(@"done: %@", NSStringFromCGRect(self.menuViewController.view.frame));
        
    }];
    
}


#pragma mark - PSHMenuViewControllerDelegate methods

- (void)menuViewController:(PSHMenuViewController*)vc menuViewTapped:(BOOL)tapped {
    [self animateHideMenu];
    
    [[self.feedsPageViewController viewControllers] enumerateObjectsUsingBlock:^(PSHCoverFeedPageViewController * feedPageViewController, NSUInteger idx, BOOL *stop) {
        if ([feedPageViewController respondsToSelector:@selector(animateShowActionsPanelView)]){
            [feedPageViewController animateShowActionsPanelView];
        }
    }];
}


- (void)coverfeedPageViewController:(PSHCoverFeedPageViewController*)vc mainViewTapped:(BOOL)tapped {
    [self animateShowMenu];
}


@end
