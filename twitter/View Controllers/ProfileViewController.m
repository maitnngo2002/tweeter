//
//  ProfileViewController.m
//  twitter
//
//  Created by Mai Ngo on 6/22/22.
//  Copyright © 2022 Emerson Malca. All rights reserved.
//

#import "ProfileViewController.h"
#import "UIImageView+AFNetworking.h"
#import "APIManager.h"
#import "UserTweetCell.h"
#import "Tweet.h"

@interface ProfileViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *backdropView;
@property (weak, nonatomic) IBOutlet UIImageView *profileView;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetCount;
@property (weak, nonatomic) IBOutlet UILabel *followingCount;
@property (weak, nonatomic) IBOutlet UILabel *followerCount;
@property (weak, nonatomic) IBOutlet UILabel *timeLine;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *tweets;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 150;
    
    self.authorLabel.text = self.user.name;
    NSString *at = @"@";
    NSString *username = [at stringByAppendingString:self.user.screenName];
    self.userLabel.text = username;
    self.bioLabel.text = self.user.bio;
    
    NSURL *backgroundURL = [NSURL URLWithString:self.user.backgroundPicture];
    self.backdropView.image = nil;
    [self.backdropView setImageWithURL:backgroundURL];
    
    NSURL *profileURL = [NSURL URLWithString:self.user.profilePicture];
    self.profileView.image = nil;
    [self.profileView setImageWithURL:profileURL];
    
    self.tweetCount.text = [self.user.tweetCount stringByAppendingString:@" Tweets"];
    self.followingCount.text = [self.user.followingCount stringByAppendingString:@" Following"];
    self.followerCount.text = [self.user.followersCount stringByAppendingString:@" Followers"];
    
    [self fetchTweets];
}

- (void)fetchTweets {
    // Get timeline
    NSDictionary *param = @{@"screen_name": self.user.screenName};
    [[APIManager shared] getUserTimelineWithParam:param WithCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            self.tweets = tweets;
            [self.tableView reloadData];
        } else {
            NSLog(@"😫😫😫 Error getting tweet: %@", error.localizedDescription);
        }
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UserTweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserTweetCell"];
    [cell setTweet: self.tweets[indexPath.row]];
    return cell;
}
    
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}
@end
