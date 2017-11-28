//
//  LocationViewController.m
//  BaiduMap
//
//  Created by Macx on 2017/11/28.
//  Copyright © 2017年 Macx. All rights reserved.
//

#import "LocationViewController.h"

#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>

@interface LocationViewController ()<BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate>
{
    BMKGeoCodeSearch *_geocodesearch;
}

@property (nonatomic, strong) BMKLocationService * locationService;

@end

@implementation LocationViewController

- (BMKLocationService *)locationService
{
    if (!_locationService) {
         _locationService = [[BMKLocationService alloc]init];
    }
    return _locationService;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   // 此处记得不用的时候需要置nil，否则影响内存的释放
    self.locationService.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.locationService.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _geocodesearch = [[BMKGeoCodeSearch alloc] init];
    _geocodesearch.delegate = self;
}

- (IBAction)showStartLocation:(UIButton *)sender
{
    self.locationService.distanceFilter = 10;
    [self.locationService startUserLocationService];
}

- (IBAction)showStopLocation:(UIButton *)sender
{
    [self.locationService stopUserLocationService];
}

/**
 *在将要启动定位时，会调用此函数
 */
- (void)willStartLocatingUser
{
    
}

/**
 *在停止定位后，会调用此函数
 */
- (void)didStopLocatingUser
{
    
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    NSLog(@">>>>>>%@-\n>>>>>>%@-\n>>>>>>%@-\n>>>>>>%@",userLocation.location,userLocation.title,userLocation.subtitle,userLocation.heading);
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"定位地址" message:[NSString stringWithFormat:@"%@",userLocation.subtitle] preferredStyle:1];
    UIAlertAction * alertAction = [UIAlertAction actionWithTitle:@"确定" style:0 handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:alertAction];
    [self presentViewController:alert animated:true completion:nil];
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    NSLog(@">>>>>>%@-\n>>>>>>%@-\n>>>>>>%@-\n>>>>>>%@",userLocation.location,userLocation.title,userLocation.subtitle,userLocation.heading);
    NSLog(@"经度：%zd\n纬度：%zd",userLocation.location.coordinate.longitude,userLocation.location.coordinate.latitude);
    
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    
    reverseGeocodeSearchOption.reverseGeoPoint = userLocation.location.coordinate;
    BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag){
        NSLog(@"反geo检索发送成功");
        [self.locationService stopUserLocationService];
    }else{
        NSLog(@"反geo检索发送失败");
    }
}

/**
 *定位失败后，会调用此函数
 *@param error 错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    
}

#pragma mark -------------地理反编码的delegate---------------

-(void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error

{
    NSLog(@"address:%@----%@",result.addressDetail.city,result.addressDetail.streetName);
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"定位地址" message:[NSString stringWithFormat:@"%@",result.address] preferredStyle:1];
    UIAlertAction * alertAction = [UIAlertAction actionWithTitle:@"确定" style:0 handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:alertAction];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
