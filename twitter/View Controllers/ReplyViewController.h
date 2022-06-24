//
//  ReplyViewController.h
//  twitter
//
//  Created by Mai Ngo on 6/24/22.
//  Copyright © 2022 Emerson Malca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ReplyViewControllerDelegate
- (void)didReply:(NSString *)idStr;
@end

@interface ReplyViewController : UIViewController
@property(strong, nonatomic) Tweet *tweet;
@property(strong, nonatomic) id<ReplyViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
