//
//  ZFValidatePwdController.h
//  newupop
//
//  Created by 中付支付 on 2017/11/8.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"

@interface ZFValidatePwdController : ZFBaseViewController

/// 0 从首页调过来  1 从优惠券跳过来  2 添加银行卡 3 
@property (nonatomic, assign)NSInteger fromType;
/// 优惠券id
@property (nonatomic, strong)NSString *couponID;

@end
