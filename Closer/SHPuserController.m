//
//  SHPuserController.m
//  Closer
//
//  Created by shani hajbi on 3/29/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHPuserController.h"
#import "Reachability.h"
#import "SHUser.h"

NSString *const kPusherKey = @"3d525a02ba7dca6d31ad";
NSString *const kParseAuthorizeingUrl = @"https://api.parse.com/1/functions/authorizePusherPresenceChannel";

NSString *const kEventType = @"eventType";
NSString *const kClientEventName = @"client-event";

NSString *const kOnline = @"online";
NSString *const kSenderId = @"sender_id";
NSString *const kSenderName = @"sender";
NSString *const kReciverId = @"reciver_id";
NSString *const kCalling = @"calling";
NSString *const kCallResult = @"call_result";

#define BACKGROUND_TASK_TIMER_DURATION 10

@interface SHPuserController()<PTPusherDelegate,PTPusherPresenceChannelDelegate>
@property (nonatomic,strong) PTPusher *pusher;
@property (nonatomic,strong) PTPusherPresenceChannel *groupChannel;
@property (nonatomic,strong) NSTimer *backgroundTaskTimer;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic) UIBackgroundTaskIdentifier timerBackgroundTask;
@property (nonatomic,copy) NSString * currentChannelName;
@property (nonatomic,copy) SHCallResultHandler callResultHandler;
@property (nonatomic,strong) NSTimer * callingTimer;
@property (nonatomic) BOOL isNegotiating;

@end


@implementation SHPuserController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _pusher = [PTPusher pusherWithKey:kPusherKey delegate:self encrypted:YES];
        _pusher.authorizationURL = [NSURL URLWithString:kParseAuthorizeingUrl];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startBackgroundTaskTimer:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopBackgroundTaskTimer:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}


- (void)connectToPuserAndSubscribeToGroupChannel:(NSString*)channelName
{
    if (!self.currentChannelName.length && !channelName) return;
    
    self.currentChannelName = channelName;
    if (self.isConnected) {
        return;
    }
    [self beginBackgroundConnectionTask];
    [_pusher connect];
    [self subscribeToChannelNamed:channelName];
}

- (void)subscribeToChannelNamed:(NSString*)channelName
{
    if (self.groupChannel && self.groupChannel.isSubscribed) {
        return;
    }
    self.groupChannel = [self.pusher subscribeToPresenceChannelNamed:channelName delegate:self];
    
    [self.groupChannel bindToEventNamed:kClientEventName handleWithBlock:^(PTPusherEvent *channelEvent) {
        SHEventType eventType = [channelEvent.data[kEventType] integerValue];
        switch (eventType) {
            case SHEventTypeCalling:
                [self handleCallingEvent:channelEvent];
                break;
            case SHEventTypePresence:
                [self handlePresenceEvent:channelEvent];
                break;
                
            default:
                break;
        }
    }];

}

- (void)handleCallingEvent:(PTPusherEvent*)channelEvent
{
    if ([channelEvent.data[kReciverId] isEqualToString:[SHUser currentUser].objectId]) {
        if ([channelEvent.data[kCalling] boolValue]) {
            //incoming call
            self.isNegotiating = YES;
            
            NSString *callerId = channelEvent.data[kSenderId];
            
            [self handleIncomingCallFromEvent:channelEvent answerHandler:^(SHCallResult callResult) {
                //send answer event
                [self sendEventToChannelWithData:@{kEventType:@(SHEventTypeCalling) ,kSenderName:[PFUser currentUser].username,kSenderId:[PFUser currentUser].objectId,kReciverId:callerId, kCalling:@(NO),kCallResult:@(callResult)}];
            }];
        }
        else
        {
            //answer
            [self.callingTimer invalidate];
            if (self.callResultHandler)
            {
                self.callResultHandler([channelEvent.data[kCallResult] integerValue],nil);
            }
        }
    }
}

- (void)handlePresenceEvent:(PTPusherEvent*)channelEvent
{
    NSString *senderId = channelEvent.data[kSenderId];
    if (![senderId isEqualToString:[SHUser currentUser].objectId]) {
        BOOL isOnline = [channelEvent.data[kOnline] boolValue];
        UIApplication *application = [UIApplication sharedApplication];
        if ([application applicationState] == UIApplicationStateBackground) {
            
        } else {
            DDLogVerbose(@"presence-channel - user message %@",[channelEvent description]);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isOnline)
                {
                    [self.delegate userDidSubscribeWithId:senderId];
                }
                else
                {
                    [self.delegate userDidUnSubscribeWithId:senderId];
                    
                }
            });
        }
    }

}


- (void)notifyAboutPresenseOnline:(BOOL)online
{
    if ([self.groupChannel isSubscribed])
    {
        NSDictionary *presenceDic = @{kEventType:@(SHEventTypePresence), kSenderId:[SHUser currentUser].objectId ,kOnline:@(online)};
        [self.groupChannel triggerEventNamed:kClientEventName data:presenceDic];
    }
}

