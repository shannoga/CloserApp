//
//  SHGroupsController.m
//  Closer
//
//  Created by shani hajbi on 3/24/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHUserProfileController.h"

@interface SHUserProfileController()
@property (nonatomic, strong) PFObject *activeGroup;
@end

@implementation SHUserProfileController

- (void)activeGroupWithBlock:(void (^)(PFObject *group))completion
{
    if (!_activeGroup) {
        
        PFRelation *relation = [[PFUser currentUser] relationforKey:@"groups"];
        PFQuery *query = [relation query];
        query.cachePolicy = kPFCachePolicyNetworkElseCache;
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                NSLog(@"error = %@",error);
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
                    NSLog(@"user has no groups");
                    completion(nil);
                }
            }
        }];

    }
    completion(_activeGroup);
}

- (void)updateUserGroup:(NSString*)groupName
{
    void(^crateRelationBlock)(PFObject *group) = ^(PFObject *group) {
        PFUser *user = [PFUser currentUser];
        PFRelation *relation = [user relationforKey:@"groups"];
        [relation addObject:group];
        
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"relation made");
               // [self getGroupUsers:group];
                
            }else{
                NSLog(@"failed create relation with error = %@",[error description]);
            }
        }];
    };
    
    PFQuery *groupQuery = [PFQuery queryWithClassName:@"Group"];
    [groupQuery whereKey:@"groupName" equalTo:groupName];
    [groupQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"error = %@",error);
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
                    NSLog(@"failed creating group with error = %@",[error description]);
                }
            }];
            
        }
    }];
    
    
}

- (void)getActiveGroupUsersWithBlock:(void (^)(NSArray *users,NSError *error))completion
{
    
    PFQuery *query = [PFUser query];

    [query whereKey:@"groups" equalTo:self.activeGroup];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved %d scores.", objects.count);
            NSMutableArray *users = [NSMutableArray arrayWithArray:objects];
            for (PFUser *user in objects) {
                //move currect user to the begginig of the array
                if ([[PFUser currentUser].username isEqualToString:user.username]) {
                    [users removeObject:user];
                }
            }
            completion(users,nil);
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
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
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
        else{
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    } progressBlock:^(int percentDone) {
        // Update your progress spinner here. percentDone will be between 0 and 100.
      //  HUD.progress = (float)percentDone/100;
    }];
    

}

@end
