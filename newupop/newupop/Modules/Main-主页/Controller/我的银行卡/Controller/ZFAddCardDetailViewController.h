//
//  ZFAddCardDetailViewController.h
//  newupop
//
//  Created by Jellyfish on 2017/12/20.
//  Copyright © 2017年 中付支付. All rights reserved.
//  添加银行卡-银行卡详情

#import "ZFBaseViewController.h"

@interface ZFAddCardDetailViewController : ZFBaseViewController

typedef NS_ENUM(NSInteger, BankCardType) {
    BankCardTypeDebit = 0,  // 借记卡
    BankCardTypeCredit, // 信用卡
};

typedef NS_ENUM(NSInteger, PickViewType) {
    PickViewTypeIdType,      // 证件类型
    PickViewTypeCountryCode,   // 区号
};

- (instancetype)initWithBankCardType:(BankCardType)type cardNo:(NSString *)cardNo;

@end
