//
//  ZFSuccessController.h
//  newupop
//
//  Created by 中付支付 on 2017/7/26.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"

@interface ZFSuccessController : ZFBaseViewController
/// 0 设置支付密码  1 修改支付密码  2 找回支付密码  3 忘记登录密码
@property (nonatomic, assign)NSInteger successType;

@end
