//
//  SHAddUsersViewController.m
//  Closer
//
//  Created by shani hajbi on 3/27/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHAddUsersViewController.h"

@interface SHAddUsersViewController ()<UISearchBarDelegate>
@property (nonatomic,weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic,strong) PFObject *group;
@property (nonatomic,strong) NSArray *results;
@property (nonatomic) BOOL isSearching;
@end

@implementation SHAddUsersViewController

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.results count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UserCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PFUser *user = self.results[indexPath.row];
    cell.textLabel.text = user.username;
    cell.detailTextLabel.text = user.email;
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    PFUser *user = self.results[indexPath.row];

    NSString *invitationString = NSLocalizedString(@"Are you sure you want to add %@",nil);
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Add User",nil) message:[NSString stringWithFormat:invitationString,user.username] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil] show];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return !self.isSearching;
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (searchBar.text.length < 3) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Please Note",nil) message:NSLocalizedString(@"Enter at least 3 carachters to perfom search",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil] show];
        return;
    }
    self.isSearching = YES;
    [searchBar resignFirstResponder];
    PFQuery *query = [PFUser query];
    query.cachePolicy =  kPFCachePolicyCacheElseNetwork;
    query.maxCacheAge = 360;
    [query whereKey:@"username" containsString:searchBar.text];
   [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
       if (objects) {
           self.results = objects;
       }
       else
       {
           NSLog(@"error = %@", error);
       }
       dispatch_async(dispatch_get_main_queue(), ^{
           [self.tableView reloadData];
           self.isSearching = NO;

       });
   }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    self.results = @[];
    [self.tableView reloadData];
}


@end
