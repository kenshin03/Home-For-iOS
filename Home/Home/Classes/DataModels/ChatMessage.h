//
//  ChatMessage.h
//  Home
//
//  Created by Kenny Tang on 6/24/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ChatMessage : NSManagedObject

@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSString * fromGraphID;
@property (nonatomic, retain) NSNumber * hideFromView;
@property (nonatomic, retain) NSString * messageBody;
@property (nonatomic, retain) NSString * toGraphID;
@property (nonatomic, retain) NSString * threadID;

@end
