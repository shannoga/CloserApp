//
//  SHGamesController.h
//  Closer
//
//  Created by shani hajbi on 2/13/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHGameViewController.h"

@class SHControllerContext,SHBaseViewController;

@interface SHGamesController : NSObject
@property (nonatomic,strong) SHControllerContext *context;
@property (nonatomic,strong) SHGameViewController *gameViewController;
@property (nonatomic,strong) SHGamesDataSource *dataSource;
@property (nonatomic) MainGames currentGame;

- (void)startNewGame:(MainGames)game completion:(void (^)())completion;

- (NSInteger)currentGameQuestionIndex;
- (id)getSingleObjectGameObjectForIndex:(NSUInteger)index;

- (void)adminDidMoveToStepAtIndex:(NSUInteger)index;


@end
