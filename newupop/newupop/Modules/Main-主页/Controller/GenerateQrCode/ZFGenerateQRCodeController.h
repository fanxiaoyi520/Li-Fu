//
//  ZFGenerateQRCodeController.h
//  newupop
//
//  Created by 中付支付 on 2017/8/2.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"

@interface ZFGenerateQRCodeController : ZFBaseViewController

@property (nonatomic, strong)NSString *passWord;
/// 0 从首页调过来  1 从优惠券跳过来
@property (nonatomic, assign)NSInteger fromType;
/// 优惠券id
@property (nonatomic, strong)NSString *couponID;


@end
