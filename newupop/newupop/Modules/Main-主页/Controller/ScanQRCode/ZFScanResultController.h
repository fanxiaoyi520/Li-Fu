//
//  ZFScanResultController.h
//  newupop
//
//  Created by 中付支付 on 2017/8/29.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "ZFQuickPayPayInfo.h"

@interface ZFScanResultController : ZFBaseViewController

@property (nonatomic, strong)ZFQuickPayPayInfo *quickPayPayInfo;
///二维码字符串
@property (nonatomic, strong)NSString *resultStr;

@end
