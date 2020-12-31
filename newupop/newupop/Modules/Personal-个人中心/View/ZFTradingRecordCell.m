//
//  ZFTradingRecordCell.m
//  newupop
//
//  Created by 中付支付 on 2017/8/4.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFTradingRecordCell.h"

@implementation ZFTradingRecordCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *ID = @"ZFTradingRecordCell";
    ZFTradingRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[ZFTradingRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createView];
    }
    
    return self;
}

- (void)createView{
    //图标
    _logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 36, 36)];
    _logoImageView.image = [UIImage imageNamed:@"avatar_default"];
    [self addSubview:_logoImageView];
    
    //公司
    _companyName = [[UILabel alloc] initWithFrame:CGRectMake(_logoImageView.right+10, 10, SCREEN_WIDTH, 23)];
    _companyName.font = [UIFont systemFontOfSize:12];
    _companyName.textColor = UIColorFromRGB(0x313131);
    [self addSubview:_companyName];
    
    //时间
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_companyName.x, _companyName.bottom, 110, 23)];
    _timeLabel.textColor = ZFAlpColor(0, 0, 0, 0.6);
    _timeLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:_timeLabel];
    
    // 扣款金额
    _payMoney = [[UILabel alloc] initWithFrame:CGRectMake(_timeLabel.right, 0, SCREEN_WIDTH-_timeLabel.right-15, 66)];
    _payMoney.textColor = ZFAlpColor(0, 0, 0, 0.6);
    _payMoney.font = [UIFont boldSystemFontOfSize:14];
    _payMoney.textAlignment = NSTextAlignmentRight;
    [self addSubview:_payMoney];
}

- (void)setTradeModel:(TradeModel *)tradeModel{ 
    _logoImageView.image = [UIImage imageNamed:[SmallUtils getImageWitCode:tradeModel.merType]];
    _companyName.text = tradeModel.merName;
    _timeLabel.text = [self getFormatterTimeStr:tradeModel.orderTime];
    NSString *billingCurr = [SmallUtils transformCurrencyNum2SymbolString:tradeModel.billingCurr];
//    if (billingCurr.length < 1) {
//        billingCurr = tradeModel.billingCurr;
//    }
    //"txnType":"PER" 交易    "txnType":"PVR" 撤销
    NSString *character = @"-";
    if ([tradeModel.txnType isEqualToString:@"PVR"]) {
        character = @"+";
    }
    _payMoney.text = [NSString stringWithFormat:@"%@ %@  %.2f", character, billingCurr, [tradeModel.billingAmt doubleValue]/100];
}

- (NSString *)getFormatterTimeStr:(NSString *)timeStr{
    NSDateFormatter *fm = [[NSDateFormatter alloc] init];
    [fm setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *date = [fm dateFromString:timeStr];
    [fm setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateStr = [fm stringFromDate:date];
    NSArray *timeArr = [dateStr componentsSeparatedByString:@" "];
    NSArray *timeArr1 = [timeArr[0] componentsSeparatedByString:@"-"];
    NSString *result = [NSString stringWithFormat:@"%@-%@ %@", timeArr1[1], timeArr1[2], timeArr[1]];
    
    return result;
}

@end
