//
//  SHCollectionViewFriendCell.m
//  Closer
//
//  Created by shani hajbi on 3/25/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHCollectionViewFriendCell.h"

@implementation SHCollectionViewFriendCell

- (void)awakeFromNib
{
    self.friendImageView.layer.cornerRadius = CGRectGetHeight(self.friendImageView.bounds)/2;
    self.friendImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.friendImageView.layer.borderWidth = 2;
    self.friendImageView.layer.masksToBounds = YES;
    self.contentView.backgroundColor = [UIColor clearColor];
}

- (void)layoutSubviews
{
    
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
