//
//  SHMenuController.m
//  Closer
//
//  Created by shani hajbi on 3/1/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHGamesMenuController.h"
#import "SHMessagesCoordinator.h"
#import "SHGameSelectionViewController.h"

@interface SHGamesMenuController()
@property (nonatomic) BOOL playerIsAdmin;
@end

@implementation SHGamesMenuController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _playerIsAdmin = [[SHMessagesCoordinator sharedCoordinator] playerMode] == PlayerModeAdult;
        if (!_playerIsAdmin) {
            [self startLiteningToMenuUpdates];
        }
    }
    return self;
}

- (SHMessagesCoordinator *)coordinator
{
    return [SHMessagesCoordinator sharedCoordinator];
}

- (void)startLiteningToMenuUpdates
{
    [[SHMessagesCoordinator sharedCoordinator] startUpdatingAdminMenuMessages:^(MenuMessage message, NSUInteger menuItemIndex) {
        switch (message) {
            case MenuMessageMaimMenuNavigation:
                [self adminDidMoveToMainMenuAtIndex:menuItemIndex];
                break;
            case MenuMessageSelectMainGame:
                [self adminDidSelectMainGameAtIndex:menuItemIndex];
                break;
            case MenuMessageBackToMainMenu:
                [self adminDidGoBackToMainMenu];
                break;
            case MenuMessageSubGameNavigation:
                //TODO:
                break;
            case MenuMessageSelectSubGame:
                [self adminDidSelectSubGameAtIndex:menuItemIndex];
                break;
            case MenuMessageBackToSubGamesMenu:
                //TODO:
                break;
                
            default:
                break;
        }
    }];

}

- (void)adminDidMoveToMainMenuAtIndex:(NSInteger)index
{
    if (self.playerIsAdmin)
    {
        [[self coordinator] sendMessageOfType:MessageTypeMenu message:MenuMessageMaimMenuNavigation index:index];
    }
    else
    {
        [self.menuViewController adminDidNavigateToPageAtIndex:index];
    }
}

- (void)adminDidSelectMainGameAtIndex:(NSInteger)index
{
    if (self.playerIsAdmin)
    {
        [[self coordinator] sendMessageOfType:MessageTypeMenu message:MenuMessageSelectMainGame index:index];
    }
    else
    {
        [self.menuViewController adminDidSelectPageForMainGame:index];
    }
}

- (void)adminDidGoBackToMainMenu
{
    if (self.playerIsAdmin)
    {
        [[self coordinator] sendMessageOfType:MessageTypeMenu message:MenuMessageBackToMainMenu index:0];
    }
    else
    {
        [self.menuViewController adminDidGoBackToMainMenu];
    }
}

- (void)adminDidSelectSubGameAtIndex:(NSInteger)subGameIndex
{
    if (self.playerIsAdmin)
    {
        [[self coordinator] sendMessageOfType:MessageTypeMenu message:MenuMessageSelectSubGame index:subGameIndex];
    }
    else
    {
        [self.menuViewController adminDidSelectSubGameAtIndex:subGameIndex];
    }
}

- (void)prepareForLogout
{
#warning Impliment
}



@end
