//
//  AddAnnoationsViewController.m
//  BaiduMap
//
//  Created by Macx on 2017/11/28.
//  Copyright © 2017年 Macx. All rights reserved.
//

#import "AddAnnoationsViewController.h"

@interface AddAnnoationsViewController (){
    BMKClusterManager *_clusterManager;//点聚合管理类
    NSInteger _clusterZoom;//聚合级别
    NSMutableArray *_clusterCaches;//点聚合缓存标注
    BMKGeoCodeSearch *_geocodesearch;
}

@property (nonatomic, strong) BMKMapView * mapView;

@property (nonatomic, strong) BMKLocationService * locationService;

@end

@implementation AddAnnoationsViewController

- (BMKLocationService *)locationService
{
    if (!_locationService) {
        _locationService = [[BMKLocationService alloc]init];
    }
    return _locationService;
}

-(void)viewWillAppear:(BOOL)animated {
       [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    // 此处记得不用的时候需要置nil，否则影响内存的释放
    self.locationService.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    self.locationService.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.locationService startUserLocationService];
    _mapView = [[BMKMapView alloc]initWithFrame:self.view.bounds];
    self.view = _mapView;
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态为普通定位模式
    _mapView.showsUserLocation = YES;//显示定位图层
    
    _geocodesearch = [[BMKGeoCodeSearch alloc] init];
    _geocodesearch.delegate = self;
    //[self configurationParams];
}

- (void) configurationParams:(CLLocationCoordinate2D)coor
{
    _clusterCaches = [[NSMutableArray alloc] init];
    for (NSInteger i = 3; i < 22; i++) {
        [_clusterCaches addObject:[NSMutableArray array]];
    }
    
    //点聚合管理类
    _clusterManager = [[BMKClusterManager alloc] init];
    //CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(39.915, 116.404);
    //向点聚合管理类中添加标注
    for (NSInteger i = 0; i < 20; i++) {
        double lat =  (arc4random() % 100) * 0.001f;
        double lon =  (arc4random() % 100) * 0.001f;
        BMKClusterItem *clusterItem = [[BMKClusterItem alloc] init];
        clusterItem.coor = CLLocationCoordinate2DMake(coor.latitude + lat, coor.longitude + lon);
        [_clusterManager addClusterItem:clusterItem];
    }
}

//更新聚合状态
- (void)updateClusters {
    _clusterZoom = (NSInteger)_mapView.zoomLevel;
    @synchronized(_clusterCaches) {
        __block NSMutableArray *clusters = [_clusterCaches objectAtIndex:(_clusterZoom - 3)];
        
        if (clusters.count > 0) {
            [_mapView removeAnnotations:_mapView.annotations];
            [_mapView addAnnotations:clusters];
        } else {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                ///获取聚合后的标注
                __block NSArray *array = [_clusterManager getClusters:_clusterZoom];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    for (BMKCluster *item in array) {
                        BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc] init];
                        annotation.coordinate = item.coordinate;
                        [clusters addObject:annotation];
                    }
                    [_mapView removeAnnotations:_mapView.annotations];
                    [_mapView addAnnotations:clusters];
                });
            });
        }
    }
}

#pragma mark - BMKMapViewDelegate
// 根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    //普通annotation
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        BMKPinAnnotationView*annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil) {
            annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.pinColor = BMKPinAnnotationColorPurple;
        annotationView.canShowCallout= YES;      //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop=YES;         //设置标注动画显示，默认为NO
        annotationView.draggable = YES;          //设置标注可以拖动，默认为NO
        return annotationView;
    }
    return nil;
}

/**
 *当点击annotation view弹出的泡泡时，调用此接口
 *@param mapView 地图View
 *@param view 泡泡所属的annotation view
 */
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view
{
    if ([view isKindOfClass:[BMKPinAnnotationView class]])
    {
        BMKPinAnnotationView *clusterAnnotation = (BMKPinAnnotationView*)view.annotation;
        [mapView setCenterCoordinate:view.annotation.coordinate];
        [mapView zoomIn];
    }
}

/**
 *地图初始化完毕时会调用此接口
 *@param mapview 地图View
 */
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView
{
    [self updateClusters];
}

/**
 *地图渲染每一帧画面过程中，以及每次需要重绘地图时（例如添加覆盖物）都会调用此接口
 *@param mapview 地图View
 *@param status 此时地图的状态
 */
- (void)mapView:(BMKMapView *)mapView onDrawMapFrame:(BMKMapStatus *)status
{
    if (_clusterZoom != 0 && _clusterZoom != (NSInteger)mapView.zoomLevel)
    {
        [self updateClusters];
    }
}

#pragma mark BMKLocationServiceDelegate
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
    [_mapView updateLocationData:userLocation];
    [self reverseGeocode:userLocation];
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
    [self reverseGeocode:userLocation];
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
    /**
     当前位置为中心
     */
    [self.mapView setCenterCoordinate:result.location animated:YES];
    [self configurationParams:result.location];
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"定位地址" message:[NSString stringWithFormat:@"%@",result.address] preferredStyle:1];
    UIAlertAction * alertAction = [UIAlertAction actionWithTitle:@"确定" style:0 handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:alertAction];
    [self presentViewController:alert animated:true completion:nil];
}

/**
 反地理编码
 */
- (void) reverseGeocode:(BMKUserLocation *)userLocation
{
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

- (void)dealloc {
    if (_mapView) {
        _mapView = nil;
    }
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
    
