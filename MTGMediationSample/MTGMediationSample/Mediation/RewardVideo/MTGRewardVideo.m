//
//  MTGRewardVideo.m
//  MTGMediationSample
//
//  Created by CharkZhang on 2019/1/17.
//  Copyright © 2019 CharkZhang. All rights reserved.
//

#import "MTGRewardVideo.h"
#import "MTGMediationRewardVideoAdManager.h"
#import "MTGRewardVideoReward.h"
#import "MTGRewardVideoError.h"

#define INVOKE_IN_MAINTHREAD(code) \
if ([NSThread isMainThread]) {  \
    code    \
}else{  \
    dispatch_async(dispatch_get_main_queue(), ^{    \
        code    \
    }); \
}

static MTGRewardVideo *gSharedInstance = nil;

@interface MTGRewardVideo()<MTGMediationRewardVideoAdManagerDelegate>

@property (nonatomic, strong) NSMutableDictionary *rewardedVideoAdManagers;
@property (nonatomic, strong) NSLock *lock;

+ (MTGRewardVideo *)sharedInstance;

@end

@implementation MTGRewardVideo

+ (void)registerRewardVideoDelegate:(id<MTGRewardVideoDelegate>)delegate{

    MTGRewardVideo *sharedInstance = [[self class] sharedInstance];
    sharedInstance.delegate = delegate;
}

+ (void)loadRewardVideoAdWithAdUnitID:(NSString *)adUnitID mediationSettings:(NSDictionary *)mediationSettings{
    INVOKE_IN_MAINTHREAD(
         [MTGRewardVideo _loadRewardVideoAdWithAdUnitID:adUnitID mediationSettings:mediationSettings];
     );
}

+ (void)_loadRewardVideoAdWithAdUnitID:(NSString *)adUnitID mediationSettings:(NSDictionary *)mediationSettings{

    MTGRewardVideo *sharedInstance = [[self class] sharedInstance];
    
    if (![adUnitID length]) {
        NSError *error = [NSError errorWithDomain:MTGRewardVideoAdsSDKDomain code:MTGRewardVideoAdErrorInvalidAdUnitID userInfo:nil];
        [sharedInstance rewardVideoAdDidFailToLoadForAdUnitID:adUnitID error:error];
        return;
    }

    MTGMediationRewardVideoAdManager *adManager = sharedInstance.rewardedVideoAdManagers[adUnitID];
    
    if (!adManager) {
        adManager = [[MTGMediationRewardVideoAdManager alloc] initWithAdUnitID:adUnitID delegate:sharedInstance];
        sharedInstance.rewardedVideoAdManagers[adUnitID] = adManager;
    }
    adManager.mediationSettings = mediationSettings;
    [adManager loadRewardedVideoAd];
}


+ (BOOL)hasAdAvailableForAdUnitID:(NSString *)adUnitID{

    return [MTGRewardVideo _hasAdAvailableForAdUnitID:adUnitID];
}

+ (BOOL)_hasAdAvailableForAdUnitID:(NSString *)adUnitID{
    
    if (![adUnitID length]) {
        return NO;
    }
    MTGRewardVideo *sharedInstance = [[self class] sharedInstance];
    [sharedInstance.lock lock];
    MTGMediationRewardVideoAdManager *adManager = sharedInstance.rewardedVideoAdManagers[adUnitID];
    [sharedInstance.lock unlock];
    
    return [adManager hasAdAvailable];
}

+ (void)presentRewardVideoAdForAdUnitID:(NSString *)adUnitID fromViewController:(UIViewController *)viewController{
    
    INVOKE_IN_MAINTHREAD(
         [MTGRewardVideo _presentRewardVideoAdForAdUnitID:adUnitID fromViewController:viewController];
    );

}
+ (void)_presentRewardVideoAdForAdUnitID:(NSString *)adUnitID fromViewController:(UIViewController *)viewController{

    if (![adUnitID length]) {
        NSError *error = [NSError errorWithDomain:MTGRewardVideoAdsSDKDomain code:MTGRewardVideoAdErrorInvalidAdUnitID userInfo:nil];
        [[[self class] sharedInstance] rewardVideoAdDidFailToLoadForAdUnitID:adUnitID error:error];
        return;
    }

    MTGRewardVideo *sharedInstance = [[self class] sharedInstance];
    
    MTGMediationRewardVideoAdManager *adManager = sharedInstance.rewardedVideoAdManagers[adUnitID];
    
    if (!adManager) {
        NSLog(@"The reward video could not be shown: "
              @"no ads have been loaded for adUnitID: %@", adUnitID);
        NSError *error = [NSError errorWithDomain:MTGRewardVideoAdsSDKDomain code:MTGRewardVideoAdUnLoaded userInfo:nil];
        [sharedInstance rewardVideoAdDidFailToPlayForAdUnitID:adUnitID error:error];
        return;
    }
    
    if (!viewController) {
        NSLog(@"The reward video could not be shown: "
                          @"a nil view controller was passed to -presentRewardedVideoAdForAdUnitID:fromViewController:.");
        NSError *error = [NSError errorWithDomain:MTGRewardVideoAdsSDKDomain code:MTGRewardVideoAdViewControllerInvalid userInfo:nil];
        [sharedInstance rewardVideoAdDidFailToPlayForAdUnitID:adUnitID error:error];
        return;
    }
    
    if (![viewController.view.window isKeyWindow]) {
        NSLog(@"Attempting to present a rewarded video ad in non-key window. The ad may not render properly.");
        NSError *error = [NSError errorWithDomain:MTGRewardVideoAdsSDKDomain code:MTGRewardVideoAdViewControllerInvalid userInfo:nil];
        [sharedInstance rewardVideoAdDidFailToPlayForAdUnitID:adUnitID error:error];
        return;
    }
    
    [adManager presentRewardedVideoFromViewController:viewController];
}

