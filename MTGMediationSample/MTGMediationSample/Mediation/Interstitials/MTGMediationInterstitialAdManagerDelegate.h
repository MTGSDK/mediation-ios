//
//  MTGMediationInterstitialAdManagerDelegate.h
//  MTGMediationSample
//
//  Created by CharkZhang on 2019/2/19.
//  Copyright © 2019 CharkZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MTGMediationInterstitialAdManager;
@protocol MTGMediationInterstitialAdManagerDelegate <NSObject>


- (void)managerDidLoadInterstitial:(MTGMediationInterstitialAdManager *)manager;
- (void)manager:(MTGMediationInterstitialAdManager *)manager didFailToLoadInterstitialWithError:(NSError *)error;
- (void)managerDidPresentInterstitial:(MTGMediationInterstitialAdManager *)manager;
- (void)manager:(MTGMediationInterstitialAdManager *)manager didFailToPresentInterstitialWithError:(NSError *)error;
- (void)managerWillDismissInterstitial:(MTGMediationInterstitialAdManager *)manager;
- (void)managerDidReceiveTapEventFromInterstitial:(MTGMediationInterstitialAdManager *)manager;
- (NSDictionary *)managerReceiveMediationSetting;

@end

