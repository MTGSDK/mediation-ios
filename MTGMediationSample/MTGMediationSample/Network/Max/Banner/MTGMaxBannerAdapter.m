//
//  MTGMaxBannerAdapter.m
//  MTGMediationSample
//
//  Created by zhangchark on 2020/9/22.
//  Copyright © 2020 CharkZhang. All rights reserved.
//

#import "MTGMaxBannerAdapter.h"
#import "MaxAdapterHelper.h"
#import "MTGBannerConstants.h"

#import <AppLovinSDK/AppLovinSDK.h>

@interface MTGMaxBannerAdapter()<MAAdViewAdDelegate>
@property (nonatomic, strong) MAAdView *adView;
@end


@implementation MTGMaxBannerAdapter


- (void)requestBannerAdWithCustomEventInfo:(NSDictionary *)info{

    NSString *errorMsg = nil;
    NSString *unitId = nil;
    if([info objectForKey:MTG_BANNER_UNITID]){
        unitId = [NSString stringWithFormat:@"%@",[info objectForKey:MTG_BANNER_UNITID]];
    }
    if (!unitId) errorMsg = @"Invalid Max Banner AD_UNIT_ID";

    if (errorMsg) {
        NSError *error = [NSError errorWithDomain:@"com.ironsource" code:-1 userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
        if (self.delegate && [self.delegate respondsToSelector:@selector(customEventDidFailToLoadAdWithError:)]) {
            [self.delegate customEventDidFailToLoadAdWithError:error];
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
    
    NSInteger width = 320;
    NSInteger height = 50;
    if ([info objectForKey:MTG_BANNER_WIDTH]){
        width = [[info objectForKey:MTG_BANNER_WIDTH] integerValue];
    }
    if ([info objectForKey:MTG_BANNER_HEIGHT]){
        height = [[info objectForKey:MTG_BANNER_HEIGHT] integerValue];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        self.adView = [[MAAdView alloc] initWithAdUnitIdentifier:unitId];
        self.adView.delegate = self;

        [self.adView loadAd];
    });
}


#pragma mark - MAAdDelegate Protocol

- (void)didLoadAd:(MAAd *)ad
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventDidLoadAd:)]) {
        [self.delegate customEventDidLoadAd:self.adView];
    }
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withErrorCode:(NSInteger)errorCode
{
    NSError *error = [NSError errorWithDomain:@"com.max" code:errorCode userInfo:nil];
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventDidFailToLoadAdWithError:)]) {
        [self.delegate customEventDidFailToLoadAdWithError:error];
    }
}

- (void)didClickAd:(MAAd *)ad
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventClick)]) {
        [self.delegate customEventClick];
    }
}

- (void)didDisplayAd:(MAAd *)ad
{
    ;
}

- (void)didHideAd:(MAAd *)ad
{
    ;
}

- (void)didFailToDisplayAd:(MAAd *)ad withErrorCode:(NSInteger)errorCode
{
    ;
}

#pragma mark - MAAdViewAdDelegate Protocol

- (void)didExpandAd:(MAAd *)ad
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventWillPresentScreen)]) {
        [self.delegate customEventWillPresentScreen];
    }
}

- (void)didCollapseAd:(MAAd *)ad
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventDidDismissScreen)]) {
        [self.delegate customEventDidDismissScreen];
    }
}



@end
