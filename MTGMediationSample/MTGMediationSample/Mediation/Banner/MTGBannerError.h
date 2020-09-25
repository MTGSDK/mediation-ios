//
//  MTGBannerError.h
//  MTGMediationSample
//
//  Created by zhangchark on 2020/9/20.
//  Copyright © 2020 CharkZhang. All rights reserved.
//

#import <Foundation/Foundation.h>



typedef enum {
    MTGBannerAdErrorUnknown = -1,
    MTGBannerAdErrorInvalidAdUnitID = -1000,
    MTGBannerAdErrorTimeout = -1001,
    MTGBannerAdErrorCurrentUnitIsLoading = -1002,
    MTGBannerAdErrorAdDataInValid = -1003,
    MTGBannerAdErrorNoAdsAvailable = -1100,
    MTGBannerAdErrorInvalidCustomEvent = -1200,

    MTGBannerAdUnLoaded = -2000,
    MTGRewardVideoAdViewControllerInvalid = -2100,

} MTGBannerErrorCode;



extern NSString * const MTGBannerAdsSDKDomain;


