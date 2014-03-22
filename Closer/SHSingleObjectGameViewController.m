//
//  SHSingleObjectGameViewController.m
//  Closer
//
//  Created by shani hajbi on 2/12/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHSingleObjectGameViewController.h"
#import "SHGameObjectView.h"
#import "SHGameObject.h"
#import "SHGamesController.h"
@interface SHSingleObjectGameViewController ()
@property (nonatomic,weak) IBOutlet SHGameObjectView *gameObjectView;
@property (nonatomic) NSInteger currentStepIndex;
@end

@implementation SHSingleObjectGameViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (SHGamesDataSource*)dataSource
{
    return self.controllerContext.gamesController.dataSource;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.currentStepIndex = 0;
    NSAssert(self.dataSource.gameObjects.count, @"Controller has no game objects");
    [self updateObjectForStepIndex:self.currentStepIndex];
}

- (void)gotoNextStep:(UIButton*)sender
{
    if (self.currentStepIndex >= self.dataSource.gameObjects.count -1) {
        return;
    }
    self.currentStepIndex +=1;
    [self gotoStepAtIndex:self.currentStepIndex];
}

- (void)getBackToPrevStep:(UIButton*)sender
{
    if (self.currentStepIndex <= 0) {
        return;
    }
    self.currentStepIndex -=1;
    [self gotoStepAtIndex:self.currentStepIndex];
}

- (void)gotoStepAtIndex:(NSInteger)index
{
    [super gotoStepAtIndex:index];
    if ((index > self.dataSource.gameObjects.count -1) || index < 0) {
        return;
    }
    self.currentStepIndex = index;
    [self updateObjectForStepIndex:self.currentStepIndex];
}

- (void)updateObjectForStepIndex:(NSUInteger)stepIndex
{
    [self.gameObjectView stopParticleEffect];

    SHGameObject *gameObject = self.dataSource.gameObjects[stepIndex];
    self.instructionsLabel.text = gameObject.instructionsString;
    [self.gameObjectView setTitle:gameObject.title];
    [self.gameObjectView setImageName:gameObject.imageName];
    self.instructionsLabel.text = gameObject.instructionsString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
