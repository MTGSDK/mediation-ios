//
//  MTGMintegralRewardVideoAdapter.m
//  MTGMediationSample
//
//  Created by CharkZhang on 2019/1/21.
//  Copyright © 2019 CharkZhang. All rights reserved.
//

#import "MTGMintegralRewardVideoAdapter.h"
#import "MTGRewardVideoReward.h"
#import "MTGRewardVideoConstants.h"
#import "MintegralAdapterHelper.h"

#if __has_include(<MTGSDKReward/MTGRewardAdManager.h>)

    #import <MTGSDK/MTGSDK.h>
    #import <MTGSDKReward/MTGRewardAdManager.h>
#else
    #import "MTGSDK.h"
    #import "MTGRewardAdManager.h"
#endif

@interface MTGMintegralRewardVideoAdapter () <MTGRewardAdLoadDelegate,MTGRewardAdShowDelegate>

@property (nonatomic, copy) NSString *adUnit;
@property (nonatomic, copy) NSString *placementId;
@property (nonatomic, copy) NSString *rewardId;
@property (nonatomic, copy) NSString *userId;

@end

@implementation MTGMintegralRewardVideoAdapter

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info{
    // The default implementation of this method does nothing. Subclasses must override this method
    // and implement code to load a rewarded video here.
    
    NSString *appId = nil;
    NSString *appKey = nil;
    NSString *unitId = nil;
    NSString *placementId = nil;

    if([info objectForKey:MTG_APPID]){
        appId = [NSString stringWithFormat:@"%@",[info objectForKey:MTG_APPID]];
    }
    if([info objectForKey:MTG_APIKEY]){
        appKey = [NSString stringWithFormat:@"%@",[info objectForKey:MTG_APIKEY]];
    }
    if([info objectForKey:MTG_REWARDVIDEO_UNITID]){
        unitId = [NSString stringWithFormat:@"%@",[info objectForKey:MTG_REWARDVIDEO_UNITID]];
    }
    if ([info objectForKey:MTG_REWARDVIDEO_PLACEMENTID]) {
        placementId = [NSString stringWithFormat:@"%@",[info objectForKey:MTG_REWARDVIDEO_PLACEMENTID]];
    }

    NSString *errorMsg = nil;
    if (!appId) errorMsg = @"Invalid MTG appId";
    if (!appKey) errorMsg = @"Invalid MTG appKey";
    if (!unitId) errorMsg = @"Invalid MTG unitId";
    if (!placementId) errorMsg = @"Invalid MTG placementId";

    if (errorMsg) {
        NSError *error = [NSError errorWithDomain:@"com.mintegral" code:-1 userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(rewardedVideoDidFailToLoadAdForCustomEvent: error:)]) {
            [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
        }
        
        return;
    }
    
    self.adUnit = unitId;
    self.placementId = placementId;

    if([info objectForKey:MTG_REWARDVIDEO_REWARDID]){
        self.rewardId = [NSString stringWithFormat:@"%@",[info objectForKey:MTG_REWARDVIDEO_REWARDID]];
    }
    if([info objectForKey:MTG_REWARDVIDEO_USER]){
        self.userId = [NSString stringWithFormat:@"%@",[info objectForKey:MTG_REWARDVIDEO_USER]];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{

        if (![MintegralAdapterHelper isSDKInitialized]) {
            
            [[MTGSDK sharedInstance] setAppID:appId ApiKey:appKey];
            [MintegralAdapterHelper sdkInitialized];
        }

        [[MTGRewardAdManager sharedInstance] loadVideoWithPlacementId:placementId unitId:self.adUnit delegate:self];
    });
}

