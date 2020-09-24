//
//  MaxAdapterHelper.h
//  MTGMediationSample
//
//  Created by zhangchark on 2020/9/22.
//  Copyright © 2020 CharkZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define AppLovinAdapterVersion  @"1.1.0"

@interface MaxAdapterHelper : NSObject

+(BOOL)isSDKInitialized;

+(void)sdkInitialized;

@end

NS_ASSUME_NONNULL_END

