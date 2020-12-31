//
//  ZFSetLoginPwdController.h
//  newupop
//
//  Created by 中付支付 on 2017/7/21.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"

@interface ZFSetLoginPwdController : ZFBaseViewController

/// 0 注册时设置密码   1 个人中心修改密码  2 忘记密码设置密码
@property (nonatomic, assign)NSInteger type;

@end
