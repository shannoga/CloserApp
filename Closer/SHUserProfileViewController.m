//
//  SHUserProfileViewController.m
//  Closer
//
//  Created by shani hajbi on 3/22/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHUserProfileViewController.h"
#import "SHMainViewController.h"
#import "UIActionSheet+Blocks.h"
#import "SHOoVooSDKController.h"
#import "SHUserProfileController.h"
#import "SHCollectionViewFriendCell.h"

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
    self.profileController = [[SHUserProfileController alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.profileController updateUserGroup:@"Shani and Asif"];
    self.groupFriendsView.scrollEnabled = YES;
    [self.profileController activeGroupWithBlock:^(PFObject *group) {
        if (group) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.activeGroupLabel.text = group[@"groupName"];
                self.avatarImageView.image = [UIImage imageNamed:@""]; // placeholder image
                self.avatarImageView.file = (PFFile *)group[@"groupImage"]; // remote image
                [self.avatarImageView loadInBackground:^(UIImage *image, NSError *error) {
                    NSLog(@"");
                }];
            });
            [self.profileController getActiveGroupUsersWithBlock:^(NSArray *users, NSError *error) {
                if (users.count) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.friends = users;
                        [self.groupFriendsView reloadData];
                    });
                    
                }
            }];
        }
        
    }];
    
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.friends.count;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SHCollectionViewFriendCell *cell = (SHCollectionViewFriendCell*)[cv dequeueReusableCellWithReuseIdentifier:@"FriendCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor orangeColor];
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    cell.friendImageView.image = [UIImage imageNamed:@""]; // placeholder image
    cell.friendImageView.file = (PFFile *)user[@"userImage"]; // remote image
    [cell.friendImageView loadInBackground:^(UIImage *image, NSError *error) {
        NSLog(@"");
    }];
    cell.friendNameLabel.text = user.username;
    return cell;
}


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
}


#pragma mark – UICollectionViewDelegateFlowLayout


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize retval = CGSizeMake(60, 60);
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
        BOOL isOoVooREady = [self.controllerContext.sdkController oovooSDKLoggedIn];
        if (isOoVooREady) {
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
    
}

- (IBAction)editAvatar:(id)sender
{
    //if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//        
//        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                              message:@"Device has no camera"
//                                                             delegate:nil
//                                                    cancelButtonTitle:@"OK"
//                                                    otherButtonTitles: nil];
//        
//        [myAlertView show];
    
    //}
//    NSLog(@"window = %@",[self.view.window description]);
    [self selectPhoto];
   
}

- (void)takePhoto{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
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
