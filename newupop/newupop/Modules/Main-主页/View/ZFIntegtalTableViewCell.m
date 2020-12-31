//
//  ZFIntegtalTableViewCell.m
//  newupop
//
//  Created by 中付支付 on 2017/11/3.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFIntegtalTableViewCell.h"

@implementation ZFIntegtalTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createView];
    }
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    return self;
}

- (void)createView{
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 180, 14)];
//    _titleLabel.textColor = UIColorFromRGB(0x5eb1e3);
    _titleLabel.text = NSLocalizedString(@"积分抵扣", nil);
    _titleLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:_titleLabel];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_titleLabel.x, _titleLabel.bottom+9, 200, 14)];
    _timeLabel.textColor = [UIColor grayColor];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    //_timeLabel.text = @"2017-08-22 12:12:12";
    [self addSubview:_timeLabel];
    
    _integralLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-140, 0, 120, 25)];
    _integralLabel.centerY = self.height/2;
    _integralLabel.font = [UIFont systemFontOfSize:24];
//    _integralLabel.textColor = UIColorFromRGB(0xf58336);
    _integralLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_integralLabel];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    _integralLabel.centerY = self.height/2;
}

- (void)setIntegralModel:(IntegralModel *)integralModel{
    //交易时间
    NSString *payTime = integralModel.recCreateTm;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *payDate = [formatter dateFromString:payTime];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *payTimeStr = [formatter stringFromDate:payDate];
    
    _timeLabel.text = payTimeStr;
    _integralLabel.text = [NSString stringWithFormat:@"-%@", integralModel.useCredit];
}

@end
