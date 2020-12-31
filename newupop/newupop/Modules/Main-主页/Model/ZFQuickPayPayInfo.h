//
//  ZFQuickPayPayInfo.h
//  newupop
//
//  Created by 中付支付 on 2017/9/5.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFQuickPayPayInfo : NSObject
/// 商品名称
@property (nonatomic, copy)NSString *productName;
/// 商品描述（可空）
@property (nonatomic, copy)NSString *productDescription;
/// 商品金额（可空）
@property (nonatomic, copy)NSString *productPrice;
/// 第三方商户号（可空）
@property (nonatomic, copy)NSString *swMerchantNo;
/// 第三方终端号（可空）
@property (nonatomic, copy)NSString *swTerminalNo;
/// 货币种类
@property (nonatomic, copy)NSString *currencyType;
/// 订单唯一号（中付返回订单号）
@property (nonatomic, copy)NSString *webOrderId;
/// 手机号
@property (nonatomic, copy)NSString *mobile;

// 总部接口使用了以下属性
/// 付款二维码（由二维码解码得来）
@property (nonatomic, copy)NSString *QRCode;
/// 商户号(未加密,由二维码里截取后解密得来）
@property (nonatomic, copy)NSString *QRCodeMerchantInfoNoEncrypt;
/// 商户号(已3DES加密，由二维码里截取后解密后3DES加密得来）
@property (nonatomic, copy)NSString *QRCodeMerchantInfoEncrypted;
/// 二维码类型,1可变金额（用户输入金额），2固定金额  3银联二维码固定金额  4 银联二维码输入金额  5 url格式固定金额  6 URL格式输入金额
@property (nonatomic, copy)NSString *QRType;
/// 交易金额（用户输入,当地货币，单位：元）
@property (nonatomic, copy)NSString *payMoney;
/// 交易金额（转化后的金额，单位：分）
@property (nonatomic, copy)NSString *payMoney_Transformed;
/// 商户名
@property (nonatomic, copy)NSString *merName;
/// 商户所在国家（编号）
@property (nonatomic, copy)NSString *sysareaId;
/// 交易币种（序号）
@property (nonatomic, copy)NSString *txnCurr;
/// 扣账币种（序号）
@property (nonatomic, copy)NSString *billingCurr;
/// 扣账金额（服务器计算后返回，单位：分）
@property (nonatomic, copy)NSString *billingAmt;
/// 扣账金额（转化后的金额，单位：元）
@property (nonatomic, copy)NSString *billingAmt_Transformed;
/// 扣账汇率
@property (nonatomic, copy)NSString *billingRate;
/// 接入唯一订单号
@property (nonatomic, copy)NSString *inTradeOrderNo;
/// 订单有效期
@property (nonatomic, copy)NSString *payTimeout;
/// 银行卡号（明文的卡号）
@property (nonatomic, copy)NSString *accNo;
/// 银行卡号（已3DES加密，解密后使用accNo字段保存），删除（解绑）卡时需要传此字段
@property (nonatomic, copy)NSString *cardNumEncrypted;
/// 银行卡序号
@property (nonatomic, copy)NSString *cardSerialNum;
/// 银行卡名称
@property (nonatomic, copy)NSString *cardName;
/// 银行卡类型
@property (nonatomic, copy)NSString *cardType;
/// 付款返回代码（若返回0支付成功，不需要重复查询，若返回3跳转发起查询，其它情况皆属于失败情况）
@property (nonatomic, copy)NSString *payResultCode;
/// 付款返回信息
@property (nonatomic, copy)NSString *payResultMSG;

///upopOrderId
@property (nonatomic, copy)NSString *upopOrderId;

///优惠金额
@property (nonatomic, strong)NSString *discountValue;
///优惠币种
@property (nonatomic, strong)NSString *discountCurr;
///积分金额
@property (nonatomic, strong)NSString *creditAmt;
///积分币种
@property (nonatomic, strong)NSString *creditCurr;

///终端号
@property (nonatomic, strong)NSString *termCode;
///扣款银行
@property (nonatomic, strong)NSString *bankName;
///订单时间
@property (nonatomic, strong)NSString *payTime;
///交易参考号
@property (nonatomic, strong)NSString *queryId;
///使用积分
@property (nonatomic, strong)NSString *useCredit;


///商户id
@property (nonatomic, strong)NSString *merId;

@end
