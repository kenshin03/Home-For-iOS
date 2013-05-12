//
//  PSHFacebookDataService.m
//  SocialHome
//
//  Created by Kenny Tang on 4/12/13.
//  Copyright (c) 2013 corgitoergosum.net. All rights reserved.
//

#import "PSHFacebookDataService.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

#import "PSHConstants.h"
#import "FeedItem.h"
#import "ItemSource.h"
#import "PSHFeedComment.h"
#import "PSHNotification.h"

typedef void (^InitAccountSuccessBlock)();

@interface PSHFacebookDataService()

@property (nonatomic, strong) ACAccountStore * accountStore;
@property (nonatomic, strong) ACAccount * facebookAccount;
@property (nonatomic, strong) NSDateFormatter * dateFormatter;
@property (nonatomic, strong) NSNumberFormatter * numberFormatter;
@property (nonatomic, strong) NSArray * handledStatusFeedTypes;
@property (nonatomic, strong) NSArray * handledPhotoFeedTypes;


@end


@implementation PSHFacebookDataService

+ (PSHFacebookDataService*) sharedService {
    static PSHFacebookDataService * singleton = nil;
	static dispatch_once_t once;
	dispatch_once(&once, ^{
        singleton = [[self alloc] init];
    });
	return singleton;
}

- (id)init {
    self = [super init];
    if (self){
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZ";
        self.numberFormatter = [[NSNumberFormatter alloc] init];
        self.numberFormatter.numberStyle = kCFNumberFormatterNoStyle;
        self.handledPhotoFeedTypes = @[@"added_photos", @"mobile_status_update", @"shared_story"];
        self.handledStatusFeedTypes = @[@"mobile_status_update", @"wall_post"];
    }
    return self;
}

- (void) initAccount:(InitAccountSuccessBlock)success {
    if (self.accountStore == nil){
        self.accountStore = [[ACAccountStore alloc] init];
    }
    
    // separate request for read and writes
    ACAccountType * facebookAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSDictionary * readOptions = @{ACFacebookAppIdKey:kPSHFacebookAppID, ACFacebookPermissionsKey: @[@"email", @"read_stream", @"user_photos", @"user_activities", @"friends_activities"], ACFacebookAudienceKey:ACFacebookAudienceEveryone};
    [self.accountStore requestAccessToAccountsWithType:facebookAccountType options:readOptions
                                            completion: ^(BOOL granted, NSError *e) {
                                                
                                                DDLogVerbose(@"granted: %i", granted);
                                                DDLogVerbose(@"error: %@", e);
                                                
                                                // to-do: clean up this code
                                                
                                                if (granted) {
                                                    NSArray *accounts = [self.accountStore accountsWithAccountType:facebookAccountType];
                                                    //it will always be the last object with SSO
                                                    self.facebookAccount = [accounts lastObject];
                                                    
                                                    NSDictionary * facebookOptions = @{ACFacebookAppIdKey:kPSHFacebookAppID, ACFacebookPermissionsKey: @[@"publish_actions", @"publish_stream", @"manage_notifications"], ACFacebookAudienceKey:ACFacebookAudienceFriends};
                                                    
                                                    //    ACAccountType * facebookAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
                                                    [self.accountStore requestAccessToAccountsWithType:facebookAccountType options:facebookOptions
                                                                                            completion: ^(BOOL granted, NSError *error) {
                                                                                                DDLogVerbose(@"granted: %i", granted);
                                                                                                DDLogError(@"error: %@", error);
                                                                                                if (granted) {
                                                                                                    NSArray *accounts = [self.accountStore accountsWithAccountType:facebookAccountType];
                                                                                                    
                                                                                                    DDLogVerbose(@"accounts: %@", accounts);
                                                                                                    //it will always be the last object with SSO
                                                                                                    self.facebookAccount = [accounts lastObject];
                                                                                                    success();
                                                                                                } else {
                                                                                                    
                                                                                                    dispatch_sync(dispatch_get_main_queue(), ^{
                                                                                                        
                                                                                                        if ((error.code == 7) || (error.code == 6)){
                                                                                                            // User tapped 'Don't Allow'
                                                                                                            // Error Domain=com.apple.accounts Code=7 "The operation couldn’t be completed. (com.apple.accounts error 7.)"
                                                                                                            // FB account not set up on device
                                                                                                            // The operation couldn’t be completed. (com.apple.accounts error 6.)
                                                                                                            
                                                                                                            UIAlertView *alert = [[UIAlertView alloc]
                                                                                                                                  initWithTitle:@"Facebook account not set up"
                                                                                                                                  message:@"Please set up facebook account in Settings first"
                                                                                                                                  delegate:self
                                                                                                                                  cancelButtonTitle:@"Okay"
                                                                                                                                  otherButtonTitles:nil,nil];
                                                                                                            
                                                                                                            [alert show];
                                                                                                            
                                                                                                        }
                                                                                                    });
                                                                                                } }];
                                                    
                                                } else {
                                                    //Fail gracefully...
                                                    dispatch_sync(dispatch_get_main_queue(), ^{
                                                        DDLogVerbose(@"error getting permission %@",e);
                                                        UIAlertView *alert = [[UIAlertView alloc]
                                                                              initWithTitle:@"Facebook account not set up"
                                                                              message:@"Please set up facebook account in Settings first"
                                                                              delegate:self
                                                                              cancelButtonTitle:@"Okay"
                                                                              otherButtonTitles:nil,nil];
                                                        
                                                        [alert show];
                                                    });
                                                    
                                                } }];
    

}



