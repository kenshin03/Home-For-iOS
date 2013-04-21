//
//  PSHFeedComment.h
//  SocialHome
//
//  Created by Kenny Tang on 4/18/13.
//  Copyright (c) 2013 corgitoergosum.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSHFeedComment : NSObject

@property (nonatomic, strong) NSString * commentGraphID;
@property (nonatomic, strong) NSString * commentorGraphID;
@property (nonatomic, strong) NSString * commentorName;
@property (nonatomic, strong) NSString * comment;
@property (nonatomic, strong) NSDate * createdTime;
@property (nonatomic) NSInteger likesCount;


@end
