//
//  ZFHeadScrollviewViewController.h
//  newupop
//
//  Created by Jellyfish on 2017/11/6.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "YZDisplayViewController.h"

typedef NS_ENUM(NSInteger, ZFHeadScrollviewType) {
    ZFHeadScrollviewTypeUpan = 0,   // 优计划
    ZFHeadScrollviewTypeMyCoupon,   // 我的优惠券
};

@interface ZFHeadScrollviewViewController : YZDisplayViewController

- (instancetype)initWithHeadType:(ZFHeadScrollviewType)headType;

@end
