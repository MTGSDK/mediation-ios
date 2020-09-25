//
//  MTGBannerManager.m
//  MTGMediationSample
//
//  Created by zhangchark on 2020/9/20.
//  Copyright © 2020 CharkZhang. All rights reserved.
//

#import "MTGBannerManager.h"
#import "MTGAdServerCommunicator.h"
#import "MTGBannerAdapter.h"
#import <UIKit/UIKit.h>
#import "MTGBannerError.h"
#import "MTGBannerManagerDelegate.h"

@interface MTGBannerManager ()<MTGBannerAdapterDelegate>

@property (nonatomic, strong) MTGAdServerCommunicator *communicator;
@property (nonatomic, strong) MTGBannerAdapter *requestingAdapter;
@property (nonatomic, strong) UIView *requestingAdapterAdContentView;

@property (nonatomic, assign) BOOL loading;

@end

@implementation MTGBannerManager

- (id)initWithDelegate:(id<MTGBannerManagerDelegate>)delegate{

    self = [super init];
    if (self) {
        self.delegate = delegate;

        self.communicator = [[MTGAdServerCommunicator alloc] initWithDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [self.communicator cancel];
    [self.communicator setDelegate:nil];
}


- (void)loadAdWithAdUnitID:(NSString *)adUnitID{

    if (self.loading) {
        NSError *error = [NSError errorWithDomain:MTGBannerAdsSDKDomain code:MTGBannerAdErrorCurrentUnitIsLoading userInfo:nil];
        [self sendLoadFailedWithError:error];
        return;
    }

    self.requestingAdapter = nil;
    self.requestingAdapterAdContentView = nil;

    [self.communicator cancel];

    self.loading = YES;

    MTGMediationAdType adType = MTGMediationAdTypeBannerAd;
    [self.communicator requestAdUnitInfosWithAdUnit:adUnitID adType:(adType)];
}


- (void)startAutomaticallyRefreshingContents:(int)refreshInterval
{
    ;// will support later if needed
}

- (void)stopAutomaticallyRefreshingContents
{
    ;// will support later if needed
}

#pragma mark - MTGAdServerCommunicatorDelegate
- (void)communicatorDidReceiveAdUnitInfos:(NSArray *)infos{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self createThreadhandleInfos:infos];
    });
}

- (void)createThreadhandleInfos:(NSArray *)infos{
    
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    [infos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSDictionary *adInfo = (NSDictionary *)obj;
        
        [self.requestingAdapter unregisterDelegate];
        self.requestingAdapter = nil;
        
        MTGBannerAdapter *adapter = [[MTGBannerAdapter alloc] initWithDelegate:self mediationSettings:@{}];
        
        self.requestingAdapter = adapter;
        
        [self.requestingAdapter getAdWithInfo:adInfo completionHandler:^(BOOL success, NSError * _Nonnull error,UIView *view) {
            if (success) {
                *stop = YES;
                dispatch_semaphore_signal(sem);

                [self sendLoadSuccess:view];
            }else{
                
                [self.requestingAdapter unregisterDelegate];
                self.requestingAdapter = nil;
                
                dispatch_semaphore_signal(sem);

                //if the last loop failed
                if (idx == (infos.count - 1)) {
                    [self sendLoadFailedWithError:error];
                }
                //else: continue next request loop
            }
            
        }];
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }];
    
    self.loading = NO;
}


- (void)communicatorDidFailWithError:(NSError *)error{
    
    [self sendLoadFailedWithError:error];
    
    self.loading = NO;
}



#pragma Private Methods -

- (void)sendLoadFailedWithError:(NSError *)error{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(managerDidFailToLoadAdWithError:)]) {
            [self.delegate managerDidFailToLoadAdWithError:error];
        }
    });
}

- (void)sendLoadSuccess:(UIView *)view{

    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(managerDidLoadAd:)]) {
            [self.delegate managerDidLoadAd:view];
        }
    });
}

#pragma mark MTGBannerAdapterDelegate -
- (UIViewController *)viewControllerForPresentingModalView{
    if (self.delegate && [self.delegate respondsToSelector:@selector(viewControllerForPresentingModalView)]) {
        return [self.delegate viewControllerForPresentingModalView];
    }
    return nil;
}

- (void)adapterAdClick:(NSString *)adUnitId{
    if (self.delegate && [self.delegate respondsToSelector:@selector(adViewClick)]) {
        [self.delegate adViewClick];
    }
}

- (void)adapterUserActionDidFinish:(nonnull NSString *)adUnitId {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userActionDidFinish)]) {
        [self.delegate userActionDidFinish];
    }
}

- (void)adapterUserActionWillBegin:(nonnull NSString *)adUnitId {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userActionWillBegin)]) {
        [self.delegate userActionWillBegin];
    }
}

- (void)adapterUserWillLeaveApplication:(nonnull NSString *)adUnitId {
    if (self.delegate && [self.delegate respondsToSelector:@selector(adapterUserWillLeaveApplication:)]) {
        [self.delegate userWillLeaveApplication];
    }
}

- (void)adapterImpressionDidFire:(nonnull NSString *)adUnitId {
    ;
}


@end

