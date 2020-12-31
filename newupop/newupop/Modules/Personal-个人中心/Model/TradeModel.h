//
//  TradeModel.h
//  newupop
//
//  Created by 中付支付 on 2017/8/4.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TradeModel : NSObject

///产品金额
@property (nonatomic, strong)NSString *txnAmt;
///产品币种
@property (nonatomic, strong)NSString *txnCurr;
///扣账金额
@property (nonatomic, strong)NSString *billingAmt;
///商户订单号
@property (nonatomic, strong)NSString *orderId;
///银行名称
@property (nonatomic, strong)NSString *bankName;
///银行卡类型
@property (nonatomic, strong)NSString *cardType;
///银行卡号
@property (nonatomic, strong)NSString *cardNum;
///商户号
@property (nonatomic, strong)NSString *merId;
///商户名称
@property (nonatomic, strong)NSString *merName;
///终端号
@property (nonatomic, strong)NSString *termCode;
///扣账币种
@property (nonatomic, strong)NSString *billingCurr;
///订单时间
@property (nonatomic, strong)NSString *orderTime;
///
@property (nonatomic, strong)NSString *merType;

///使用积分
@property (nonatomic, strong)NSString *useCredit;
///积分抵扣
@property (nonatomic, strong)NSString *creditAmt;
///交易参考号
@property (nonatomic, strong)NSString *serialNumber;

///交易状态
@property (nonatomic, strong)NSString *status;
///扣账汇率
@property (nonatomic, strong)NSString *billingRate;
///交易银行卡序号
@property (nonatomic, strong)NSString *cardSerialNumber;

///优惠券信息
@property (nonatomic, strong)NSString *couponDes;

///交易币种订单金额
@property (nonatomic, strong)NSString *billingCurrTxnAmt;
///订单币种使用积分金额
@property (nonatomic, strong)NSString *txnCurrCreditAmt;
///交易币种折扣金额
@property (nonatomic, strong)NSString *billingCurrdiscountAmt;

/** 按月归类：交易月份 */
@property(nonatomic, copy) NSString *tradeMonth;

///交易类型
@property (nonatomic, strong)NSString *txnType;


@end
