//
//  Tweet.m
//  twitter
//
//  Created by Mai Ngo on 6/21/22.
//  Copyright © 2022 Emerson Malca. All rights reserved.
//

#import "Tweet.h"
#import "DateTools.h"
#import "User.h"

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
        self.text = dictionary[@"full_text"];
        self.favoriteCount = [dictionary[@"favorite_count"] intValue];
        self.favorited = [dictionary[@"favorited"] boolValue];
        self.retweetCount = [dictionary[@"retweet_count"] intValue];
        self.retweeted = [dictionary[@"retweeted"] boolValue];
        
        // initialize user
        NSDictionary *user = dictionary[@"user"];
        self.user = [[User alloc] initWithDictionary:user];
        
        // Format createdAt date string
        NSString *createdAtOriginalString = dictionary[@"created_at"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        // Configure the input format to parse the date string
        formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];

        // Convert String to Date
        NSDate *date = [formatter dateFromString:createdAtOriginalString];

        self.date = date;

        self.createdAtString = self.date.shortTimeAgoSinceNow;
        
        NSLog(@"%@", [formatter stringFromDate:date]);
        
        
//        self.createdAtString = [formatter stringFromDate:date];

        
        self.videoUrlArray = [[NSMutableArray alloc] init];
        self.imageUrlArray = [[NSMutableArray alloc] init];
        NSArray *mediaUrls = dictionary[@"entities"][@"media"];
        NSArray *videoUrls = dictionary[@"entities"][@"urls"];
        for (NSDictionary *url in videoUrls) {
            [self.videoUrlArray addObject:url[@"expanded_url"]];
        }
        for (NSDictionary *url in mediaUrls) {
            [self.imageUrlArray addObject:url[@"media_url_https"]];
        }
    }
    return self;
}


+ (NSMutableArray *)tweetsWithArray:(NSArray *)dictionaries {
    NSMutableArray *tweets = [NSMutableArray array];
    for (NSDictionary *dictionary in dictionaries) {
        Tweet *tweet = [[Tweet alloc] initWithDictionary:dictionary];
        [tweets addObject:tweet];
    }
    return tweets;
}


@end
