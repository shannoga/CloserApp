//
//  SHGamesProvider.h
//  Closer
//
//  Created by shani hajbi on 3/1/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const kMainGames[] = {
    [MainGamesLetters]            = @"Letters",
    [MainGamesNumbers]            = @"Numbers",
    [MainGamesShapes]             = @"Shapes",
    [MainGamesShadows]            = @"Shadows",
    [MainGamesAnimals]            = @"Animals",
    [MainGamesColors]             = @"Colors",
};

static NSString *const kMainGamesImages[] = {
    [MainGamesLetters]            = @"Letters",
    [MainGamesNumbers]            = @"Numbers",
    [MainGamesShapes]             = @"Shapes",
    [MainGamesShadows]            = @"Shadows",
    [MainGamesAnimals]            = @"sheep",
    [MainGamesColors]             = @"Colors",
};

#pragma mark letters games
typedef NS_ENUM(NSInteger, LettersGames)
{
    GameLettersSingleLetter,
    LETTERS_GAMES_COUNT
};

static NSString *const kLettersGamesGameControllerType[] = {
    [GameLettersSingleLetter]            = @"SingleObjectGameController",
};

#pragma mark shapes games
typedef NS_ENUM(NSInteger, ShapesGames)
{
    GameShapesSingleSahpe,
    SHAPES_GAMES_COUNT
};

static NSString *const kShapesGamesGameControllerType[] = {
    [GameShapesSingleSahpe]            = @"SingleObjectGameController",
};

#pragma mark colors games
typedef NS_ENUM(NSInteger, ColorsGames)
{
    GamsColorsSingleColor,
    GamsColorsMixingColors,
    COLORS_GAMES_COUNT
};

static NSString *const kColorsGamesGameControllerType[] = {
    [GamsColorsSingleColor]            = @"SingleObjectGameController",
    [GamsColorsMixingColors]            = @"SingleObjectGameController",

};

#pragma mark colors games
typedef NS_ENUM(NSInteger, ShadowsGames)
{
    GamesShadowsSingleShadow,
    SHADOWS_GAMES_COUNT
};

static NSString *const kShadowsGamesGameControllerType[] = {
    [GamesShadowsSingleShadow]            = @"SingleObjectGameController",
};

#pragma mark numbers games
typedef NS_ENUM(NSInteger, NumbersGames)
{
    GameNumbersSingleNumber,
    GameNumbersBiggerAndSmaller,
    NUMBERS_GAMES_COUNT
};

static NSString *const kNumbersGamesGameControllerType[] = {
    [GameNumbersSingleNumber]            = @"SingleObjectGameController",
    [GameNumbersBiggerAndSmaller]            = @"SingleObjectGameController",
};


#pragma mark animals games
typedef NS_ENUM(NSInteger, AnimalsGames)
{
    GameAnimalsSingleAnimal,
    GameAnimalsAnimalSound,
    ANIMALS_GAMES_COUNT
};

static NSString *const kAnimalsGamesGameControllerType[] = {
    [GameAnimalsSingleAnimal]            = @"SingleObjectGameController",
    [GameAnimalsAnimalSound]            = @"SingleObjectGameController",

};


@interface SHGamesProvider : NSObject
//+ (NSArray*)subGamesForGame:(MainGames)game;
+ (NSInteger)numberOfSubGamesForGame:(MainGames)game;
+ (NSString*)titleForMainGame:(MainGames)mainGame localized:(BOOL)localized;
+ (NSString*)titleForSubGame:(MainGames)mainGame atIndex:(NSInteger)index localized:(BOOL)localized;
+ (NSString*)segueNameForMainGame:(MainGames)mainGame atIndex:(NSInteger)index;
@end
