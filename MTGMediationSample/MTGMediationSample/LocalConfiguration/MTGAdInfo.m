//
//  MTGAdInfo.m
//  MTGMediationSample
//
//  Created by CharkZhang on 2019/1/18.
//  Copyright © 2019 CharkZhang. All rights reserved.
//

#import "MTGAdInfo.h"

@implementation MTGAdInfo

//RewardVideo
+ (NSArray *)rewardVideoAdUnitIds{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"RewardVideoAdInfosData" ofType:@"plist"];
    NSDictionary *adUnitIdInfos = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *adUnitIds = adUnitIdInfos.allKeys;
    return adUnitIds;
}

+ (NSArray *)rewardVideoInfosWithAdUnitId:(NSString *)adUnitId{

    NSString *path = [[NSBundle mainBundle] pathForResource:@"RewardVideoAdInfosData" ofType:@"plist"];
    NSDictionary *adUnitIdInfos = [NSDictionary dictionaryWithContentsOfFile:path];

    NSArray *networkInfos = [adUnitIdInfos objectForKey:adUnitId];
    return networkInfos;
}

//Interstitial
+ (NSArray *)interstitialAdUnitIds{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"InterstitialAdInfosData" ofType:@"plist"];
    NSDictionary *adUnitIdInfos = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *adUnitIds = adUnitIdInfos.allKeys;
    return adUnitIds;
}

+ (NSArray *)interstitialInfosWithAdUnitId:(NSString *)adUnitId{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"InterstitialAdInfosData" ofType:@"plist"];
    NSDictionary *adUnitIdInfos = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSArray *networkInfos = [adUnitIdInfos objectForKey:adUnitId];
    return networkInfos;
}

//Banner
+ (NSArray *)bannerAdUnitIds{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"BannerAdInfosData" ofType:@"plist"];
    NSDictionary *adUnitIdInfos = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *adUnitIds = adUnitIdInfos.allKeys;
    return adUnitIds;
}

+ (NSArray *)bannerInfosWithAdUnitId:(NSString *)adUnitId{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"BannerAdInfosData" ofType:@"plist"];
    NSDictionary *adUnitIdInfos = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSArray *networkInfos = [adUnitIdInfos objectForKey:adUnitId];
    return networkInfos;
}


@end
