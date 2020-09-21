//
//  MTGBannerAdapter.m
//  MTGMediationSample
//
//  Created by zhangchark on 2020/9/20.
//  Copyright © 2020 CharkZhang. All rights reserved.
//

#import "MTGBannerAdapter.h"
#import "MTGBannerCustomEvent.h"
#import "MTGBannerConstants.h"
#import "MTGBannerError.h"

@interface MTGBannerAdapter ()<MTGBannerCustomEventDelegate>


@property (nonatomic, strong) MTGBannerCustomEvent *bannerCustomEvent;

@property (nonatomic, weak) id<MTGBannerAdapterDelegate> delegate;
@property (nonatomic, copy) void(^completionHandler)(BOOL success,NSError *error,UIView *view);

@property (nonatomic, copy)  NSString *adUnitID;
@property (nonatomic, copy)  NSString *networkName;
@property (nonatomic, strong) NSDictionary *mediationSettings;
@property (nonatomic, assign)  BOOL hasExpired;
@property (nonatomic, assign)  BOOL hasCancelPreviousPerform;

@end

@implementation MTGBannerAdapter

- (id)initWithDelegate:(id<MTGBannerAdapterDelegate>)delegate mediationSettings:(NSDictionary *)mediationSettings{
    
    if (self = [super init]) {
        _delegate = delegate;
        _mediationSettings = mediationSettings;
    }
    return self;
}

- (void)getAdWithInfo:(NSDictionary *)adInfo completionHandler:(void (^ __nullable)(BOOL success,NSError *error,UIView *view))completion{
    
    NSMutableDictionary *adInfoWithMediationSetting = [NSMutableDictionary dictionaryWithDictionary:adInfo];
    [adInfoWithMediationSetting addEntriesFromDictionary:_mediationSettings];
    
    self.adUnitID = [adInfo objectForKey:MTG_BANNER_UNITID];
    self.networkName = [adInfo objectForKey:MTG_BANNER_NETWORKNAME];
    NSString *customEventClassName = [adInfo objectForKey:MTG_BANNER_CLASSNAME ];
    
    self.bannerCustomEvent = [self buildCustomEventFromCustomClass:NSClassFromString(customEventClassName)];
    
    if (self.bannerCustomEvent) {
        
        NSTimeInterval duration = [[adInfo objectForKey:MTG_BANNER_TIMEOUT] doubleValue];
        [self startTimeoutTimer:duration];
        
        self.completionHandler = completion;
        
        [self.bannerCustomEvent requestBannerAdWithCustomEventInfo:adInfoWithMediationSetting];
    } else {
        
        NSError *error = [NSError errorWithDomain:MTGBannerAdsSDKDomain code:MTGBannerAdErrorInvalidCustomEvent userInfo:nil];
        [self sendLoadFailedWithError:error];
    }
}

- (void)unregisterDelegate
{
    self.delegate = nil;
}





#pragma Private Methods -

-(void)dealloc{
    
    [self cancelPreviousPerform];
    _completionHandler = nil;
}


- (MTGBannerCustomEvent *)buildCustomEventFromCustomClass:(Class)customClass{
    
    MTGBannerCustomEvent *customEvent = [[customClass alloc] init];
    
    if (![customEvent isKindOfClass:[MTGBannerCustomEvent class]]) {
        return nil;
    }
    customEvent.delegate = self;
    return customEvent;
}


- (void)startTimeoutTimer:(NSTimeInterval)duration{
    
    if (duration < 1) {
        duration = 10;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self performSelector:@selector(timeout) withObject:nil afterDelay:duration];
    });
}

- (void)timeout{
    
    self.hasExpired = YES;
    NSError *error = [NSError errorWithDomain:MTGBannerAdsSDKDomain code:MTGBannerAdErrorTimeout userInfo:nil];
    [self sendLoadFailedWithError:error];
}

- (void)cancelPreviousPerform{
    
    if (self.hasCancelPreviousPerform) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeout) object:nil];
    self.hasCancelPreviousPerform = YES;
}


- (void)sendLoadFailedWithError:(NSError *)error{
    
    if (self.completionHandler) {
        self.completionHandler(NO, error,nil);
    }
    self.completionHandler = nil;
}

- (void)sendLoadSuccess:(UIView *)view{
    
    if (_hasExpired) {
        return;
    }
    
    if (self.completionHandler && ![self.completionHandler isEqual:[NSNull null]]) {
        
        NSLog(@"current unit%@ loadSuccess,  and ad network is:%@ ",self.adUnitID,self.networkName);
        self.completionHandler(YES, nil,view);
    }
    self.completionHandler = nil;
    
}


#pragma mark - MTGBannerCustomEventDelegate

- (void)customEventDidLoadAd:(UIView *)view{
    [self cancelPreviousPerform];
    [self sendLoadSuccess:view];
}

- (void)customEventDidFailToLoadAdWithError:(NSError *)error{
    
    [self cancelPreviousPerform];
    [self sendLoadFailedWithError:error];
}


-(UIViewController *)viewControllerForPresentingModalView{
    if (self.delegate && [self.delegate respondsToSelector:@selector(viewControllerForPresentingModalView)]) {
        return [self.delegate viewControllerForPresentingModalView];
    }
    return nil;
}

- (void)customEventWillPresentScreen{
    if (self.delegate && [self.delegate respondsToSelector:@selector(adapterUserActionWillBegin:)]) {
        [self.delegate adapterUserActionWillBegin:self.adUnitID];
    }
}

- (void)customEventDidDismissScreen{
    if (self.delegate && [self.delegate respondsToSelector:@selector(adapterUserActionDidFinish:)]) {
        [self.delegate adapterUserActionDidFinish:self.adUnitID];
    }
}

-(void)customEventClick{
    if (self.delegate && [self.delegate respondsToSelector:@selector(adapterAdClick:)]) {
        [self.delegate adapterAdClick:self.adUnitID];
    }
}

- (void)customEventUserWillLeaveApplication{
    if (self.delegate && [self.delegate respondsToSelector:@selector(adapterUserWillLeaveApplication:)]) {
        [self.delegate adapterUserWillLeaveApplication:self.adUnitID];
    }
}

- (void)customEventImpressionDidFire{
    if (self.delegate && [self.delegate respondsToSelector:@selector(adapterImpressionDidFire:)]) {
        [self.delegate adapterImpressionDidFire:self.adUnitID];
    }
}



@end
