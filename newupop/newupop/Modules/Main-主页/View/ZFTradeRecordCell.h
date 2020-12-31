//
//  ZFTradeRecordCell.h
//  newupop
//
//  Created by Jellyfish on 2017/7/21.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TradeModel.h"

@protocol ZFTradeRecordCellDelegate <NSObject>

@optional
// 交易记录点击
- (void)didClickTradeRecordBtn;
// 查看详情按钮点击
- (void)didClickDetailsBtn;

@end


@interface ZFTradeRecordCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;


/** LotteryCategoryCell 代理 */
@property (nonatomic, weak) id <ZFTradeRecordCellDelegate> delegate;

@property (nonatomic, strong)TradeModel *tradeModel;

///交易类型
@property (nonatomic, strong)UILabel *payType;
///交易时间
@property (nonatomic, strong)UILabel *payTime;
///产品金额
@property (nonatomic, strong)UILabel *productAmount;
///扣款金额
@property (nonatomic, strong)UILabel *chargeAmount;
///交易地址
@property (nonatomic, strong)UILabel *address;


@end
