//
//  PSHHomeButtonView.m
//  SocialHome
//
//  Created by Kenny Tang on 4/19/13.
//  Copyright (c) 2013 corgitoergosum.net. All rights reserved.
//

#import "PSHHomeButtonView.h"

@implementation PSHHomeButtonView

- (id)initWithCoder:(NSCoder *)coder  {
    if (self = [super init]) {
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSLog(@"initWithFrame");
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
