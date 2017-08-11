//
//  MapViewController.m
//  MapDemo
//
//  Created by apple on 2017/8/11.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CustomAnnotation.h"
@interface MapViewController ()<MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) CLLocationManager *locationManager;//位置管理器
@property (nonatomic, strong) CLGeocoder *geoCoder;//地理编码

@end

@implementation MapViewController
-(CLGeocoder *)geoCoder{
    if (!_geoCoder) {
        _geoCoder = [[CLGeocoder alloc] init];

    }
    return _geoCoder;
}
-(CLLocationManager *)locationManager{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
            [_locationManager requestAlwaysAuthorization];
        }
    }
    return _locationManager;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置代理
    self.mapView.delegate = self;
    /**
     *  MKMapTypeStandard = 0, // 标准
     MKMapTypeSatellite, // 卫星
     MKMapTypeHybrid, // 混合
     MKMapTypeSatelliteFlyover NS_ENUM_AVAILABLE(10_11, 9_0), // 3D立体卫星
     MKMapTypeHybridFlyover NS_ENUM_AVAILABLE(10_11, 9_0), // 3D立体混合
     */
    //设置地图的类型
    self.mapView.mapType = MKMapTypeStandard;
    //设置地图的操控项
    self.mapView.scrollEnabled = YES;//滚动
    self.mapView.zoomEnabled = YES;//缩放
    self.mapView.rotateEnabled = YES;//旋转
    //设置地图的显示项

    self.mapView.showsCompass = YES;//显示指南针
    self.mapView.showsScale = YES;//比例尺
    self.mapView.showsTraffic = YES;//显示交通
    self.mapView.showsPointsOfInterest = YES;//兴趣点
    self.mapView.showsBuildings = YES;//建筑物



    //显示用户的位置
    [self locationManager];

    // 只是在地图上, 添加一个蓝点 , 标示用户当前位置, 不会自动放大地图
    // 不会追踪用户的位置信息,
    //self.mapView.showsUserLocation = YES;

    // 设置用户追踪模式
    // 在地图上, 添加一个蓝点 , 标示用户当前位置, 会自动放大地图
    //  还会自动追踪用户的位置, (不灵光)
   // self.mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;

}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    // 添加大头针 MVC
    // 在地图上操作大头针,实际上是控制大头针数据模型
    // 添加大头针就是添加大头针数据模型
    // 删除大头针就是删除大头针数据模型

    //1、获取当前手指在地图上点击的位置
    CGPoint point = [[touches anyObject]locationInView:self.mapView];

    //2、把点坐标转换为经纬度
    CLLocationCoordinate2D center = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];

    //3、添加大头针到地图上
    CustomAnnotation *annotation = [self addAnnotationWithCoordinate:center Title:@"Stephen" SubTitle:@"周星驰的老铁"];
//    [self.mapView addAnnotation:annotation];

    //4、地理反编码
    CLLocation *location = [[CLLocation alloc]initWithLatitude:center.latitude longitude:center.longitude];
    [self.geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (!error) {
            CLPlacemark *placemark = [placemarks firstObject];
            annotation.title = placemark.locality;
            annotation.subtitle = placemark.name;
            NSLog(@"%@-----%@", placemark.locality, placemark.name);
        }
    }];
}

#pragma mark - 添加大头针的方法
-(CustomAnnotation *)addAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate Title:(NSString *)title SubTitle:(NSString *)subTitle{
    // 1. 创建大头针数据模型
    CustomAnnotation *annotation = [[CustomAnnotation alloc]init];
    annotation.coordinate = coordinate;
    annotation.title = title;
    annotation.subtitle = subTitle;

    // 2. 添加大头针数据模型
    [self.mapView addAnnotation:annotation];
    return annotation;
}




#pragma mark - MKMapViewDelegate
/**
 *  当地图获取到用户位置时调用
 *
 *  @param mapView      地图
 *  @param userLocation 大头针数据模型
 */
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    /**
     *  MKUserLocation 大头针数据模型
     *  location : 当前位置对象
     *  heading  : 当前朝向
     *  title    : 标题
     *  subtitle : 子标题
     */
    userLocation.title = @"Stephen到此一游";
    userLocation.subtitle = @"哈啊哈哈";

    //显示当前地图的中心, 在哪个具体的经纬度坐标 但是不会自动放大地图的比例
    //[self.mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];

    CLLocationCoordinate2D centerCoordinate = userLocation.location.coordinate;
    MKCoordinateSpan span = MKCoordinateSpanMake(0.027023, 0.018108);//跨度（经纬度的跨度，确定一个区域）
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);
    //设置地图显示的区域
    [self.mapView setRegion:region];


}
/**
 *  地图区域改变时调用
 *
 *  @param mapView  地图
 *  @param animated 动画
 */
-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    NSLog(@"%f----%f", mapView.region.span.latitudeDelta, mapView.region.span.longitudeDelta);
}
@end
