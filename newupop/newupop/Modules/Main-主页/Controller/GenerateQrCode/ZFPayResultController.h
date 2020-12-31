//
//  ZFPayResultController.h
//  newupop
//
//  Created by 中付支付 on 2017/11/13.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "TradeModel.h"

@interface ZFPayResultController : ZFBaseViewController
///结果类型 0 有trademodel不用查  1 失败  2 只有orderID
@property (nonatomic, assign)NSInteger resultType;
///失败信息
@property (nonatomic, strong)NSString *errorMsg;
///成功模型
@property (nonatomic, strong)TradeModel *tradeModel;

///订单号
@property (nonatomic, strong)NSString *orderId;
///不用删除前面控制器
@property (nonatomic, assign)BOOL notRemoveVC;

@end
