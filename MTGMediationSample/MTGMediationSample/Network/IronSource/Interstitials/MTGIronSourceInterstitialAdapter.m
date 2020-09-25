//
//  MTGIronSourceInterstitialAdapter.m
//  MTGMediationSample
//
//  Created by ym on 2019/2/12.
//  Copyright © 2019 CharkZhang. All rights reserved.
//

#import "MTGIronSourceInterstitialAdapter.h"
#import "MTGInterstitialConstants.h"
#import "IronSourceAdapterHelper.h"

#import <IronSource/IronSource.h>

@interface MTGIronSourceInterstitialAdapter () <ISInterstitialDelegate>
@property (nonatomic, copy) NSString *placementName;
@end

@implementation MTGIronSourceInterstitialAdapter

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info{
    
    NSString *appKey = nil;
    if([info objectForKey:MTG_APPKEY]){
        appKey = [NSString stringWithFormat:@"%@",[info objectForKey:MTG_APPKEY]];
    }
    
    NSString *errorMsg = nil;
    if (!appKey) errorMsg = @"Invalid IRON appKey";
    
    if (errorMsg) {
        NSError *error = [NSError errorWithDomain:@"com.ironsource" code:-1 userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didFailToLoadInterstitialWithError:)]) {
            [self.delegate didFailToLoadInterstitialWithError:error];
        }
        return;
    }
    
    NSString *unitId;
    if([info objectForKey:MTG_INTERSTITIAL_UNITID]){
        unitId = [NSString stringWithFormat:@"%@",[info objectForKey:MTG_INTERSTITIAL_UNITID]];
    }
    if([info objectForKey:MTG_INTERSTITIAL_PLACEMENTNAME]){
        self.placementName = [NSString stringWithFormat:@"%@",[info objectForKey:MTG_INTERSTITIAL_PLACEMENTNAME]];
    }
    
 
    dispatch_async(dispatch_get_main_queue(), ^{

        [IronSource setInterstitialDelegate:self];
        
        if (![IronSourceAdapterHelper isSDKInitialized]) {
            
            if(unitId && [unitId length] != 0 && ![unitId isEqualToString:@"null"]){
                [IronSource initWithAppKey:appKey adUnits:@[unitId]];
            }else{
                [IronSource initWithAppKey:appKey];
            }
            
            [IronSourceAdapterHelper sdkInitialized];
        }
        [IronSource loadInterstitial];

    });
}

- (BOOL)hasAdAvailable{
    
    return [IronSource hasInterstitial];
}

- (void)presentInterstitialFromViewController:(UIViewController *)viewController{
    if([self hasAdAvailable]){
        if (self.placementName && [self.placementName length] != 0) {
            [IronSource showInterstitialWithViewController:viewController placement:self.placementName];
        } else {
            [IronSource showInterstitialWithViewController:viewController];
        }
    }else{
        NSString *errorMsg = @"current interstitialVideo showFail，video not ready";
        NSError *error = [NSError errorWithDomain:@"com.ironsource"  code:-2 userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didFailToPresentInterstitialWithError:)]) {
            [self.delegate didFailToPresentInterstitialWithError:error];
        }
    }
}

#pragma mark InterstitialAdDelegate

- (void)didClickInterstitial
{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveTapEventFromInterstitial)]) {
        [self.delegate didReceiveTapEventFromInterstitial];
    }
}

- (void)interstitialDidClose
{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(willDismissInterstitial)]) {
        [self.delegate willDismissInterstitial];
    }
}

- (void)interstitialDidFailToLoadWithError:(NSError *)error
{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFailToLoadInterstitialWithError:)]) {
        [self.delegate didFailToLoadInterstitialWithError:error];
    }
}

- (void)interstitialDidFailToShowWithError:(NSError *)error
{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFailToPresentInterstitialWithError:)]) {
        [self.delegate didFailToPresentInterstitialWithError:error];
    }
}

- (void)interstitialDidLoad
{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didLoadInterstitial)]) {
        [self.delegate didLoadInterstitial];
    }
}

- (void)interstitialDidOpen
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPresentInterstitial)]) {
        [self.delegate didPresentInterstitial];
    }
}

- (void)interstitialDidShow
{
    ;
}

@end
