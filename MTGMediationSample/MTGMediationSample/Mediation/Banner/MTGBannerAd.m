//
//  MTGBannerAd.m
//  MTGMediationSample
//
//  Created by zhangchark on 2020/9/20.
//  Copyright © 2020 CharkZhang. All rights reserved.
//

#import "MTGBannerAd.h"
#import "MTGMediationBannerManager.h"
#import "MTGBannerManagerDelegate.h"

@interface MTGBannerAd ()<MTGBannerManagerDelegate>

@property (nonatomic, strong) MTGMediationBannerManager *adManager;

@end


@implementation MTGBannerAd

-(void)destroy{
    
}

- (void)dealloc
{
    self.adManager.delegate = nil;
}

- (id)initWithAdUnitId:(NSString *)adUnitId bannerViewSize:(CGSize)viewSize{
    if (self = [super init])
    {
        self.adUnitId = adUnitId;
        self.adManager = [[MTGMediationBannerManager alloc] initWithDelegate:self];
    }
    return self;
}


- (void)loadAd{
    
    [self.adManager loadAdWithAdUnitID:self.adUnitId];
}



#pragma mark - MTGBannerManagerDelegate
- (void)adViewClick{
    
    if ([self.delegate respondsToSelector:@selector(adViewClick:)]) {
        [self.delegate adViewClick:self];
    }
}


- (void)managerDidFailToLoadAdWithError:(nonnull NSError *)error {
    
    if ([self.delegate respondsToSelector:@selector(adView:didFailToLoadAdWithError:)]) {
        [self.delegate adView:self didFailToLoadAdWithError:error];
    }
}


- (void)managerDidLoadAd:(nonnull UIView *)adView {
    
    if ([self.delegate respondsToSelector:@selector(adViewDidLoadAd:)]) {
        [self.delegate adViewDidLoadAd:adView];
    }
}


- (void)userActionDidFinish {
    if ([self.delegate respondsToSelector:@selector(didDismissModalViewForAd:)]) {
        [self.delegate didDismissModalViewForAd:self];
    }
}


- (void)userActionWillBegin {
    if ([self.delegate respondsToSelector:@selector(willPresentModalViewForAd:)]) {
        [self.delegate willPresentModalViewForAd:self];
    }
}


- (void)userWillLeaveApplication {
    if ([self.delegate respondsToSelector:@selector(willLeaveApplicationFromAd:)]) {
        [self.delegate willLeaveApplicationFromAd:self];
    }
}


- (nonnull UIViewController *)viewControllerForPresentingModalView {
    return [self.delegate viewControllerForPresentingModalView];
}

@end
