//
//  ZFBankCardModel.h
//  newupop
//
//  Created by Jellyfish on 2017/7/25.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFBCOpenedModel.h"

@interface ZFBankCardModel : NSObject

/** logo */
@property (nonatomic, copy) NSString *logoStr;
/** 银行名称 */
@property (nonatomic, copy) NSString *bankName;
/** 卡类型 1借记卡 2信用卡 */
@property (nonatomic, copy) NSString *cardType;
/** 加密卡号 */
@property (nonatomic, copy) NSString *encryCardNo;
/** 卡号 */
@property (nonatomic, copy) NSString *cardNo;
/** 序号 */
@property (nonatomic, copy) NSString *serialNumber;
/** 国家区域 */
@property (nonatomic, copy) NSString *sysareaId;

/** 模型cell高度 */
@property (nonatomic, assign) CGFloat rowHeight;

///是否选中
@property (nonatomic, strong)NSString *isSelect;

///卡序列
@property (nonatomic, strong)NSString *paymentOrder;
///卡id
@property (nonatomic, strong)NSString *cardId;
///区分卡类型   000001 中付卡   000002 银联卡
@property (nonatomic, strong)NSString *channelType;

///英文名
@property (nonatomic, strong)NSString *bankNameLog;

///余额不足  1 不足
@property (nonatomic, strong)NSString *underbalance;

/// 开通地区情况
@property (nonatomic, strong)ZFBCOpenedModel *openCountry;

/// 预留手机号码
@property (nonatomic, strong)NSString *phoneNumber;

@end
