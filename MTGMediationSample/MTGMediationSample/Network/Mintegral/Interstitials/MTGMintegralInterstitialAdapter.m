//
//  MTGMintegralInterstitialAdapter.m
//  MTGMediationSample
//
//  Created by ym on 2019/2/12.
//  Copyright © 2019 CharkZhang. All rights reserved.
//

#import "MTGMintegralInterstitialAdapter.h"
#import "MTGInterstitialConstants.h"
#import "MintegralAdapterHelper.h"

#if __has_include(<MTGSDKInterstitialVideo/MTGInterstitialVideoAdManager.h>)

    #import <MTGSDK/MTGSDK.h>
    #import <MTGSDKInterstitialVideo/MTGInterstitialVideoAdManager.h>
#else
    #import "MTGInterstitialVideoAdManager.h"
#endif

@interface MTGMintegralInterstitialAdapter () <MTGInterstitialVideoDelegate>

@property (nonatomic, copy) NSString *adUnit;
@property (nonatomic, copy) NSString *placementId;

@property (nonatomic, readwrite, strong) MTGInterstitialVideoAdManager *mtgInterstitialVideoAdManager;

@end

@implementation MTGMintegralInterstitialAdapter


- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info{
    
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
    if([info objectForKey:MTG_INTERSTITIAL_UNITID]){
        unitId = [NSString stringWithFormat:@"%@",[info objectForKey:MTG_INTERSTITIAL_UNITID]];
    }
    if ([info objectForKey:MTG_INTERSTITIAL_PLACEMENTID]) {
        placementId = [NSString stringWithFormat:@"%@",[info objectForKey:MTG_INTERSTITIAL_PLACEMENTID]];
    }

    NSString *errorMsg = nil;
    if (!appId) errorMsg = @"Invalid MTG appId";
    if (!appKey) errorMsg = @"Invalid MTG appKey";
    if (!unitId) errorMsg = @"Invalid MTG unitId";
    if (!placementId) errorMsg = @"Invalid MTG placementId";

    if (errorMsg) {
        NSError *error = [NSError errorWithDomain:@"com.mintegral" code:-1 userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didFailToLoadInterstitialWithError:)]) {
            [self.delegate didFailToLoadInterstitialWithError:error];
        }

        return;
    }
    
    self.placementId = placementId;
    self.adUnit = unitId;
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        if (![MintegralAdapterHelper isSDKInitialized]) {
            
            [[MTGSDK sharedInstance] setAppID:appId ApiKey:appKey];
            [MintegralAdapterHelper sdkInitialized];
        }
        
        if (!self.mtgInterstitialVideoAdManager) {
            self.mtgInterstitialVideoAdManager = [[MTGInterstitialVideoAdManager alloc] initWithPlacementId:placementId unitId:self.adUnit delegate:self];
        }

        [self.mtgInterstitialVideoAdManager loadAd];
        
    });
}

- (BOOL)hasAdAvailable{

    BOOL availableAd = [self.mtgInterstitialVideoAdManager isVideoReadyToPlayWithPlacementId:self.placementId unitId:self.adUnit];
    return availableAd;
}

- (void)presentInterstitialFromViewController:(UIViewController *)viewController{
    
    if([self hasAdAvailable]){
        [self.mtgInterstitialVideoAdManager showFromViewController:viewController];
    }else{
        NSString *errorMsg = @"current interstitialVideo showFail，video not ready";
        NSError *error = [NSError errorWithDomain:@"com.mintegral"  code:-2 userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didFailToPresentInterstitialWithError:)]) {
            [self.delegate didFailToPresentInterstitialWithError:error];
        }
    }
}

#pragma mark InterstitialAdDelegate

/**
 *  Called when the ad is successfully load , and is ready to be displayed
 */
- (void)onInterstitialVideoLoadSuccess:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didLoadInterstitial)]) {
        [self.delegate didLoadInterstitial];
    }
}

/**
 *  Called when there was an error loading the ad.
 *
 *  @param error       - error object that describes the exact error encountered when loading the ad.
 */
- (void)onInterstitialVideoLoadFail:(nonnull NSError *)error adManager:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFailToLoadInterstitialWithError:)]) {
        [self.delegate didFailToLoadInterstitialWithError:error];
    }
}
/**
 *  Called when the ad display success
 *
 */
- (void)onInterstitialVideoShowSuccess:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPresentInterstitial)]) {
        [self.delegate didPresentInterstitial];
    }
}

/**
 *  Called when the ad failed to display for some reason
 *
 *  @param error       - error object that describes the exact error encountered when showing the ad.
 */
- (void)onInterstitialVideoShowFail:(nonnull NSError *)error adManager:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFailToPresentInterstitialWithError:)]) {
        [self.delegate didFailToPresentInterstitialWithError:error];
    }
}

/**
 *  Called when the ad is clicked
 *
 */
- (void)onInterstitialVideoAdClick:(MTGInterstitialVideoAdManager *_Nonnull)adManager{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveTapEventFromInterstitial)]) {
        [self.delegate didReceiveTapEventFromInterstitial];
    }
}

/**
 *  Called when the ad is closed
 *
 */
- (void)onInterstitialVideoAdDismissedWithConverted:(BOOL)converted adManager:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(willDismissInterstitial)]) {
        [self.delegate willDismissInterstitial];
    }
}

@end
