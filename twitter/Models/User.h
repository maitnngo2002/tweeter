//
//  User.h
//  twitter
//
//  Created by Mai Ngo on 6/21/22.
//  Copyright © 2022 Emerson Malca. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface User : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *screenName;
@property (strong, nonatomic) NSString *profilePicture;
@property (strong, nonatomic) NSString *bio;
@property (strong, nonatomic) NSString *backgroundPicture;
@property (strong, nonatomic) NSString *tweetCount;
@property (strong, nonatomic) NSString *followingCount;
@property (strong, nonatomic) NSString *followersCount;


- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
