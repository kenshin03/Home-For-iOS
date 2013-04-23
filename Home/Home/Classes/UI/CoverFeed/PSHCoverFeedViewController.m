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

@interface PSHCoverFeedViewController ()<UIPageViewControllerDataSource>

@property (nonatomic, strong) NSMutableArray * feedItemsArray;
@property (nonatomic, strong) UIPageViewController * feedsPageViewController;
@property (nonatomic, strong) NSDateFormatter * dateFormatter;

@property (nonatomic, strong) PSHCoverFeedPageViewController * currentPagePageViewController;

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
    
    [self.feedsPageViewController setViewControllers:@[currentPagePageViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
    }];
    
    CGRect pageViewRect = self.view.bounds;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        pageViewRect = CGRectInset(pageViewRect, 40.0, 40.0);
    }
    self.feedsPageViewController.view.frame = pageViewRect;
    
    self.view.gestureRecognizers = self.feedsPageViewController.gestureRecognizers;
    
    
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
        
        return nextPageViewController;
        
        
    }else{
        return nil;
    }
}

- (void) initMenuViewController {
    PSHMenuViewController * menuViewController = [[PSHMenuViewController alloc] init];
    [self addChildViewController:menuViewController];
    [self.view addSubview:menuViewController.view];
    [menuViewController didMoveToParentViewController:self];
    
}

@end
