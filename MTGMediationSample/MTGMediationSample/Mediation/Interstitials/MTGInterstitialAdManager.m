//
//  MTGInterstitialAdManager.m
//  MTGMediationSample
//
//  Created by CharkZhang on 2019/2/19.
//  Copyright © 2019 CharkZhang. All rights reserved.
//

#import "MTGInterstitialAdManager.h"
#import "MTGInterstitialAdapter.h"
#import "MTGAdServerCommunicator.h"
#import "MTGInterstitialError.h"


#define INVOKE_IN_MAINTHREAD(code) \
if ([NSThread isMainThread]) {  \
        code    \
    }else{  \
    dispatch_async(dispatch_get_main_queue(), ^{    \
        code    \
    }); \
}


@interface MTGInterstitialAdManager ()<MTGAdServerCommunicatorDelegate,MTGPrivateInnerInterstitialDelegate>

@property (nonatomic, readonly) NSString *adUnitID;

@property (nonatomic, strong) MTGInterstitialAdapter *adapter;
@property (nonatomic, strong) MTGAdServerCommunicator *communicator;

@property (nonatomic, assign) BOOL loading;

@end

@implementation MTGInterstitialAdManager

- (void)dealloc
{
    [_communicator cancel];
    [_communicator setDelegate:nil];
    
    [self.adapter unregisterDelegate];
    self.adapter = nil;
}

- (id)initWithAdUnitID:(NSString *)adUnitID delegate:(id<MTGInterstitialAdManagerDelegate>)delegate{

    if (self = [super init]) {
        _adUnitID = [adUnitID copy];
        _communicator = [[MTGAdServerCommunicator alloc] initWithDelegate:self];
        _delegate = delegate;
    }
    
    return self;
}

- (void)loadInterstitial{
    
    if (self.loading) {
        NSError *error = [NSError errorWithDomain:MTGInterstitialAdsSDKDomain code:MTGInterstitialAdErrorCurrentUnitIsLoading userInfo:nil];
        [self sendLoadFailedWithError:error];
        return;
    }
    
    self.loading = YES;

    MTGMediationAdType adType = MTGMediationAdTypeInteristialAd;
    [self.communicator requestAdUnitInfosWithAdUnit:_adUnitID adType:(adType)];
}

-(BOOL)ready{

    if (!self.adapter) {
        return NO;
    }
    return [self.adapter hasAdAvailable];
}


- (void)presentInterstitialFromViewController:(UIViewController *)controller{

    [self.adapter presentInterstitialFromViewController:controller];
}


#pragma Private Methods -

- (void)sendLoadFailedWithError:(NSError *)error{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(manager:didFailToLoadInterstitialWithError:)]) {
            [self.delegate manager:self didFailToLoadInterstitialWithError:error];
        }
    });
}

- (void)sendLoadSuccess{

    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(managerDidLoadInterstitial:)]) {

            [self.delegate managerDidLoadInterstitial:self];
        }
    });
}

- (void)sendShowFailedWithError:(NSError *)error{

    if (_delegate && [_delegate respondsToSelector:@selector(manager:didFailToPresentInterstitialWithError:)]) {
        [_delegate manager:self didFailToPresentInterstitialWithError:error];
    }
}


#pragma mark MTGAdServerCommunicatorDelegate -
- (void)communicatorDidReceiveAdUnitInfos:(NSArray *)infos{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self createThreadhandleInfos:infos];
    });
}

- (void)createThreadhandleInfos:(NSArray *)infos{
    
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    [infos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSDictionary *adInfo = (NSDictionary *)obj;
        
        [self.adapter unregisterDelegate];
        self.adapter = nil;
        
        MTGInterstitialAdapter *adapter = [[MTGInterstitialAdapter alloc] initWithDelegate:self mediationSettings:@{}];
        
        self.adapter = adapter;
        
        [self.adapter getAdWithInfo:adInfo completionHandler:^(BOOL success, NSError * _Nonnull error) {
            if (success) {
                *stop = YES;
                dispatch_semaphore_signal(sem);

                [self sendLoadSuccess];
            }else{
                
                [self.adapter unregisterDelegate];
                self.adapter = nil;
                
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


#pragma mark - MTGPrivateInnerInterstitialDelegate

- (void)didFailToLoadInterstitialWithError:(nonnull NSError *)error {
    
    [self sendLoadFailedWithError:error];
}

- (void)didFailToPresentInterstitialWithError:(nonnull NSError *)error {
    [self sendShowFailedWithError:error];
}

- (void)didLoadInterstitial {
    [self sendLoadSuccess];

}

- (void)didPresentInterstitial {

    INVOKE_IN_MAINTHREAD(
         if (self.delegate && [self.delegate respondsToSelector:@selector(managerDidPresentInterstitial:)]) {
             [self.delegate managerDidPresentInterstitial:self];
         }
    );
}

- (void)didReceiveTapEventFromInterstitial {
    
    INVOKE_IN_MAINTHREAD(
         if (self.delegate && [self.delegate respondsToSelector:@selector(managerDidReceiveTapEventFromInterstitial:)]) {
             [self.delegate managerDidReceiveTapEventFromInterstitial:self];
         }
    );
}

- (void)willDismissInterstitial {
    
    INVOKE_IN_MAINTHREAD(
         if (self.delegate && [self.delegate respondsToSelector:@selector(managerWillDismissInterstitial:)]) {
             [self.delegate managerWillDismissInterstitial:self];
         }
     );
}

@end
