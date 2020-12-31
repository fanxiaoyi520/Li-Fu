//
//  ZFTradeDetaiController.h
//  newupop
//
//  Created by 中付支付 on 2017/9/7.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "TradeModel.h"

@interface ZFTradeDetaiController : ZFBaseViewController

/// 0 交易记录  
@property (nonatomic, assign)NSInteger fromType;

@property (nonatomic, strong)TradeModel *tradeModel;

///交易类型 PER 交易  PVR 撤销
@property (nonatomic, strong)NSString *txnType;

//@property (nonatomic, copy)NSString *startDate;

@end
