//
//  SHGameMenuViewController.h
//  Closer
//
//  Created by shani hajbi on 2/12/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHBaseViewController.h"

@interface SHGameMenuViewController : SHBaseViewController
@property NSString *titleText;
@property MainGames mainGame;
- (void)adminDidSelectSubGameAtIndex:(NSInteger)index;

@end
