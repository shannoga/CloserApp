//
//  SHPusherControllerA.m
//  Closer
//
//  Created by shani hajbi on 4/9/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHPusherControllerA.h"
#import "ClientDisconnectionHandler.h"
#import "Reachability.h"
#import <MessageUI/MessageUI.h>
#import <QuartzCore/QuartzCore.h>
#import <Pusher/Pusher.h>

#define kManualReconnectionLimit 3
#define kPusherReachabilityHostname         @"pusher.com"
#define kPusherTriggerEventURL              [NSURL URLWithString:@"http://test.pusher.com/hello?env=default"]
NSString *const kPusherKeyA = @"3d525a02ba7dca6d31ad";


@interface SHPusherControllerA ()<PTPusherDelegate, ClientDisconnectionHandlerDelegate, MFMailComposeViewControllerDelegate> {
    PTPusher *_client;
    Reachability *_reachability;
    NSOperationQueue *_queue;
    ClientDisconnectionHandler *_disconnectionHandler;
}
@property (nonatomic, assign) BOOL allowAutomaticReconnections;

@end

@implementation SHPusherControllerA


- (id)init
{
    self = [super init];
    if (self) {
        [self _setupPusher];
        [self _setupReachability];
        [self _setupDisconnectionHandler];
        [self _setupBackgroundingNotifications];
        [_client connect];
    }
    
    return self;
}



/////////////////////////////////
#pragma mark - Pusher
/////////////////////////////////

- (void)_setupPusher
{
    
    // setup client
    _client = [PTPusher pusherWithKey:kPusherKeyA delegate:self encrypted:NO];
    _client.reconnectDelay = 3.0;
    
    // subscribe to channel and bind to event
    PTPusherChannel *channel = [_client subscribeToChannelNamed:@"channel"];
    [channel bindToEventNamed:@"event" handleWithBlock:^(PTPusherEvent *channelEvent) {
        // channelEvent.data is a NSDictianary of the JSON object received
        
        // convert back to json
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:channelEvent.data options:0 error:&error];
        
        if (!jsonData) {
            DDLogError(@"[App] JSON error: %@", error);
        } else {
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            DDLogWarn(@"[Pusher] Event received: %@", jsonString);
        }
    }];
}

- (void)_setupDisconnectionHandler
{
    _disconnectionHandler = [[ClientDisconnectionHandler alloc] initWithClient:_client reachability:_reachability];
    _disconnectionHandler.reconnectPermitted = YES;
    _disconnectionHandler.reconnectAttemptLimit = kManualReconnectionLimit;
    _disconnectionHandler.delegate = self;
}


//////////////////////////////////
#pragma mark - Pusher Delegate Connection
//////////////////////////////////

