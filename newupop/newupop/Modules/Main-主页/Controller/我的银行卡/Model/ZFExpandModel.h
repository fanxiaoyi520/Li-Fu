//
//  ZFExpandModel.h
//  newupop
//
//  Created by Jellyfish on 2017/7/25.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZFBankCardModel;

@interface ZFExpandModel : NSObject

/** 主文字 */
@property (nonatomic, copy) NSString *name;

/** 银行卡模型数组 */
@property (nonatomic, strong) NSMutableArray<ZFBankCardModel *> *dataArray;

///区分卡类型   000001 中付卡   000002 银联卡
@property (nonatomic, strong)NSString *channelType;

@end