- (BOOL)hasAdAvailable{
    // Subclasses must override this method and implement coheck whether or not a rewarded vidoe ad
    // is available for presentation.
    
    return [[MTGRewardAdManager sharedInstance] isVideoReadyToPlayWithPlacementId:self.placementId unitId:self.adUnit];
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController{
    // The default implementation of this method does nothing. Subclasses must override this method
    // and implement code to display a rewarded video here.
    
    if ([self hasAdAvailable]) {
        
        if ([[MTGRewardAdManager sharedInstance] respondsToSelector:@selector(showVideoWithPlacementId:unitId:withRewardId:userId:delegate:viewController:)]) {
            [[MTGRewardAdManager sharedInstance] showVideoWithPlacementId:self.placementId unitId:self.adUnit withRewardId:self.rewardId userId:self.userId delegate:self viewController:viewController];
        }
        
    } else {
        NSError *error = [NSError errorWithDomain:@"com.mintegral" code:-1 userInfo:@{NSLocalizedDescriptionKey : @"current rewardVideo showFail，video not ready"}];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(rewardVideoAdDidFailToPlayForCustomEvent: error:)]) {
            [self.delegate rewardVideoAdDidFailToPlayForCustomEvent:self error:error];
            
        }
    }
}


#pragma mark RewardVideoAdDelegate

/**
 *  Called when the ad is successfully load , and is ready to be displayed
 *
 *  @param unitId - the unitId string of the Ad that was loaded.
 */
- (void)onVideoAdLoadSuccess:(nullable NSString *)placementId unitId:(nullable NSString *)unitId{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardedVideoDidLoadAdForCustomEvent:)]) {
        [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
    }
}




- (void)onVideoAdLoadFailed:(nullable NSString *)placementId unitId:(nullable NSString *)unitId error:(nonnull NSError *)error{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardedVideoDidFailToLoadAdForCustomEvent: error:)]) {
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
    }
}

/**
 *  Called when the ad display success
 *
 *  @param unitId - the unitId string of the Ad that display success.
 */
- (void)onVideoAdShowSuccess:(nullable NSString *)placementId unitId:(nullable NSString *)unitId{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardVideoAdDidShowForCustomEvent:)]) {
        [self.delegate rewardVideoAdDidShowForCustomEvent:self];
    }
}

/**
 *  Called when the ad failed to display for some reason
 *
 *  @param unitId      - the unitId string of the Ad that failed to be displayed.
 *  @param error       - error object that describes the exact error encountered when showing the ad.
 */
- (void)onVideoAdShowFailed:(nullable NSString *)placementId unitId:(nullable NSString *)unitId withError:(nonnull NSError *)error{

    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardVideoAdDidFailToPlayForCustomEvent: error:)]) {
        [self.delegate rewardVideoAdDidFailToPlayForCustomEvent:self error:error];
    }
}

/**
 *  Called when the ad is clicked
 *
 *  @param unitId - the unitId string of the Ad clicked.
 */
- (void)onVideoAdClicked:(nullable NSString *)placementId unitId:(nullable NSString *)unitId{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardVideoAdDidReceiveTapEventForCustomEvent: )]) {
        [self.delegate rewardVideoAdDidReceiveTapEventForCustomEvent:self];
    }
}

/**
 *  Called when the ad has been dismissed from being displayed, and control will return to your app
 *
 *  @param unitId      - the unitId string of the Ad that has been dismissed
 *  @param converted   - BOOL describing whether the ad has converted
 *  @param rewardInfo  - the rewardInfo object containing an array of reward objects that should be given to your user.
 */
- (void)onVideoAdDismissed:(nullable NSString *)placementId unitId:(nullable NSString *)unitId withConverted:(BOOL)converted withRewardInfo:(nullable MTGRewardAdInfo *)rewardInfo{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardVideoAdWillDisappearForCustomEvent: )]) {
            [self.delegate rewardVideoAdWillDisappearForCustomEvent:self];
    }
    
    if (!converted || !rewardInfo) {
        return;
    }
    
    MTGRewardVideoReward *reward = [[MTGRewardVideoReward alloc] initWithCurrencyType:rewardInfo.rewardName amount:[NSNumber numberWithInteger:rewardInfo.rewardAmount]];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardVideoAdShouldRewardForCustomEvent: reward:)]) {
        [self.delegate rewardVideoAdShouldRewardForCustomEvent:self reward:reward];
    }
}

@end
