//
//  SHGameDescriptionViewController.h
//  Closer
//
//  Created by shani hajbi on 2/11/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHBaseViewController.h"

@interface SHGameDescriptionViewController : SHBaseViewController
@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;
@property MainGames mainGame;
- (void)adminSelectedMainGame;
- (void)adminDidGoBackToMainMenu;
- (void)adminDidSelectSubGameIndex:(NSInteger)subGameIndex;
@end
