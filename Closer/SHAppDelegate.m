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
#import "SHOoVooSDKController.h"
#import "SHPubNubController.h"
#import "SHUser.h"
#import "SHUserProfileController.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"
#import <Crashlytics/Crashlytics.h>
@interface SHAppDelegate()


@end

@implementation SHAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    // Initialize File Logger
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    
    // Configure File Logger
    [fileLogger setMaximumFileSize:(1024 * 1024)];
    [fileLogger setRollingFrequency:(3600.0 * 24.0)];
    [[fileLogger logFileManager] setMaximumNumberOfLogFiles:5];
    [DDLog addLogger:fileLogger];
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        [[SHMessagesCoordinator sharedCoordinator] setPlayerMode:PlayerModeKid];
    }
    else{
        [[SHMessagesCoordinator sharedCoordinator] setPlayerMode:PlayerModeAdult];
    }
    [SHUser registerSubclass];

    [Parse setApplicationId:@"gXCpOQmQqCCzCJtHhx3Z3fdHN8qpH5424KKJ8qh8"
                  clientKey:@"yUop2E0uGF0JNdrmOd6oA5HJfycz93BA83aRjHxB"];
    
    [PFFacebookUtils initializeFacebook];
    [PFTwitterUtils initializeWithConsumerKey:@"Ud6XVwUuzR0M2CWodrVheA"
                               consumerSecret:@"UKOaCbehw9j8b54c1Uj7ogujj4fS0JnaCwEHd363o8"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [Crashlytics startWithAPIKey:@"b0dd9cdba40063988f614c1b8a29f1ecabab3f51"];
    [self setAppearence];
    
    self.controllerContext = [[SHControllerContext alloc] init];
    [self.controllerContext setUpControllers];
    
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
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    
//    [PubNub setConfiguration: [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com"
//                                                           publishKey:@"pub-c-293e2b1e-94b8-42e3-bf9f-c35c6004d049"
//                                                         subscribeKey:@"sub-c-93ef06c0-bf52-11e3-8337-02ee2ddab7fe"
//                                                            secretKey:nil]];
//    
//    [PubNub connect];
//    
//    PNChannel *master_channel = [PNChannel channelWithName:@"master_channel_name" shouldObservePresence:YES];
//    
//    [PubNub subscribeOnChannel:master_channel];
//    
//    [PubNub sendMessage:@"my_unique_channel_name" toChannel:master_channel];
    return YES;
}

- (void)userLoggedIn
{
    SHUser *user = [SHUser currentUser];
    [Crashlytics setUserIdentifier:user.objectId];
    [Crashlytics setUserEmail:user.email];
    [Crashlytics setUserName:user.username];

    [self loginToOoVoo];
    [self.controllerContext.userProfileController activeGroupWithBlock:^(PFObject *group) {
        [self.controllerContext.pubnubController subscribeToGroupChannel];
    
       
        [self updateUIforLogin];
        [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
        [[PFInstallation currentInstallation] saveEventually];
    }];
  

}


- (void)userLoggedOut
{
    [self.controllerContext prepareForLogout];
    [self updateUIforLogout];
    [self.controllerContext.pubnubController unsubscibeFromGroupChannel];
}

- (void)loginToOoVoo
{
    [self.controllerContext.sdkController loginToOoVooSDKWithSuccess:^(ooVooInitResult result) {
        
    }];
}



- (void)updateUIforLogin
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    UINavigationController *nvc = (UINavigationController*)[storyboard instantiateInitialViewController];
    SHUserProfileViewController *vc = (SHUserProfileViewController*) nvc.viewControllers[0];
    vc.controllerContext = self.controllerContext;
    self.window = nil;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = nvc;
    [self.window makeKeyAndVisible];
}

- (void)updateUIforLogout
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    UINavigationController *vc =[storyboard instantiateViewControllerWithIdentifier:@"LoginController"];
    self.window = nil;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
}

- (void)setAppearence
{
   // [[UILabel appearance] setFont:[UIFont fontWithName:@"Futura-Medium" size:16.0]];
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
    if ([self.controllerContext.sdkController hasActiveSession]) {
        [[ooVooController sharedController] setCameraEnabled:NO];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //[self.controllerContext.pusherController disconnectFromPusher];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if ([self.controllerContext.sdkController hasActiveSession]) {
        [[ooVooController sharedController] setCameraEnabled:YES];
    }
    //[self.controllerContext.pusherController connectToPuser];

    
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

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    //currentInstallation[@"user"] = [PFUser currentUser];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}



@end
