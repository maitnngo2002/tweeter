//
//  ReplyViewController.m
//  twitter
//
//  Created by Mai Ngo on 6/24/22.
//  Copyright © 2022 Emerson Malca. All rights reserved.
//

#import "ReplyViewController.h"
#import "User.h"
#import "ProfileButton.h"
#import "APIManager.h"

@interface ReplyViewController ()

@property (weak, nonatomic) IBOutlet UITextView *replyTextView;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *tweetTagName;
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;
@property (weak, nonatomic) IBOutlet UILabel *replyToLabel;

@property (weak, nonatomic) IBOutlet ProfileButton *tweetUserButton;
@property (weak, nonatomic) IBOutlet ProfileButton *ownUserButton;

@property (strong, nonatomic) User *ownUser;

@end

@implementation ReplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[APIManager shared] getCurrentUser:^(User *user, NSError *error) {
         if(error) {
              NSLog(@"Error fetching user information: %@", error.localizedDescription);
         }
         else{
             NSLog(@"Successfully fetched user info: %@", user.name);
             self.ownUser = user;
             [self refreshData];
         }
     }];
}

- (void)refreshData {
    // Set tweet user image
    NSString *URLString = self.tweet.user.profilePicture;
    NSURL *url = [NSURL URLWithString:URLString];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    [self.tweetUserButton setBackgroundImage: [UIImage imageWithData:urlData] forState:UIControlStateNormal];
    self.tweetUserButton.layer.cornerRadius = self.tweetUserButton.frame.size.width / 3;
    self.tweetUserButton.clipsToBounds = YES;
    
    // Set own user image
    NSString *userURLString = self.ownUser.profilePicture;
    NSURL *userUrl = [NSURL URLWithString:userURLString];
    NSData *userUrlData = [NSData dataWithContentsOfURL:userUrl];
    [self.ownUserButton setBackgroundImage: [UIImage imageWithData:userUrlData] forState:UIControlStateNormal];
    
    self.tweetTagName.text = self.tweet.user.screenName;
    self.userName.text = self.tweet.user.name;
    
    self.tweetTextView.text = self.tweet.text;
    
    // Set replying to label
    self.replyToLabel.text = [@"Replying to " stringByAppendingString:self.tweet.user.screenName];

    
}

- (IBAction)closeBtnAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)replyButton:(id)sender {
    NSString *mention = [@"@" stringByAppendingString:self.tweet.user.screenName];
    NSString *replyText = [[mention stringByAppendingString:@" "] stringByAppendingString:self.replyTextView.text];

    [[APIManager shared] postReplyToTweet:replyText statusId:self.tweet.idStr completion:^(Tweet *tweet, NSError *error) {
        if(error){
            NSLog(@"Error replying to Tweet: %@", error.localizedDescription);
        }
        else{
            NSLog(@"Reply Tweet Success!");
            [self.delegate didReply:self.tweet.idStr];
        }
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
