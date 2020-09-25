//
//  MTGBannerAdDelegate.h
//  MTGMediationSample
//
//  Created by zhangchark on 2020/9/20.
//  Copyright © 2020 CharkZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@class MTGBannerAd;


@protocol MTGBannerAdDelegate <NSObject>

@required
- (UIViewController *)viewControllerForPresentingModalView;


@optional

- (void)adViewDidLoadAd:(UIView *)view;

- (void)adView:(MTGBannerAd *)ad didFailToLoadAdWithError:(NSError *)error;

- (void)adViewClick:(MTGBannerAd *)ad;

- (void)willPresentModalViewForAd:(MTGBannerAd *)ad;

- (void)didDismissModalViewForAd:(MTGBannerAd *)ad;

- (void)willLeaveApplicationFromAd:(MTGBannerAd *)ad;

- (void)viewImpressionFromAd:(MTGBannerAd *)ad;

@end

NS_ASSUME_NONNULL_END
