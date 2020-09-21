//
//  MTGBannerCustomEvent.h
//  MTGMediationSample
//
//  Created by zhangchark on 2020/9/20.
//  Copyright © 2020 CharkZhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol MTGBannerCustomEventDelegate <NSObject>

- (void)customEventDidLoadAd:(UIView *)view;
- (void)customEventDidFailToLoadAdWithError:(NSError *)error;
- (void)customEventWillPresentScreen;
- (void)customEventDidDismissScreen;
- (void)customEventClick;
- (void)customEventUserWillLeaveApplication;
- (void)customEventImpressionDidFire;
- (UIViewController *)viewControllerForPresentingModalView;

@end



@interface MTGBannerCustomEvent : NSObject

@property (nonatomic, weak) id<MTGBannerCustomEventDelegate> delegate;

- (void)requestBannerAdWithCustomEventInfo:(NSDictionary *)info;

- (void)destroy;


@end

NS_ASSUME_NONNULL_END

