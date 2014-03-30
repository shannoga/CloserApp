//
//  SHUserProfileViewController.m
//  Closer
//
//  Created by shani hajbi on 3/22/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHUserProfileViewController.h"
#import "SHMainViewController.h"
#import "SHOoVooSDKController.h"
#import "SHUserProfileController.h"
#import "SHCollectionViewFriendCell.h"
#import "GetGravatar.h"
#import <MBProgressHUD.h>
#import <UIActionSheet+Blocks.h>
#import "SHPuserController.h"

@interface SHUserProfileViewController ()<SHMainViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
@property (nonatomic,weak) IBOutlet UILabel *activeGroupLabel;
@property (nonatomic,weak) IBOutlet PFImageView *avatarImageView;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *SDKStateIndicatorView;
@property (nonatomic,weak) IBOutlet UICollectionView *groupFriendsView;

@property (nonatomic,strong) NSArray *friends;
@property (nonatomic,strong)  SHUserProfileController *profileController;

- (IBAction)logout:(id)sender;
- (IBAction)editAvatar:(id)sender;
@end

@implementation SHUserProfileViewController

- (void)awakeFromNib
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.profileController = [[SHUserProfileController alloc] initWithControllerContext:self.controllerContext];

    self.groupFriendsView.backgroundColor = [UIColor clearColor];
    self.avatarImageView.image = [UIImage imageNamed:@"avatar_placeholder"];
    self.groupFriendsView.scrollEnabled = YES;
   
    [self showHud];
    [self.profileController activeGroupWithBlock:^(PFObject *group) {
        if (group) {
            [self.controllerContext.pusherController listenToPusherCahnnel:group.objectId eventName:@"StartGame"];

            dispatch_async(dispatch_get_main_queue(), ^{
                self.activeGroupLabel.text = [PFUser currentUser].username;
                self.avatarImageView.image = [UIImage imageNamed:@"avatar_placeholder"];
                self.avatarImageView.file = (PFFile *)group[@"groupImage"];
                [self.avatarImageView loadInBackground:^(UIImage *image, NSError *error) {
                    if (error) {
                        NSLog(@"error = %@",error.userInfo);
                    }
                }];
            });
            [self.profileController getActiveGroupUsersWithBlock:^(NSArray *users, NSError *error) {
                if (users.count) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.friends = users;
                        
                        [self.groupFriendsView reloadData];
                    });
                    
                }
                [self hideHud];

            }];
        }

    }];
    self.avatarImageView.layer.cornerRadius = CGRectGetHeight(self.avatarImageView.bounds)/2;
    self.avatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.avatarImageView.layer.borderWidth = 3;
    self.avatarImageView.layer.masksToBounds = YES;
    

    
//    NSString *email = [PFUser currentUser].email;
//    NSURL *url = [GetGravatar gravatarURLForEmail:@"shannoga@me.com" size:@"200" default:nil];
//    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
//    dispatch_async(q, ^{
//        /* Fetch the image from the server... */
//        NSData *data = [NSData dataWithContentsOfURL:url];
//        UIImage *img = [[UIImage alloc] initWithData:data];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            /* This is the main thread again, where we set the tableView's image to
//             be what we just fetched. */
//            self.avatarImageView.image = img;
//        });
//    });
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.friends.count + 1;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SHCollectionViewFriendCell *cell = (SHCollectionViewFriendCell*)[cv dequeueReusableCellWithReuseIdentifier:@"FriendCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    if (indexPath.row != self.friends.count) {
        PFUser *user = [self.friends objectAtIndex:indexPath.row];
        cell.friendImageView.image = [UIImage imageNamed:@""]; // placeholder image
        cell.friendImageView.file = (PFFile *)user[@"userImage"]; // remote image
        [cell.friendImageView loadInBackground:^(UIImage *image, NSError *error) {
            NSLog(@"");
        }];
        cell.friendNameLabel.text = user.username;
    }
    else
    {
        cell.friendNameLabel.text = NSLocalizedString(@"ADD",nil);

    }
    return cell;
}


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.friends.count)
    {
        [self performSegueWithIdentifier:@"addUsersSegue" sender:self];
    }
    else
    {
        PFUser *user = [self.friends objectAtIndex:indexPath.row];
//        // Find users near a given location
//        //PFQuery *userQuery = [PFUser query];
//      //  [userQuery whereKey:@"location"
//         //      nearGeoPoint:stadiumLocation
//             //   withinMiles:[NSNumber numberWithInt:1]]
//        
//        // Find devices associated with these users
//        PFQuery *pushQuery = [PFInstallation query];
//        [pushQuery whereKey:@"user" equalTo:user];
//        
//        // Send push notification to query
//        PFPush *push = [[PFPush alloc] init];
//       // [push setData:<#(NSDictionary *)#>]
//        [push setQuery:pushQuery]; // Set our Installation query
//        [push setMessage:@"Free hotdogs at the Parse concession stand!"];
//        [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            if(error)
//            {
//                NSLog(@"error = %@", error.userInfo);
//            }
//            else if (succeeded)
//            {
//                NSLog(@"push sent to : %@", user.username);
//
//            }
//        }];
        [self.controllerContext.pusherController sendEventToChannelWithData:@{@"sender":[PFUser currentUser].objectId,@"reciver":user.objectId}];
        [self performSegueWithIdentifier:@"startSession" sender:self];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
}


#pragma mark – UICollectionViewDelegateFlowLayout


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize retval = CGSizeMake(90, 90);
    retval.height += 2; retval.width += 2;
    return retval;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(2, 2, 2, 2);
}




#pragma mark - Actions
- (IBAction)exitGame:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"startSession"]) {
        BOOL isOoVooREady = [self.controllerContext.sdkController oovooSDKLoggedIn];
        return isOoVooREady;

    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"startSession"]) {
        BOOL isOoVooReady = [self.controllerContext.sdkController oovooSDKLoggedIn];
        if (isOoVooReady) {
            [(SHMainViewController*)segue.destinationViewController setDelegate:self];
        }
        else
        {
            NSLog(@"should retry init oovoo");
        }
    }
}

- (void)userDidExitGame
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)logout:(id)sender
{
    [PFUser logOut];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLoggdOut" object:nil];
    
}

- (void)EditGroup
{
    //[self.profileController updateUserGroup:@"Shani and Asif"];
}

- (IBAction)editAvatar:(id)sender
{
    // does the device have a camera?
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        RIButtonItem *selectPhotoButton = [RIButtonItem itemWithLabel:NSLocalizedString(@"Choose from library",nil) action:^{
            [self selectPhoto];
        }];
        RIButtonItem *takePhotoButton = [RIButtonItem itemWithLabel:NSLocalizedString(@"Take a photo",nil) action:^{
            [self takePhoto];
        }];
        UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Image source",nil) cancelButtonItem:[RIButtonItem itemWithLabel:NSLocalizedString(@"Cancel",nil)] destructiveButtonItem:nil otherButtonItems:takePhotoButton,selectPhotoButton, nil];
        [ac showInView:self.view];
    }
    else
    {
        [self selectPhoto];
    }
}

- (void)takePhoto{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)selectPhoto {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.avatarImageView.image = chosenImage;
    [self.profileController updateGroupImage:chosenImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


@end
