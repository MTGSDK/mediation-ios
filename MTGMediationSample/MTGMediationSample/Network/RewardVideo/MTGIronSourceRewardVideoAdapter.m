//
//  MTGIronSourceRewardVideoAdapter.m
//  MTGMediationSample
//
//  Created by CharkZhang on 2019/1/21.
//  Copyright © 2019 CharkZhang. All rights reserved.
//

#import "MTGIronSourceRewardVideoAdapter.h"
#import "MTGRewardVideoReward.h"

#import <IronSource/IronSource.h>

#define USERID @"demoapp"

@interface MTGIronSourceRewardVideoAdapter () <ISRewardedVideoDelegate>
@property (nonatomic, strong) ISPlacementInfo   *rvPlacementInfo;
@property (nonatomic, copy) NSString *placementName;
@property (nonatomic, assign) BOOL isLoadSuccess;
@end

@implementation MTGIronSourceRewardVideoAdapter

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info{
    self.isLoadSuccess = NO;
    
    NSString *appKey = [info objectForKey:@"appkey"];
    
    NSString *errorMsg = nil;
    if (!appKey) errorMsg = @"Invalid IRON appKey";
    
    if (errorMsg) {
        NSError *error = [NSError errorWithDomain:@"com.ironsource" code:-1 userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
        if (self.delegate && [self.delegate respondsToSelector:@selector(rewardedVideoDidFailToLoadAdForCustomEvent: error:)]) {
            [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
        }
        return;
    }
    

    NSString *unitId = [info objectForKey:@"unitid"];
    self.placementName = [info objectForKey:@"placementname"];
 
    
    [IronSource setRewardedVideoDelegate:self];
    
    
    NSString *userId = [IronSource advertiserId];
    if([userId length] == 0){
        //If we couldn't get the advertiser id, we will use a default one.
        userId = USERID;
    }
    
    // After setting the delegates you can go ahead and initialize the SDK.
    [IronSource setUserId:userId];
    
    if([unitId length] == 0){
        [IronSource initWithAppKey:appKey];
    }else{
        [IronSource initWithAppKey:appKey adUnits:@[unitId]];
    }
}

- (BOOL)hasAdAvailable{
    
    //return [IronSource hasISDemandOnlyRewardedVideo:self.instanceId];
     return [IronSource hasRewardedVideo];
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController{
    
    if ([self.placementName length] == 0) {
        [IronSource showRewardedVideoWithViewController:viewController];
    } else {
        [IronSource showRewardedVideoWithViewController:viewController placement:self.placementName];
    }
}

#pragma mark - Rewarded Video Delegate Functions

// This method lets you know whether or not there is a video
// ready to be presented. It is only after this method is invoked
// with 'hasAvailableAds' set to 'YES' that you can should 'showRV'.
- (void)rewardedVideoHasChangedAvailability:(BOOL)available {
    if(self.isLoadSuccess)
        return;

    if(available){
        if (self.delegate && [self.delegate respondsToSelector:@selector(rewardedVideoDidLoadAdForCustomEvent:)]) {
                    [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
        }
        self.isLoadSuccess = YES;
    }else{
        NSError *error = [NSError errorWithDomain:@"com.ironsource" code:-1 userInfo:@{NSLocalizedDescriptionKey : @"rewardvideo load fail"}];
        if (self.delegate && [self.delegate respondsToSelector:@selector(rewardedVideoDidFailToLoadAdForCustomEvent: error:)]) {
            [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
        }
    }
}

// This method gets invoked after the user has been rewarded.
- (void)didReceiveRewardForPlacement:(ISPlacementInfo *)placementInfo {
    
    self.rvPlacementInfo = placementInfo;
}

// This method gets invoked when there is a problem playing the video.
// If it does happen, check out 'error' for more information and consult
// our knowledge center for help.
- (void)rewardedVideoDidFailToShowWithError:(NSError *)error {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardVideoAdDidFailToPlayForCustomEvent: error:)]) {
        [self.delegate rewardVideoAdDidFailToPlayForCustomEvent:self error:error];
    }
}


// This method gets invoked when we take control, but before
// the video has started playing.
- (void)rewardedVideoDidOpen{
}

// This method gets invoked when we return controlback to your hands.
// We chose to notify you about rewards here and not in 'didReceiveRewardForPlacement'.
// This is because reward can occur in the middle of the video.
- (void)rewardedVideoDidClose{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardVideoAdWillDisappearForCustomEvent:)]) {
        [self.delegate rewardVideoAdWillDisappearForCustomEvent:self];
    }
    
    if (self.rvPlacementInfo) {
     
        MTGRewardVideoReward *reward = [[MTGRewardVideoReward alloc] initWithCurrencyType:self.rvPlacementInfo.rewardName amount:self.rvPlacementInfo.rewardAmount];
    
        if (self.delegate && [self.delegate respondsToSelector:@selector(rewardVideoAdShouldRewardForCustomEvent: reward:)]) {
            [self.delegate rewardVideoAdShouldRewardForCustomEvent:self reward:reward];
        }
        
        self.rvPlacementInfo = nil;
    }
}

// This method gets invoked when the video has started playing.
- (void)rewardedVideoDidStart {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardVideoAdDidShowForCustomEvent:)]) {
        [self.delegate rewardVideoAdDidShowForCustomEvent:self];
    }
}

// This method gets invoked when the video has stopped playing.
- (void)rewardedVideoDidEnd {
}

- (void)didClickRewardedVideo:(ISPlacementInfo *)placementInfo{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardVideoAdDidReceiveTapEventForCustomEvent:)]) {
        [self.delegate rewardVideoAdDidReceiveTapEventForCustomEvent:self];
    }
}


@end
