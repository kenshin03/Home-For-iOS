//
//  PSHChatHead.m
//  Home
//
//  Created by Kenny Tang on 5/14/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import "PSHChatHead.h"

@implementation PSHChatHead

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)init{
    self = [super init];
    if (self){
        
        UINib *nib = [UINib nibWithNibName:@"PSHChatHead" bundle:nil];
        NSArray *nibArray = [nib instantiateWithOwner:self options:nil];
        self = nibArray[0];
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
