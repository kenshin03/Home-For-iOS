//
//  PSHFacebookDataService.h
//  SocialHome
//
//  Created by Kenny Tang on 4/12/13.
//  Copyright (c) 2013 corgitoergosum.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import "FeedItem.h"
#import "ChatMessage.h"

typedef void (^Success)();
typedef void (^FetchFeedSuccess)(NSArray * resultsArray, NSError * error);
typedef void (^FetchNotificationsSuccess)(NSArray * resultsArray, NSError * error);

typedef void (^FetchProfileSuccess)(NSString * graphID, NSString * avartarImageURL, NSError * error);
typedef void (^FetchCommentsSuccess)(NSArray * resultsArray, NSError * error);
typedef void (^FetchSourceCoverImageSuccessBlock)(NSString * coverImageURL, NSString * avartarImageURL, NSString * name);

typedef void (^FetchInboxChatsSuccess)(NSArray * resultsArray, NSError * error);
typedef void (^SearchFriendsSuccess)(NSArray * searchResultsArray, NSError * error);


@interface PSHFacebookDataService : NSObject

+ (PSHFacebookDataService*) sharedService;

@property (nonatomic, strong, readonly) ACAccount * facebookAccount;



- (void) fetchFeed:(FetchFeedSuccess)fetchFeedSuccess;

- (void) fetchOwnProfile:(FetchProfileSuccess)fetchProfileSuccess;

- (void) likeFeed:(NSString*)graphID;

- (void) unlikeFeed:(NSString*)graphID;


- (void) fetchNotifications:(FetchNotificationsSuccess)fetchNotificationsSuccess;

- (void) fetchComments:(NSString*)graphID success:(FetchCommentsSuccess)fetchCommentsSuccess;


- (void) fetchInboxChats:(FetchInboxChatsSuccess)fetchInboxSuccess;

- (void) fetchMessageThread:(NSString*)threadID success:(FetchFeedSuccess)fetchThreadSuccess;



- (void) postComment:(NSString*) message forItem:(NSString*)itemGraphID success:(Success)successBlock;

- (void) fetchSourceCoverImageURLFor:(NSString*)fromGraphID success:(FetchSourceCoverImageSuccessBlock) successBlock;

- (void) removeAllCachedFeeds:(Success)successBlock;

- (void) removeAllCachedNotifications:(Success)successBlock;


- (void) addChatMessage:(NSString*)fromID toID:(NSString*)toID message:(NSString*)message success:(Success)successBlock;


- (void) searchFriendsWithName:(NSString*)nameString success:(SearchFriendsSuccess)successBlock;


@end
