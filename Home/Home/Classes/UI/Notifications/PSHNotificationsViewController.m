//
//  PSHNotificationsViewController.m
//  Home
//
//  Created by Kenny Tang on 5/12/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import "PSHNotificationsViewController.h"
#import "PSHFacebookDataService.h"

@interface PSHNotificationsViewController ()

@property (nonatomic, strong) NSMutableArray * notificationsArray;

@end

@implementation PSHNotificationsViewController

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
    self.notificationsArray = [@[] mutableCopy];
    
    [self initNotificationsTableView];
    [self fetchNotifications];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) initNotificationsTableView {
    
}


- (void) fetchNotifications {
    PSHFacebookDataService * facebookDataService = [PSHFacebookDataService sharedService];
    [facebookDataService fetchNotifications:^(NSArray *resultsArray, NSError *error) {
        
        
        [self.notificationsArray removeAllObjects];
        [self.notificationsArray addObjectsFromArray:resultsArray];
        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.commentsTableView reloadData];
        });
    }];
    
    
    
    
}

@end
