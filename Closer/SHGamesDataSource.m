//
//  SHGamesDataSource.m
//  Closer
//
//  Created by shani hajbi on 2/13/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHGamesDataSource.h"
#import "SHGameObject.h"
@implementation SHGamesDataSource

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)setDataSourceForGame:(MainGames)game completion:(void (^)())completion

{
    self.gameObjects = [NSMutableArray array];

    [self createGameObjectsForGame:game completion:^{
        if (completion) {
            completion();
        }
    }];
}

#pragma mark plists
- (void)createGameObjectsForGame:(MainGames)game completion:(void (^)())completion
{
    NSString * path = [[NSBundle mainBundle] pathForResource:kMainGames[game] ofType:@"plist"];
    NSArray * gameObjectsList = [[NSArray alloc] initWithContentsOfFile:path];
   
    for (NSDictionary *dic in gameObjectsList)
    {
        SHGameObject *gameObject = [[SHGameObject alloc] initWithTitle:dic[@"title"] imageName:dic[@"imageName"] instructionsString:dic[@"instructions"]];
        [self.gameObjects addObject:gameObject];
    }
    if (completion) {
        completion();
    }
}

- (void)setGameObjects:(NSMutableArray *)gameObjects
{
    _gameObjects = gameObjects;
}

@end
