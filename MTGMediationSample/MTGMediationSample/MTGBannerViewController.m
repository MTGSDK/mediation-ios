//
//  MTGBannerViewController.m
//  MTGMediationSample
//
//  Created by zhangchark on 2020/9/20.
//  Copyright © 2020 CharkZhang. All rights reserved.
//

#import "MTGBannerViewController.h"
#import "MTGAdInfo.h"
#import "MTGBannerAd.h"

@interface MTGBannerViewController ()<MTGBannerAdDelegate>

@property (weak, nonatomic) IBOutlet UIButton *loadAdButton;

@property (nonatomic, strong) MTGBannerAd *bannerAd;
@property (nonatomic, strong) UIView *bannerView;

@end

@implementation MTGBannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Banner";

    NSArray *adUnitInfos = [MTGAdInfo bannerAdUnitIds];
    NSString *adUnitId = (adUnitInfos.count > 0)?adUnitInfos[0]: nil;

    MTGBannerAd *bannerAd = [[MTGBannerAd alloc] initWithAdUnitId:adUnitId bannerViewSize:StandardBannerType320x50];
    bannerAd.delegate = self;
    self.bannerAd = bannerAd;
}

- (IBAction)loadAd:(id)sender {
    self.loadAdButton.enabled = NO;
    [self.bannerAd loadAd];
}


- (void)showMsg:(NSString *)content{

    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:content preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Got it" style:(UIAlertActionStyleDefault) handler:NULL];
    [vc addAction:action];

    [self presentViewController:vc animated:YES completion:NULL];
}

#pragma mark - MTGBannerAdDelegate
- (nonnull UIViewController *)viewControllerForPresentingModalView {
    return self;
}

- (void)adViewDidLoadAd:(UIView *)view{

    NSLog(@"%s",__PRETTY_FUNCTION__);

    dispatch_async(dispatch_get_main_queue(), ^{

        self.loadAdButton.enabled = YES;

        if (@available(iOS 11.0, *)) {
            [view setCenter:CGPointMake(self.view.center.x,self.view.frame.size.height - (view.frame.size.height/2.0) - self.view.safeAreaInsets.bottom)]; // safeAreaInsets is available from iOS 11.0
        } else {
            [view setCenter:CGPointMake(self.view.center.x,self.view.frame.size.height - (view.frame.size.height/2.0))];
        }
        [self.view addSubview:view];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

            if (self.bannerView) {
                [self.bannerView removeFromSuperview];
                self.bannerView = nil;
            }
            self.bannerView = view;
        });
    });
}

- (void)adView:(MTGBannerAd *)view didFailToLoadAdWithError:(NSError *)error{
    
    NSLog(@"%s",__PRETTY_FUNCTION__);

    self.loadAdButton.enabled = YES;
    NSString *msg = [NSString stringWithFormat:@"load BannerAd failed:%@",error.description];
    [self showMsg:msg];
}

- (void)adViewClick:(MTGBannerAd *)ad{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)willPresentModalViewForAd:(MTGBannerAd *)view{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)didDismissModalViewForAd:(MTGBannerAd *)view{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)willLeaveApplicationFromAd:(MTGBannerAd *)view{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)viewImpressionFromAd:(MTGBannerAd *)view{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

@end