- (void) fetchOwnProfile:(FetchProfileSuccess)fetchProfileSuccess{
    
    InitAccountSuccessBlock successBlock = ^{
        [self _fetchOwnProfile:fetchProfileSuccess];
    };
    
    if (self.facebookAccount == nil){
        [self initAccount:successBlock];
    }else{
        successBlock();
    }
}

- (void) _fetchOwnProfile:(FetchProfileSuccess)fetchProfileSuccess{
    
    NSURL * feedURL = [NSURL URLWithString:@"https://graph.facebook.com/me"];
    
    NSDictionary * params = @{@"fields":@"picture"};
    SLRequest * request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:feedURL parameters:params];
    DDLogVerbose(@"request.URL: %@", request.URL);
    request.account = self.facebookAccount;
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSString * responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        DDLogVerbose(@"responseString: %@", responseString);
        NSError* responseError;
        NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&responseError];
        
        NSString * graphID = jsonDict[@"id"];
        NSString * avartarImageURL = jsonDict[@"picture"][@"data"][@"url"];
        
        fetchProfileSuccess(graphID, avartarImageURL, nil);
    }];
}

- (void) removeAllCachedFeeds:(Success)successBlock {
    
//    NSArray * feedItemsArray = [FeedItem findAllSortedBy:@"createdTime" ascending:NO];
//    [feedItemsArray enumerateObjectsUsingBlock:^(FeedItem * feed, NSUInteger idx, BOOL *stop) {
//        [feed deleteInContext:[NSManagedObjectContext defaultContext]];
//        DDLogVerbose(@"deleteing feed...");
//    }];
    
    [FeedItem MR_truncateAllInContext:[NSManagedObjectContext defaultContext]];
    [[NSManagedObjectContext MR_defaultContext] saveWithOptions:MRSaveSynchronously completion:^(BOOL success, NSError *error) {
        //
        DDLogVerbose(@"removeAllCachedFeeds");
        successBlock();
    }];
    
    
}

- (void) fetchFeed:(FetchFeedSuccess)fetchFeedSuccess {
    
    InitAccountSuccessBlock successBlock = ^{
        [self _fetchFeed:fetchFeedSuccess];
    };
    
    if (self.facebookAccount == nil){
        [self initAccount:successBlock];
    }else{
        successBlock();
    }
}

- (void) _fetchFeed:(FetchFeedSuccess)fetchFeedSuccess{
    
    NSURL * feedURL = [NSURL URLWithString:@"https://graph.facebook.com/me/home"];
    
    
    NSDictionary * params = @{@"limit":@"100"};
    SLRequest * request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:feedURL parameters:params];
    DDLogVerbose(@"request.URL: %@", request.URL);
    request.account = self.facebookAccount;
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSString * responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        DDLogVerbose(@"responseString: %@", responseString);
        NSError* responseError;
        NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&responseError];
        [self parseHomeDataJSON:jsonDict fetchFeedSuccess:fetchFeedSuccess];

    }];
}

