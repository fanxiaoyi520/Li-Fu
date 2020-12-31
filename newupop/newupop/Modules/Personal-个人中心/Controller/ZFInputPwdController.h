//
//  ZFInputPwdController.h
//  newupop
//
//  Created by 中付支付 on 2017/7/26.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"

@interface ZFInputPwdController : ZFBaseViewController

/// 0 设置支付密码  1 修改支付密码  2 找回支付密码  3 二次绑卡验证支付密码 4 首页设置密码 5 使用优惠券设置支付密码
@property (nonatomic, assign)NSInteger inputType;
///第几次输入
@property (nonatomic, assign)NSInteger inputCount;
///上页传来的密码
@property (nonatomic, strong)NSString *firstPwd;

@end
