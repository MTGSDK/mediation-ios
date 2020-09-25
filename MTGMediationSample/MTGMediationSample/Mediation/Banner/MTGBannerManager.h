//
//  MTGBannerManager.h
//  MTGMediationSample
//
//  Created by zhangchark on 2020/9/20.
//  Copyright © 2020 CharkZhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTGAdServerCommunicator.h"

@protocol MTGBannerManagerDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface MTGBannerManager : NSObject <MTGAdServerCommunicatorDelegate>



@property (nonatomic, weak) id<MTGBannerManagerDelegate> delegate;

- (id)initWithDelegate:(id<MTGBannerManagerDelegate>)delegate;

- (void)loadAdWithAdUnitID:(NSString *)adUnitID;

- (void)startAutomaticallyRefreshingContents:(int)refreshInterval;

- (void)stopAutomaticallyRefreshingContents;



@end

NS_ASSUME_NONNULL_END
