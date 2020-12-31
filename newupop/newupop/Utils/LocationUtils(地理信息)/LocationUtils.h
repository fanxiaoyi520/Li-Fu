//
//  LocationUtils.h
//  newupop
//
//  Created by 中付支付 on 2017/7/28.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationUtils : NSObject <CLLocationManagerDelegate>
@property (nonatomic, strong)CLLocationManager *lm;
@property (nonatomic, strong)NSString *latitude;
@property (nonatomic, strong)NSString *longitude;
///所在国家
@property (nonatomic, strong)NSString *country;
///所在城市
@property (nonatomic, strong)NSString *city;
///国家代码
@property (nonatomic, strong)NSString *ISOCountryCode;
@property (nonatomic, strong)NSString *BalanceISOCountryCode;

///是否显示提示
@property (nonatomic, assign)BOOL isShowTip;

///马来和新加坡才能交易 2018-11-7
@property (nonatomic, strong)NSString *mustCode;

+ (instancetype)sharedInstance; // 获取此类的对象（类方法）
- (void)startLocation; // 应用启动时调用
- (void)stopLocation; // 应用进入后台时调用

- (NSString *)getLatitude;
- (NSString *)getLongitude;
@end
