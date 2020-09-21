//
//  MTGIronSourceBannerAdapter.m
//  MTGMediationSample
//
//  Created by zhangchark on 2020/9/20.
//  Copyright © 2020 CharkZhang. All rights reserved.
//

#import "MTGIronSourceBannerAdapter.h"
#import "MTGBannerConstants.h"
#import "IronSourceAdapterHelper.h"

#import <IronSource/IronSource.h>
#import <IronSource/ISBannerView.h>

@interface MTGIronSourceBannerAdapter () <ISBannerDelegate>
@property (nonatomic, copy) NSString *placementName;
@property (nonatomic, strong) ISBannerView *bannerView;

@end


@implementation MTGIronSourceBannerAdapter


- (void)requestBannerAdWithCustomEventInfo:(NSDictionary *)info{
    
    NSString *appKey = nil;
    if([info objectForKey:MTG_APPKEY]){
        appKey = [NSString stringWithFormat:@"%@",[info objectForKey:MTG_APPKEY]];
    }
    
    NSString *errorMsg = nil;
    if (!appKey) errorMsg = @"Invalid IRON appKey";
    
    if (errorMsg) {
        NSError *error = [NSError errorWithDomain:@"com.ironsource" code:-1 userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
        if (self.delegate && [self.delegate respondsToSelector:@selector(customEventDidFailToLoadAdWithError:)]) {
            [self.delegate customEventDidFailToLoadAdWithError:error];
        }
        return;
    }
    
    NSString *unitId = nil;
    if([info objectForKey:MTG_BANNER_UNITID]){
        unitId = [NSString stringWithFormat:@"%@",[info objectForKey:MTG_BANNER_UNITID]];
    }
    if([info objectForKey:MTG_BANNER_PLACEMENTNAME]){
        self.placementName = [NSString stringWithFormat:@"%@",[info objectForKey:MTG_BANNER_PLACEMENTNAME]];
    }
    
    [IronSource setBannerDelegate:self];
    
    if (![IronSourceAdapterHelper isSDKInitialized]) {
        
        if(unitId && [unitId length] != 0 && ![unitId isEqualToString:@"null"]){
            [IronSource initWithAppKey:appKey adUnits:@[unitId]];
        }else{
            [IronSource initWithAppKey:appKey];
        }
        
        [IronSourceAdapterHelper sdkInitialized];
    }
    
    UIViewController *viewController = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(viewControllerForPresentingModalView)]) {
        viewController = [self.delegate viewControllerForPresentingModalView];
    }
    
    NSInteger width = 320;
    NSInteger height = 50;
    if ([info objectForKey:MTG_BANNER_WIDTH]){
        width = [[info objectForKey:MTG_BANNER_WIDTH] integerValue];
    }
    if ([info objectForKey:MTG_BANNER_HEIGHT]){
        height = [[info objectForKey:MTG_BANNER_HEIGHT] integerValue];
    }

    ISBannerSize *size = [[ISBannerSize alloc] initWithWidth:width andHeight:height];

    [IronSource loadBannerWithViewController:viewController size:size placement:self.placementName];
    
}

- (void)destroy{
    //to override in subclass
    ;
}


#pragma mark - ISBannerDelegate
- (void)bannerDidDismissScreen {
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventDidDismissScreen)]) {
        [self.delegate customEventDidDismissScreen];
    }
}

- (void)bannerDidFailToLoadWithError:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventDidFailToLoadAdWithError:)]) {
        [self.delegate customEventDidFailToLoadAdWithError:error];
    }
}

- (void)bannerDidLoad:(ISBannerView *)bannerView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventDidLoadAd:)]) {
        [self.delegate customEventDidLoadAd:bannerView];
    }
}

- (void)bannerWillLeaveApplication {
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventUserWillLeaveApplication)]) {
        [self.delegate customEventUserWillLeaveApplication];
    }
}

- (void)bannerWillPresentScreen {
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventWillPresentScreen)]) {
        [self.delegate customEventWillPresentScreen];
    }
}

- (void)didClickBanner {
    if (self.delegate && [self.delegate respondsToSelector:@selector(customEventClick)]) {
        [self.delegate customEventClick];
    }
}

@end