- (void)handleIncomingCallFromEvent:(PTPusherEvent*)channelEvent answerHandler:(void (^)(SHCallResult callResult))answerHandler
{
    UIApplication *application = [UIApplication sharedApplication];

    //incoming call
    if ([application applicationState] == UIApplicationStateBackground)
    {
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
        localNotif.timeZone = [NSTimeZone defaultTimeZone];
        NSString *pushString = NSLocalizedString(@"%@ invites you to play",nil);
        NSString *senderName = channelEvent.data[kSenderName];
        localNotif.alertBody = [NSString stringWithFormat:pushString,senderName];
        localNotif.alertAction = @"Accept";
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        [application scheduleLocalNotification:localNotif];
    }
    else
    {
        DDLogVerbose(@"Recieved game invitation");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate userDidCall:channelEvent.data[kSenderId] answerHandler:answerHandler];
        });
    }

}


- (void)sendEventToChannelWithData:(NSDictionary*)data
{
    if ([self.groupChannel isSubscribed])
    {
        [self.groupChannel triggerEventNamed:kClientEventName data:data];
    }
}

- (void)callUser:(SHUser*)user WithCallResultHandler:(SHCallResultHandler)callResultHandler
{
    self.callResultHandler = callResultHandler;
    NSDictionary *message = @{kEventType:@(SHEventTypeCalling),kSenderName:[PFUser currentUser].username,kSenderId:[PFUser currentUser].objectId,kReciverId:user.objectId, kCalling:@(YES),kCallResult:@(SHCallResultUnknown)};
    if (YES){//user.online) {
        [self startCallingTimer];
        [self sendEventToChannelWithData:message];
    }
    else
    {
        //alert user that the user is offline and full back to push notification
        [self sendPushToUser:user withData:message];
    }
}

- (void)startCallingTimer
{
    self.callingTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(callTimeOut:) userInfo:nil repeats:NO];
}

- (void)callTimeOut:(NSTimer*)timer
{
    [timer invalidate];
    if(self.callResultHandler)
    {
        self.callResultHandler(SHCallResultTimedOut,nil);
    }
    
}

- (void)sendPushToUser:(SHUser*)user withData:(NSDictionary*)data
{
    PFQuery *innerQuery = [SHUser query];
    [innerQuery whereKey:@"objectId" equalTo:user.objectId];
    PFQuery *query = [PFInstallation query];
    [query whereKey:@"user" matchesQuery:innerQuery];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:query];
    NSString *pushString = NSLocalizedString(@"%@ invites you to play",nil);
    [push setMessage:[NSString stringWithFormat:pushString,[PFUser currentUser].username]];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error)
        {
            DDLogError(@"error = %@", error.userInfo);
        }
        else if (succeeded)
        {
            DDLogInfo(@"push sent to : %@", user.username);
            
        }
    }];
}



- (void)beginBackgroundConnectionTask
{
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        DDLogVerbose(@"Background task ended from beginBackgroundTaskWithExpirationHandler");
        [self endBackgroundTasks:self.backgroundTaskTimer];
    }];
}

- (void)beginBackgroundTimerTask
{
    self.timerBackgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        DDLogVerbose(@"Background timer task ended from beginBackgroundTaskWithExpirationHandler");
        [self endBackgroundTasks:self.backgroundTaskTimer];
    }];
}


- (void)endBackgroundTasks:(NSTimer*)timer
{
    DDLogVerbose(@"Background task ended from timer");
    
    if (timer) {
        [timer invalidate];
    }
    if (self.groupChannel.isSubscribed)
    {
        [self notifyAboutPresenseOnline:NO];
    }
    [self disconnectFromPusher];
    
    [[UIApplication sharedApplication] endBackgroundTask: self.backgroundTask];
    self.backgroundTask = UIBackgroundTaskInvalid;
    [[UIApplication sharedApplication] endBackgroundTask: self.timerBackgroundTask];
    self.timerBackgroundTask = UIBackgroundTaskInvalid;
    
}

- (void)startBackgroundTaskTimer:(NSNotification*)notification
{
    DDLogVerbose(@"Went to background, starting background timer");
    [self beginBackgroundTimerTask];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //run function methodRunAfterBackground
        self.backgroundTaskTimer = [NSTimer timerWithTimeInterval:BACKGROUND_TASK_TIMER_DURATION target:self selector:@selector(endBackgroundTasks:) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:self.backgroundTaskTimer forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] run];
    });
}

- (void)stopBackgroundTaskTimer:(NSNotification*)notification
{
    DDLogVerbose(@"Returned to fourground stoping background timer");
    
    [[UIApplication sharedApplication] endBackgroundTask: self.timerBackgroundTask];
    self.timerBackgroundTask = UIBackgroundTaskInvalid;
    [self.backgroundTaskTimer invalidate];
    self.backgroundTaskTimer = nil;
    [self connectToPuserAndSubscribeToGroupChannel:self.currentChannelName];
}

- (void)disconnectFromPusher
{
    DDLogVerbose(@"trying to disconnect from pusher");
    
    [self.groupChannel unsubscribe];
    [_pusher disconnect];
    self.isConnected = NO;
}




#pragma mark - PTPusherDelegate


