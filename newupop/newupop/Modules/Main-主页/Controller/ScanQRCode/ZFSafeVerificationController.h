//
//  ZFSafeVerificationController.h
//  newupop
//
//  Created by 中付支付 on 2017/12/20.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "ZFBankCardModel.h"
#import "ZFUPBankCardModel.h"

@interface ZFSafeVerificationController : ZFBaseViewController

///银行卡
@property (nonatomic, strong)ZFBankCardModel *bcModel;

///银行卡类型 1 信用卡  0 非信用卡
@property (nonatomic, assign)NSInteger cardType;
///认证类型 HK SG ..
@property (nonatomic, strong)NSString *verificationType;


@property (nonatomic, copy)NSString *orderId;

///收到验证码的手机号
@property (nonatomic, strong)NSString *phoneNumber;


///银行卡
@property (nonatomic, strong)ZFUPBankCardModel *upModel;

- (instancetype)initWithParams:(NSDictionary *)params;

@end
