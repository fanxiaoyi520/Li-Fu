//
//  TradeSectionModel.h
//  newupop
//
//  Created by Jellyfish on 2017/12/27.
//  Copyright © 2017年 中付支付. All rights reserved.
//  头部模型

#import <Foundation/Foundation.h>
#import "TradeModel.h"

@interface TradeSectionModel : NSObject

/** 月份 */
@property(nonatomic, copy) NSString *month;
/** 总笔数 */
@property(nonatomic, copy) NSString *totals;

/** 每月有多少笔 */
@property (nonatomic, strong) NSMutableArray<TradeModel *> *currentMonthArray;

@end
