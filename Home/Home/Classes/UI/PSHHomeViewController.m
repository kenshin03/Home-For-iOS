//
//  PSHHomeViewController.m
//  SocialHome
//
//  Created by Kenny Tang on 4/12/13.
//  Copyright (c) 2013 corgitoergosum.net. All rights reserved.
//

#import "PSHHomeViewController.h"
#import "PSHCoverFeedViewController.h"


@interface PSHHomeViewController ()

@end


@implementation PSHHomeViewController

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
    
    
    PSHCoverFeedViewController * coverFeedViewController = [[PSHCoverFeedViewController alloc] init];
    [self.navigationController pushViewController:coverFeedViewController animated:NO];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