- (void)pusher:(PTPusher *)pusher connectionDidConnect:(PTPusherConnection *)connection
{
    [_disconnectionHandler handleConnection];
    
    DDLogInfo(@"[Pusher] connected (%@)",connection);
   
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection failedWithError:(NSError *)error
{
    if (error) {
        DDLogError(@"[Pusher] connection failed: %@", [error localizedDescription]);
    } else {
        DDLogError(@"[Pusher] connection failed");
    }
    
    //_pusherConnectionView.status = PDStatusViewStatusDisconnected;
    
    [_disconnectionHandler handleDisconnectionWithError:error];
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection didDisconnectWithError:(NSError *)error willAttemptReconnect:(BOOL)reconnect
{
    if (error) {
        
        DDLogInfo(@"[Pusher] didDisconnectWithError: %@ willAttemptReconnect: %@", [error localizedDescription], (reconnect ? @"YES" : @"NO"));
    } else {
        DDLogInfo(@"[Pusher] disconnected");
    }
    
    //_pusherConnectionView.status = PDStatusViewStatusDisconnected;
    // we only want to manually handle disconnections if reconnect will not happen automatically
    if (!reconnect) {
        [_disconnectionHandler handleDisconnectionWithError:error];
    }
}

- (BOOL)pusher:(PTPusher *)pusher connectionWillConnect:(PTPusherConnection *)connection
{
    [self _pusherConnecting];
    
    return YES;
}

- (BOOL)pusher:(PTPusher *)pusher connectionWillAutomaticallyReconnect:(PTPusherConnection *)connection afterDelay:(NSTimeInterval)delay
{
    if (_disconnectionHandler.reconnectPermitted) {
        DDLogInfo(@"[Pusher] will reconnect in %.0f seconds", delay);
        //_pusherConnectionView.status = PDStatusViewStatusWaiting;

    } else {
        DDLogInfo(@"[Pusher] will not automatically reconnect");
        //_pusherConnectionView.status = PDStatusViewStatusDisconnected;

    }
    
    return _disconnectionHandler.reconnectPermitted;
}

//////////////////////////////////
#pragma mark - Pusher Delegate Channel
//////////////////////////////////

- (void)pusher:(PTPusher *)pusher didSubscribeToChannel:(PTPusherChannel *)channel
{
    DDLogInfo(@"[Pusher] did subscribe to channel: %@", channel.name);
}

- (void)pusher:(PTPusher *)pusher didUnsubscribeFromChannel:(PTPusherChannel *)channel
{
    DDLogInfo(@"[Pusher] did unsubscribe to channel: %@", channel.name);
}

- (void)pusher:(PTPusher *)pusher didFailToSubscribeToChannel:(PTPusherChannel *)channel withError:(NSError *)error
{
    DDLogError(@"[Pusher] failed to subscribe to channel: %@; Error: %@", channel.name, error);
}

//- (void)pusher:(PTPusher *)pusher willAuthorizeChannelWithRequest:(NSMutableURLRequest *)request
//{
//    NSLog(@"[Pusher] authorize channel with request");
//    [request setValue:@"" forHTTPHeaderField:@"X-Pusher-Token"];
//}

- (void)pusher:(PTPusher *)pusher didReceiveErrorEvent:(PTPusherErrorEvent *)errorEvent
{
   DDLogError(@"[Pusher] Error event %@", errorEvent);
}


/////////////////////////////////
#pragma mark - Reachability
/////////////////////////////////

- (void)_setupReachability
{
    [self _internetConnecting];
    
    _reachability = [Reachability reachabilityWithHostname:kPusherReachabilityHostname];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [_reachability startNotifier];
}

- (void)_reachabilityChanged:(NSNotification *)notification
{
    if ([_reachability isReachable]) {
		[self _internetDidConnect];
	} else {
        [self _internetDidDisconnect];
	}
    
   DDLogInfo(@"[Internet] %@", [_reachability currentReachabilityString]);
}

/////////////////////////////////
#pragma mark - Manual disconnection handling
/////////////////////////////////

- (void)disconnectionHandlerWillReconnect:(ClientDisconnectionHandler *)handler attemptNumber:(NSUInteger)attemptNumber
{
    DDLogError(@"[Pusher] manual reconnect attempt %d of %d.", attemptNumber, handler.reconnectAttemptLimit);
}

- (void)disconnectionHandlerWillWaitForReachabilityBeforeReconnecting:(ClientDisconnectionHandler *)handler
{
    DDLogError(@"[Pusher] will attempt re-connect when reachability changes.");
}

- (void)disconnectionHandlerReachedReconnectionLimit:(ClientDisconnectionHandler *)handler
{
   DDLogError(@"[Pusher] reached manual reconnection limit.");
}

/////////////////////////////////
#pragma mark - Backgrounding
/////////////////////////////////

- (void)_setupBackgroundingNotifications
{
    // listen for background changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appDidEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)_appDidEnterBackground:(NSNotification *)notificaiton
{
    DDLogInfo(@"[App] did enter background");

    [self connect:NO];
}

- (void)_appDidBecomeActive:(NSNotification *)notification
{
    DDLogInfo(@"[App] did become active, connection status is %@", _client.connection.connected ? @"connected" : @"disconnected");
    
    // work around
    // to make sure the state of the app is consistent even after
    // the app becomes active
    BOOL reconnect = NO;
    if (!reconnect && !_client.connection.connected)
    {
        DDLogInfo(@"[Pusher] disconnected");
        //_pusherConnectionView.status = PDStatusViewStatusDisconnected;
    }
    else if (reconnect && !_client.connection.connected && _reachability.isReachable)
    {
      
    }
      [self connect:YES];
}


/////////////////////////////////
#pragma mark - View Helper Pusher
/////////////////////////////////

- (void)_pusherConnecting
{
    //_pusherConnectionView.status = PDStatusViewStatusConnecting;
    //_connectButton.enabled = NO;
    //[_connectButton setTitle:@"Connecting" forState:UIControlStateNormal];
}


/////////////////////////////////
#pragma mark - View Helper Internet
/////////////////////////////////

- (void)_internetConnecting
{
//    _internetConnectionView.status = PDStatusViewStatusConnecting;
//    _triggerEventButton.enabled = NO;
}

- (void)_internetDidConnect
{
    if ([_reachability isReachableViaWWAN]) {
        //_internetConnectionView.status = PDStatusViewStatusConnectedCellular;
    } else if ([_reachability isReachableViaWiFi]) {
        //_internetConnectionView.status = PDStatusViewStatusConnectedWiFi;
    } else {
        //_internetConnectionView.status = PDStatusViewStatusConnected;
    }
}

- (void)_internetDidDisconnect
{
 //   _internetConnectionView.status = PDStatusViewStatusDisconnected;
   // _triggerEventButton.enabled = NO;
    DDLogError(@"user has no internet connection");
}


/////////////////////////////////
#pragma mark - Networking
/////////////////////////////////

- (void)_sendEventTriggerRequest
{
    // send request to trigger message
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:kPusherTriggerEventURL];
    request.HTTPMethod = @"POST";
    
    [NSURLConnection sendAsynchronousRequest:request queue:_queue completionHandler:^(NSURLResponse *resonse, NSData *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //_triggerEventButton.enabled = YES;
        });
        //NSLog(@"Trigger Event Response: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
}



/////////////////////////////////
#pragma mark -  Actions
/////////////////////////////////

- (void)connect:(BOOL)connect
{
    if (!connect) {
        [_client disconnect];
    } else  if (connect && !_client.connection.connected){
        [self _pusherConnecting];
        [_client connect];
    }
}

- (IBAction)triggerEventButtonPressed:(id)sender
{
//    [[PDLogger sharedInstance] logInfo:@"[Server] triggering event via REST API"];
//    
//    _triggerEventButton.enabled = NO;
//    [self _sendEventTriggerRequest];
}



//- (IBAction)sslSwitchChanged:(id)sender
//{
//    UISwitch *sslSwitch = (UISwitch *)sender;
//    
//    NSString *sslStatus = sslSwitch.on ? @"SSL" : @"non-SSL";
//    [[PDLogger sharedInstance] logInfo:@"[Pusher] switching to %@ connection", sslStatus];
//    
//    [[NSUserDefaults standardUserDefaults] setBool:sslSwitch.on forKey:kUserDefaultsSSLEnabled];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    
//    // work around the fact that PTPusher will automatically reconnect when you explicitly call
//    // disconnect, by simply removing all strong references to it, causing it to be deallocated
//    // (which will cause it to disconnect without any further callbacks).
//    _client = nil;
//    _disconnectionHandler = nil;
//    
//    // create a new SSL-enabled client and disconnection handler referencing the new client
//    [self _setupPusher];
//    [self _setupDisconnectionHandler];
//    
//    // now connect again
//    [_client connect];
//}

//- (IBAction)autoReconnectSwitchChanged:(id)sender
//{
//    UISwitch *reconnectSwitch = (UISwitch *)sender;
//    
//    // logging
//    NSString *reconnectStatus = reconnectSwitch.on ? @"ON" : @"OFF";
//    [[PDLogger sharedInstance] logInfo:@"[Pusher] auto reconnect %@", reconnectStatus];
//    
//    // user defaults
//    [[NSUserDefaults standardUserDefaults] setBool:reconnectSwitch.on forKey:kUserDefaultsReconnectEnabled];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    
//    _disconnectionHandler.reconnectPermitted = reconnectSwitch.on;
//}

//- (void)_infoButtonPressed:(id)sender
//{
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"InfoViewController"];
//    [self.navigationController pushViewController:vc animated:YES];
//}


@end
