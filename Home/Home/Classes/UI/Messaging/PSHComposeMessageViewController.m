//
//  PSHComposeMessageViewController.m
//  Home
//
//  Created by Kenny Tang on 6/5/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import "PSHComposeMessageViewController.h"
#import "PSHFacebookDataService.h"
#import "PSHComposeMessageRecipientsTableViewCell.h"
#import "PSHConversationTableViewCell.h"
#import "PSHUser.h"
#import "AsyncImageView.h"
#import <QuartzCore/QuartzCore.h>

@interface PSHComposeMessageViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UITableView *recipientsTableView;
@property (weak, nonatomic) IBOutlet UITextField *recipientsTextField;

@property (nonatomic, strong) PSHFacebookDataService * facebookDataService;
@property (nonatomic, strong) NSMutableArray * matchingRecipientsArray;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivityIndicatorView;
@property (weak, nonatomic) IBOutlet UILabel *selectedRecipientLabel;

@property (nonatomic, strong) NSMutableArray * conversationsArray;
@property (weak, nonatomic) IBOutlet UITableView *conversationsTableView;


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
    [self findOwnFacebookID];
    
    self.recipientsTextField.text = @"";
    [self.recipientsTextField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    self.recipientsTableView.hidden = YES;
    self.conversationsTableView.hidden = YES;
    self.matchingRecipientsArray = [@[] mutableCopy];
    self.conversationsArray = [@[] mutableCopy];
    
    self.facebookDataService = [PSHFacebookDataService sharedService];
    
    [self.recipientsTableView registerNib:[UINib nibWithNibName:@"PSHComposeMessageRecipientsTableViewCell" bundle:nil] forCellReuseIdentifier:@"kPSHComposeMessageRecipientsTableViewCell"];
    
    [self.conversationsTableView registerNib:[UINib nibWithNibName:@"PSHConversationTableViewCell" bundle:nil] forCellReuseIdentifier:@"kPSHConversationTableViewCell"];
    
    
    
    self.recipientsTableView.delegate = self;
    self.loadingActivityIndicatorView.hidden = YES;
    self.selectedRecipientLabel.hidden = YES;


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)findOwnFacebookID {
    FetchProfileSuccess fetchProfileSuccess =^(NSString * graphID, NSString * avartarImageURL, NSError * error){
        self.ownGraphID = graphID;
    };
    PSHFacebookDataService * facebookDataService = [PSHFacebookDataService sharedService];
    [facebookDataService fetchOwnProfile:fetchProfileSuccess];
    
}


- (void) loadConversationWithSelectedRecipient:(PSHUser *) user {
    self.loadingActivityIndicatorView.hidden = NO;
    
    __block NSString * threadID = nil;
    // find thread id from /inbox
    [self.facebookDataService fetchInboxChats:^(NSArray *resultsArray, NSError *error) {
        
        [resultsArray enumerateObjectsUsingBlock:^(ChatMessage * chatMessage, NSUInteger idx, BOOL *stop) {
            NSString * fromGraphID = chatMessage.fromGraphID;
            NSString * toGraphID = chatMessage.toGraphID;
            if ([user.uid isEqualToString:fromGraphID] || [user.uid isEqualToString:toGraphID]){
                threadID = chatMessage.threadID;
                
                // call graph api with thread
                if (threadID != nil){
                    [self.facebookDataService fetchMessageThread:threadID success:^(NSArray *resultsArray, NSError *error) {
                        [self.conversationsArray removeAllObjects];
                        [self.conversationsArray addObjectsFromArray:resultsArray];
                        [self showSelectedConversationTable];
                    }];
                }
                *stop = YES;
            }
        }];
    }];
}


- (void) showSelectedConversationTable {
    self.conversationsTableView.hidden = NO;
    [self.conversationsTableView reloadData];
    
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:[self.conversationsArray count]-1 inSection:0];
    [self.conversationsTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}


#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
}

