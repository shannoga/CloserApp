//
//  SHAppThemeClasses.h
//  Closer
//
//  Created by shani hajbi on 3/20/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHAppThemeClasses : NSObject

@end

@interface SHButton : UIButton
@property (strong, nonatomic) UIFont *titleFont UI_APPEARANCE_SELECTOR;
@end
