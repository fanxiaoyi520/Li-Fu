//
//  ZFCouponModel.m
//  newupop
//
//  Created by 中付支付 on 2017/12/22.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFCouponModel.h"

@implementation ZFCouponModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"activityId"]) {
        _couponId = value;
    }
}


@end
