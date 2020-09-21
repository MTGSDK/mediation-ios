//
//  MTGBannerAdapter.h
//  MTGMediationSample
//
//  Created by zhangchark on 2020/9/20.
//  Copyright © 2020 CharkZhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MTGBannerAdapterDelegate <NSObject>

- (UIViewController *)viewControllerForPresentingModalView;
- (void)adapterUserActionWillBegin:(NSString *)adUnitId;
- (void)adapterUserActionDidFinish:(NSString *)adUnitId;
- (void)adapterUserWillLeaveApplication:(NSString *)adUnitId;
- (void)adapterImpressionDidFire:(NSString *)adUnitId;
- (void)adapterAdClick:(NSString *)adUnitId;

@end



@interface MTGBannerAdapter : NSObject


- (id)initWithDelegate:(id<MTGBannerAdapterDelegate>)delegate mediationSettings:(NSDictionary *)mediationSettings;

- (void)getAdWithInfo:(NSDictionary *)adInfo completionHandler:(void (^ __nullable)(BOOL success,NSError *error,UIView *view))completion;

- (void)unregisterDelegate;



@end

NS_ASSUME_NONNULL_END
