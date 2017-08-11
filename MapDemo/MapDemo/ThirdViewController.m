//
//  ThirdViewController.m
//  MapDemo
//  地理编码
//  Created by apple on 2017/8/10.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "ThirdViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ThirdViewController ()

@property (nonatomic, strong) CLGeocoder *geoCoder;//地理编码管理器

@end

@implementation ThirdViewController
-(CLGeocoder *)geoCoder{
    if (!_geoCoder) {
        _geoCoder = [[CLGeocoder alloc] init];
    }
    return _geoCoder;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}




#pragma mark - 地理编码
- (IBAction)geoCoder:(id)sender {
    NSString *addressStr = self.addressTextView.text;
    if(!addressStr) return;
    [self.geoCoder geocodeAddressString:addressStr completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        /* CLPlacemark: 地标对象
         * location: 对应的位置对象
         * name: 地址全称
         * locality: 城市名称
         * 按相关性进行排序
         */
        if (!error) {
            CLPlacemark *placemark = [placemarks firstObject];
            NSLog(@"经度 = %f 纬度 = %f", placemark.location.coordinate.latitude, placemark.location.coordinate.longitude);
            self.latitudeTF.text = @(placemark.location.coordinate.latitude).stringValue;
            self.longitudeTF.text = @( placemark.location.coordinate.longitude).stringValue;
        }
    }];
}

#pragma mark - 反地理编码
- (IBAction)reverseGeoCoder:(id)sender {
    CLLocationDegrees latitude = [self.latitudeTF.text floatValue];
    CLLocationDegrees longitude = [self.longitudeTF.text floatValue];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];

    [self.geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (!error) {
            CLPlacemark *placemark = [placemarks firstObject];

            self.addressTextView.text = [NSString stringWithFormat:@"%@", placemark.name];
        }

    }];
}




@end
