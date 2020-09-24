//
//  MTGMaxInterstitialAdapter.m
//  MTGMediationSample
//
//  Created by zhangchark on 2020/9/22.
//  Copyright © 2020 CharkZhang. All rights reserved.
//

#import "MTGMaxInterstitialAdapter.h"
#import "MTGInterstitialConstants.h"
#import "MaxAdapterHelper.h"

#import <AppLovinSDK/AppLovinSDK.h>

@interface MTGMaxInterstitialAdapter()<MAAdDelegate>
@property (nonatomic, strong) MAInterstitialAd *interstitialAd;

@end


@implementation MTGMaxInterstitialAdapter


- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info{

    NSString *unitId = nil;
    if([info objectForKey:MTG_INTERSTITIAL_UNITID]){
        unitId = [NSString stringWithFormat:@"%@",[info objectForKey:MTG_INTERSTITIAL_UNITID]];
    }

    NSString *errorMsg = nil;
    if (!unitId) errorMsg = @"Invalid Max unitId";

    if (errorMsg) {
        NSError *error = [NSError errorWithDomain:@"com.mintegral" code:-1 userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didFailToLoadInterstitialWithError:)]) {
            [self.delegate didFailToLoadInterstitialWithError:error];
        }
        return;
    }
    
    if (![MaxAdapterHelper isSDKInitialized]) {
        
//    #warning - Make sure to add your AppLovin SDK key in the Info.plist under the "AppLovinSdkKey" key
//        Initialize the AppLovin SDK
        [ALSdk shared].mediationProvider = ALMediationProviderMAX;
        [[ALSdk shared] initializeSdk];

        [MaxAdapterHelper sdkInitialized];
    }

    dispatch_async(dispatch_get_main_queue(), ^{

        self.interstitialAd = [[MAInterstitialAd alloc] initWithAdUnitIdentifier:unitId];
        self.interstitialAd.delegate = self;
        [self.interstitialAd loadAd];
    });
}

- (BOOL)hasAdAvailable{
    
    return [self.interstitialAd isReady];
}


- (void)presentInterstitialFromViewController:(UIViewController *)viewController{
    
    if([self hasAdAvailable]){
        [self.interstitialAd showAd];
    }else{
        NSString *errorMsg = @"current interstitial showFail, not ready";
        NSError *error = [NSError errorWithDomain:@"com.max"  code:-2 userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didFailToPresentInterstitialWithError:)]) {
            [self.delegate didFailToPresentInterstitialWithError:error];
        }
    }
}



#pragma mark - MAAdDelegate Protocol

- (void)didLoadAd:(MAAd *)ad
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didLoadInterstitial)]) {
        [self.delegate didLoadInterstitial];
    }
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withErrorCode:(NSInteger)errorCode
{
    NSError *error = [NSError errorWithDomain:@"com.max" code:errorCode userInfo:nil];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFailToLoadInterstitialWithError:)]) {
        [self.delegate didFailToLoadInterstitialWithError:error];
    }
}

- (void)didDisplayAd:(MAAd *)ad
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPresentInterstitial)]) {
        [self.delegate didPresentInterstitial];
    }
}

- (void)didClickAd:(MAAd *)ad
{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveTapEventFromInterstitial)]) {
        [self.delegate didReceiveTapEventFromInterstitial];
    }
}

- (void)didHideAd:(MAAd *)ad
{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(willDismissInterstitial)]) {
        [self.delegate willDismissInterstitial];
    }
}

- (void)didFailToDisplayAd:(MAAd *)ad withErrorCode:(NSInteger)errorCode
{
    NSError *error = [NSError errorWithDomain:@"com.max" code:errorCode userInfo:nil];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFailToPresentInterstitialWithError:)]) {
        [self.delegate didFailToPresentInterstitialWithError:error];
    }
}

@end
