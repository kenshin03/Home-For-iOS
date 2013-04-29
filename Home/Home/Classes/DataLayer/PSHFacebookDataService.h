//
//  PSHFacebookDataService.h
//  SocialHome
//
//  Created by Kenny Tang on 4/12/13.
//  Copyright (c) 2013 corgitoergosum.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedItem.h"

typedef void (^Success)();
typedef void (^FetchFeedSuccess)(NSArray * resultsArray, NSError * error);
typedef void (^FetchProfileSuccess)(NSString * graphID, NSString * avartarImageURL, NSError * error);
typedef void (^FetchCommentsSuccess)(NSArray * resultsArray, NSError * error);
typedef void (^FetchSourceCoverImageSuccessBlock)(NSString * coverImageURL, NSString * avartarImageURL);

@interface PSHFacebookDataService : NSObject

+ (PSHFacebookDataService*) sharedService;

- (void) fetchFeed:(FetchFeedSuccess)fetchFeedSuccess;

- (void) fetchOwnProfile:(FetchProfileSuccess)fetchProfileSuccess;

- (void) likeFeed:(NSString*)graphID;

- (void) unlikeFeed:(NSString*)graphID;


- (void) fetchComments:(NSString*)graphID success:(FetchCommentsSuccess)fetchCommentsSuccess;

- (void) postComment:(NSString*) message forItem:(NSString*)itemGraphID success:(Success)successBlock;

- (void) fetchSourceCoverImageURLFor:(NSString*)fromGraphID success:(FetchSourceCoverImageSuccessBlock) successBlock;

- (void) removeAllCachedFeeds:(Success)successBlock;

@end
