//
//  ZFUPBankCardModel.h
//  newupop
//
//  Created by Jellyfish on 2017/12/25.
//  Copyright © 2017年 中付支付. All rights reserved.
//  银联国际银行卡模型

#import <Foundation/Foundation.h>

@interface ZFUPBankCardModel : NSObject

@property (nonatomic, strong)NSArray<NSString *> *cvm;

@property (nonatomic, copy)NSString *tncURL;

@property (nonatomic, copy)NSString *enrolID;

@property (nonatomic, copy)NSString *tncID;

@end