- (void) parseHomeDataJSON:(NSDictionary*)jsonDict fetchFeedSuccess:(FetchFeedSuccess)fetchFeedSuccess{
    [jsonDict[@"data"] enumerateObjectsUsingBlock:^(NSDictionary * dataDict, NSUInteger idx, BOOL *stop) {
        
        
        NSString * graphID = dataDict[@"id"];
        NSString * type = dataDict[@"type"];
        NSString * statusType = dataDict[@"status_type"];
        NSString * story = dataDict[@"story"];
        
        NSArray * foundItems = [FeedItem findByAttribute:@"graphID" withValue:graphID];
        DDLogVerbose(@"found?:%i type:%@ subType:%@", [foundItems count], type, statusType);
        if (([foundItems count] == 0) && [self isHandledFeedType:type subType:statusType]){
            
            // timestamps
            NSString * createdTime = dataDict[@"created_time"];
            NSString * updatedTime = dataDict[@"updated_time"];
            
        
            // source
            NSString * fromGraphID = dataDict[@"from"][@"id"];
            NSString * fromCategory = dataDict[@"from"][@"category"];
            NSString * fromName = dataDict[@"from"][@"name"];
            ItemSource * feedSource = [ItemSource createInContext:[NSManagedObjectContext defaultContext]];
            feedSource.category = fromCategory;
            feedSource.graphID = fromGraphID;
            feedSource.name = fromName;
            
            // common attributes
            NSString * message = dataDict[@"message"];
            //        NSString * caption = dataDict[@"caption"];
            
            // likes and comments
            NSNumber * likesCount;
            NSNumber * commentsCount;
            NSString * latestCommentators;
            BOOL likedByMe = NO;
            if (dataDict[@"likes"]){
                likesCount = [NSNumber numberWithInt:[dataDict[@"likes"][@"count"] integerValue]];
                likedByMe = [self checkIfPostIsLikedByMe:dataDict[@"likes"]];
            }
            if (dataDict[@"comments"][@"data"]){
                commentsCount = [NSNumber numberWithInt:[dataDict[@"comments"][@"count"] integerValue]];
                NSArray * commentatorsArray = dataDict[@"comments"][@"data"];
                if ([commentatorsArray count] > 1){
                    NSString * commentatorNames = [NSString stringWithFormat:@"%@, %@", commentatorsArray[0][@"from"][@"name"], commentatorsArray[1][@"from"][@"name"]];
                    
                    if ([commentsCount integerValue] > 2){
                        latestCommentators = [NSString stringWithFormat:@"%@ and %i others", commentatorNames, [commentsCount integerValue]];
                    }
                }
            }
            
            // place
            /*
             "place":{
             "id":"115684475121527",
             "name":"Round Table Pizza",
             "location":{
             "street":"860 Old San Francisco Rd",
             "city":"Sunnyvale",
             "state":"CA",
             "country":"United States",
             "zip":"94086-8101",
             "latitude":37.366364599963,
             "longitude":-122.01638825862
             }
             },
             */
            
            // start populating feedItem
            FeedItem * feedItem = [FeedItem createInContext:[NSManagedObjectContext defaultContext]];
            feedItem.graphID = graphID;
            feedItem.type = type;
            feedItem.message = message;
            if (dataDict[@"story"]){
                feedItem.message = dataDict[@"story"];
            }
            if (dataDict[@"caption"]){
                feedItem.message = dataDict[@"caption"];
                if (dataDict[@"name"]){
                    feedItem.message = [NSString stringWithFormat:@"%@ %@", feedItem.message, dataDict[@"name"]];
                }
            }
            feedItem.likesCount = likesCount;
            feedItem.commentsCount = commentsCount;
            feedItem.latestCommentors = latestCommentators;
            feedItem.likedByMe = [NSNumber numberWithBool:likedByMe];
            
            // handling for photos
            if ([type isEqualToString:@"photo"]){
                if (([statusType isEqualToString:@"added_photos"]) || (story != nil) || ([statusType isEqualToString:@"mobile_status_update"]) || ([statusType isEqualToString:@"shared_story"])){
                    NSString * imageURL = dataDict[@"picture"];
                    imageURL = [imageURL stringByReplacingOccurrencesOfString:@"_s" withString:@"_n"];
                    feedItem.imageURL = imageURL;
                }
            }else if ([type isEqualToString:@"status"]){
                if ((!dataDict[@"picture"]) && (([statusType isEqualToString:@"mobile_status_update"]) || ([statusType isEqualToString:@"wall_post"]))){
                    // get image from source graphID
                    
                    
                    FetchSourceCoverImageSuccessBlock sucessBlock = ^(NSString * coverImageURL, NSString * avartarImageURL){
                        feedItem.imageURL = coverImageURL;
                        feedItem.source.imageURL = avartarImageURL;
                        
                        [[NSManagedObjectContext MR_defaultContext] saveWithOptions:MRSaveSynchronously completion:^(BOOL success, NSError *error) {
                            //
                            DDLogVerbose(@"saving cover images");
                        }];
                        
                    };
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [self fetchSourceCoverImageURLFor:fromGraphID success:sucessBlock];
                        
                    });
                }
            }
            
            feedItem.createdTime = [self.dateFormatter dateFromString:createdTime];
            feedItem.updatedTime = [self.dateFormatter dateFromString:updatedTime];
            
            feedItem.source = feedSource;
        }
    }];
    
    [[NSManagedObjectContext MR_defaultContext] saveWithOptions:MRSaveSynchronously completion:^(BOOL success, NSError *error) {
        //
        DDLogVerbose(@"saving all feed items");
        NSArray * feedItemsArray = [FeedItem findAllSortedBy:@"createdTime" ascending:NO];
        fetchFeedSuccess(feedItemsArray, nil);
        
    }];
    
}

