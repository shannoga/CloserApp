//
//  SHSignUpViewController.m
//  Closer
//
//  Created by shani hajbi on 3/20/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHSignUpViewController.h"
#import "UIAlertView+Blocks.h"
#import "MBProgressHUD.h"

@interface SHSignUpViewController ()
@property (nonatomic,weak) IBOutlet UITextField *userNameLabel;
@property (nonatomic,weak) IBOutlet UITextField *passwordLabel;
@property (nonatomic,weak) IBOutlet UITextField *emailLabel;
- (IBAction)signup:(id)sender;
@end

@implementation SHSignUpViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    self.title = NSLocalizedString(@"SIGN UP", nil);

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signup:(id)sender
{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"Logging in",nil);
    
    PFUser *user = [PFUser user];
    user.username = _userNameLabel.text;
    user.password = _passwordLabel.text;
    user.email = _emailLabel.text;
    
    // other fields can be set just like with PFObject
    // user[@"phone"] = @"415-392-0202";
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (!error) {
            // Hooray! Let them use the app now.
            [self userLoggedIn];
            [self setUpTrialCreditsForUser:user];
            
        } else {
            NSString *errorString = [error userInfo][@"error"];
            DDLogError(@"error = %@",errorString);
            [self presentAlertWithError:errorString];
            
            // Show the errorString somewhere and let the user try again.
        }
    }];
}


- (void)presentAlertWithError:(NSString*)errorString
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:errorString delegate:self cancelButtonTitle:NSLocalizedString(@"Close", nil) otherButtonTitles:nil, nil];
    [av show];
}

- (void)setUpTrialCreditsForUser:(PFUser*)user
{
    user[@"credits"] = @0;
    //  user[@"groupName"] = @"asifshani";
    [user saveInBackground];
}

- (void)userLoggedIn
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLoggdIn" object:nil];
}


//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    // Configure the cell...
//    
//    return cell;
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
