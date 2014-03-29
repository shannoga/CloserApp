//
//  SHControllerContext.m
//  Closer
//
//  Created by shani hajbi on 3/1/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHControllerContext.h"
#import "SHGamesMenuController.h"
#import "SHGamesController.h"
#import "SHOoVooSDKController.h"
#import "SHPuserController.h"

@implementation SHControllerContext

- (void)setUpControllers
{
    self.menuController = [[SHGamesMenuController alloc] init];
    self.menuController.context = self;
    
    self.gamesController = [[SHGamesController alloc] init];
    self.gamesController.context = self;
    
    self.sdkController = [[SHOoVooSDKController alloc] init];
    self.sdkController.context = self;
    
    self.pusherController = [[SHPuserController alloc] init];
    self.pusherController.context = self;
}
@end
