//
//  PSHInboxHeaderTableViewCell.m
//  Home
//
//  Created by Kenny Tang on 6/5/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import "PSHInboxHeaderTableViewCell.h"

@implementation PSHInboxHeaderTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction)messageButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(inboxHeaderTableViewCell:didTapOnWritePostButton:)]){
        [self.delegate inboxHeaderTableViewCell:self didTapOnWritePostButton:YES];
    }
    
}

@end
