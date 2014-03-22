//
//  SHLoginScreenViewController.m
//  Closer
//
//  Created by shani hajbi on 2/19/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHLoginScreenViewController.h"
#import "SHMainViewController.h"
#import "UIAlertView+Blocks.h"
#import "MBProgressHUD.h"

@interface SHLoginScreenViewController ()
@property (nonatomic,weak) IBOutlet UITextField *userNameLabel;
@property (nonatomic,weak) IBOutlet UITextField *passwordLabel;
@property (nonatomic,weak) IBOutlet UITextField *emailLabel;
- (IBAction)login:(id)sender;
- (IBAction)signup:(id)sender;
- (IBAction)loginWithFacebook:(id)sender;
- (IBAction)loginWithTwitter:(id)sender;

@end

@implementation SHLoginScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    self.title = NSLocalizedString(@"LOGIN", nil);

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    [[((UITableViewHeaderFooterView*) view) textLabel] setTextColor : [UIColor greenColor]];
    [[((UITableViewHeaderFooterView*) view) contentView]setBackgroundColor:[UIColor redColor]];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    [[((UITableViewHeaderFooterView*) view) textLabel] setTextColor : [UIColor greenColor]];
    [[((UITableViewHeaderFooterView*) view) contentView]setBackgroundColor:[UIColor redColor]];


}


- (IBAction)login:(id)sender
{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"Logging in",nil);
    [PFUser logInWithUsernameInBackground:_userNameLabel.text password:_passwordLabel.text block:^(PFUser *user, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (!error) {
            [self userLoggedIn];
        }  else {
            NSString *errorString = [error userInfo][@"error"];
            NSLog(@"error = %@",errorString);
            [self presentAlertWithError:errorString];
        }
    }];
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
            NSLog(@"error = %@",errorString);
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

@end
