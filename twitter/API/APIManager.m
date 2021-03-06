//
//  APIManager.m
//  twitter
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "APIManager.h"
#import "Tweet.h"

static NSString *const baseURLString = @"https://api.twitter.com";

@interface APIManager()

@end

@implementation APIManager

+ (instancetype)shared {
    static APIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    
    NSURL *const baseURL = [NSURL URLWithString:baseURLString];

    NSString *const path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *const dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *key = [dict objectForKey: @"consumer_Key"];
    NSString *secret = [dict objectForKey: @"consumer_Secret"];
    
    // Check for launch arguments override
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"consumer-key"]) {
        key = [[NSUserDefaults standardUserDefaults] stringForKey:@"consumer-key"];
    }
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"consumer-secret"]) {
        secret = [[NSUserDefaults standardUserDefaults] stringForKey:@"consumer-secret"];
    }
    
    self = [super initWithBaseURL:baseURL consumerKey:key consumerSecret:secret];
    return self;
}

- (void)postTweetRequest:(NSString *)urlString parameters:(NSDictionary *)parameters completion:(void (^)(Tweet *, NSError *))completion {
    [self POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable tweetDictionary) {
        Tweet *tweet = [[Tweet alloc]initWithDictionary:tweetDictionary];
        completion(tweet, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)postReplyToTweet:(NSString *)text statusId:(NSString *)statusId completion:(void (^)(Tweet *, NSError *))completion {
    NSString *const urlString = @"1.1/statuses/update.json";
    NSDictionary *const parameters = @{@"status":text, @"in_reply_to_status_id":statusId};
    [self postTweetRequest:urlString parameters:parameters completion:^(Tweet *tweet, NSError *error) {
        if(tweet) {
            completion(tweet, nil);
        }
        else {
            completion(nil, error);
        }
    }];
}

- (void)getHomeTimelineWithCompletion:(void(^)(NSArray *tweets, NSError *error))completion {
    [self GET:@"1.1/statuses/home_timeline.json"
   parameters:@{@"tweet_mode":@"extended"} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSArray *  _Nullable tweetDictionaries) {
           // Success
           NSMutableArray *tweets = [Tweet tweetsWithArray:tweetDictionaries];
           completion(tweets, nil);
       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           // There was a problem
           completion(nil, error);
    }];
}

- (void)getHomeTimelineAfterIdWithCompletion:(NSString *)maxIdStr completion:(void(^)(NSArray *tweets, NSError *error))completion {
    [self GET:@"1.1/statuses/home_timeline.json"
   parameters:@{@"tweet_mode":@"extended", @"max_id":maxIdStr} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSArray *  _Nullable tweetDictionaries) {
           // Success
           NSMutableArray *tweets = [Tweet tweetsWithArray:tweetDictionaries];
        if (tweets.count > 0) {
            [tweets removeObjectAtIndex:0];
            completion(tweets, nil);
        }
            
       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           // There was a problem
           completion(nil, error);
    }];
}

- (void)postStatusWithText:(NSString *)text completion:(void (^)(Tweet *, NSError *))completion {
    NSString *const urlString = @"1.1/statuses/update.json";
    NSDictionary *const parameters = @{@"status": text};
    [self postTweetRequest:urlString parameters:parameters completion:^(Tweet *tweet, NSError *error) {
        if(tweet) {
            completion(tweet, nil);
        }
        else {
            completion(nil, error);
        }
    }];
}

- (void)favorite:(Tweet *)tweet completion:(void (^)(Tweet *, NSError *))completion {
    NSString *const urlString = @"1.1/favorites/create.json";
    NSDictionary *const parameters = @{@"id": tweet.idStr};
    [self postTweetRequest:urlString parameters:parameters completion:^(Tweet *tweet, NSError *error) {
        if(tweet) {
            completion(tweet, nil);
        }
        else {
            completion(nil, error);
        }
    }];
}

- (void)unfavorite:(Tweet *)tweet completion:(void (^)(Tweet *, NSError *))completion {
    NSString *const urlString = @"1.1/favorites/destroy.json";
    NSDictionary *const parameters = @{@"id": tweet.idStr};
    [self postTweetRequest:urlString parameters:parameters completion:^(Tweet *tweet, NSError *error) {
        if(tweet) {
            completion(tweet, nil);
        }
        else {
            completion(nil, error);
        }
    }];
}

- (void)retweet:(Tweet *)tweet completion:(void (^)(Tweet *, NSError *))completion {
    NSString *const urlString = [NSString stringWithFormat:@"1.1/statuses/retweet/%@.json", tweet.idStr];
    NSDictionary *const parameters = @{@"id": tweet.idStr};
    [self postTweetRequest:urlString parameters:parameters completion:^(Tweet *tweet, NSError *error) {
        if(tweet) {
            completion(tweet, nil);
        }
        else {
            completion(nil, error);
        }
    }];
}

- (void)unretweet:(Tweet *)tweet completion:(void (^)(Tweet *, NSError *))completion {
    NSString *const urlEnd = [tweet.idStr stringByAppendingString:@".json"];
    NSString *const urlString = [@"1.1/statuses/unretweet/" stringByAppendingString:urlEnd];
    NSDictionary *parameters = @{@"id": tweet.idStr};
    [self postTweetRequest:urlString parameters:parameters completion:^(Tweet *tweet, NSError *error) {
        if(tweet) {
            completion(tweet, nil);
        }
        else {
            completion(nil, error);
        }
    }];
}

- (void)getCurrentUser:(void (^)(User *, NSError *))completion {
    NSString *const urlString = @"1.1/account/verify_credentials.json";
    [self GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable userDictionary) {
        User *user = [[User alloc]initWithDictionary:userDictionary];
        completion(user, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)getUserTimelineWithParam: (NSDictionary *)param WithCompletion:(void(^)(NSArray *tweets, NSError *error))completion {
    
    // Create a GET Request
    [self GET:@"1.1/statuses/user_timeline.json"
   parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSArray *  _Nullable tweetDictionaries) {
       // Success
       NSMutableArray *tweets  = [Tweet tweetsWithArray:tweetDictionaries];
       completion(tweets, nil);
   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       // There was a problem
       completion(nil, error);
   }];
}


@end
