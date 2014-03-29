//
//  SHPuserController.m
//  Closer
//
//  Created by shani hajbi on 3/29/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHPuserController.h"
#import "Reachability.h"

@interface SHPuserController()<PTPusherDelegate,PTPusherPresenceChannelDelegate>
@property (nonatomic,strong) PTPusher *pusher;
@property (nonatomic,strong) PTPusherPresenceChannel *groupChannel;
@end


@implementation SHPuserController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _pusher = [PTPusher pusherWithKey:@"3d525a02ba7dca6d31ad" delegate:self encrypted:YES];
        _pusher.authorizationURL = [NSURL URLWithString:@"https://api.parse.com/1/functions/authorizePusherPresenceChannel"];
    }
    return self;
}


- (void)connectToPuser
{
    [_pusher connect];
}

- (void)disconnectFromPusher
{
   [self.groupChannel unsubscribe];
   [_pusher disconnect];
}

- (void)listenToPusherCahnnel:(NSString*)channelName eventName:(NSString*)eventName
{
    self.groupChannel = [self.pusher subscribeToPresenceChannelNamed:channelName];
    [self.groupChannel bindToEventNamed:eventName handleWithBlock:^(PTPusherEvent *channelEvent) {
        // channelEvent.data is a NSDictianary of the JSON object received
        NSLog(@"");
    }];
}





- (BOOL)pusher:(PTPusher *)pusher connectionWillConnect:(PTPusherConnection *)connection
{
    return [[PFUser currentUser] isAuthenticated];
}


- (void)pusher:(PTPusher *)pusher connectionDidConnect:(PTPusherConnection *)connection
{
    NSLog(@"[PUSHER] conncted to pusher with connection: %@",connection);
}


- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection didDisconnectWithError:(NSError *)error willAttemptReconnect:(BOOL)willAttemptReconnect
{
    NSLog(@"[PUSHER] disconnected from pusher with error: %@, auto reconnect = %@",error.userInfo,willAttemptReconnect ? @"yes" : @"no");
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
        [self connectToPuser];
        
        // we can stop observing reachability changes now
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [reachability stopNotifier];
    }
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection failedWithError:(NSError *)error
{
     NSLog(@"[PUSHER] connection failed with error: %@",error.userInfo);
}

- (BOOL)pusher:(PTPusher *)pusher connectionWillAutomaticallyReconnect:(PTPusherConnection *)connection afterDelay:(NSTimeInterval)delay
{
    return [[PFUser currentUser] isAuthenticated];
}

- (void)pusher:(PTPusher *)pusher willAuthorizeChannel:(PTPusherChannel *)channel withRequest:(NSMutableURLRequest *)request
{
    NSLog(@"%@",[request allHTTPHeaderFields]);
    [request setValue:@"gXCpOQmQqCCzCJtHhx3Z3fdHN8qpH5424KKJ8qh8" forHTTPHeaderField: @"X-Parse-Application-Id"];
    [request setValue:@"7svhz5aXSOM0sERsX8UAKMwBDJYbfRTGfo48nW9y" forHTTPHeaderField: @"X-Parse-REST-API-Key"];
    [request setValue:[PFUser currentUser].sessionToken forHTTPHeaderField: @"X-Parse-Session-Token"];
}


- (void)pusher:(PTPusher *)pusher didSubscribeToChannel:(PTPusherChannel *)channel
{
    NSLog(@"[PUSHER] did subscribe to channel named = %@",channel.name);
    NSLog(@"[PUSHER] channel members = %@",self.groupChannel.members);

}


- (void)pusher:(PTPusher *)pusher didUnsubscribeFromChannel:(PTPusherChannel *)channel
{
    NSLog(@"[PUSHER] did unsubscribe from channel named = %@",channel.name);

}

- (void)pusher:(PTPusher *)pusher didFailToSubscribeToChannel:(PTPusherChannel *)channel withError:(NSError *)error
{
    NSLog(@"[PUSHER] did fail to subscribe from channel named = %@, error = %@",channel.name,[error description]);

}


- (void)pusher:(PTPusher *)pusher didReceiveErrorEvent:(PTPusherErrorEvent *)errorEvent
{
    NSLog(@"[PUSHER] did receive error event with message = %@ code = %i",errorEvent.message,errorEvent.code);

}


#pragma mark - PTPusherPresenceChannelDelegate

- (void)presenceChannelDidSubscribe:(PTPusherPresenceChannel *)channel
{
    NSLog(@"[PUSHER] did subscribe to presense channel named = %@",channel.name);
    NSLog(@"[PUSHER] channel members = %@",self.groupChannel.members);
}

- (void)presenceChannel:(PTPusherPresenceChannel *)channel memberAdded:(PTPusherChannelMember *)member
{
    NSLog(@"[PUSHER] member subscribed to channel = %@",member.userID);
}

- (void)presenceChannel:(PTPusherPresenceChannel *)channel memberRemoved:(PTPusherChannelMember *)member
{
    NSLog(@"[PUSHER] member unsubscribed to channel = %@",member.userID);

}

@end
