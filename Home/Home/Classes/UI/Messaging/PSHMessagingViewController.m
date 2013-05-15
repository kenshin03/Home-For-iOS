//
//  PSHMessagingViewController.m
//  Home
//
//  Created by Kenny Tang on 5/14/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import "PSHMessagingViewController.h"
#import "PSHFacebookDataService.h"
#import "PSHFacebookXMPPService.h"
#import "PSHChatHead.h"
#import "ChatMessage.h"
#import <QuartzCore/QuartzCore.h>

@interface PSHMessagingViewController ()

@end

@implementation PSHMessagingViewController

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
    [self initChatHeads];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI elements

- (void) initChatHeads {
    
    NSArray * chatsArray = [ChatMessage findAllSortedBy:@"createdDate" ascending:NO];
    if ([chatsArray count] > 0){
        
        // get latest message
        ChatMessage * firstMessage = chatsArray[0];
        
        PSHChatHead * chatHead = [[PSHChatHead alloc] init];
        chatHead.badgeLabel.text = @"1";
        
        chatHead.frame = CGRectMake(100.0f, 100.0f, 80.0f, 80.0f);
        [self.view addSubview:chatHead];
        
        NSString * fromGraphID = firstMessage.fromGraphID;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            PSHFacebookDataService * dataService = [PSHFacebookDataService sharedService];
            [dataService fetchSourceCoverImageURLFor:fromGraphID success:^(NSString * coverImageURL, NSString * avartarImageURL) {
                
                UIImage * fromImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avartarImageURL]]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    chatHead.profileImageView.clipsToBounds = YES;
                    chatHead.profileImageView.autoresizesSubviews = YES;
                    [chatHead.profileImageView.layer setCornerRadius:40.0f];
                    [chatHead.profileImageView.layer setMasksToBounds:YES];
                    
                    chatHead.profileImageView.image = fromImage;
                    
                });
            }];
        });
        
        
    }
    
}


@end
