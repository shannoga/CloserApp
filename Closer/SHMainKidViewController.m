//
//  SHMainKidViewController.m
//  Closer
//
//  Created by shani hajbi on 2/11/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHMainKidViewController.h"
#import "SHLoginScreenViewController.h"
#import "SHGameSelectionViewController.h"
#import "SHVideoConferenceViewController.h"
#import "UIActionSheet+Blocks.h"
@interface SHMainKidViewController ()
@property (nonatomic,weak) IBOutlet UIButton *exitButton;
- (IBAction)exitGame:(id)sender;
@end

@implementation SHMainKidViewController


- (void)awakeFromNib
{

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.exitButton.hidden = YES;
#ifdef DEBUG
    self.exitButton.hidden = NO;

#endif
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MenuEmbed"]) {
        UINavigationController *navController = segue.destinationViewController;
        SHGameSelectionViewController *menuController = (SHGameSelectionViewController *)navController.viewControllers[0];
        self.controllerContext.menuController.menuViewController = menuController;
        menuController.controllerContext = self.controllerContext;
    }
    else if ([segue.identifier isEqualToString:@"VideoEmbed"])
    {
        SHVideoConferenceViewController *videoController = (SHVideoConferenceViewController *)segue.destinationViewController;
        videoController.controllerContext = self.controllerContext;
    }
}

- (IBAction)exitGame:(id)sender
{
    [self.delegate userDidExitGame];
}

@end
