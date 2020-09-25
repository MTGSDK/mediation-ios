//
//  MTGMediationRewardVideoAdManager.h
//  MTGMediationSample
//
//  Created by CharkZhang on 2019/1/17.
//  Copyright © 2019 CharkZhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MTGRewardVideoReward;
@protocol MTGMediationRewardVideoAdManagerDelegate <NSObject>


- (void)rewardVideoAdDidLoadForAdUnitID:(NSString *)adUnitID;

- (void)rewardVideoAdDidFailToLoadForAdUnitID:(NSString *)adUnitID error:(NSError *)error;

- (void)rewardVideoAdDidShowForAdUnitID:(NSString *)adUnitID;

- (void)rewardVideoAdDidFailToPlayForAdUnitID:(NSString *)adUnitID error:(NSError *)error;

- (void)rewardVideoAdWillDisappearForAdUnitID:(NSString *)adUnitID;

- (void)rewardVideoAdShouldRewardForAdUnitID:(NSString *)adUnitID reward:(MTGRewardVideoReward *)reward;

- (void)rewardVideoAdDidReceiveTapEventForAdUnitID:(NSString *)adUnitID;

@end

@interface MTGMediationRewardVideoAdManager : NSObject

@property (nonatomic, weak) id<MTGMediationRewardVideoAdManagerDelegate> delegate;
@property (nonatomic, readonly) NSString *adUnitID;
@property (nonatomic, strong) NSDictionary *mediationSettings;


- (instancetype)initWithAdUnitID:(NSString *)adUnitID delegate:(id<MTGMediationRewardVideoAdManagerDelegate>)delegate;


- (void)loadRewardedVideoAd;
- (BOOL)hasAdAvailable;
- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController;


@end

NS_ASSUME_NONNULL_END
