//
//  TimelineViewController.m
//  twitter
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "TimelineViewController.h"
#import "APIManager.h"
#import "TweetCell.h"
#import "UIImageView+AFNetworking.h"
#import "ComposeViewController.h"
#import "DetailsViewController.h"
#import "ProfileViewController.h"
#import "DateTools.h"

@interface TimelineViewController () <UITableViewDelegate, UITableViewDataSource, ComposeViewControllerDelegate, TweetCellDelegate>
- (IBAction)didTapLogout:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *tweetsArray;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tweetsArray = [[NSMutableArray alloc] init];
    
    [self fetchTweets];
    
    // initialize an UIRefreshControl
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchTweets) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
}

- (void)fetchTweets {
    // Get timeline
    [[APIManager shared] getHomeTimelineWithCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            NSLog(@"😎😎😎 Successfully loaded home timeline");
            for (Tweet *tweet in tweets) {
                [self.tweetsArray addObject:tweet];
                NSString *text = tweet.text;
                NSLog(@"%@", text);
            }
            [self.tableView reloadData];
        } else {
            NSLog(@"😫😫😫 Error getting home timeline: %@", error.localizedDescription);
        }
        [self.refreshControl endRefreshing];
    }];
}

- (void)didTweet:(Tweet *)tweet {
    [self.tweetsArray insertObject:tweet atIndex:0];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    
    Tweet *tweet = self.tweetsArray[indexPath.row];
    cell.tweet = tweet;
    User *user = tweet.user;
    
    cell.authorLabel.text = user.name;
    
    NSString *at = @"@";
    NSString *username = [at stringByAppendingString:user.screenName];
    
    cell.userLabel.text = username;
    cell.tweetLabel.text = tweet.text;
    
    NSURL *profileURL = [NSURL URLWithString:user.profilePicture];
    cell.profileView.image = nil;
    
    [cell.profileView setImageWithURL:profileURL];
    
    
    cell.retweetLabel.text = [NSString stringWithFormat:@"%d", tweet.retweetCount];
    cell.favoriteLabel.text = [NSString stringWithFormat:@"%d", tweet.favoriteCount];
        
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
    
    NSDate *date = [formatter dateFromString:tweet.createdAtString];
    [cell formatDate:date];
//    cell.dateLabel.text = tweet.createdAtString;
    NSLog(@"%@", tweet.createdAtString);
    cell.delegate = self;
    
    return cell;
}
    
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweetsArray.count;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"composeSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        ComposeViewController *composeController = (ComposeViewController*)navigationController.topViewController;
        composeController.delegate = self;
    } else if ([segue.identifier isEqualToString:@"profileSegue"]) {
        ProfileViewController *userProfileViewController = [segue destinationViewController];
        userProfileViewController.user = sender;
    } else {
        TweetCell *cell = sender;
        DetailsViewController *tweetDetailController = [segue destinationViewController];
        tweetDetailController.tweet = cell.tweet;
    }
}

- (IBAction)didTapLogout:(id)sender {
    // TimelineViewController.m
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    appDelegate.window.rootViewController = loginViewController;
    
    [[APIManager shared] logout];

}

- (void)tweetCell:(TweetCell *)tweetCell didTap:(User *)user{
    [self performSegueWithIdentifier:@"profileSegue" sender:user];
}
@end
