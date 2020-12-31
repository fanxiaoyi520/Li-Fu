//
//  LocationUtils.m
//  newupop
//
//  Created by 中付支付 on 2017/7/28.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "LocationUtils.h"
#import <UIKit/UIDevice.h>

#define IS_IOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)

@implementation LocationUtils

+ (instancetype)sharedInstance{
    static dispatch_once_t LocationManagerOnceToken;
    static LocationUtils *sharedInstance = nil;
    dispatch_once(&LocationManagerOnceToken, ^{
        sharedInstance = [[LocationUtils alloc] init];
    });
    return sharedInstance;
}

- (instancetype) init{
    self = [super init];
    
    if(self) {
        [self lm];
    }
    return self;
}

- (CLLocationManager *)lm{
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        DLog(@"没有定位权限--");
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _isShowTip = YES;
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"请您打开定位权限，否则无法使用此功能", nil) preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *confirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                // 去设置中心
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                    exit(1);
                }
            }];
            [alert addAction:cancel];
            [alert addAction:confirm];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil] ;
        });
    }
    
    if (!_lm) {
        _isShowTip = NO;
        if ([CLLocationManager locationServicesEnabled]) {
            if (nil == _lm) {
                _lm = [[CLLocationManager alloc]init];
                _lm.delegate = self;
                //设置定位精度
                _lm.desiredAccuracy = kCLLocationAccuracyHundredMeters;
                //设置位置更新的最小距离
                _lm.distanceFilter = 100.f;
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {//ios8之后点版本需要使用下面的方法才能定位。使用一个即可。
                    //[_lm requestAlwaysAuthorization];
                    [_lm requestWhenInUseAuthorization];
                }
            }
        }else{
            DLog(@"定位服务不可利用");
        }
    }
    return _lm;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    DLog(@"--%d", status);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    DLog(@"location %@",error);
    //    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"定位失败,请检查是否开启定位权限" preferredStyle:UIAlertControllerStyleAlert];
    //    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil];
    //    [alert addAction:confirm];
    //    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES
    //                                                                               completion:nil] ;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    _latitude = [NSString stringWithFormat:@"%3.5f",newLocation.coordinate.latitude];
    _longitude = [NSString stringWithFormat:@"%3.5f",newLocation.coordinate.longitude];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    // 设备的当前位置
    CLLocation *currLocation = [locations firstObject];
    //获取经纬度
    _latitude = [NSString stringWithFormat:@"%3.5f",currLocation.coordinate.latitude];
    _longitude = [NSString stringWithFormat:@"%3.5f",currLocation.coordinate.longitude];
    //    _latLon.text =[NSString stringWithFormat:@"lat %@,\nlong %@",_latitude,_longitude];
    //获取海拔 航向 速度
    DLog(@"经度：%@,纬度：%@,海拔：%f,航向：%f,行走速度：%f",_longitude,_latitude,currLocation.altitude,currLocation.course,currLocation.speed);
    CLGeocoder *geoCd = [[CLGeocoder alloc] init];
    [geoCd reverseGeocodeLocation:currLocation completionHandler:^(NSArray *array, NSError *error){
        if (array.count > 0){
            CLPlacemark *placemark = [array objectAtIndex:0];
            
            //获取国家
            _country = placemark.country;
            DLog(@"country -- %@", _country);
            _ISOCountryCode = placemark.ISOcountryCode;
            _BalanceISOCountryCode = placemark.ISOcountryCode;
            DLog(@"ISOcountryCode = %@", placemark.ISOcountryCode);
            
            _mustCode = placemark.ISOcountryCode;
            
            //获取城市
            _city = placemark.locality;
            if (!_city) {
                //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                _city = placemark.administrativeArea;
            }
            DLog(@"city = %@", _city);
        }
        else if (error == nil && [array count] == 0)
        {
            DLog(@"No results were returned.");
        }
        else if (error != nil)
        {
            DLog(@"An error occurred = %@", error);
        }
        [self stopLocation];
    }];
}


- (void)startLocation{
    [self.lm startUpdatingLocation];
}

- (void)stopLocation{
    [self.lm stopUpdatingLocation];
}

- (NSString *)ISOCountryCode{
    if (!_ISOCountryCode) {
        [self.lm startUpdatingLocation];
    }
    
    //澳门返回hk
    if ([_ISOCountryCode isEqualToString:@"MO"]) {
        _ISOCountryCode = @"HK";
    }
    
    //中国内地 返回上次交易地址 默认hk
    if ([_ISOCountryCode isEqualToString:@"CN"]) {
        NSString *rememberCode = [[NSUserDefaults standardUserDefaults] objectForKey:ISOCOUNTRYCODELASTPAY];
        if (rememberCode && rememberCode.length > 0) {
            _ISOCountryCode = rememberCode;
        } else {
            _ISOCountryCode = @"HK";
        }
    }
    
    //若定位失败 则返回上次交易的countrycode
    if (!_ISOCountryCode) {
        NSString *rememberCode = [[NSUserDefaults standardUserDefaults] objectForKey:ISOCOUNTRYCODELASTPAY];
        if (!rememberCode) {
            rememberCode = [[NSUserDefaults standardUserDefaults] objectForKey:ISOCOUNTRYCODELASTADD];
        }
        if (!rememberCode) {
            return @"HK";
        }
        return rememberCode;
    }
    
    return _ISOCountryCode;
}

- (NSString *)getLatitude{
    return _latitude == nil ? @"0.00000" : _latitude;
}

- (NSString *)getLongitude{
    return _longitude == nil ? @"0.00000" : _longitude;
}

- (NSString *)mustCode{
    return _mustCode;
}

@end
