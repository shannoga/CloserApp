//
//  SHGameSelectionViewController.h
//  Closer
//
//  Created by shani hajbi on 2/11/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHBaseViewController.h"
@interface SHGameSelectionViewController : SHBaseViewController
- (void)adminDidNavigateToPageAtIndex:(NSInteger)index;
- (void)adminDidSelectPageForMainGame:(NSInteger)index;
- (void)adminDidGoBackToMainMenu;
- (void)adminDidSelectSubGameAtIndex:(NSInteger)subGameIndex;

@end
