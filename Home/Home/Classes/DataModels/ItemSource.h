//
//  ItemSource.h
//  Home
//
//  Created by Kenny Tang on 4/21/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FeedItem;

@interface ItemSource : NSManagedObject

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * graphID;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) FeedItem *owner;

@end
