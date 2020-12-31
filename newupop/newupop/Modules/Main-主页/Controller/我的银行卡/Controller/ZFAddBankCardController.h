//
//  ZFAddBankCardController.h
//  newupop
//
//  Created by 中付支付 on 2017/8/1.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"

@interface ZFAddBankCardController : ZFBaseViewController

///首次添加 yes  否则 no
@property (nonatomic, assign)BOOL isFirst;

/// 1 扫码枪银行卡  2 银联银行卡
@property (nonatomic, assign)NSInteger addType;

@end
