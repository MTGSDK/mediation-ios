//
//  MTGAdServerCommunicator.m
//  MTGMediationSample
//
//  Created by CharkZhang on 2019/1/18.
//  Copyright © 2019 CharkZhang. All rights reserved.
//

#import "MTGAdServerCommunicator.h"
#import "MTGAdInfo.h"
#import "MTGRewardVideoError.h"

@interface MTGAdServerCommunicator()


@end

@implementation MTGAdServerCommunicator

- (id)initWithDelegate:(id<MTGAdServerCommunicatorDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)requestAdUnitInfosWithAdUnit:(NSString *)adUnitId adType:(MTGMediationAdType)adType{
    
    // request local configuration for ad infos
    NSArray *adUnitInfos = nil;
    switch (adType) {
        case MTGMediationAdTypeRewardVideoAd:
            adUnitInfos = [MTGAdInfo rewardVideoInfosWithAdUnitId:adUnitId];
            break;
        case MTGMediationAdTypeInteristialAd:
            adUnitInfos = [MTGAdInfo interstitialInfosWithAdUnitId:adUnitId];
            break;
        case MTGMediationAdTypeBannerAd:
            adUnitInfos = [MTGAdInfo bannerInfosWithAdUnitId:adUnitId];
            break;
        default:
            break;
    }

    if (adUnitInfos.count) {

        if (_delegate && [_delegate respondsToSelector:@selector(communicatorDidReceiveAdUnitInfos:)]) {
            [_delegate communicatorDidReceiveAdUnitInfos:adUnitInfos];
        }
        return;
    }
    // we will support send request for remote ad infos later
    if (_delegate && [_delegate respondsToSelector:@selector(communicatorDidFailWithError:)]) {
        NSError *error = [NSError errorWithDomain:MTGRewardVideoAdsSDKDomain code:MTGRewardVideoAdErrorAdDataInValid userInfo:nil];
        [_delegate communicatorDidFailWithError:error];
    }
}

- (void)cancel{
    
    //cancel request remote infos
}

#pragma mark -
/*
- (void)communicatorDidReceiveAdUnitInfos:(NSArray *)infos{
    
}
- (void)communicatorDidFailWithError:(NSError *)error{
    
}
*/

@end
