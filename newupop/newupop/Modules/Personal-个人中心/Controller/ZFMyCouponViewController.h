//
//  ZFMyCouponViewController.h
//  newupop
//
//  Created by Jellyfish on 2017/11/6.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"

typedef NS_ENUM(NSInteger, ZFCouponUseType) {
    ZFCouponUseTypeNotUse = 1,  // 未使用
    ZFCouponUseTypeUsed,        // 已使用
    ZFCouponUseTypeExpired,     // 已过期
};

@interface ZFMyCouponViewController : ZFBaseViewController

@end
