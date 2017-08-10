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

@property (nonatomic, strong) CLLocation *lastLocation;

@property (weak, nonatomic) IBOutlet UIImageView *compassImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.locationManager startUpdatingHeading];
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

//获取当前设备的朝向
-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    NSLog(@"11111");
    /*
     ** CLHeading
     *  trueHeading: 距离磁北方向的角度
     *  headingAccuracy: 如果是负值，代表当前位置数据不可用
     */
    if(newHeading.headingAccuracy < 0) return;
    //1、获取设备的朝向
    CLLocationDirection angle = newHeading.magneticHeading;
    //1.1 将角度转换为弧度
    float radius = angle/180 * M_PI;
    //2、设置罗盘转动
    [UIView animateWithDuration:0.5 animations:^{
        self.compassImageView.transform = CGAffineTransformMakeRotation(-radius);
    }];


}

//获取用户的位置信息更新
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    NSLog(@"定位到了");
    //按时间排序 获取最新的一个位置
    CLLocation *latestLocation = [locations lastObject];
    /*
     Coordinate : 坐标的经纬度
     altitude   : 海拔
     horizontalAccuracy : 如果是负值，代表当前位置数据不可用
     verticalAccuracy   : 如果是负值，代表当前海拔数据不可用
     cours      :  航向（0.0---359.9）
     speed      :  速度
     floor      :  楼层
     distanceFromLocation : 计算两个坐标点之间的直线距离
     */
    if (latestLocation.horizontalAccuracy < 0) return;
    //1、确定当前航向
    NSInteger index = (int)latestLocation.course / 90;

    NSArray *courseArr = @[@"北偏东",@"东偏南",@"南偏西",@"西偏北"];

    NSString *courseStr = courseArr[index];

    //2、确定偏离角度
    NSInteger angle = (int)latestLocation.course % 90;
    if (angle == 0) {//代表正方向
        courseStr = [@"正" stringByAppendingString:[courseStr substringToIndex:1]];
    }

    //3、确定行走高度
    float distance = 0;
    if(_lastLocation){
        distance = [latestLocation distanceFromLocation:_lastLocation];

    }
    _lastLocation = latestLocation;

    NSString *noticeStr = nil;
    if (angle) {
        noticeStr = [NSString stringWithFormat:@"%@ %zd 度方向, 移动了 %f 米", courseStr, angle, distance];
    }else{
        noticeStr = [NSString stringWithFormat:@"%@ 方向, 移动了 %f 米", courseStr, distance];
    }


    NSLog(@"%@", noticeStr);

}
//定位失败调用
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"定位失败");
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
