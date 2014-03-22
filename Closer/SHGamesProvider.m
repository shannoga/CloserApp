//
//  SHGamesProvider.m
//  Closer
//
//  Created by shani hajbi on 3/1/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHGamesProvider.h"

@implementation SHGamesProvider


+ (NSInteger)numberOfSubGamesForGame:(MainGames)game
{
    switch (game) {
        case MainGamesAnimals:
            return ANIMALS_GAMES_COUNT;
            break;
        case MainGamesColors:
            return COLORS_GAMES_COUNT;
            break;
        case MainGamesLetters:
            return LETTERS_GAMES_COUNT;
            break;
        case MainGamesNumbers:
            return NUMBERS_GAMES_COUNT;
            break;
        case MainGamesShadows:
            return SHADOWS_GAMES_COUNT;
            break;
        case MainGamesShapes:
            return SHAPES_GAMES_COUNT;
            break;
            
        default:
            break;
    }
    
    return 0;
}


+ (NSString*)titleForMainGame:(MainGames)mainGame localized:(BOOL)localized
{
    switch (mainGame) {
        case MainGamesAnimals:
            return localized ? NSLocalizedString(@"Animals", @"Games titles") : @"Animals";
            break;
        case MainGamesColors:
            return localized ? NSLocalizedString(@"Colors", @"Games titles") : @"Colors";
            break;
        case MainGamesLetters:
            return localized ? NSLocalizedString(@"Letters", @"Games titles") : @"Letters";
            break;
        case MainGamesNumbers:
            return localized ? NSLocalizedString(@"Numbers", @"Games titles") : @"Numbers";
            break;
        case MainGamesShadows:
            return localized ? NSLocalizedString(@"Shadows", @"Games titles") : @"Shadows";
            break;
        case MainGamesShapes:
            return localized ? NSLocalizedString(@"Shapes", @"Games titles") : @"Shapes";
            break;
        default:
            break;
    }
    return @"";
}


+ (NSArray*)subGamesForGame:(MainGames)game
{
    return nil;
}

//sub games
+ (NSString*)localizedNameForNumbersGmaeAtIndex:(NumbersGames)numerGames localized:(BOOL)localized
{
    switch (numerGames) {
        case GameNumbersSingleNumber:
            return localized ? NSLocalizedString(@"Numbers Identification", @"Games titles") : @"Numbers Identification";
            break;
        case GameNumbersBiggerAndSmaller:
            return localized ? NSLocalizedString(@"Bigger or smaller", @"Games titles") : @"Bigger or smaller";
            break;
        case NUMBERS_GAMES_COUNT:
            break;
    }
    return @"";
}

+ (NSString*)localizedNameForLettersGmaeAtIndex:(LettersGames)lettersGame localized:(BOOL)localized
{
    switch (lettersGame) {
        case GameLettersSingleLetter:
            return localized ? NSLocalizedString(@"Letters Identification", @"Games titles") : @"Letters Identification";
            break;
        case LETTERS_GAMES_COUNT:
            break;
    }
    return @"";
}

+ (NSString*)localizedNameForAnimalsGmaeAtIndex:(AnimalsGames)animalsGame localized:(BOOL)localized
{
    switch (animalsGame) {
        case GameAnimalsSingleAnimal:
            return localized ? NSLocalizedString(@"Animals Identification", @"Games titles") : @"Animals Identification";
            break;
        case GameAnimalsAnimalSound:
            return localized ? NSLocalizedString(@"Animals Sounds", @"Games titles") : @"Animals Identification";
            break;
        case ANIMALS_GAMES_COUNT:
            break;
    }
    return @"";
}

+ (NSString*)localizedNameForShadowsGmaeAtIndex:(ShadowsGames)shadowsGame localized:(BOOL)localized
{
    switch (shadowsGame) {
        case GamesShadowsSingleShadow:
            return localized ? NSLocalizedString(@"Shdows Identification", @"Games titles") : @"Shdows Identification";
            break;
        case SHADOWS_GAMES_COUNT:
            break;
    }
    return @"";
}

+ (NSString*)localizedNameForColorsGmaeAtIndex:(ColorsGames)colorsGame localized:(BOOL)localized
{
    switch (colorsGame) {
        case GamsColorsSingleColor:
            return localized ? NSLocalizedString(@"Colors Identification", @"Games titles") : @"Colors Identification";
            break;
        case GamsColorsMixingColors:
            return localized ? NSLocalizedString(@"Colors Mixings", @"Games titles") : @"Colors Mixings";
            break;
        case COLORS_GAMES_COUNT:
            break;
    }
    return @"";
}


+ (NSString*)localizedNameForShapesGmaeAtIndex:(ShapesGames)shapesGame localized:(BOOL)localized
{
    switch (shapesGame) {
        case GameShapesSingleSahpe:
            return localized ? NSLocalizedString(@"Shapes Identification", @"Games titles") : @"Shapes Identification";
            break;
        case SHAPES_GAMES_COUNT:
            break;
    }
    return @"";
}


+ (NSString*)titleForSubGame:(MainGames)mainGame atIndex:(NSInteger)index localized:(BOOL)localized
{
    
    switch (mainGame) {
        case MainGamesAnimals:
            return [self localizedNameForAnimalsGmaeAtIndex:index localized:localized];
            break;
        case MainGamesColors:
            return [self localizedNameForColorsGmaeAtIndex:index localized:localized];
            break;
        case MainGamesLetters:
            return [self localizedNameForLettersGmaeAtIndex:index localized:localized];
            break;
        case MainGamesNumbers:
            return [self localizedNameForNumbersGmaeAtIndex:index localized:localized];
            break;
        case MainGamesShadows:
            return [self localizedNameForShadowsGmaeAtIndex:index localized:localized];
            break;
        case MainGamesShapes:
            return [self localizedNameForShapesGmaeAtIndex:index localized:localized];
            break;
            
        default:
            break;
    }
    
    return @"";
}

+ (NSString*)segueNameForMainGame:(MainGames)mainGame atIndex:(NSInteger)index;
{
    switch (mainGame) {
            
        case MainGamesAnimals:
            return kAnimalsGamesGameControllerType[index];
            break;
        case MainGamesColors:
            return kColorsGamesGameControllerType[index];
            break;
        case MainGamesLetters:
            return kLettersGamesGameControllerType[index];
            break;
        case MainGamesNumbers:
            return kNumbersGamesGameControllerType[index];
            break;
        case MainGamesShadows:
            return kShadowsGamesGameControllerType[index];
            break;
        case MainGamesShapes:
            return kShapesGamesGameControllerType[index];
            break;
            
        default:
            break;
    }
    
    return @"";
    
}

@end