- (IBAction)textFieldValueChanged:(UITextField *)textField  {
    NSString * editedText = textField.text;
    NSLog(@"editedText: %@", editedText);
    self.loadingActivityIndicatorView.hidden = NO;
    [self.loadingActivityIndicatorView startAnimating];
    [self.facebookDataService searchFriendsWithName:editedText success:^(NSArray *searchResultsArray, NSError *error) {
        // reload table
        [self.matchingRecipientsArray removeAllObjects];
        [self.matchingRecipientsArray addObjectsFromArray:searchResultsArray];
        self.recipientsTableView.hidden = NO;
        [self.recipientsTableView reloadData];
        self.loadingActivityIndicatorView.hidden = YES;
    }];
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.recipientsTableView){
        [self.recipientsTextField resignFirstResponder];
        self.recipientsTextField.hidden = YES;
        
        self.selectedRecipientLabel.hidden = NO;
        PSHUser * user = self.matchingRecipientsArray[indexPath.row];
        self.selectedRecipientLabel.text = user.name;
        self.selectedRecipientLabel.layer.cornerRadius = 10;
        self.selectedRecipientLabel.layer.masksToBounds = YES;
        
        PSHComposeMessageRecipientsTableViewCell * cell = (PSHComposeMessageRecipientsTableViewCell*)[self.recipientsTableView cellForRowAtIndexPath:indexPath];
        cell.selected = NO;
        
        self.recipientsTableView.hidden = YES;
        
        [self loadConversationWithSelectedRecipient:user];
        
    }else if (tableView == self.conversationsTableView){
        // don't do anything?
        
    }
    
}


#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.recipientsTableView){
    
        PSHComposeMessageRecipientsTableViewCell * cell = (PSHComposeMessageRecipientsTableViewCell*)[self.recipientsTableView dequeueReusableCellWithIdentifier:@"kPSHComposeMessageRecipientsTableViewCell"];
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:cell.userImageView];
        
        cell.userImageView.image = nil;
        cell.namesLabel.text = @"";
        cell.contentView.backgroundColor = [UIColor whiteColor];
        
        PSHUser * user = self.matchingRecipientsArray[indexPath.row];
        cell.namesLabel.text = user.name;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            PSHFacebookDataService * dataService = [PSHFacebookDataService sharedService];
            [dataService fetchSourceCoverImageURLFor:user.uid success:^(NSString * coverImageURL, NSString * avartarImageURL, NSString* name) {
                cell.userImageView.imageURL = [NSURL URLWithString:avartarImageURL];
            }];
        });
        return cell;
        
    }else if (tableView == self.conversationsTableView){
        
        ChatMessage * chatMessage = self.conversationsArray[indexPath.row];

        NSString * fromGraphID = chatMessage.fromGraphID;
        PSHConversationTableViewCell * cell = (PSHConversationTableViewCell*)[self.conversationsTableView dequeueReusableCellWithIdentifier:@"kPSHConversationTableViewCell"];
        cell.messageLabel.text = chatMessage.messageBody;

        CGSize messageSize = [cell.messageLabel.text sizeWithFont:cell.messageLabel.font constrainedToSize:CGSizeMake(320, cell.messageLabel.frame.size.height)];
        CGRect imageFrame = cell.conversationBackgroundImageView.frame;
        imageFrame.size.width = messageSize.width + 20.0f;
        cell.conversationBackgroundImageView.frame = imageFrame;
        
        if ([fromGraphID isEqualToString:self.ownGraphID]){
            cell.isFromSelf = YES;
        }else{
            cell.isFromSelf = NO;
        }
        return cell;
        
    }else{
        return nil;
    }
    
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.recipientsTableView){
        return [self.matchingRecipientsArray count];
        
    }else if (tableView == self.conversationsTableView){
        return [self.conversationsArray count];
        
    }else{
        return 0;
    }
    
}


- (IBAction)cancelButtonTapped:(id)sender {
    [self.delegate composeMessageViewController:self dismissComposeMessage:YES];
}


@end
