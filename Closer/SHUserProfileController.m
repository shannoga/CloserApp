//
//  SHGroupsController.m
//  Closer
//
//  Created by shani hajbi on 3/24/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHUserProfileController.h"
#import "SHPubNubController.h"
#import "SHUser.h"

@interface SHUserProfileController()<SHPubNubControllerDelegate>
@end

@implementation SHUserProfileController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _activeUsers = [NSMutableArray array];
    }
    return self;
}

- (void)activeGroupWithBlock:(void (^)(PFObject *group))completion
{
    if (!_activeGroup) {
        
        PFRelation *relation = [[SHUser currentUser] relationforKey:@"groups"];
        PFQuery *query = [relation query];
        query.cachePolicy = kPFCachePolicyNetworkElseCache;
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                DDLogError(@"error = %@",error);
                completion(nil);
            }
            else
            {
                if ([objects count]) {
                    _activeGroup = objects[0];
                    completion(objects[0]);
                }
                else
                {
                    DDLogWarn(@"user has no groups");
                    completion(nil);
                }
            }
        }];

    }
    else
    {
        completion(_activeGroup);
    }
}

- (void)updateUserGroup:(NSString*)groupName
{
    void(^crateRelationBlock)(PFObject *group) = ^(PFObject *group) {
        PFUser *user = [PFUser currentUser];
        PFRelation *relation = [user relationforKey:@"groups"];
        [relation addObject:group];
        
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
               // [self getGroupUsers:group];
                
            }else{
                DDLogError(@"failed create relation with error = %@",[error description]);
            }
        }];
    };
    
    PFQuery *groupQuery = [PFQuery queryWithClassName:@"Group"];
    [groupQuery whereKey:@"groupName" equalTo:groupName];
    [groupQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            DDLogError(@"error = %@",error);
        }
        if ([objects count]) {
            PFObject *group = (PFObject*)objects[0];
            crateRelationBlock(group);
        }
        else
        {
            PFObject *group = [PFObject objectWithClassName:@"Group"];
            group[@"groupName"] = groupName;
            [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    crateRelationBlock(group);
                }else{
                    DDLogError(@"failed creating group with error = %@",[error description]);
                }
            }];
            
        }
    }];
    
    
}

- (void)getActiveGroupUsersWithBlock:(void (^)(NSArray *users,NSError *error))completion
{
    
    PFQuery *query = [SHUser query];

    [query whereKey:@"groups" equalTo:self.activeGroup];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            DDLogDebug(@"Successfully retrieved %lu scores.", (unsigned long)objects.count);
            NSMutableArray *users = [NSMutableArray arrayWithArray:objects];
            for (SHUser *user in objects) {
                //move currect user to the begginig of the array
                if ([[PFUser currentUser].username isEqualToString:user.username]) {
                    [users removeObject:user];
                }
                else
                {
                    user.online = NO;
                    [self.activeUsers addObject:user];
                }
            }
            
            completion(users,nil);
        } else {
            DDLogError(@"Error: %@ %@", error, [error userInfo]);
            completion(nil,error);

        }
    }];
}

- (void)updateGroupImage:(UIImage*)image
{
    NSData *imageData = UIImagePNGRepresentation(image);
    PFFile *imageFile = [PFFile fileWithName:@"group_image.png" data:imageData];
    
    //HUD creation here (see example for code)
    
    // Save PFFile
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            [self.activeGroup setObject:imageFile forKey:@"groupImage"];
        
            
            [self.activeGroup saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    //[self refresh:nil];
                }
                else{
                    // Log details of the failure
                    DDLogError(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
        else{
            // Log details of the failure
            DDLogError(@"Error: %@ %@", error, [error userInfo]);
        }
    } progressBlock:^(int percentDone) {
        // Update your progress spinner here. percentDone will be between 0 and 100.
      //  HUD.progress = (float)percentDone/100;
    }];
    

}

- (void)sortActiveContacts
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"online" ascending:NO];
    NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor,nameSortDescriptor];
    NSArray *sortedArray = [self.activeUsers sortedArrayUsingDescriptors:sortDescriptors];
    self.activeUsers = [sortedArray mutableCopy];
    [self.delegate activeUsersDidUpdatePresence];
}

- (void)updateUserPresence:(NSString*)userId online:(BOOL)online
{
    [self.activeUsers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SHUser * user = (SHUser*)obj;
        if ([user.objectId isEqualToString:userId]) {
            user.online = online;
            *stop = YES;
        }
    }];
    [self sortActiveContacts];
}

#pragma mark - SHPuserControllerDelegate

- (void)didSubscribeToPresenseChannelWithMembers:(PTPusherChannelMembers *)members
{
    [self.activeUsers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SHUser * user = (SHUser*)obj;
        PTPusherChannelMember *member = [members memberWithID:user.objectId];
        if (member) {
            user.online = YES;
        }
    }];
    [self sortActiveContacts];
}

- (void)userDidSubscribeWithId:(NSString *)userId
{
    [self updateUserPresence:userId online:YES];
}

- (void)userDidUnSubscribeWithId:(NSString *)userId
{
    [self updateUserPresence:userId online:NO];

}

- (void)userDidCall:(NSString *)userId answerHandler:(void (^)(SHCallResult))callResult
{
    [self.delegate userDidCall:userId answerHandler:callResult];
}

- (void)prepareForLogout
{
    [_activeUsers removeAllObjects];
    _activeGroup = nil;
}
@end
