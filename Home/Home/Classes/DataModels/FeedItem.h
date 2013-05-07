//
//  FeedItem.h
//  Home
//
//  Created by Kenny Tang on 5/7/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ItemSource;

@interface FeedItem : NSManagedObject

@property (nonatomic, retain) NSNumber * commentsCount;
@property (nonatomic, retain) NSDate * createdTime;
@property (nonatomic, retain) NSString * graphID;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSNumber * likedByMe;
@property (nonatomic, retain) NSNumber * likesCount;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSDate * updatedTime;
@property (nonatomic, retain) NSString * latestCommentors;
@property (nonatomic, retain) ItemSource *source;

@end