- (BOOL)pusher:(PTPusher *)pusher connectionWillConnect:(PTPusherConnection *)connection
{
    return [[PFUser currentUser] isAuthenticated];
}


- (void)pusher:(PTPusher *)pusher connectionDidConnect:(PTPusherConnection *)connection
{
    DDLogVerbose(@"[PUSHER] conncted to pusher with connection: %@",connection);
    if (self.groupChannel.isSubscribed)
    {
        [self notifyAboutPresenseOnline:YES];
    }else
    {
        [pusher subscribeToChannelNamed:self.currentChannelName];
        
    }
    self.isConnected = YES;
}


- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection didDisconnectWithError:(NSError *)error willAttemptReconnect:(BOOL)willAttemptReconnect
{
    DDLogVerbose(@"[PUSHER] disconnected from pusher with error: %@, auto reconnect = %@",error.userInfo,willAttemptReconnect ? @"yes" : @"no");
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    
    if ([reachability currentReachabilityStatus] == NotReachable) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:reachability];
        [reachability startNotifier];
    }
}

- (void)reachabilityChanged:(NSNotification*)notification
{
    Reachability *reachability = notification.object;
    
    if ([reachability currentReachabilityStatus] != NotReachable) {
        // we seem to have some kind of network reachability, so try again
        [self connectToPuserAndSubscribeToGroupChannel:self.currentChannelName];
        
        // we can stop observing reachability changes now
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [reachability stopNotifier];
    }
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection failedWithError:(NSError *)error
{
    DDLogError(@"[PUSHER] connection failed with error: %@",error.userInfo);
    if (self.groupChannel.isSubscribed)
    {
        [self notifyAboutPresenseOnline:NO];
    }
    self.isConnected = NO;
}

- (BOOL)pusher:(PTPusher *)pusher connectionWillAutomaticallyReconnect:(PTPusherConnection *)connection afterDelay:(NSTimeInterval)delay
{
    return [[PFUser currentUser] isAuthenticated];
}

- (void)pusher:(PTPusher *)pusher willAuthorizeChannel:(PTPusherChannel *)channel withRequest:(NSMutableURLRequest *)request
{
    [request setValue:@"gXCpOQmQqCCzCJtHhx3Z3fdHN8qpH5424KKJ8qh8" forHTTPHeaderField: @"X-Parse-Application-Id"];
    [request setValue:@"7svhz5aXSOM0sERsX8UAKMwBDJYbfRTGfo48nW9y" forHTTPHeaderField: @"X-Parse-REST-API-Key"];
    [request setValue:[PFUser currentUser].sessionToken forHTTPHeaderField: @"X-Parse-Session-Token"];
}


- (void)pusher:(PTPusher *)pusher didSubscribeToChannel:(PTPusherChannel *)channel
{
    DDLogInfo(@"[PUSHER] did subscribe to channel named = %@",channel.name);
    DDLogInfo(@"[PUSHER] channel members = %@",self.groupChannel.members);
    
}


- (void)pusher:(PTPusher *)pusher didUnsubscribeFromChannel:(PTPusherChannel *)channel
{
    DDLogInfo(@"[PUSHER] did unsubscribe from channel named = %@",channel.name);
    
}

- (void)pusher:(PTPusher *)pusher didFailToSubscribeToChannel:(PTPusherChannel *)channel withError:(NSError *)error
{
    DDLogError(@"[PUSHER] did fail to subscribe from channel named = %@, error = %@",channel.name,[error description]);
    
}


- (void)pusher:(PTPusher *)pusher didReceiveErrorEvent:(PTPusherErrorEvent *)errorEvent
{
    DDLogError(@"[PUSHER] did receive error event with message = %@ code = %ld",errorEvent.message,(long)errorEvent.code);
    
}


#pragma mark - PTPusherPresenceChannelDelegate

- (void)presenceChannelDidSubscribe:(PTPusherPresenceChannel *)channel
{
    if (self.groupChannel.isSubscribed)
    {
        [self notifyAboutPresenseOnline:YES];
    }
    DDLogInfo(@"[PUSHER] did subscribe to presense channel named = %@",channel.name);
    DDLogInfo(@"[PUSHER] channel members = %@",self.groupChannel.members);
    [self.delegate didSubscribeToPresenseChannelWithMembers:self.groupChannel.members];
}

- (void)presenceChannel:(PTPusherPresenceChannel *)channel memberAdded:(PTPusherChannelMember *)member
{
    DDLogInfo(@"[PUSHER] member subscribed to channel = %@",member.userID);
    [self.delegate userDidSubscribeWithId:member.userID];
}

- (void)presenceChannel:(PTPusherPresenceChannel *)channel memberRemoved:(PTPusherChannelMember *)member
{
    DDLogInfo(@"[PUSHER] member unsubscribed from channel = %@",member.userID);
    [self.delegate userDidUnSubscribeWithId:member.userID];
}

- (void)prepareForLogout
{
    [self endBackgroundTasks:self.backgroundTaskTimer];
    [self disconnectFromPusher];
    self.groupChannel = nil;
    self.currentChannelName = nil;
}
@end
