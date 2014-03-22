//
//  SHGameSelectionViewController.m
//  Closer
//
//  Created by shani hajbi on 2/11/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHGameSelectionViewController.h"
#import "SHGameDescriptionViewController.h"
#import "SHGamesProvider.h"

@interface SHGameSelectionViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@property (strong, nonatomic) UIPageViewController *pageViewController;
- (IBAction)goToNextPage:(id)sender;
- (IBAction)goToPreviousPage:(id)sender;
@end

@implementation SHGameSelectionViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GameSelectionPageViewControler"];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    self.title = kMainGames[0];
    
    SHGameDescriptionViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((SHGameDescriptionViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    if (index == 0) {
        index = MAIN_GAMES_COUNT-1;
    }
    else
    {
        index--;
    }
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((SHGameDescriptionViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == MAIN_GAMES_COUNT) {
        index = 0;
    }
    return [self viewControllerAtIndex:index];
}

- (SHGameDescriptionViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if ((MAIN_GAMES_COUNT == 0) || (index >= MAIN_GAMES_COUNT)) {
        return nil;
    }
    // Create a new view controller and pass suitable data.
    SHGameDescriptionViewController *gameDescriptionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SHGameDescriptionViewController"];
    gameDescriptionViewController.imageFile = [SHGamesProvider titleForMainGame:index localized:NO];
    gameDescriptionViewController.titleText = [SHGamesProvider titleForMainGame:index localized:YES];
    gameDescriptionViewController.pageIndex = index;
    gameDescriptionViewController.controllerContext = self.controllerContext;
    
    return gameDescriptionViewController;
}


- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    NSUInteger index = [self currentPage].pageIndex;
    self.title = kMainGames[index];
}

- (SHGameDescriptionViewController *)currentPage
{
    return (SHGameDescriptionViewController *)self.pageViewController.viewControllers[0];
}

#pragma mark user actions



- (void)goToPageAtIndex:(NSInteger)index completion:(void (^)(NSInteger index))completion
{
    
    if (index >= MAIN_GAMES_COUNT-1 || index < 0) {
        return;
    }
    __weak SHGameSelectionViewController *weakSelf = self;
    NSString *title = kMainGames[index];
    [self.pageViewController setViewControllers:@[[self viewControllerAtIndex:index]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        weakSelf.title = title;
        if (completion) {
            completion(index);
        }
    }];
}



- (IBAction)goToNextPage:(id)sender
{
    NSUInteger index = ((SHGameDescriptionViewController*) self.pageViewController.viewControllers[0]).pageIndex;
    if (index >= MAIN_GAMES_COUNT-1) {
        index = 0;
    }
    else
    {
        index +=1;
    }
    __weak SHGameSelectionViewController *weakSelf = self;
    NSString *title = kMainGames[index];
    [self.pageViewController setViewControllers:@[[self viewControllerAtIndex:index]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        weakSelf.title = title;
        [weakSelf.controllerContext.menuController adminDidMoveToMainMenuAtIndex:index];
    }];
}

- (IBAction)goToPreviousPage:(id)sender
{
    NSUInteger index = ((SHGameDescriptionViewController*) self.pageViewController.viewControllers[0]).pageIndex;
    if (index == 0) {
        index =  MAIN_GAMES_COUNT-1;
    }
    else
    {
        index -=1;
    }
    __weak SHGameSelectionViewController *weakSelf = self;
    NSString *title = kMainGames[index];
    [self.pageViewController setViewControllers:@[[self viewControllerAtIndex:index]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
        weakSelf.title = title;
        [weakSelf.controllerContext.menuController adminDidMoveToMainMenuAtIndex:index];
    }];
}


#pragma mark -Admin actions
- (void)adminDidNavigateToPageAtIndex:(NSInteger)index
{
    [self goToPageAtIndex:index completion:nil];
}

- (void)adminDidSelectPageForMainGame:(NSInteger)index
{
    
    if ([self currentPage].pageIndex == index)
    {
        [[self currentPage] adminSelectedMainGame];

    }
    else
    {
        __weak SHGameSelectionViewController *weakSelf = self;
        [self goToPageAtIndex:index completion:^(NSInteger index) {
            [[weakSelf currentPage] adminSelectedMainGame];

        }];
    }
}

- (void)adminDidGoBackToMainMenu
{
    [[self currentPage] adminDidGoBackToMainMenu];
}

- (void)adminDidSelectSubGameAtIndex:(NSInteger)subGameIndex
{
    [[self currentPage] adminDidSelectSubGameIndex:subGameIndex];
}

@end
