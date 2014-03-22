//
//  SHAppThemeClasses.m
//  Closer
//
//  Created by shani hajbi on 3/20/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHAppThemeClasses.h"

@implementation SHAppThemeClasses

@end


@implementation SHButton
- (void)setTitleFont:(UIFont *)font {
    if (_titleFont != font) {
        _titleFont = font;
        self.titleLabel.font = font;
    }
}
@end