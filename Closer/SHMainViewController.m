//
//  SHMainViewController.m
//  Closer
//
//  Created by shani hajbi on 2/11/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHMainViewController.h"
#import "SHLoginScreenViewController.h"
#import "SHKidMenuViewController.h"
#import "SHVideoConferenceViewController.h"
#import "UIActionSheet+Blocks.h"
@interface SHMainViewController ()
- (IBAction)exitGame:(id)sender;
@end

@implementation SHMainViewController


- (void)awakeFromNib
{

}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
        SHKidMenuViewController *menuController = (SHKidMenuViewController *)navController.viewControllers[0];
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
