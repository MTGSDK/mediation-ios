//
//  MTGAdTableTableViewController.m
//  MTGMediationSample
//
//  Created by CharkZhang on 2019/1/24.
//  Copyright © 2019 CharkZhang. All rights reserved.
//

#import "MTGAdTableTableViewController.h"
#import "MTGRewardVideoViewController.h"
#import "MTGInterstitialViewController.h"
#import "MTGBannerViewController.h"

@interface MTGAdTableTableViewController ()

@property (nonatomic,strong)  NSMutableArray *items;

@end

@implementation MTGAdTableTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Mediation Demo";
    self.tableView.tableFooterView = [UIView new];

    self.items = [NSMutableArray new];
    [self.items addObject:@"RewardVideo Ad"];
    [self.items addObject:@"Interstitial Ad"];
    [self.items addObject:@"Banner Ad"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *ssid = @"TableViewCellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ssid];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ssid];
    }
    NSString *itemString = [self.items objectAtIndex:indexPath.row];
    cell.textLabel.text = itemString;

    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSUInteger index = indexPath.row;
    switch (index) {
        case 0:
            //RewardVideo
            [self toRewardVideoViewController];
            break;
        case 1:
            //Interstitial
            [self toInterstitialViewController];
            break;
        case 2:
            //Banner
            [self toMTGBannerViewController];
        default:
            break;
    }
}

#pragma mark - Private methods
- (void)toRewardVideoViewController{
    
    [self.navigationController pushViewController:[[MTGRewardVideoViewController alloc] initWithNibName:@"MTGRewardVideoViewController" bundle:nil] animated:YES];
}

- (void)toInterstitialViewController{
    
    [self.navigationController pushViewController:[[MTGInterstitialViewController alloc] initWithNibName:@"MTGInterstitialViewController" bundle:nil] animated:YES];
}

- (void)toMTGBannerViewController{

    [self.navigationController pushViewController:[[MTGBannerViewController alloc] initWithNibName:@"MTGBannerViewController" bundle:nil] animated:YES];
}

@end