- (BOOL) isHandledFeedType:(NSString*)feedType subType:(NSString*)subType{
    if ([feedType isEqualToString:@"photo"]){
        return [self.handledPhotoFeedTypes containsObject:subType];
    }else if ([feedType isEqualToString:@"status"]){
        return [self.handledStatusFeedTypes containsObject:subType];
    }else{
        return NO;
    }
}

- (void)fetchSourceCoverImageURLFor:(NSString*)fromGraphID success:(FetchSourceCoverImageSuccessBlock) successBlock{
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@?fields=cover,picture", fromGraphID]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSString * coverImageURLString = nil;
        NSString * avartarImageURLString = nil;
        
        if ([JSON valueForKeyPath:@"cover.source"]){
            coverImageURLString = [JSON valueForKeyPath:@"cover.source"];
        }
        if ([JSON valueForKeyPath:@"picture.data.url"]){
            avartarImageURLString = [JSON valueForKeyPath:@"picture.data.url"];
        }
        
        successBlock(coverImageURLString, avartarImageURLString);
        
    } failure:nil];
    [operation start];
}

#pragma mark - Likes and Comments

- (void) unlikeFeed:(NSString*)graphID {
    
    DDLogVerbose(@"unlikeFeed");
    
    InitAccountSuccessBlock successBlock = ^{
        NSString * graphIDSuffix = [graphID componentsSeparatedByString:@"_"][1];
        NSString * likeURLString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/likes", graphIDSuffix];
        NSURL * feedURL = [NSURL URLWithString:likeURLString];
        
        SLRequest * request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodDELETE URL:feedURL parameters:nil];
        DDLogVerbose(@"request.URL: %@", request.URL);
        request.account = self.facebookAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            NSString * responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            DDLogVerbose(@"responseString: %@", responseString);
        }];
    };
    
    if (self.facebookAccount == nil){
        [self initAccount:successBlock];
    }else{
        successBlock();
    }
    
}

- (void) likeFeed:(NSString*)graphID {
    
    DDLogVerbose(@"likeFeed");
    
    InitAccountSuccessBlock successBlock = ^{
        NSString * likeURLString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/likes", graphID];
        NSURL * feedURL = [NSURL URLWithString:likeURLString];
        
        SLRequest * request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodPOST URL:feedURL parameters:nil];
        DDLogVerbose(@"request.URL: %@", request.URL);
        request.account = self.facebookAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            NSString * responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            DDLogVerbose(@"responseString: %@", responseString);
        }];
    };
    
    if (self.facebookAccount == nil){
        [self initAccount:successBlock];
    }else{
        successBlock();
    }
}


