//
//  SHGameCoordinator.h
//  Closer
//
//  Created by shani hajbi on 2/24/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, PlayerMode)
{
    PlayerModeAdult,
    PlayerModeKid
};



typedef NS_ENUM(NSInteger, MainGames)
{
    MainGamesLetters,
    MainGamesNumbers,
    MainGamesShapes,
    MainGamesShadows,
    MainGamesAnimals,
    MainGamesColors,
    
    MAIN_GAMES_COUNT
};



typedef NS_ENUM(NSUInteger, Prizes)
{
    PrizeBox,
    PrizeMedal,
    PrizeTrophy,
    PrizeLettersMaster,
    PrizeNumbersMaster
};

typedef NS_ENUM(NSUInteger, VoiceFeedbacks)
{
    VoiceFeedbackHorray,
    VoiceFeedbackGreat,
    VoiceFeedbackChampion,
};

//1000

typedef NS_ENUM(NSUInteger, MenuMessage)
{
    MenuMessageMaimMenuNavigation = 1000,
    MenuMessageSelectMainGame = 1100,
    MenuMessageBackToMainMenu = 1200,
    MenuMessageSubGameNavigation = 1300,
    MenuMessageSelectSubGame = 1400,
    MenuMessageBackToSubGamesMenu = 1500,
};

//2000
typedef NS_ENUM(NSUInteger, ProgressMessage)
{
    ProgressMessageStartGame = 2000,
    ProgressMessageGoToGameStep = 2100,
    ProgressMessageEndGame = 2200,
};

typedef NS_ENUM(NSUInteger, FeedbackMessage)
{
    FeedbackMessage1 = 3000,
    FeedbackMessage2 = 3001,
    FeedbackMessage3 = 3002,
};


typedef NS_ENUM(NSUInteger, MessageType)
{
    MessageTypeMenu = 1,
    MessegeTypeProgress = 2,
    MessageTypeFeedback = 3,
};





@interface SHMessagesCoordinator : NSObject
+ (id)sharedCoordinator;

typedef void(^SHCoordinatorMenuHandler)(MenuMessage message, NSUInteger menuItemIndex);
typedef void(^SHCoordinatorProgressHandler)(ProgressMessage message, NSUInteger stepIndex);
typedef void(^SHCoordinatorFeedbackHandler)(FeedbackMessage message);

@property (nonatomic) PlayerMode playerMode;
@property (nonatomic) BOOL playerIsAdmin;

- (void)sendMessageOfType:(MessageType)messegeType message:(NSUInteger)message index:(NSInteger)index;

- (void)startUpdatingAdminMenuMessages:(SHCoordinatorMenuHandler)menuHandler;
- (void)startUpdatingAdminProgressMessages:(SHCoordinatorProgressHandler)progressHandler;
- (void)startUpdatingAdminFeedbackMessages:(SHCoordinatorFeedbackHandler)feedbackHandler;
@end
