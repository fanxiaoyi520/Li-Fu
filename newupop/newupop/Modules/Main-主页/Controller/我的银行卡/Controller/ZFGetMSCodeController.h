//
//  ZFGetMSCodeController.h
//  newupop
//
//  Created by 中付支付 on 2017/9/8.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "ZFBankCardModel.h"
#import "ZFUPBankCardModel.h"

@interface ZFGetMSCodeController : ZFBaseViewController
///银行卡类型 1 信用卡  0 非信用卡  2 银联卡
@property (nonatomic, assign)NSInteger cardType;

// 其他地区需要
@property (nonatomic, copy)NSString *orderId;

// 显示手机号码需要
@property (nonatomic, copy)NSString *phoneNumber;

// 其他地区必要参数
- (instancetype)initWithParams:(NSDictionary *)params;


// 银联国际需要
@property (nonatomic, copy)NSString *otpMethod;

// 银联国际必要参数
- (instancetype)initWithBankCardModel:(ZFBankCardModel *)bcModel UPBankCardModel:(ZFUPBankCardModel *)upModel;

///获取验证码状态  79时不用验证码
@property (nonatomic, strong)NSString *status;

// 是绑卡0 还是认证1
@property (nonatomic, assign)NSInteger fromType;

@end
