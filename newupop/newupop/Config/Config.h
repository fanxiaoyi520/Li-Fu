//
//  ZFConstant.h
//  newupop
//
//  Created by Jellyfish on 2017/7/20.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#ifndef Config_h
#define Config_h


// 测试环境接口地址
//#define BASEURL @"https://utestapp.sinopayonline.com:8090/UGateWay/appService"
//#define BASEURL_XUNI @"https://utest.sinopayonline.com:8444/UGateWay/virtualCard" // 虚拟卡测试
//#define ReceiptsWebUrl @"http://test13.qtopay.cn/UGateWay/merchantReceiptServlet" ///小票网页//zxltodo
 //cn.qtopay.inhouse.zffkb


/////当前生产地址
#define BASEURL @"https://u.sinopayonline.com/UGateWay/appService"
#define BASEURL_XUNI @"https://u.sinopayonline.com/UGateWay/virtualCard" //虚拟卡
#define ReceiptsWebUrl @"https://u.sinopayonline.com/UGateWay/merchantReceiptServlet" ///小票网页
//

///网络请求时菊花
#define NetRequestText NSLocalizedString(@"加载中", @"加载中")
///网络请求失败
#define NetRequestError NSLocalizedString(@"网络请求失败", nil)
// 二维码
/// 扫码付款二维码Prefix(前辍）,用户输入金额
#define QRCODE_PREFIX_QUICKPAYORDERABROAD @"https://u.sinopayonline.com/UGateWay/scanCode?m="
#define QRCODE_PREFIX_QUICKPAYORDERABROAD2 @"https://u.sinopayonline.com/UGateWay/scanCode?s="
/// 扫码付款二维码Prefix(前辍）,固定金额
#define QRCODE_CONSTANT_PREFIX_QUICKPAYORDERABROAD @"https://u.sinopayonline.com/UGateWay/scanCode?payId="

// 加解密
#define TRIPLEDES_IV_QUICKPAYABROAD         @"01234567"                // 3DES的iv
#define TRIPLEDES_KEY_QRCODE_QUICKPAYABROAD @"J2OKyoMA0fcKROy51sWNhPpk"// 二维码解密3DES的key
#define TRIPLEDES_IV_QRCODE_QUICKPAYABROAD  @"omcZNJ4X"                // 二维码解密3DES的iv

///网络是否可用key
#define NETWORK_ISOK @"networkStatus"

///身份证号限制输入内容
#define IDNumLimitString @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

///是否设置支付密码
#define PayPwdAlreadySet [NSString stringWithFormat:@"setedPayPwd%@", [ZFGlobleManager getGlobleManager].userPhone]
///最后添加的银行卡的国家编号
#define ISOCOUNTRYCODELASTADD @"ISOCountryCodeLastAdd"
///最后消费的银行卡的国家编号
#define ISOCOUNTRYCODELASTPAY @"ISOCountryCodeLastPay"

///绑卡通知
#define BINDING_CARD_ALREADY @"banding_card_already"
///交易成功后通知
#define TRADE_SUCCESS @"trade_success"

///上次交易选的银行卡
#define LastTradeCardKey @"last_tradecard_key"


///用户姓名
#define UserName [NSString stringWithFormat:@"userName%@", [ZFGlobleManager getGlobleManager].userPhone]
///用户证件号
#define UserIdCardNum [NSString stringWithFormat:@"userIdCardNum%@", [ZFGlobleManager getGlobleManager].userPhone]
///用户证件类型
#define IdType [NSString stringWithFormat:@"idType%@", [ZFGlobleManager getGlobleManager].userPhone]

///是否可以更改用户姓名 0 可以
#define isCanChangeName [NSString stringWithFormat:@"isCanChangeName%@", [ZFGlobleManager getGlobleManager].userPhone]
///是否可以更改用户证件号
#define isCanChangeUserIdCardNum [NSString stringWithFormat:@"isCanChangeUserIdCardNum%@", [ZFGlobleManager getGlobleManager].userPhone]
///是否可以更改用户证件类型
#define isCanChangeIdType [NSString stringWithFormat:@"isCanChangeIdType%@", [ZFGlobleManager getGlobleManager].userPhone]

#endif /* Config_h */
