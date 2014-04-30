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
#import "SHUser.h"
#import "SHMessagesCoordinator.h"
#import "SHPubNubController.h"
#import <Crashlytics/Crashlytics.h>

@interface SHUserProfileViewController ()<SHMainViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource, SHUserProfileControllerDelegate>
@property (nonatomic,weak) IBOutlet UILabel *activeGroupLabel;
@property (nonatomic,weak) IBOutlet PFImageView *avatarImageView;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *SDKStateIndicatorView;
@property (nonatomic,weak) IBOutlet UICollectionView *groupFriendsView;
@property (nonatomic,copy) NSString *sessionSegueuId;
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
    
    //[[Crashlytics sharedInstance] crash];

    self.controllerContext.userProfileController.delegate = self;
    self.groupFriendsView.backgroundColor = [UIColor clearColor];
    self.avatarImageView.image = [UIImage imageNamed:@"avatar_placeholder"];
    self.groupFriendsView.scrollEnabled = YES;
   
    //[self showHud];
    [self.controllerContext.userProfileController activeGroupWithBlock:^(PFObject *group) {
        if (group) {

            dispatch_async(dispatch_get_main_queue(), ^{
                self.activeGroupLabel.text = [PFUser currentUser].username;
                self.avatarImageView.image = [UIImage imageNamed:@"avatar_placeholder"];
                self.avatarImageView.file = (PFFile *)group[@"groupImage"];
                [self.avatarImageView loadInBackground:^(UIImage *image, NSError *error) {
                    if (error) {
                        DDLogError(@"error = %@",error.userInfo);
                    }
                }];
            });
            [self.controllerContext.userProfileController getActiveGroupUsersWithBlock:^(NSArray *users, NSError *error) {
                if (users.count) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.groupFriendsView reloadData];
                    });
                    
                }
               // [self hideHud];

            }];
        }

    }];
    self.avatarImageView.layer.cornerRadius = CGRectGetHeight(self.avatarImageView.bounds)/2;
    self.avatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.avatarImageView.layer.borderWidth = 3;
    self.avatarImageView.layer.masksToBounds = YES;
    
    self.sessionSegueuId = [[SHMessagesCoordinator sharedCoordinator] playerMode] == PlayerModeAdult ? @"startAdultSession" : @"startKidSession";

    
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
    return self.controllerContext.userProfileController.activeUsers.count + 1;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SHCollectionViewFriendCell *cell = (SHCollectionViewFriendCell*)[cv dequeueReusableCellWithReuseIdentifier:@"FriendCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    if (indexPath.row != self.controllerContext.userProfileController.activeUsers.count) {
        SHUser *user = [self.controllerContext.userProfileController.activeUsers objectAtIndex:indexPath.row];
        cell.friendImageView.image = [UIImage imageNamed:@""]; // placeholder image
        cell.friendImageView.file = (PFFile *)user[@"userImage"]; // remote image
        cell.friendImageView.alpha = user.online ? 1 : .5;
        [cell.friendImageView loadInBackground:^(UIImage *image, NSError *error) {
        }];
        cell.friendNameLabel.text = user.username;
    }
    else
    {
        cell.friendImageView.alpha = 1;
        cell.friendNameLabel.text = NSLocalizedString(@"ADD",nil);
    }
    return cell;
}


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.controllerContext.userProfileController.activeUsers.count)
    {
        [self performSegueWithIdentifier:@"addUsersSegue" sender:self];
    }
    else
    {
        SHUser *user = [self.controllerContext.userProfileController.activeUsers objectAtIndex:indexPath.row];
        [self showHud];
        [self.controllerContext.pubnubController callUserWithObjectId:user.objectId WithCallResultHandler:^(SHCallResult callResult, NSError *error) {
            switch (callResult) {
                case SHCallResultAnswered:
                        [self performSegueWithIdentifier:self.sessionSegueuId sender:self];
                    break;
                case SHCallResultRejected:
                    //close call and present a rejected message
                    break;
                case SHCallResultTimedOut:
                    //close call and present a time out message
                    break;
                case SHCallResultUnknown:
                    //close call and present a general error
                    break;
                    
                default:
                    break;
            }
            [self hideHud];
        }];

       
    }
}


- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark – SHUserProfileControllerDelegate
- (void)activeUsersDidUpdatePresence
{
    [self.groupFriendsView reloadData];
}

- (void)userDidCall:(NSString *)userId answerHandler:(void (^)(SHCallResult))callResult
{
    RIButtonItem *answerItem = [RIButtonItem itemWithLabel:NSLocalizedString(@"Play",nil) action:^{
        [self performSegueWithIdentifier:self.sessionSegueuId sender:self];
        callResult(SHCallResultAnswered);
    }];
    
    RIButtonItem *rejectItem = [RIButtonItem itemWithLabel:NSLocalizedString(@"Reject",nil) action:^{
        callResult(SHCallResultRejected);
    }];
    [[[UIAlertView alloc] initWithTitle:@"call" message:NSLocalizedString(@"wants to play with you",nil) cancelButtonItem:nil otherButtonItems:answerItem,rejectItem, nil] show];
    
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
    if ([identifier isEqualToString:self.sessionSegueuId]) {
        BOOL isOoVooREady = [self.controllerContext.sdkController oovooSDKLoggedIn];
        return isOoVooREady;

    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:self.sessionSegueuId]) {
        BOOL isOoVooReady = [self.controllerContext.sdkController oovooSDKLoggedIn];
        if (isOoVooReady) {
            [(SHMainViewController*)segue.destinationViewController setDelegate:self];
            [(SHMainViewController*)segue.destinationViewController setControllerContext:self.controllerContext];
        }
        else
        {
            DDLogWarn(@"should retry init oovoo");
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
    [self.controllerContext.userProfileController updateGroupImage:chosenImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}




@end
