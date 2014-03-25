//
//  SHMainViewController.m
//  Closer
//
//  Created by shani hajbi on 2/11/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHMainViewController.h"
#import "SHLoginScreenViewController.h"
#import "SHGameSelectionViewController.h"
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
    [UIActionSheet showInView:self.view
                    withTitle:@"Are you sure you want to delete all the things?"
            cancelButtonTitle:@"Cancel"
       destructiveButtonTitle:@"Delete all the things"
            otherButtonTitles:@[@"Just some of the things", @"Most of the things"]
                     tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                         NSLog(@"Chose %@", [actionSheet buttonTitleAtIndex:buttonIndex]);
                     }];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"segue = %@",segue);
    if ([segue.identifier isEqualToString:@"MenuEmbed"]) {
        UINavigationController *navController = segue.destinationViewController;
        SHGameSelectionViewController *menuController = (SHGameSelectionViewController *)navController.viewControllers[0];
        self.controllerContext.menuController.menuViewController = menuController;
        menuController.controllerContext = self.controllerContext;
        
        NSLog(@"menu contorller : %@",navController.viewControllers[0]);
    }
}

- (IBAction)exitGame:(id)sender
{
    [self.delegate userDidExitGame];
}

@end
