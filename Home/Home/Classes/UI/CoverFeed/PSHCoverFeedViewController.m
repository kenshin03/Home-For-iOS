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
#import "PSHMessagingViewController.h"
#import "FeedItem.h"
#import "ItemSource.h"

@interface PSHCoverFeedViewController ()<UIPageViewControllerDataSource, PSHMenuViewControllerDelegate, PSHCoverFeedPageViewControllerDelegate, PSHMessagingViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray * feedItemsArray;
@property (nonatomic, strong) UIPageViewController * feedsPageViewController;
@property (nonatomic, strong) NSDateFormatter * dateFormatter;

@property (nonatomic, strong) PSHCoverFeedPageViewController * currentPagePageViewController;
@property (nonatomic, strong) PSHMenuViewController * menuViewController;
@property (nonatomic, strong) UIView * menuView;
@property (nonatomic, strong) UIView * messagingView;


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
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    self.view.frame = screenBounds;
    
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
    if ([self.feedItemsArray count] == 0){
        // do nothing
        return;
    }
    
    FeedItem * firstFeedItem = self.feedItemsArray[0];
    PSHCoverFeedPageViewController * currentPagePageViewController = [[PSHCoverFeedPageViewController alloc] init];
    currentPagePageViewController.feedType = firstFeedItem.type;
    currentPagePageViewController.messageLabelString = firstFeedItem.message;
    currentPagePageViewController.infoLabelString = [NSString stringWithFormat:@"%@ - %@", [self.dateFormatter stringFromDate:firstFeedItem.updatedTime], firstFeedItem.source.name];
    currentPagePageViewController.likesCount = [firstFeedItem.likesCount integerValue];
    currentPagePageViewController.commentsCount = [firstFeedItem.commentsCount integerValue];
    currentPagePageViewController.lastestCommentatorsString = firstFeedItem.latestCommentors;
    currentPagePageViewController.feedItemGraphID = firstFeedItem.graphID;
    currentPagePageViewController.feedType = firstFeedItem.type;
    currentPagePageViewController.likedByMe = firstFeedItem.likedByMe.boolValue;
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
        prevPageViewController.lastestCommentatorsString = previousFeedItem.latestCommentors;
        prevPageViewController.feedItemGraphID = previousFeedItem.graphID;
        prevPageViewController.feedType = previousFeedItem.type;
        prevPageViewController.currentIndex = previousIndex;
        prevPageViewController.likedByMe = previousFeedItem.likedByMe.boolValue;
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
        nextPageViewController.lastestCommentatorsString = nextFeedItem.latestCommentors;
        nextPageViewController.feedItemGraphID = nextFeedItem.graphID;
        nextPageViewController.feedType = nextFeedItem.type;
        nextPageViewController.currentIndex = nextIndex;
        nextPageViewController.likedByMe = nextFeedItem.likedByMe.boolValue;
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
    [self.menuViewController animateHideMenuButtons];
    self.menuView = self.menuViewController.view;
    
}

- (void) animateHideMenu {
    
    CGRect destFrame = self.menuViewController.view.frame;
    destFrame.origin.y = self.view.frame.size.height;
    
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.menuViewController.view.frame = destFrame;
        
    } completion:^(BOOL finished) {
        [self.menuViewController animateHideMenuButtons];
    }];
    
}

- (void) animateShowMenu {
    [self.menuViewController animateHideMenuButtons];
    [self.menuViewController animateHideLauncher];
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

- (void)menuViewController:(PSHMenuViewController*)vc messagesButtonTapped:(BOOL)tapped {
    [self animateHideMenu];
    
    PSHMessagingViewController * messagingViewController = [[PSHMessagingViewController alloc] init];
    messagingViewController.delegate = self;
    [self addChildViewController:messagingViewController];
    
    self.messagingView = messagingViewController.view;
    
    [messagingViewController didMoveToParentViewController:self];
    [self.view addSubview:messagingViewController.view];
    
}

- (void)menuViewController:(PSHMenuViewController*)vc viewSwipedToLeft:(BOOL)tapped {
     [self animateHideMenu];
    
}

- (void)menuViewController:(PSHMenuViewController*)vc viewSwipedToRight:(BOOL)tapped {
    [self animateHideMenu];
    
}


- (void)menuViewController:(PSHMenuViewController*)vc menuViewTapped:(BOOL)tapped {
    [self animateHideMenu];
    
    [[self.feedsPageViewController viewControllers] enumerateObjectsUsingBlock:^(PSHCoverFeedPageViewController * feedPageViewController, NSUInteger idx, BOOL *stop) {
        if ([feedPageViewController respondsToSelector:@selector(animateShowActionsPanelView)]){
            [feedPageViewController animateShowActionsPanelView];
        }
    }];
}

- (void)menuViewController:(PSHMenuViewController*)vc reloadButtonTapped:(BOOL)tapped {
    [self animateHideMenu];
    
    
    [self.feedItemsArray removeAllObjects];
    [self.feedsPageViewController.view removeFromSuperview];
    [self.feedsPageViewController removeFromParentViewController];
    self.feedsPageViewController = nil;
    
    self.facebookDataService = [PSHFacebookDataService sharedService];
    [self.facebookDataService removeAllCachedFeeds:^{
        
        
        NSArray * feedItemsArray = [FeedItem findAllSortedBy:@"createdTime" ascending:NO];
        if ([feedItemsArray count] > 0){
            [self.feedItemsArray removeAllObjects];
            [self.feedItemsArray addObjectsFromArray:feedItemsArray];
            [self initFeedsPageViewController];
            
        }else{
            self.facebookDataService = [PSHFacebookDataService sharedService];
            [self.facebookDataService fetchFeed:^(NSArray *resultsArray, NSError *error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.feedItemsArray removeAllObjects];
                    [self.feedItemsArray addObjectsFromArray:resultsArray];
                    // reload page view controller
                    [self initFeedsPageViewController];
                });
            }];
        }
        
        [self.view bringSubviewToFront:self.menuView];
    }];
    
}

#pragma mark - PSHCoverFeedPageViewController methods

- (void)coverfeedPageViewController:(PSHCoverFeedPageViewController*)vc mainViewTapped:(BOOL)tapped {
    [self animateShowMenu];
}

- (void)coverfeedPageViewController:(PSHCoverFeedPageViewController*)vc feedID:(NSString*)feedID unliked:(BOOL)unliked {
    // unlike the feed
    [self.feedItemsArray enumerateObjectsUsingBlock:^(FeedItem * feedItem, NSUInteger idx, BOOL *stop) {
        if ([feedItem.graphID isEqualToString:feedID]){
            if (unliked){
                feedItem.likedByMe = [NSNumber numberWithBool:NO];
            }else{
                feedItem.likedByMe = [NSNumber numberWithBool:YES];
            }
        }
    }];
    
}

#pragma mark - PSHMessagingViewControllerDelegate methods

- (void)messagingViewController:(PSHMessagingViewController*)vc messagingDissmissed:(BOOL)dismissed {
    [self animateShowMenu];
    [self.messagingView removeFromSuperview];
}


@end
