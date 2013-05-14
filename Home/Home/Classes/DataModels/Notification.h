//
//  Notification.h
//  Home
//
//  Created by Kenny Tang on 5/14/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Notification : NSManagedObject

@property (nonatomic, retain) NSString * fromGraphID;
@property (nonatomic, retain) NSString * fromImageURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * applicationName;
@property (nonatomic, retain) NSDate * updatedTime;
@property (nonatomic, retain) NSDate * createdTime;
@property (nonatomic, retain) NSString * link;

@end
