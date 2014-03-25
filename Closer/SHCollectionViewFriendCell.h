//
//  SHCollectionViewFriendCell.h
//  Closer
//
//  Created by shani hajbi on 3/25/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SHCollectionViewFriendCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet PFImageView *friendImageView;
@property (nonatomic, weak) IBOutlet UILabel *friendNameLabel;
@end
