//
//  ZFTradeRecordCell.m
//  newupop
//
//  Created by Jellyfish on 2017/7/21.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFTradeRecordCell.h"

@implementation ZFTradeRecordCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *ID = @"ZFTradeRecordCell";
    ZFTradeRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[ZFTradeRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupSubviews];
    }
    return self;
}

/** 添加子控件 */
- (void)setupSubviews {
    // 类型标志
    UIImageView *markIV = [UIImageView new];
    markIV.frame = CGRectMake(20, 10, 24, 28);
    markIV.image = [UIImage imageNamed:@"home_record"];
    [self addSubview:markIV];
    
    // 交易类型
    _payType = [UILabel new];
    _payType.text = NSLocalizedString(@"快捷支付", nil);
    _payType.textColor = [UIColor blackColor];
    _payType.font = [UIFont systemFontOfSize:12.0];
    _payType.origin = CGPointMake(CGRectGetMaxX(markIV.frame)+10, markIV.y);
    [_payType sizeToFit];
    [self addSubview:_payType];
    
    // 交易时间
    _payTime = [UILabel new];
    _payTime.text = @"-- -- --";
    _payTime.textColor = [UIColor grayColor];
    _payTime.font = [UIFont systemFontOfSize:10.0];
    _payTime.x = _payType.x;
    _payTime.y = CGRectGetMaxY(_payType.frame);
    [_payTime sizeToFit];
    [self addSubview:_payTime];
    
    
    // 交易记录
    UIImageView *recordIV = [UIImageView new];
    recordIV.size = CGSizeMake(25, 22);
    recordIV.x = SCREEN_WIDTH-45;
    recordIV.centerY = markIV.centerY;
    recordIV.image = [UIImage imageNamed:@"record_more"];
    [self addSubview:recordIV];
    
    // 添加点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recordBtnClicked)];
    recordIV.userInteractionEnabled = YES;
    [recordIV addGestureRecognizer:tap];
    
    
    // 产品金额
    _productAmount = [UILabel new];
    _productAmount.text = NSLocalizedString(@"产品金额", nil);
    _productAmount.textColor = [UIColor blackColor];
    _productAmount.textAlignment = NSTextAlignmentCenter;
    _productAmount.font = [UIFont systemFontOfSize:15.0];
    [_productAmount sizeToFit];
    [self addSubview:_productAmount];
    [_productAmount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(markIV.mas_bottom).offset(20);
    }];
    
    // 扣款金额
    [self layoutIfNeeded];
    _chargeAmount = [UILabel new];
    _chargeAmount.text = NSLocalizedString(@"扣款金额", nil);
    _chargeAmount.textColor = [UIColor blackColor];
    _chargeAmount.textAlignment = NSTextAlignmentCenter;
    _chargeAmount.font = [UIFont systemFontOfSize:15.0];
    [_chargeAmount sizeToFit];
    [self addSubview:_chargeAmount];
    [_chargeAmount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_productAmount);
        make.top.mas_equalTo(_productAmount.mas_bottom).offset(8);
    }];
    
    // 交易地址
    [self layoutIfNeeded];
    _address = [UILabel new];
    _address.text = @"------";
    _address.textColor = [UIColor grayColor];
    _address.textAlignment = NSTextAlignmentCenter;
    _address.font = [UIFont systemFontOfSize:12.0];
    [_address sizeToFit];
    [self addSubview:_address];
    [_address mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(_chargeAmount.mas_bottom).offset(10);
    }];
    
    // 分割线
    [self layoutIfNeeded];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_address.frame)+11, SCREEN_WIDTH-40, 1)];
    lineView.backgroundColor = GrayBgColor;
    [self addSubview:lineView];
    
    // 查看详情
    UIButton *detailBtn = [UIButton new];
    [detailBtn setTitle:NSLocalizedString(@"查看详情", nil) forState:0];
    [detailBtn setTitleColor:MainThemeColor forState:0];
    detailBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [detailBtn sizeToFit];
    detailBtn.centerX = SCREEN_WIDTH/2;
    detailBtn.y = CGRectGetMaxY(lineView.frame)+5;
    //[detailBtn addTarget:self action:@selector(detailBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:detailBtn];
    
    UIButton *bigDetailBtn = [UIButton new];
    bigDetailBtn.frame = CGRectMake(0, lineView.bottom, SCREEN_WIDTH, 30);
    [bigDetailBtn addTarget:self action:@selector(detailBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:bigDetailBtn];
}

- (void)setTradeModel:(TradeModel *)tradeModel{
    _payTime.text = [self getFormatterTimeStr:tradeModel.orderTime];
    [_payTime sizeToFit];
    _productAmount.text = [NSString stringWithFormat:@"%@  %@ %.2f", NSLocalizedString(@"产品金额", nil), [SmallUtils transformCurrencyNum2SymbolString:tradeModel.txnCurr], [tradeModel.txnAmt doubleValue]/100];
    [_productAmount sizeToFit];
    _chargeAmount.text = [NSString stringWithFormat:@"%@  %@ %.2f", NSLocalizedString(@"扣款金额", nil), [SmallUtils transformCurrencyNum2SymbolString:tradeModel.billingCurr], [tradeModel.billingAmt doubleValue]/100];
    [_chargeAmount sizeToFit];
    _address.text = tradeModel.merName;
    [_address sizeToFit];
}

- (NSString *)getFormatterTimeStr:(NSString *)timeStr{
    if ([timeStr isKindOfClass:[NSNull class]]) {
        return @"";
    }
    NSDateFormatter *fm = [[NSDateFormatter alloc] init];
    [fm setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *date = [fm dateFromString:timeStr];
    [fm setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateStr = [fm stringFromDate:date];
    NSArray *timeArr = [dateStr componentsSeparatedByString:@" "];
    NSArray *timeArr1 = [timeArr[0] componentsSeparatedByString:@"-"];
    NSString *result = [NSString stringWithFormat:@"%@%@%@%@ %@", timeArr1[1], NSLocalizedString(@"月", nil), timeArr1[2], NSLocalizedString(@"日", nil), timeArr[1]];
    
    return result;
}

#pragma mark -- 点击方法
/// 交易记录
- (void)recordBtnClicked {
    [self.delegate didClickTradeRecordBtn];
}



/// 查看详情
- (void)detailBtnClicked {
    [self.delegate didClickDetailsBtn];
}

@end
