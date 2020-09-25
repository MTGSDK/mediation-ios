//
//  MTGBannerManagerDelegate.h
//  MTGMediationSample
//
//  Created by zhangchark on 2020/9/20.
//  Copyright © 2020 CharkZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MTGBannerAd;
@protocol MTGBannerAdDelegate;


NS_ASSUME_NONNULL_BEGIN

@protocol MTGBannerManagerDelegate <NSObject>


- (UIViewController *)viewControllerForPresentingModalView;
- (void)managerDidLoadAd:(UIView *)ad;
- (void)managerDidFailToLoadAdWithError:(NSError *)error;
- (void)userActionWillBegin;
- (void)userActionDidFinish;
- (void)adViewClick;
- (void)userWillLeaveApplication;



@end

NS_ASSUME_NONNULL_END
