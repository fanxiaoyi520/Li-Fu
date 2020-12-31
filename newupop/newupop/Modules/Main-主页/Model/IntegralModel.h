//
//  IntegralModel.h
//  newupop
//
//  Created by 中付支付 on 2017/11/3.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IntegralModel : NSObject

///
@property (nonatomic, strong)NSString *termCode;
///积分消费修改日期
@property (nonatomic, strong)NSString *recUpdateTm;
///当前总积分
@property (nonatomic, strong)NSString *currTotalCredit;
///商户号
@property (nonatomic, strong)NSString *merCode;
///用户id
@property (nonatomic, strong)NSString *userId;
///积分消费日期
@property (nonatomic, strong)NSString *recCreateTm;
///积分类型
@property (nonatomic, strong)NSString *creditType;
///消费后的总积分
@property (nonatomic, strong)NSString *useTotalCredit;
///订单号
@property (nonatomic, strong)NSString *orderNumber;
///使用积分
@property (nonatomic, strong)NSString *useCredit;

@end
