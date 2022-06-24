//
//  ComposeViewController.m
//  twitter
//
//  Created by Mai Ngo on 6/21/22.
//  Copyright © 2022 Emerson Malca. All rights reserved.
//

#import "ComposeViewController.h"
#import "APIManager.h"

@interface ComposeViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *characterCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *warningLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tweetButton;

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.textView.delegate = self;
    [self.warningLabel setHidden:YES];

}
//
//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
//    // Set the max character limit
//    int characterLimit = 140;
//
//    // Construct what the new text would be if we allowed the user's latest edit
//    NSString *newText = [self.textView.text stringByReplacingCharactersInRange:range withString:text];
//
//    // TODO: Update character count label
//    self.characterCountLabel.text = [NSString stringWithFormat:@"%lu", [newText length]];
//
//    if (newText.length < characterLimit) {
//        [self.warningLabel setHidden:YES];
//    }
//    // Should the new text should be allowed? True/False
//    return newText.length < characterLimit;
//}
//    // TODO: Allow or disallow the new text

- (void)textViewDidChange:(UITextView *)textView {
    NSString *text = self.textView.text;
    NSInteger *count = [text length];
    NSString *countString = [NSString stringWithFormat:@"%lu", count];
    self.characterCountLabel.text = countString;
    if(count > 140) {
        [self.warningLabel setHidden:NO];
        self.characterCountLabel.textColor = [UIColor redColor];
        self.tweetButton.enabled = NO;
    }
    else {
        [self.warningLabel setHidden:YES];
        self.characterCountLabel.textColor = [UIColor blackColor];
        self.tweetButton.enabled = YES;
    }
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}
- (IBAction)tweet:(id)sender {
    [[APIManager shared] postStatusWithText:self.textView.text completion:^(Tweet *tweet, NSError *error) {
        if(error){
            NSLog(@"Error composing Tweet: %@", error.localizedDescription);
        }
        else{
            [self.delegate didTweet:tweet];
            NSLog(@"Compose Tweet Success!");
            [self dismissViewControllerAnimated:true completion:nil];
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

@end
