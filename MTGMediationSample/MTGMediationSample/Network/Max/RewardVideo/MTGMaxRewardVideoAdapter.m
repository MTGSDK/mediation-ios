//
//  MTGMaxRewardVideoAdapter.m
//  MTGMediationSample
//
//  Created by zhangchark on 2020/9/22.
//  Copyright © 2020 CharkZhang. All rights reserved.
//

#import "MTGMaxRewardVideoAdapter.h"
#import "MTGRewardVideoConstants.h"
#import "MTGRewardVideoReward.h"
#import "MaxAdapterHelper.h"

#import <AppLovinSDK/AppLovinSDK.h>

@interface MTGMaxRewardVideoAdapter()<MARewardedAdDelegate>
@property (nonatomic, strong) MARewardedAd *rewardedAd;

@end

@implementation MTGMaxRewardVideoAdapter



- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info{
    // The default implementation of this method does nothing. Subclasses must override this method
    // and implement code to load a rewarded video here.

    NSString *unitId = nil;
    if([info objectForKey:MTG_REWARDVIDEO_UNITID]){
        unitId = [NSString stringWithFormat:@"%@",[info objectForKey:MTG_REWARDVIDEO_UNITID]];
    }

    NSString *errorMsg = nil;
    if (!unitId) errorMsg = @"Invalid MTG unitId";

    if (errorMsg) {
        NSError *error = [NSError errorWithDomain:@"com.max" code:-1 userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(rewardedVideoDidFailToLoadAdForCustomEvent: error:)]) {
            [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
        }
        
        return;
    }

    if (![MaxAdapterHelper isSDKInitialized]) {
        
//    #warning - Make sure to add your AppLovin SDK key in the Info.plist under the "AppLovinSdkKey" key
//        Initialize the AppLovin SDK
        [ALSdk shared].mediationProvider = ALMediationProviderMAX;
//        [[ALSdk shared] initializeSdk];

//        [MaxAdapterHelper sdkInitialized];
        [[ALSdk shared] initializeSdkWithCompletionHandler:^(ALSdkConfiguration *configuration) {
            // AppLovin SDK is initialized, start loading ads now or later if ad gate is reached
            dispatch_async(dispatch_get_main_queue(), ^{
                self.rewardedAd = [MARewardedAd sharedWithAdUnitIdentifier: unitId];
                self.rewardedAd.delegate = self;
                [self.rewardedAd loadAd];
            });
        }];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.rewardedAd = [MARewardedAd sharedWithAdUnitIdentifier: unitId];
            self.rewardedAd.delegate = self;
            [self.rewardedAd loadAd];
        });
    }

//    [[ALSdk shared] showMediationDebugger];


}

- (BOOL)hasAdAvailable{
    // Subclasses must override this method and implement coheck whether or not a rewarded vidoe ad
    // is available for presentation.
    
    return [self.rewardedAd isReady];
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController{
    // The default implementation of this method does nothing. Subclasses must override this method
    // and implement code to display a rewarded video here.
    
    if ([self hasAdAvailable]) {
        
        [self.rewardedAd showAd];
    } else {
        NSError *error = [NSError errorWithDomain:@"com.max" code:-1 userInfo:@{NSLocalizedDescriptionKey : @"current rewardVideo showFail，video not ready"}];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(rewardVideoAdDidFailToPlayForCustomEvent: error:)]) {
            [self.delegate rewardVideoAdDidFailToPlayForCustomEvent:self error:error];
        }
    }
}


#pragma mark - MAAdDelegate Protocol

- (void)didLoadAd:(MAAd *)ad
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardedVideoDidLoadAdForCustomEvent:)]) {
        [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
    }
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withErrorCode:(NSInteger)errorCode
{
    NSError *error = [NSError errorWithDomain:@"com.max" code:errorCode userInfo:nil];
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardedVideoDidFailToLoadAdForCustomEvent: error:)]) {
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
    }
}

- (void)didDisplayAd:(MAAd *)ad
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardVideoAdDidShowForCustomEvent:)]) {
        [self.delegate rewardVideoAdDidShowForCustomEvent:self];
    }
}

- (void)didClickAd:(MAAd *)ad
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardVideoAdDidReceiveTapEventForCustomEvent: )]) {
        [self.delegate rewardVideoAdDidReceiveTapEventForCustomEvent:self];
    }
}

- (void)didHideAd:(MAAd *)ad
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardVideoAdWillDisappearForCustomEvent: )]) {
            [self.delegate rewardVideoAdWillDisappearForCustomEvent:self];
    }
}

- (void)didFailToDisplayAd:(MAAd *)ad withErrorCode:(NSInteger)errorCode
{
    NSError *error = [NSError errorWithDomain:@"com.max" code:errorCode userInfo:nil];
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardVideoAdDidFailToPlayForCustomEvent: error:)]) {
        [self.delegate rewardVideoAdDidFailToPlayForCustomEvent:self error:error];
    }
}

#pragma mark - MARewardedAdDelegate Protocol

- (void)didStartRewardedVideoForAd:(MAAd *)ad
{
    ;
}

- (void)didCompleteRewardedVideoForAd:(MAAd *)ad
{
    ;
}

- (void)didRewardUserForAd:(MAAd *)ad withReward:(MAReward *)reward
{
    NSString *rewardName = reward.label ? reward.label : MAReward.defaultLabel;
    NSInteger rewardAmount = reward.amount > 0 ?reward.amount : MAReward.defaultAmount;

    MTGRewardVideoReward *rewardInfo = [[MTGRewardVideoReward alloc] initWithCurrencyType:rewardName amount:[NSNumber numberWithInteger:rewardAmount]];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardVideoAdShouldRewardForCustomEvent: reward:)]) {
        [self.delegate rewardVideoAdShouldRewardForCustomEvent:self reward:rewardInfo];
    }
}

@end