#pragma mark - Private

+ (MTGRewardVideo *)sharedInstance
{
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        gSharedInstance = [[self alloc] init];
    });
    
    return gSharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _rewardedVideoAdManagers = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

-(NSLock *)lock{
    if (_lock) {
        return _lock;
    }
    _lock = [[NSLock alloc] init];
    return _lock;
}

#pragma mark -


- (void)rewardVideoAdDidLoadForAdUnitID:(nonnull NSString *)adUnitID {
    
    INVOKE_IN_MAINTHREAD(
         MTGRewardVideo *sharedInstance = [[self class] sharedInstance];

         if (sharedInstance.delegate && [sharedInstance.delegate respondsToSelector:@selector(rewardVideoAdDidLoadForAdUnitID:)]) {
             [sharedInstance.delegate rewardVideoAdDidLoadForAdUnitID:adUnitID];
         }
    );
}

- (void)rewardVideoAdDidFailToLoadForAdUnitID:(nonnull NSString *)adUnitID error:(nonnull NSError *)error {

    INVOKE_IN_MAINTHREAD(
         MTGRewardVideo *sharedInstance = [[self class] sharedInstance];
         
         if (sharedInstance.delegate && [sharedInstance.delegate respondsToSelector:@selector(rewardVideoAdDidFailToLoadForAdUnitID:error:)]) {
             [sharedInstance.delegate rewardVideoAdDidFailToLoadForAdUnitID:adUnitID error:error];
         }
    );
}

- (void)rewardVideoAdDidShowForAdUnitID:(nonnull NSString *)adUnitID {
    
    INVOKE_IN_MAINTHREAD(
         MTGRewardVideo *sharedInstance = [[self class] sharedInstance];
         
         if (sharedInstance.delegate && [sharedInstance.delegate respondsToSelector:@selector(rewardVideoAdDidPlayForAdUnitID:)]) {
             [sharedInstance.delegate rewardVideoAdDidPlayForAdUnitID:adUnitID];
         }
    );
}

- (void)rewardVideoAdDidFailToPlayForAdUnitID:(nonnull NSString *)adUnitID error:(nonnull NSError *)error {

    INVOKE_IN_MAINTHREAD(
         MTGRewardVideo *sharedInstance = [[self class] sharedInstance];
         
         if (sharedInstance.delegate && [sharedInstance.delegate respondsToSelector:@selector(rewardVideoAdDidFailToPlayForAdUnitID:error:)]) {
             [sharedInstance.delegate rewardVideoAdDidFailToPlayForAdUnitID:adUnitID error:error];
         }
    );
}


- (void)rewardVideoAdDidReceiveTapEventForAdUnitID:(nonnull NSString *)adUnitID {
    
    INVOKE_IN_MAINTHREAD(
         MTGRewardVideo *sharedInstance = [[self class] sharedInstance];
         
         if (sharedInstance.delegate && [sharedInstance.delegate respondsToSelector:@selector(rewardVideoAdDidReceiveTapEventForAdUnitID:)]) {
             [sharedInstance.delegate rewardVideoAdDidReceiveTapEventForAdUnitID:adUnitID];
         }
    );
}


- (void)rewardVideoAdShouldRewardForAdUnitID:(nonnull NSString *)adUnitID reward:(nonnull MTGRewardVideoReward *)reward {

    INVOKE_IN_MAINTHREAD(
         MTGRewardVideo *sharedInstance = [[self class] sharedInstance];
         
         if (sharedInstance.delegate && [sharedInstance.delegate respondsToSelector:@selector(rewardVideoAdShouldRewardForAdUnitID:reward:)]) {
             [sharedInstance.delegate rewardVideoAdShouldRewardForAdUnitID:adUnitID reward:reward];
         }
    );
}

- (void)rewardVideoAdWillDisappearForAdUnitID:(nonnull NSString *)adUnitID {

    INVOKE_IN_MAINTHREAD(
         MTGRewardVideo *sharedInstance = [[self class] sharedInstance];
         
         if (sharedInstance.delegate && [sharedInstance.delegate respondsToSelector:@selector(rewardVideoAdWillDisappearForAdUnitID:)]) {
             [sharedInstance.delegate rewardVideoAdWillDisappearForAdUnitID:adUnitID];
         }
    );
}

@end
