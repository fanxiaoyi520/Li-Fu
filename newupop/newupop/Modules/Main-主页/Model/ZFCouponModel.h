//
//  ZFCouponModel.h
//  newupop
//
//  Created by 中付支付 on 2017/12/22.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFCouponModel : NSObject

///优惠类型 1 金额 2 打折
@property (nonatomic, copy)NSString *discountType;
///活动简介
@property (nonatomic, copy)NSString *activityIntroduction;
///优惠金额上限
@property (nonatomic, copy)NSString *maxDiscount;
///优惠券编号
@property (nonatomic, copy)NSString *couponId;
///优惠金额
@property (nonatomic, copy)NSString *discountAmt;
///使用条件金额
@property (nonatomic, copy)NSString *maxAmt;

- (void)setValue:(id)value forUndefinedKey:(NSString *)key;

@end
