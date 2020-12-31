//
//  ZFRecentTradeView.h
//  newupop
//
//  Created by 中付支付 on 2017/11/3.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TradeModel.h"

@protocol ZFRecentTradeViewDelegate <NSObject>

@optional
// 交易记录点击
- (void)didClickTradeRecordBtn;
// 查看详情按钮点击
- (void)didClickDetailsBtn;

@end

@interface ZFRecentTradeView : UIView

/** LotteryCategoryCell 代理 */
@property (nonatomic, weak) id <ZFRecentTradeViewDelegate> delegate;

@property (nonatomic, strong)TradeModel *tradeModel;
///类型标志
@property (nonatomic, strong)UIImageView *markIV;
///商户名称
@property (nonatomic, strong)UILabel *payType;
///交易时间
@property (nonatomic, strong)UILabel *payTime;
///产品金额
@property (nonatomic, strong)UILabel *productAmount;
///扣款金额
@property (nonatomic, strong)UILabel *chargeAmount;
///查看详情
@property (nonatomic, strong)UIButton *detailBtn;
///暂无订单底部
@property (nonatomic, strong)UIView *noTradeView;


@end
