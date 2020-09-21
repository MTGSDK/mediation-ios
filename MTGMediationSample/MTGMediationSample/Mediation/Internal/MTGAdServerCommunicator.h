//
//  MTGAdServerCommunicator.h
//  MTGMediationSample
//
//  Created by CharkZhang on 2019/1/18.
//  Copyright © 2019 CharkZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef enum : NSUInteger {
    MTGMediationAdTypeRewardVideoAd,
    MTGMediationAdTypeInteristialAd,
    MTGMediationAdTypeBannerAd,
} MTGMediationAdType;

@protocol MTGAdServerCommunicatorDelegate;

@interface MTGAdServerCommunicator : NSObject

@property (nonatomic,weak) id<MTGAdServerCommunicatorDelegate> delegate;

- (id)initWithDelegate:(id<MTGAdServerCommunicatorDelegate>)delegate;

- (void)requestAdUnitInfosWithAdUnit:(NSString *)adUnitId adType:(MTGMediationAdType)adType;

- (void)cancel;


@end


////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol MTGAdServerCommunicatorDelegate <NSObject>

@required
- (void)communicatorDidReceiveAdUnitInfos:(NSArray *)infos;
- (void)communicatorDidFailWithError:(NSError *)error;

@end


NS_ASSUME_NONNULL_END
