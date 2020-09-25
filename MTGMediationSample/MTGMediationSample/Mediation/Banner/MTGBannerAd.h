//
//  MTGBannerAd.h
//  MTGMediationSample
//
//  Created by zhangchark on 2020/9/20.
//  Copyright © 2020 CharkZhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTGMediationBannerAdDelegate.h"

NS_ASSUME_NONNULL_BEGIN


#define StandardBannerType320x50 CGSizeMake(320, 50)
#define LargeBannerType320x90 CGSizeMake(320, 90)
#define MediumRectangularBanner300x250 CGSizeMake(300, 250)


@interface MTGBannerAd : NSObject


- (id)initWithAdUnitId:(NSString *)adUnitId bannerViewSize:(CGSize)viewSize;

@property (nonatomic, copy) IBInspectable NSString *adUnitId;

@property (nonatomic, weak) id<MTGMediationBannerAdDelegate> delegate;


- (void)loadAd;



@end

NS_ASSUME_NONNULL_END
