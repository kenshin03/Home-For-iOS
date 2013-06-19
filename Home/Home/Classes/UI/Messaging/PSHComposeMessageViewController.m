//
//  PSHComposeMessageViewController.m
//  Home
//
//  Created by Kenny Tang on 6/5/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import "PSHComposeMessageViewController.h"
#import "PSHFacebookDataService.h"

@interface PSHComposeMessageViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UITableView *recipientsTableView;
@property (weak, nonatomic) IBOutlet UITextField *recipientsTextField;

@property (nonatomic, strong) PSHFacebookDataService * facebookDataService;
@property (nonatomic, strong) NSMutableArray * matchingRecipientsArray;

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
    
    self.recipientsTextField.text = @"";
    [self.recipientsTextField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    self.recipientsTableView.hidden = YES;
    [self.recipientsTableView removeFromSuperview];
    self.matchingRecipientsArray = [@[] mutableCopy];
    
    self.facebookDataService = [PSHFacebookDataService sharedService];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
}

- (IBAction)textFieldValueChanged:(UITextField *)textField  {
    NSString * editedText = textField.text;
    NSLog(@"editedText: %@", editedText);
    [self.facebookDataService searchFriendsWithName:editedText success:^(NSArray *searchResultsArray, NSError *error) {
        // reload table
    }];
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
        /*
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
         */
    return nil;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.matchingRecipientsArray count];
}




@end
