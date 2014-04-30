//
//  SHGamesSelectionController.h
//  Closer
//
//  Created by shani hajbi on 3/1/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHMenuProtocol.h"

@class SHControllerContext, SHGameSelectionViewController,SHBaseViewController;
@interface SHGamesMenuController : NSObject
@property (nonatomic,strong) SHControllerContext *context;
@property (nonatomic,strong) SHBaseViewController <SHMenuProtocol> *menuViewController;

- (void)adminDidMoveToMainMenuAtIndex:(NSInteger)index;
- (void)adminDidSelectMainGameAtIndex:(NSInteger)index;
- (void)adminDidGoBackToMainMenu;
- (void)adminDidSelectSubGameAtIndex:(NSInteger)subGameIndex;
- (void)prepareForLogout;
@end
