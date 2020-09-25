//
//  MTGInterstitialViewController.m
//  MTGMediationSample
//
//  Created by CharkZhang on 2019/1/24.
//  Copyright © 2019 CharkZhang. All rights reserved.
//

#import "MTGInterstitialViewController.h"
#import "MTGMediationInterstitialAdManager.h"

#import "MTGAdInfo.h"

@interface MTGInterstitialViewController ()<MTGMediationInterstitialAdManagerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *loadButton;
@property (weak, nonatomic) IBOutlet UIButton *showButton;

@property (nonatomic,copy)  NSString *adUnitId;

@property (nonatomic,strong)  MTGMediationInterstitialAdManager *interstitialManager;
@end

@implementation MTGInterstitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Interstitial";
    self.showButton.userInteractionEnabled = NO;
    
    NSArray *adUnitInfos = [MTGAdInfo interstitialAdUnitIds];
    self.adUnitId = (adUnitInfos.count > 0)?adUnitInfos[0]: nil;

}

-(MTGMediationInterstitialAdManager *)interstitialManager{
    if (_interstitialManager) {
        return _interstitialManager;
    }
    _interstitialManager = [[MTGMediationInterstitialAdManager alloc] initWithAdUnitID:self.adUnitId delegate:self];
    return _interstitialManager;
}


- (IBAction)loadInterstitialAction:(id)sender {

    if (!self.adUnitId) {
        NSString *msg = @"Your adUnitId is nil";
        [self showMsg:msg];
        return;
    }
    [self.interstitialManager loadInterstitial];
}

- (IBAction)showInterstitialAction:(id)sender {

    if ([self.interstitialManager ready]) {
        [self.interstitialManager presentInterstitialFromViewController:self];
    }else{
        NSString *msg = @"video still not ready";
        [self showMsg:msg];
    }
}

- (void)showMsg:(NSString *)content{
    
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:content preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Got it" style:(UIAlertActionStyleDefault) handler:NULL];
    [vc addAction:action];
    
    [self presentViewController:vc animated:YES completion:NULL];
}

#pragma mark - MTGMediationInterstitialAdManagerDelegate

- (void)manager:(MTGMediationInterstitialAdManager *)manager didFailToLoadInterstitialWithError:(NSError *)error {
    self.showButton.userInteractionEnabled = NO;
    NSString *msg = [NSString stringWithFormat:@"error: %@",error.description];
    [self showMsg:msg];
}

- (void)managerDidLoadInterstitial:(MTGMediationInterstitialAdManager *)manager {
    
    self.showButton.userInteractionEnabled = YES;
    NSString *msg = [NSString stringWithFormat:@"unit %@ loadSuccess",manager];
    [self showMsg:msg];
}

- (void)managerDidPresentInterstitial:(MTGMediationInterstitialAdManager *)manager {
    //
}

- (void)manager:(MTGMediationInterstitialAdManager *)manager didFailToPresentInterstitialWithError:(NSError *)error {
    //
}

- (void)managerDidReceiveTapEventFromInterstitial:(MTGMediationInterstitialAdManager *)manager {
    //
}

- (void)managerWillDismissInterstitial:(MTGMediationInterstitialAdManager *)manager {
    //
}

-(NSDictionary *)managerReceiveMediationSetting{
    
    NSDictionary *mediationSettings = @{MTG_INTERSTITIAL_USER:@"Your userId"};
    return mediationSettings;
}

@end
