//
//  SHGameViewController.m
//  Closer
//
//  Created by shani hajbi on 2/12/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHGameViewController.h"
#import "SHGamesDataSource.h"
#import "SHGamesController.h"
#import "SHMessagesCoordinator.h"
@interface SHGameViewController ()
@end

@implementation SHGameViewController


- (void)awakeFromNib
{
 
    // [self.gameDataSource setDataSourceForGame:@"string"];
}

- (void)toggleControllButtons
{
    BOOL shouldHideAdultControls =  ![[SHMessagesCoordinator sharedCoordinator] playerIsAdmin];
    self.nextButton.hidden = self.prevButton.hidden = shouldHideAdultControls;
    self.instructionsLabel.hidden = shouldHideAdultControls;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // if (![[SHGameCoordinator sharedCoordinator] playerIsAdmin]) {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.view layoutIfNeeded];
    // }
    if(!self.gameDataSource)
    {
        self.gameDataSource= self.controllerContext.gamesController.dataSource;
    }
    NSLog(@"self.gameDataSource = %@",self.gameDataSource);
    [self toggleControllButtons];

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Sunbclasses methods
- (void)gotoStepAtIndex:(NSInteger)index
{
    [self.controllerContext.gamesController adminDidMoveToStepAtIndex:index];
}

- (IBAction)closeGame:(UIButton*)sender;
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)getBackToPrevStep:(UIButton*)sender
{
    
}
- (IBAction)gotoNextStep:(UIButton*)sender
{

}


@end
