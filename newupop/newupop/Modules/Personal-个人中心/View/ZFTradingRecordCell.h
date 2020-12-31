//
//  ZFTradingRecordCell.h
//  newupop
//
//  Created by 中付支付 on 2017/8/4.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TradeModel.h"

@interface ZFTradingRecordCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;

///公司logo
@property (nonatomic, strong)UIImageView *logoImageView;
///公司名称
@property (nonatomic, strong)UILabel *companyName;
///时间
@property (nonatomic, strong)UILabel *timeLabel;
///产品金额
//@property (nonatomic, strong)UILabel *productMoney;
///扣款金额
@property (nonatomic, strong)UILabel *payMoney;

///交易model
@property (nonatomic, strong)TradeModel *tradeModel;

@end
