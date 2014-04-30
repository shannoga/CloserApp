//
//  SHOnBoardingViewController.m
//  Closer
//
//  Created by shani hajbi on 3/20/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHOnBoardingViewController.h"
#import "SHOnboardingSinglePageViewController.h"
@interface SHOnBoardingViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *onboardingPages;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControll;

- (IBAction)loginWithFacebook:(id)sender;
- (IBAction)loginWithTwitter:(id)sender;
@end

@implementation SHOnBoardingViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.onboardingPages = @[@"Page1",@"Page2",@"Page3",@"Page4"];
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OnBoardingPageViewControler"];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    SHOnboardingSinglePageViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];

    [self.view bringSubviewToFront:self.buttonsView];
    [self.view bringSubviewToFront:self.pageControll];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((SHOnboardingSinglePageViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    if (index == 0) {
        index = [self.onboardingPages count]-1;
    }
    else
    {
        index--;
    }
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((SHOnboardingSinglePageViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.onboardingPages count]) {
        index = 0;
    }
    return [self viewControllerAtIndex:index];
}

- (SHOnboardingSinglePageViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.onboardingPages count] == 0) || (index >= [self.onboardingPages count])) {
        return nil;
    }
    // Create a new view controller and pass suitable data.
    SHOnboardingSinglePageViewController *siglePageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SHOnboardingSinglePageViewController"];
    siglePageViewController.imageFile = [SHGamesProvider titleForMainGame:index localized:NO];
    siglePageViewController.titleText = [SHGamesProvider titleForMainGame:index localized:YES];
    siglePageViewController.pageIndex = index;
    siglePageViewController.controllerContext = self.controllerContext;
    
    return siglePageViewController;
}


- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    NSUInteger index = [self currentPage].pageIndex;
    self.pageControll.currentPage = index;
    self.title = NSLocalizedString(@"Back", nil);
}

- (SHOnboardingSinglePageViewController *)currentPage
{
    return (SHOnboardingSinglePageViewController *)self.pageViewController.viewControllers[0];
}

#pragma mark login methods
- (IBAction)loginWithFacebook:(id)sender
{
    NSArray *permissions = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
        if (error) {
            [self presentAlertWithError:[error localizedDescription]];
        }
        if (!user) {
            DDLogInfo(@"Uh oh. The user cancelled the Facebook login.");
        } else if (user.isNew) {
            DDLogInfo(@"User signed up and logged in through Facebook!");
            
            [self userLoggedIn];
            
        } else {
            DDLogInfo(@"User logged in through Facebook!");
            [self userLoggedIn];
        }
    }];
}

- (IBAction)loginWithTwitter:(id)sender
{
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (error) {
            [self presentAlertWithError:[error localizedDescription]];
        }
        if (!user) {
            DDLogInfo(@"Uh oh. The user cancelled the Twitter login.");
            return;
        } else if (user.isNew) {
            DDLogInfo(@"User signed up and logged in with Twitter!");
            [self userLoggedIn];
            
        } else {
            DDLogInfo(@"User logged in with Twitter!");
            [self userLoggedIn];
            
        }
    }];
}


- (void)presentAlertWithError:(NSString*)errorString
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:errorString delegate:self cancelButtonTitle:NSLocalizedString(@"Close", nil) otherButtonTitles:nil, nil];
    [av show];
}


- (void)userLoggedIn
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLoggdIn" object:nil];
}


@end
