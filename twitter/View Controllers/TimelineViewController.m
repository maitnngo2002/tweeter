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
#import "ReplyButton.h"
#import "ReplyViewController.h"

@interface TimelineViewController () <UITableViewDelegate, UITableViewDataSource, ComposeViewControllerDelegate, ReplyViewControllerDelegate, TweetCellDelegate>
- (IBAction)didTapLogout:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *tweetsArray;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

NSString *const composeSegue = @"composeSegue";
NSString *const profileSegue = @"profileSegue";

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
            for (Tweet *tweet in tweets) {
                [self.tweetsArray addObject:tweet];
            }
            [self.tableView reloadData];
        } else {
            NSLog(@"😫😫😫 Error getting home timeline: %@", error.localizedDescription);
        }
        [self.refreshControl endRefreshing];
    }];
}

- (void)fetchNextTimelinePage {
    if (self.tweetsArray) {
        Tweet *lastTweet = [self.tweetsArray lastObject];
        [[APIManager shared] getHomeTimelineAfterIdWithCompletion:lastTweet.idStr completion:^(NSArray *tweets, NSError *error) {
            if (tweets) {
                for(Tweet *tweet in tweets) {
                    [self.tweetsArray addObject:tweet];
                }
                [self.tableView reloadData];
                [self.refreshControl endRefreshing];
            } else {
                NSLog(@"😫😫😫 Error getting more tweets: %@", error.localizedDescription);
            }
        }];
    }
}

- (void)didTweet:(Tweet *)tweet {
    [self.tweetsArray insertObject:tweet atIndex:0];
    [self.tableView reloadData];
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
    
    NSURL *const profileURL = [NSURL URLWithString:user.profilePicture];
    cell.profileView.image = nil;
    
    [cell.profileView setImageWithURL:profileURL];
    
    // Enable reply button
    cell.replyButton.originalTweet = tweet;
    [cell.replyButton addTarget:self action:@selector(didReply:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.retweetLabel.text = [NSString stringWithFormat:@"%d", tweet.retweetCount];
    cell.favoriteLabel.text = [NSString stringWithFormat:@"%d", tweet.favoriteCount];
    
    cell.dateLabel.text = tweet.createdAtString;
        
    cell.delegate = self;
    
    if(indexPath.row == self.tweetsArray.count - 1) {
        [self fetchNextTimelinePage];
    }
    return cell;
}
    
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweetsArray.count;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:composeSegue]) {
        UINavigationController *navigationController = [segue destinationViewController];
        ComposeViewController *composeController = (ComposeViewController*)navigationController.topViewController;
        composeController.delegate = self;
    } else if ([segue.identifier isEqualToString:profileSegue]) {
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

- (IBAction)didReply:(id)sender {
    ReplyButton *buttonClicked = (ReplyButton *)sender;
    ReplyViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ReplyViewController"];
    viewController.tweet = buttonClicked.originalTweet;
    viewController.delegate = self;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)tweetCell:(TweetCell *)tweetCell didTap:(User *)user{
    [self performSegueWithIdentifier:@"profileSegue" sender:user];
}


@end
