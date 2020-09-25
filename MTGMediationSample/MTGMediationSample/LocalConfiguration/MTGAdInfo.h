//
//  MTGAdInfo.h
//  MTGMediationSample
//
//  Created by CharkZhang on 2019/1/18.
//  Copyright © 2019 CharkZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTGAdInfo : NSObject

//RewardVideo
+ (NSArray *)rewardVideoAdUnitIds;
+ (NSArray *)rewardVideoInfosWithAdUnitId:(NSString *)adUnitId;


//Interstitial
+ (NSArray *)interstitialAdUnitIds;
+ (NSArray *)interstitialInfosWithAdUnitId:(NSString *)adUnitId;


//Banner
+ (NSArray *)bannerAdUnitIds;
+ (NSArray *)bannerInfosWithAdUnitId:(NSString *)adUnitId;


@end

NS_ASSUME_NONNULL_END
