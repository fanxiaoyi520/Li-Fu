//
//  ZFMainViewController.h
//  newupop
//
//  Created by Jellyfish on 2017/7/20.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"

@interface ZFMainViewController : ZFBaseViewController

typedef NS_ENUM(NSInteger, MainOperationType) {
    MainOperationTypeScan = 0,  // 扫一扫付款
    MainOperationTypeQrCode,      // 付款码付款
    MainOperationTypeMyBankCard,    // 我的银行卡
};



@end

