//
//  MTGMintegralBannerAdapter.m
//  MTGMediationSample
//
//  Created by zhangchark on 2020/9/20.
//  Copyright © 2020 CharkZhang. All rights reserved.
//

#import "MTGMintegralBannerAdapter.h"
#import "MTGBannerConstants.h"
#import "MintegralAdapterHelper.h"

#if __has_include(<MTGSDKBanner/MTGBannerAdView.h>)

    #import <MTGSDK/MTGSDK.h>
    #import <MTGSDKBanner/MTGBannerAdView.h>
#else
    #import "MTGBannerAdView.h"
#endif

@interface MTGMintegralBannerAdapter () <MTGBannerAdViewDelegate>

@property (nonatomic, copy) NSString *adUnit;
@property (nonatomic, copy) NSString *placementId;

@property (nonatomic, readwrite, strong) MTGBannerAdView *bannerView;

@end

@implementation MTGMintegralBannerAdapter

- (void)requestBannerAdWithCustomEventInfo:(NSDictionary *)info{
    
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
    if([info objectForKey:MTG_BANNER_UNITID]){
        unitId = [NSString stringWithFormat:@"%@",[info objectForKey:MTG_BANNER_UNITID]];
    }
    if ([info objectForKey:MTG_BANNER_PLACEMENTID]) {
        placementId = [NSString stringWithFormat:@"%@",[info objectForKey:MTG_BANNER_PLACEMENTID]];
    }

    NSString *errorMsg = nil;
    if (!appId) errorMsg = @"Invalid MTG appId";
    if (!appKey) errorMsg = @"Invalid MTG appKey";
    if (!unitId) errorMsg = @"Invalid MTG unitId";
    if (!placementId) errorMsg = @"Invalid MTG placementId";

    if (errorMsg) {
        NSError *error = [NSError errorWithDomain:@"com.mintegral" code:-1 userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(customEventDidFailToLoadAdWithError:)]) {
            [self.delegate customEventDidFailToLoadAdWithError:error];
        }

        return;
    }
    
    self.placementId = placementId;
    self.adUnit = unitId;
    
    UIViewController *viewController = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(viewControllerForPresentingModalView)]) {
        viewController = [self.delegate viewControllerForPresentingModalView];
    }

    CGFloat width = 320;
    CGFloat heigth = 50;
    if ([info objectForKey:MTG_BANNER_WIDTH]){
        width = [[info objectForKey:MTG_BANNER_WIDTH] floatValue];
    }
    if ([info objectForKey:MTG_BANNER_HEIGHT]){
        heigth = [[info objectForKey:MTG_BANNER_HEIGHT] floatValue];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
       
        if (![MintegralAdapterHelper isSDKInitialized]) {
            
            [[MTGSDK sharedInstance] setAppID:appId ApiKey:appKey];
            [MintegralAdapterHelper sdkInitialized];
        }
        
        if (!self.bannerView) {

            CGSize size = CGSizeMake(width, heigth);
            self.bannerView = [[MTGBannerAdView alloc] initBannerAdViewWithAdSize:size placementId:self.placementId unitId:self.adUnit rootViewController:viewController];
            self.bannerView.delegate = self;
        }
        CGRect frame = self.bannerView.frame;
        frame.size.width = width;
        frame.size.height = heigth;
        self.bannerView.frame = frame;
        [self.bannerView loadBannerAd];
    });
}

- (void)destroy{
    //to override in subclass
    ;
}


#pragma mark - MTGBannerAdViewDelegate

- (void)adViewCloseFullScreen:(MTGBannerAdView *)adView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventDidDismissScreen)]) {
        [self.delegate customEventDidDismissScreen];
    }
}

- (void)adViewClosed:(MTGBannerAdView *)adView {
    ;
}

- (void)adViewDidClicked:(MTGBannerAdView *)adView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventClick)]) {
        [self.delegate customEventClick];
    }
}

- (void)adViewLoadFailedWithError:(NSError *)error adView:(MTGBannerAdView *)adView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventDidFailToLoadAdWithError:)]) {
        [self.delegate customEventDidFailToLoadAdWithError:error];
    }
}

- (void)adViewLoadSuccess:(MTGBannerAdView *)adView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventDidLoadAd:)]) {
        [self.delegate customEventDidLoadAd:adView];
    }
}

- (void)adViewWillLeaveApplication:(MTGBannerAdView *)adView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventUserWillLeaveApplication)]) {
        [self.delegate customEventUserWillLeaveApplication];
    }
}

- (void)adViewWillLogImpression:(MTGBannerAdView *)adView {
    ;
}

- (void)adViewWillOpenFullScreen:(MTGBannerAdView *)adView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventWillPresentScreen)]) {
        [self.delegate customEventWillPresentScreen];
    }
}

@end
