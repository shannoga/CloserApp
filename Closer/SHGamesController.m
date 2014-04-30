//
//  SHGamesController.m
//  Closer
//
//  Created by shani hajbi on 2/13/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHGamesController.h"
#import "SHGamesDataSource.h"
#import "SHMessagesCoordinator.h"

@class SHControllerContext;
@interface SHGamesController()
@end

@implementation SHGamesController

- (id)init
{
    self = [super init];
    if (self) {
        self.dataSource = [[SHGamesDataSource alloc] init];
        
       //if ([[SHMessagesCoordinator sharedCoordinator] playerMode] == PlayerModeKid) {
            [self startListeningForProgressMessages];
            [self startListeningForFeedbackMessages];
       //}
    }
    return self;
}

- (void)startNewGame:(MainGames)game completion:(void (^)())completion
{
    [self reset];
    [self preaperGameDataForGame:game completion:^{
        if (completion) {
            completion();
        }
    }];
    
}

- (void)reset
{
    //reset datasource
}

- (void)setWaitigStateForPlayerModeKid
{
    
}

- (void)preaperGameDataForGame:(MainGames)game completion:(void (^)())completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [_dataSource setDataSourceForGame:game completion:^{
            if (completion) {
                completion();
            }
        }];
    });
}


#pragma mark adminActions
- (void)adminDidStartGame
{
    
}

- (void)adminDidEndGame
{
    
}

- (void)adminDidMoveToStepAtIndex:(NSUInteger)index
{
    if ([[SHMessagesCoordinator sharedCoordinator] playerMode] == PlayerModeAdult) {
        [[SHMessagesCoordinator sharedCoordinator] sendMessageOfType:MessegeTypeProgress message:ProgressMessageGoToGameStep index:index];
    }
    else
    {
        [self.gameViewController gotoStepAtIndex:index];
    }
}

- (void)adminDidGotBackToStepAtIndex:(NSUInteger)index
{
    if ([[SHMessagesCoordinator sharedCoordinator] playerMode] == PlayerModeAdult) {
        [[SHMessagesCoordinator sharedCoordinator] sendMessageOfType:MessegeTypeProgress message:ProgressMessageGoToGameStep index:index];
    }
    else
    {
        [self.gameViewController gotoStepAtIndex:index];
    }
}

#pragma mark -feedbacks
- (void)adminDidSendVoiceFeedback:(VoiceFeedbacks)voiceFeedback
{
    
}

- (void)adminDidSendPrize:(Prizes)prize
{
    //present prizes
}

- (void)startListeningForProgressMessages
{
    [[SHMessagesCoordinator sharedCoordinator] startUpdatingAdminProgressMessages:^(ProgressMessage message, NSUInteger stepIndex) {
        switch (message) {
            case ProgressMessageStartGame:
                [self adminDidStartGame];
                break;
            case ProgressMessageGoToGameStep:
                [self adminDidMoveToStepAtIndex:stepIndex];
                break;
            case ProgressMessageEndGame:
                [self adminDidEndGame];
                break;
                
            default:
                break;
        }
    }];
}

- (void)startListeningForFeedbackMessages
{
    [[SHMessagesCoordinator sharedCoordinator] startUpdatingAdminFeedbackMessages:^(FeedbackMessage message) {
        switch (message) {
            case FeedbackMessage1:
                
                break;
            case FeedbackMessage2:
                
                break;
                
            default:
                break;
        }
    }];
}
@end
