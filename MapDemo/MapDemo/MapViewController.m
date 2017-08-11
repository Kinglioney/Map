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

#define kPinViewId @"kPinViewId"
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
     UIBarButtonItem *rightBarButtonItem1 = [[UIBarButtonItem alloc] initWithTitle:@"绘制轨迹" style:UIBarButtonItemStylePlain target:self action:@selector(startNav)];
    
    UIBarButtonItem *rightBarButtonItem2 = [[UIBarButtonItem alloc] initWithTitle:@"开始导航" style:UIBarButtonItemStylePlain target:self action:@selector(startNav)];
    self.navigationItem.rightBarButtonItems = @[rightBarButtonItem1,rightBarButtonItem2];

    /*********************地图属性的设置*******************************/
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

#pragma mark - 开始导航
-(void)startNav{

    [self.geoCoder geocodeAddressString:@"深圳" completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (!error) {
             CLPlacemark *beginclPL = [placemarks firstObject];
            [self.geoCoder geocodeAddressString:@"北京" completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                if (!error) {
                    CLPlacemark *endclPL = [placemarks firstObject];
                    [self beginNavWithBeginPL: beginclPL endPL:endclPL];
                }
            }];


        }
    }];



}

#pragma mark - 根据起点和终点进行导航
-(void) beginNavWithBeginPL:(CLPlacemark *)beginclPL endPL:(CLPlacemark *)endclPL{
    //存放起点和终点
    //1、创建起点信息
    MKPlacemark *beginPL = [[MKPlacemark alloc] initWithPlacemark:beginclPL];
    MKMapItem *beginItem = [[MKMapItem alloc] initWithPlacemark:beginPL];

    //2、创建起点信息
    MKPlacemark *endPL = [[MKPlacemark alloc] initWithPlacemark:endclPL];
    MKMapItem *endItem = [[MKMapItem alloc] initWithPlacemark:endPL];


    NSArray *items = @[beginItem, endItem];

    //启动参数设置: 地图类型、导航模式
    NSDictionary *dic = @{
                          MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving,
                          MKLaunchOptionsMapTypeKey : @(MKMapTypeStandard),
                          MKLaunchOptionsShowsTrafficKey : @(YES)

                          };

    //调用系统的API进行导航
    [MKMapItem openMapsWithItems:items launchOptions:dic];


    /*********************************获取导航信息********************/
    // 创建一个获取导航数据信息的请求
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = beginItem;
    request.destination = endItem;
    // 创建一个获取导航路线的对象
    MKDirections *direction = [[MKDirections alloc] initWithRequest:request];
    // 使用导航路线对象, 开始请求, 获取导航路线信息数据
    /**
     *  MKDirectionsResponse
        routes : 路线数组 <MKRoute>
     */
    
    /**
     *  MKRoute
        name : 路线名称
        advisoryNotices : 警告信息
        distance : 路线距离
        expectedTravelTime : 预期时间
        transportType : 通行方式
        polyline : 几何路线的数据模型
        steps : 行走的步骤 <MKRouteStep.
     */

    /**
     *  MKRouteStep
     *  instructions  行走提示
     *  notice : 警告
     *  polyline : 几何路线数据模型
     *  distance : 距离
     */
    [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        if(!error){
                NSLog(@"成功获取导航信息");
                [response.routes enumerateObjectsUsingBlock:^(MKRoute * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSLog(@"路线名称---%@ 距离----%f", obj.name, obj.distance);
                [obj.steps enumerateObjectsUsingBlock:^(MKRouteStep * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSLog(@"行走提示: %@", obj.instructions);
                }];
            }];
        }
    }];
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

/**
 *  当我们添加一个大头针数据模型时，地图就会调用该方法来获取对应的大头针视图
 *
 *  @param mapView  地图
 *  @param annotation 大头针数据模型
 *  @return 大头针视图
 *  如果这个方法没有实现或者返回nil，系统就会使用自带的大头针视图
 */
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    //如果想要自定义大头针视图，要么使用MKAnnotationView,或者MKAnnotationView的子类
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:kPinViewId];
    if (!annotationView) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kPinViewId];
    }
    annotationView.annotation = annotation;

    //自定义大头针视图
    //1、设置大头针的图片
    annotationView.image = [UIImage imageNamed: @"category_1"];

    //2、设置大头针弹框
    annotationView.canShowCallout = YES;
    //3、设置添加大头针时的偏移量
    annotationView.centerOffset = CGPointMake(10, 10);

    //4、设置弹框的偏移量
    annotationView.calloutOffset = CGPointMake(-10, -5);

    //5、设置弹框左边的视图
    UIImageView *leftImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    leftImageView.image = [UIImage imageNamed:@"eason"];
    annotationView.leftCalloutAccessoryView = leftImageView;


    return annotationView;
}
/**
 *  选中大头针视图调用
 *
 *  @param mapView  地图
 *  @param view 大头针视图
 */
-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    NSLog(@"选中----%@", view.annotation.title);
}
/**
 *  取消选中大头针视图调用
 *
 *  @param mapView  地图
 *  @param view 大头针视图
 */
-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{
    NSLog(@"取消选中----%@", view.annotation.title);
}
/*
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    // MKPinAnnotationView 大头针也有重复利用机制
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kPinViewId];
    if (!pinView) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kPinViewId];
    }
    //重新设置一次大头针数据模型 防止重复利用时数据出错
    pinView.annotation = annotation;

    //设置大头针可以弹框
    pinView.canShowCallout = YES;

    //设置大头针的颜色
    pinView.pinTintColor = [UIColor greenColor];

    //设置大头针的下落动画
    pinView.animatesDrop = YES;


    return pinView;
}
 */
@end