- (void) fetchNotifications:(FetchNotificationsSuccess)fetchNotificationsSuccess {
    
    InitAccountSuccessBlock successBlock = ^{
        
//        NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me/notifications?include_read=true"];
        NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me/notifications"];
        SLRequest * request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:url parameters:@{@"include_read":@"true"}];
        DDLogVerbose(@"request.URL: %@", request.URL);
        request.account = self.facebookAccount;
        
        NSMutableArray * notificationResultsArray = [@[] mutableCopy];
        
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            NSString * responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            DDLogVerbose(@"responseString: %@", responseString);
            NSError* responseError;
            NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&responseError];
            
            NSArray * notificationsJSONArray = jsonDict[@"data"];
            [notificationsJSONArray enumerateObjectsUsingBlock:^(NSDictionary * notificationJSONDict, NSUInteger idx, BOOL *stop) {
                
                PSHNotification * notification = [[PSHNotification alloc] init];
                
                id fromID = notificationJSONDict[@"from"][@"id"];
                notification.fromGraphID = fromID;
                notification.title = notificationJSONDict[@"title"];
                
                [notificationResultsArray addObject:notification];
            }];
            fetchNotificationsSuccess(notificationResultsArray, nil);
            
        }];
    };
    
    
    if (self.facebookAccount == nil){
        [self initAccount:successBlock];
    }else{
        successBlock();
    }
    
}


- (void) fetchComments:(NSString*)graphID success:(FetchCommentsSuccess)fetchCommentsSuccess {

    
    InitAccountSuccessBlock successBlock = ^{

        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/comments", graphID]];
        SLRequest * request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:url parameters:@{@"filter":@"toplevel"}];
        DDLogVerbose(@"request.URL: %@", request.URL);
        request.account = self.facebookAccount;
        
        NSMutableArray * commentsResultsArray = [@[] mutableCopy];
        
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            NSString * responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            DDLogVerbose(@"responseString: %@", responseString);
            NSError* responseError;
            NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&responseError];
                                                                              
            NSArray * commentsJSONArray = jsonDict[@"data"];
            [commentsJSONArray enumerateObjectsUsingBlock:^(NSDictionary * commentsJSONDict, NSUInteger idx, BOOL *stop) {
                PSHFeedComment * comment = [[PSHFeedComment alloc] init];
                
                if (commentsJSONDict[@"id"]){
                    comment.commentGraphID = commentsJSONDict[@"id"];
                }
                if ([commentsJSONDict valueForKeyPath:@"from.name"]){
                    comment.commentorName = [commentsJSONDict valueForKeyPath:@"from.name"];
                }
                if ([commentsJSONDict valueForKeyPath:@"from.id"]){
                    comment.commentorGraphID = [commentsJSONDict valueForKeyPath:@"from.id"];
                }
                comment.likesCount = [commentsJSONDict[@"like_count"] integerValue];
                comment.createdTime = [self.dateFormatter dateFromString:commentsJSONDict[@"created_time"]];
                comment.comment = commentsJSONDict[@"message"];
                [commentsResultsArray addObject:comment];
            }];
            fetchCommentsSuccess(commentsResultsArray, nil);
            
        }];
    };
    
    
    if (self.facebookAccount == nil){
        [self initAccount:successBlock];
    }else{
        successBlock();
    }
    
}


- (void) postComment:(NSString*) message forItem:(NSString*)itemGraphID success:(Success)commentSuccessBlock{
    
    InitAccountSuccessBlock successBlock = ^{
        
        NSDictionary * params = @{@"message": message};
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/comments", itemGraphID]];
        SLRequest * request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodPOST URL:url parameters:params];
        DDLogVerbose(@"request.URL: %@", request.URL);
        request.account = self.facebookAccount;
        
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            NSString * responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            DDLogVerbose(@"responseString: %@", responseString);
            commentSuccessBlock();
        }];
        
    };
    
    if (self.facebookAccount == nil){
        [self initAccount:successBlock];
    }else{
        successBlock();
    }
    
}

- (BOOL) checkIfPostIsLikedByMe:(NSDictionary*)likesDict {
    __block BOOL isLikedByMe = NO;
    NSString * ownGraphID = [NSString stringWithFormat:@"%ld", [(NSNumber*)[self.facebookAccount valueForKeyPath:@"properties.uid"] longValue]];
    NSArray * likedData = likesDict[@"data"];
    
    [likedData enumerateObjectsUsingBlock:^(NSDictionary * likeDict, NSUInteger idx, BOOL *stop) {
        NSString * idString = likeDict[@"id"];
        if ([idString isEqualToString:ownGraphID]){
            isLikedByMe = YES;
        }
    }];
    return isLikedByMe;
}

@end
