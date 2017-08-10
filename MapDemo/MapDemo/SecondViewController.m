//
//  SecondViewController.m
//  MapDemo
//
//  Created by apple on 2017/8/10.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "SecondViewController.h"
#import <CoreLocation/CoreLocation.h>
#define isIOS(version) [[UIDevice currentDevice].systemVersion floatValue] >= version
@interface SecondViewController ()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (strong, nonatomic) IBOutlet UILabel *noticeLbl;


@end

@implementation SecondViewController
-(CLLocationManager *)locationManager{
    if (!_locationManager) {

        //1.1 创建位置管理
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;

        /*------------------iOS8.0+定位适配--------------------*/
        if(isIOS(8.0)){
            //1.2 设置过滤距离 每隔多少米定位一次
            _locationManager.distanceFilter = 100;
            //1.3 设置定位精度
            _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            //默认情况下是只能在前台获取用户位置信息，如果想要在后台获取用户的位置信息，必须勾选后台模式中的Location updates
            //请求在前后台定位授权
            [self.locationManager requestAlwaysAuthorization];
            //1.4 请求在前台定位授权
            //[self.locationManager requestWhenInUseAuthorization];


            if(isIOS(9.0)){
                /*------------------iOS9.0+定位适配--------------------*/
                //在iOS9.0中，在前台定位授权中，即使勾选了后台模式中的Location updates，也不会获取用户定位信息，解决方法如下
                _locationManager.allowsBackgroundLocationUpdates = YES;
            }
        }
    }
    return _locationManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //区域监听
    //判断当前设备是否支持区域监听(区域类型)
    if (![CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
        return;
    }
    //1、创建区域中心
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(22.284681, 114.158177);

    //2、创建区域半径
    CLLocationDistance distance = 1000.0;
    if(distance > self.locationManager.maximumRegionMonitoringDistance)
    {
        distance = self.locationManager.maximumRegionMonitoringDistance;
    }

    //3、创建区域
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:center radius:distance identifier:@"kRegionId"];

    //3、监听一个区域
    [self.locationManager startMonitoringForRegion:region];

    // 请求某个区域的状态
    // 不止可以获取到指定区域的状态, 而且当状态发生变化时, 也会调用对应的代理方法, 告诉我们
    [self.locationManager requestStateForRegion:region];

}

#pragma mark - CLLocationManagerDelegate
//进入监听区域调用
-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    NSLog(@"进入区域---%@", region.identifier);
    self.noticeLbl.text = @"进入指定区域了";

}
//离开监听区域调用
-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
    NSLog(@"离开区域---%@", region.identifier);
    self.noticeLbl.text = @"离开指定区域了";
}

//当前请求指定区域状态的回调
-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    /*CLRegionStateUnknown,
    CLRegionStateInside,
    CLRegionStateOutside
     */
    switch (state) {
        case CLRegionStateUnknown:
        {
            NSLog(@"未知区域");
        }
            break;

        case CLRegionStateInside:{
            self.noticeLbl.text = @"进入指定区域了";
        }
            break;


        case CLRegionStateOutside:{
            self.noticeLbl.text = @"离开指定区域了";
        }
            break;

        default:
            break;
    }
}
@end
