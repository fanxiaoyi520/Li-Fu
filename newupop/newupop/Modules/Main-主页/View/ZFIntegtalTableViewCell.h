//
//  ZFIntegtalTableViewCell.h
//  newupop
//
//  Created by 中付支付 on 2017/11/3.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IntegralModel.h"

@interface ZFIntegtalTableViewCell : UITableViewCell

///积分抵扣
@property (nonatomic, strong)UILabel *titleLabel;
///时间
@property (nonatomic, strong)UILabel *timeLabel;
///积分数
@property (nonatomic, strong)UILabel *integralLabel;

@property (nonatomic, strong)IntegralModel *integralModel;

@end
