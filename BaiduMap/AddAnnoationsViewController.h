//
//  AddAnnoationsViewController.h
//  BaiduMap
//
//  Created by Macx on 2017/11/28.
//  Copyright © 2017年 Macx. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <BaiduMapAPI_Map/BMKMapComponent.h>

#import <BaiduMapAPI_Location/BMKLocationComponent.h>

#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import "BMKClusterManager.h"

#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>

@interface AddAnnoationsViewController : UIViewController<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate>

@end
