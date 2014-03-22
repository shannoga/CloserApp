//
//  SHControllerContext.h
//  Closer
//
//  Created by shani hajbi on 3/1/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHGamesMenuController.h"
@class SHGamesController;

@interface SHControllerContext : NSObject
@property (nonatomic,strong) SHGamesMenuController *menuController;
@property (nonatomic,strong) SHGamesController *gamesController;

- (void)setUpControllers;
@end
