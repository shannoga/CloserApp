//
//  SHAppDelegate.m
//  Closer
//
//  Created by shani hajbi on 2/8/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHAppDelegate.h"
#import "ooVooController.h"
#import "SHControllerContext.h"
#import "SHMainViewController.h"
#import "SHAppThemeClasses.h"
#import "SHUserProfileViewController.h"
@implementation SHAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"gXCpOQmQqCCzCJtHhx3Z3fdHN8qpH5424KKJ8qh8"
                  clientKey:@"yUop2E0uGF0JNdrmOd6oA5HJfycz93BA83aRjHxB"];
    [PFFacebookUtils initializeFacebook];
    [PFTwitterUtils initializeWithConsumerKey:@"Ud6XVwUuzR0M2CWodrVheA"
                               consumerSecret:@"UKOaCbehw9j8b54c1Uj7ogujj4fS0JnaCwEHd363o8"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [self setAppearence];
    if ([PFUser currentUser])
    {
        [self userLoggedIn];
    }
    else
    {
        [self userLoggedOut];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedIn) name:@"UserLoggdIn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedOut) name:@"UserLoggdOut" object:nil];
    
    
    return YES;
}

- (void)userLoggedIn
{
    
    ooVooInitResult result = [[ooVooController sharedController] initSdk:@"12349983350802" applicationToken:@"MDAxMDAxAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAkilaNavBrtoMUT4vK%2FdxLgQBM%2B%2FGrf8PeRbTs6MY6H7hgDJAW0RL%2FILa%2BhAYr95sU7CYvM1nDd1JuhCTZvn2g8GsN6YSPpkUy7G3OKPvyEQ%3D%3D" baseUrl:@"https://api-sdk.dev.oovoo.com/"];
    if (result == ooVooInitResultOk)
    {
        NSLog(@"logged in with ooVoo SDK version %@",[ooVooController sharedController].sdkVersion);
    }
    else
    {
        NSLog(@"Error login to ooVoo SDK - %i",result);
    }
    
    [[SHMessagesCoordinator sharedCoordinator] setPlayerMode:PlayerModeAdult];
    
    self.controllerContext = [[SHControllerContext alloc] init];
    [self.controllerContext setUpControllers];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    UINavigationController *nvc = (UINavigationController*)[storyboard instantiateInitialViewController];
    SHUserProfileViewController *vc = (SHUserProfileViewController*) nvc.viewControllers[0];
    vc.controllerContext = self.controllerContext;
    self.window = nil;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = nvc;
    [self.window makeKeyAndVisible];
}

- (void)userLoggedOut
{
    self.controllerContext = nil;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    UINavigationController *vc =[storyboard instantiateViewControllerWithIdentifier:@"LoginController"];
    self.window = nil;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
}

- (void)setAppearence
{
    [[UILabel appearance] setFont:[UIFont fontWithName:@"Futura-Medium" size:16.0]];
    [[UITextField appearance] setFont:[UIFont fontWithName:@"Futura-Medium" size:16.0]];

    [[SHButton appearance] setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [[SHButton appearance] setTitleFont:[UIFont fontWithName:@"Futura-Medium" size:16.0]];

}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[ooVooController sharedController] setCameraEnabled:NO];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[ooVooController sharedController] setCameraEnabled:YES];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
