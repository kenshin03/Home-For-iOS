//
//  PSHComposeMessageViewController.m
//  Home
//
//  Created by Kenny Tang on 6/5/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import "PSHComposeMessageViewController.h"

@interface PSHComposeMessageViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;


@end

@implementation PSHComposeMessageViewController

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
    
    self.navigationItem.title = @"N News Title";
    self.navigationBar.topItem.title = @"News Message";
    
//    self.navigationController.navigationBar.top
//    self.navigationItem.title = @"New Message";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
