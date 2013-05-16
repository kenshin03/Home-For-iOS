//
//  PSHChatHeadDismissButton.m
//  Home
//
//  Created by Kenny Tang on 5/16/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import "PSHChatHeadDismissButton.h"

@interface PSHChatHeadDismissButton()

@property (weak, nonatomic) IBOutlet UILabel *dragDownToCloseLabel;


@end


@implementation PSHChatHeadDismissButton

-(id)init{
    self = [super init];
    if (self){
        
        UINib *nib = [UINib nibWithNibName:@"PSHChatHeadDismissButton" bundle:nil];
        NSArray *nibArray = [nib instantiateWithOwner:self options:nil];
        self = nibArray[0];
    }
    return self;
}



@end
