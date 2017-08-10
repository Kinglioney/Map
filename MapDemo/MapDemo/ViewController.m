//
//  ViewController.m
//  MapDemo
//
//  Created by apple on 2017/8/10.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#define isIOS(version) [[UIDevice currentDevice].systemVersion floatValue] >= version
@interface ViewController ()<CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
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
            //[self.locationManager requestAlwaysAuthorization];
            //1.4 请求在前台定位授权
            [self.locationManager requestWhenInUseAuthorization];

            if(isIOS(9.0)){
             /*------------------iOS9.0+定位适配--------------------*/
            //在iOS9.0中，在前台定位授权中，即使勾选了后台模式中的Location updates，也不会获取用户定位信息，解决方法如下
                _locationManager.allowsBackgroundLocationUpdates = YES;
            }
        }
    }
    return _locationManager;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    //2、使用位置管理者，开始更新用户信息
    //2.1开始更新用户位置信息
    //一旦我们调用了这个方法，就会在后台不断获取用户的位置信息然后告诉外界
    // 判断定位操作是否被允许
    if([CLLocationManager locationServicesEnabled]) {

        [self.locationManager startUpdatingLocation];
        //标准定位服务 GPS、WIFI、基站
        [self.locationManager startMonitoringSignificantLocationChanges];//显著定位变化，要求手机有电话模块
    }else{//提示用户无法进行定位操作
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"定位不成功 ,请确认开启定位" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];

}

}

#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    NSLog(@"定位到了");
    //

}
//当前定位授权状态发生改变的调用
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{

    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        {
            NSLog(@"用户未决定");

        }
            break;
        case kCLAuthorizationStatusRestricted:
        {
            NSLog(@"受限制");
        }
            break;
        case kCLAuthorizationStatusDenied:
        {
            NSLog(@"被拒绝");
            //判断当前设备是否支持定位，定位服务是否开启
            if (![CLLocationManager locationServicesEnabled]) {
                NSLog(@"真正被拒绝");
            }else{
                //iOS8.0+ 通过调用一个方法，来直接到达设置界面
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication]canOpenURL:url]) {
                    [[UIApplication sharedApplication]openURL:url];
                }
            }
        }
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            NSLog(@"前后台定位授权");
        }
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            NSLog(@"前台定位授权");
        }
            break;


        default:
            break;
    }
}
@end
