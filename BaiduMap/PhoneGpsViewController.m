//
//  PhoneGpsViewController.m
//  BaiduMap
//
//  Created by Macx on 2017/11/28.
//  Copyright © 2017年 Macx. All rights reserved.
//

#import "PhoneGpsViewController.h"

#import "BNRoutePlanModel.h"
#import "BNCoreServices.h"
#import "BNaviModel.h"

@interface PhoneGpsViewController ()<BNNaviUIManagerDelegate,BNNaviRoutePlanDelegate>

@end

@implementation PhoneGpsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self startCalculateNavi];
}

#pragma mark 发起导航算路（起点和重点都放在这个方法里计算规划路径）
- (void)startCalculateNavi
{
    //***节点数组***
    NSMutableArray *nodesArray = [[NSMutableArray alloc] initWithCapacity:2];
    
    //***起点***
    //获得当前定位
    CLLocation *myLocation = [BNCoreServices_Location getLastLocation];
    
    BNRoutePlanNode *startNode=[[BNRoutePlanNode alloc] init];
    
    startNode.pos = [[BNPosition alloc] init];
    startNode.pos.x = myLocation.coordinate.longitude;
    startNode.pos.y = myLocation.coordinate.latitude;
    startNode.pos.eType = BNCoordinate_OriginalGPS;
    
    //模拟定位点
    //    BNRoutePlanNode *startNode = [[BNRoutePlanNode alloc] init];
    //    startNode.pos = [[BNPosition alloc] init];
    //    startNode.pos.x = 113.936392;
    //    startNode.pos.y = 22.547058;
    //    startNode.pos.eType = BNCoordinate_BaiduMapSDK;
    
    //将起始点加入到节点数组中
    [nodesArray addObject:startNode];
    
    //***终点***
    BNRoutePlanNode *endNode = [[BNRoutePlanNode alloc] init];
    endNode.pos = [[BNPosition alloc] init];
    endNode.pos.x = 114.077075;
    endNode.pos.y = 22.543634;
    endNode.pos.eType = BNCoordinate_BaiduMapSDK;
    
    [nodesArray addObject:endNode];
    
    //***发起路径规划***
    [BNCoreServices_RoutePlan startNaviRoutePlan:BNRoutePlanMode_Recommend naviNodes:nodesArray time:nil delegete:self userInfo:nil];
}

#pragma mark 算路成功回调
-(void)routePlanDidFinished:(NSDictionary *)userInfo{
    NSLog(@"算路成功");
    //路径规划成功，开始导航
    [BNCoreServices_UI showPage:BNaviUI_NormalNavi delegate:self extParams:nil];
}

-(void)routePlanDidFailedWithError:(NSError *)error andUserInfo:(NSDictionary *)userInfo{
    
    NSLog(@"导航失败");
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
