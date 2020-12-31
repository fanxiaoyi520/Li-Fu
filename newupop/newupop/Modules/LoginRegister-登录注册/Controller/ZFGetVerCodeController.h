//
//  ZFGetVerCodeController.h
//  newupop
//
//  Created by 中付支付 on 2017/7/25.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"

@interface ZFGetVerCodeController : ZFBaseViewController

/// 0 找回登录密码   1 找回支付密码
@property (nonatomic, assign)NSInteger getCodeType;

@end
