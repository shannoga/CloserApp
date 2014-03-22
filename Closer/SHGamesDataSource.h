//
//  SHGamesDataSource.h
//  Closer
//
//  Created by shani hajbi on 2/13/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHGamesDataSource : NSObject
@property (nonatomic,strong) NSMutableArray *gameObjects;
- (void)setDataSourceForGame:(MainGames)game completion:(void (^)())completion;

@end
