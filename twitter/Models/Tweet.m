//
//  Tweet.m
//  twitter
//
//  Created by Mai Ngo on 6/21/22.
//  Copyright © 2022 Emerson Malca. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        
        // Is this a re-tweet?
        NSDictionary *originalTweet = dictionary[@"retweeted_status"];
        if(originalTweet != nil){
            NSDictionary *userDictionary = dictionary[@"user"];
            self.retweetedByUser = [[User alloc] initWithDictionary:userDictionary];
            
            // Change tweet to original tweet
            dictionary = originalTweet;
        }
        self.idStr = dictionary[@"id_str"];
        self.text = dictionary[@"text"];
        self.favoriteCount = [dictionary[@"favorite_count"] intValue];
        self.favorited = [dictionary[@"favorited"] boolValue];
        self.retweetCount = [dictionary[@"retweet_count"] intValue];
        self.retweeted = [dictionary[@"retweeted"] boolValue];
        
        // initialize user
        NSDictionary *user = dictionary[@"user"];
        self.user = [[User alloc] initWithDictionary:user];
        
        // Format and set createdAtString
        NSString *createdAtOriginalString = dictionary[@"created_at"];
        self.createdAtString = [self formatDate:createdAtOriginalString];
        
    }
    return self;
}

-(NSString *)formatDate:(NSString *)origDate {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
        [formatter setDateFormat:@"E MMM d HH:mm:ss Z y"];
        NSDate *convertedDate = [formatter dateFromString:origDate];
        NSDate *todayDate = [NSDate date];
        double ti = [convertedDate timeIntervalSinceDate:todayDate];
        ti = ti * -1;
        if(ti < 1) {
            return @"never";
        } else  if (ti < 60) {
            return @"less than a min ago";
            //return [NSString stringWithFormat:@"%d less than a min ago"];
        } else if (ti < 3600) {
            int diff = round(ti / 60);
            return [NSString stringWithFormat:@"%d min ago", diff];
        } else if (ti < 86400) {
            int diff = round(ti / 60 / 60);
            return[NSString stringWithFormat:@"%d hr ago", diff];
        } else if (ti < INFINITY) {
            formatter.dateStyle = NSDateFormatterShortStyle;
            formatter.timeStyle = NSDateFormatterNoStyle;
            return [formatter stringFromDate:convertedDate];
        }
        else {
            return @"never";
        }
}

+ (NSMutableArray *)tweetsWithArray:(NSArray *)dictionaries{
    NSMutableArray *tweets = [NSMutableArray array];
    for (NSDictionary *dictionary in dictionaries) {
        Tweet *tweet = [[Tweet alloc] initWithDictionary:dictionary];
        [tweets addObject:tweet];
    }
    return tweets;
}

@end
