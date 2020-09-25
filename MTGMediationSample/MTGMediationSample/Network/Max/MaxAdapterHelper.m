//
//  MaxAdapterHelper.m
//  MTGMediationSample
//
//  Created by zhangchark on 2020/9/22.
//  Copyright © 2020 CharkZhang. All rights reserved.
//

#import "MaxAdapterHelper.h"


static BOOL appLovinSDKInitialized = NO;

@implementation MaxAdapterHelper

+(BOOL)isSDKInitialized{
    
    return appLovinSDKInitialized;
}

+(void)sdkInitialized{
    
    #ifdef DEBUG
    if (DEBUG) {
        NSLog(@"The version of current AppLovin Adapter is: %@",AppLovinAdapterVersion);
    }
    #endif
    appLovinSDKInitialized = YES;
}

@end
