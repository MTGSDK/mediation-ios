//
//  MTGMediationRewardVideoAdManager.m
//  MTGMediationSample
//
//  Created by CharkZhang on 2019/1/17.
//  Copyright © 2019 CharkZhang. All rights reserved.
//

#import "MTGMediationRewardVideoAdManager.h"
#import "MTGAdServerCommunicator.h"
#import "MTGRewardVideoAdapter.h"
#import "MTGRewardVideoReward.h"
#import "MTGRewardVideoError.h"

@interface MTGMediationRewardVideoAdManager ()<MTGAdServerCommunicatorDelegate,MTGRewardVideoAdapterDelegate>

@property (nonatomic, strong) MTGRewardVideoAdapter *adapter;
@property (nonatomic, strong) MTGAdServerCommunicator *communicator;

@property (nonatomic, assign) BOOL loading;

@end

@implementation MTGMediationRewardVideoAdManager

- (void)dealloc{
    [_communicator cancel];
}

- (instancetype)initWithAdUnitID:(NSString *)adUnitID delegate:(id<MTGMediationRewardVideoAdManagerDelegate>)delegate{
    if (self = [super init]) {
        _adUnitID = [adUnitID copy];
        _communicator = [[MTGAdServerCommunicator alloc] initWithDelegate:self];
        _delegate = delegate;
    }
    
    return self;
}

- (void)loadRewardedVideoAd{
    
    if (self.loading) {
        NSError *error = [NSError errorWithDomain:MTGRewardVideoAdsSDKDomain code:MTGRewardVideoAdErrorCurrentUnitIsLoading userInfo:nil];
        [self sendLoadFailedWithError:error];
        return;
    }
    
    self.loading = YES;

    MTGMediationAdType adType = MTGMediationAdTypeRewardVideoAd;
    [self.communicator requestAdUnitInfosWithAdUnit:_adUnitID adType:(adType)];
}

- (BOOL)hasAdAvailable{

    if (!self.adapter) {
        return NO;
    }
    return [self.adapter hasAdAvailable];
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController{

    [self.adapter presentRewardedVideoFromViewController:viewController];
}

#pragma Private Methods -

- (void)sendLoadFailedWithError:(NSError *)error{
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        if (self.delegate && [self.delegate respondsToSelector:@selector(rewardVideoAdDidFailToLoadForAdUnitID:error:)]) {
            [self.delegate rewardVideoAdDidFailToLoadForAdUnitID:self.adUnitID error:error];
        }
    });
}

- (void)sendLoadSuccess{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(rewardVideoAdDidLoadForAdUnitID:)]) {
            [self.delegate rewardVideoAdDidLoadForAdUnitID:self.adUnitID];
        }
    });
}

- (void)sendShowFailedWithError:(NSError *)error{
    
    if (_delegate && [_delegate respondsToSelector:@selector(rewardVideoAdDidFailToLoadForAdUnitID:error:)]) {
        [_delegate rewardVideoAdDidFailToLoadForAdUnitID:self.adUnitID error:error];
    }
    
}
/*
// for remote request
- (void)startTimeoutTimer:(NSTimeInterval)duration
{

}

- (void)timeout
{

}
 */

#pragma mark MTGAdServerCommunicatorDelegate -
- (void)communicatorDidReceiveAdUnitInfos:(NSArray *)infos{

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self createThreadhandleInfos:infos];
    });
}

- (void)createThreadhandleInfos:(NSArray *)infos{

    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    [infos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSDictionary *adInfo = (NSDictionary *)obj;

        self.adapter = nil;

        MTGRewardVideoAdapter *adapter = [[MTGRewardVideoAdapter alloc] initWithDelegate:self mediationSettings:self.mediationSettings];
        
        self.adapter = adapter;
        
        [self.adapter getAdWithInfo:adInfo completionHandler:^(BOOL success, NSError * _Nonnull error) {
            if (success) {
                *stop = YES;
                dispatch_semaphore_signal(sem);
                [self sendLoadSuccess];

            }else{
                
                self.adapter = nil;
                dispatch_semaphore_signal(sem);

                //if the last loop failed
                if (idx == (infos.count - 1)) {
                    [self sendLoadFailedWithError:error];
                }
                //else: continue next request loop
            }
        }];
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }];
    
    self.loading = NO;
}


- (void)communicatorDidFailWithError:(NSError *)error{

    [self sendLoadFailedWithError:error];

    self.loading = NO;
}


#pragma mark MTGRewardVideoAdapterDelegate -

- (void)rewardVideoAdDidLoadForAdUnitID:(NSString *)adUnitID{
    
    if (_delegate && [_delegate respondsToSelector:@selector(rewardVideoAdDidLoadForAdUnitID:)]) {
        [_delegate rewardVideoAdDidLoadForAdUnitID:self.adUnitID];
    }
}

- (void)rewardVideoAdDidFailToLoadForAdUnitID:(NSString *)adUnitID error:(NSError *)error{
    
    if (_delegate && [_delegate respondsToSelector:@selector(rewardVideoAdDidFailToLoadForAdUnitID:error:)]) {
        [_delegate rewardVideoAdDidFailToLoadForAdUnitID:self.adUnitID error:error];
    }
}

- (void)rewardVideoAdDidShowForAdUnitID:(NSString *)adUnitID{
 
    if (_delegate && [_delegate respondsToSelector:@selector(rewardVideoAdDidShowForAdUnitID:)]) {
        [_delegate rewardVideoAdDidShowForAdUnitID:self.adUnitID];
    }
}

- (void)rewardVideoAdDidFailToPlayForAdUnitID:(NSString *)adUnitID error:(NSError *)error{
    
    if (_delegate && [_delegate respondsToSelector:@selector(rewardVideoAdDidFailToPlayForAdUnitID:error:)]) {
        [_delegate rewardVideoAdDidFailToPlayForAdUnitID:self.adUnitID error:error];
    }
}

- (void)rewardVideoAdWillDisappearForAdUnitID:(NSString *)adUnitID{
    
    if (_delegate && [_delegate respondsToSelector:@selector(rewardVideoAdWillDisappearForAdUnitID:)]) {
        [_delegate rewardVideoAdWillDisappearForAdUnitID:self.adUnitID];
    }
}

- (void)rewardVideoAdShouldRewardForAdUnitID:(NSString *)adUnitID reward:(MTGRewardVideoReward *)reward{
    
    if (_delegate && [_delegate respondsToSelector:@selector(rewardVideoAdShouldRewardForAdUnitID:reward:)]) {
        [_delegate rewardVideoAdShouldRewardForAdUnitID:self.adUnitID reward:reward];
    }
}

- (void)rewardVideoAdDidReceiveTapEventForAdUnitID:(NSString *)adUnitID{
    
    if (_delegate && [_delegate respondsToSelector:@selector(rewardVideoAdDidReceiveTapEventForAdUnitID:)]) {
        [_delegate rewardVideoAdDidReceiveTapEventForAdUnitID:self.adUnitID];
    }
}



@end
