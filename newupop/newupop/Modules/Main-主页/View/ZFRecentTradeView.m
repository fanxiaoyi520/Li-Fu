//
//  ZFRecentTradeView.m
//  newupop
//
//  Created by 中付支付 on 2017/11/3.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFRecentTradeView.h"

@implementation ZFRecentTradeView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupSubviews];
    }
    return self;
}

/** 添加子控件 */
- (void)setupSubviews {
    // 类型标志
    _markIV = [UIImageView new];
    _markIV.frame = CGRectMake(20, 11, 28, 28);
    _markIV.image = [UIImage imageNamed:@"home_record"];
    [self addSubview:_markIV];
    
    // 商户名称
    _payType = [UILabel new];
    _payType.text = NSLocalizedString(@"暂无订单", nil);
    _payType.textColor = [UIColor blackColor];
    _payType.font = [UIFont systemFontOfSize:16.0];
    _payType.origin = CGPointMake(CGRectGetMaxX(_markIV.frame)+15, _markIV.y+3);
    [_payType sizeToFit];
    [self addSubview:_payType];
    
    // 交易时间
    _payTime = [UILabel new];
    //_payTime.text = @"-- -- --";
    _payTime.textColor = [UIColor grayColor];
    _payTime.font = [UIFont systemFontOfSize:12.0];
    _payTime.x = _payType.x;
    _payTime.y = CGRectGetMaxY(_payType.frame)+5;
    [_payTime sizeToFit];
    [self addSubview:_payTime];
    
    
    // 交易记录
    UIImageView *recordIV = [UIImageView new];
    recordIV.size = CGSizeMake(25, 5);
    recordIV.x = SCREEN_WIDTH-45;
    recordIV.centerY = _markIV.centerY;
    recordIV.image = [UIImage imageNamed:@"home_more"];
    [self addSubview:recordIV];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(SCREEN_WIDTH-25-30, 0, 40, 50);
    [btn addTarget:self action:@selector(recordBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    
    // 添加点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recordBtnClicked)];
    recordIV.userInteractionEnabled = YES;
    [recordIV addGestureRecognizer:tap];
    
    UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(0, _markIV.bottom+10, self.width, 2)];
    lineView1.backgroundColor = GrayBgColor;
    [self addSubview:lineView1];
    
    // 产品金额
//    _productAmount = [[UILabel alloc] initWithFrame:CGRectMake(0, _markIV.bottom+25, 80, 15)];
//    //_productAmount.text = NSLocalizedString(@"订单金额", nil);
//    _productAmount.textColor = [UIColor blackColor];
//    _productAmount.textAlignment = NSTextAlignmentCenter;
//    _productAmount.font = [UIFont systemFontOfSize:15.0];
//    _productAmount.centerX = self.centerX;
//    [self addSubview:_productAmount];
    
    // 扣款金额
    [self layoutIfNeeded];
    _chargeAmount = [[UILabel alloc] initWithFrame:CGRectMake(0, lineView1.bottom+25, 80, 25)];
    _chargeAmount.textColor = [UIColor blackColor];
    _chargeAmount.alpha = 0.8;
    _chargeAmount.textAlignment = NSTextAlignmentCenter;
    _chargeAmount.font = [UIFont systemFontOfSize:24.0];
    [self addSubview:_chargeAmount];
    
    // 分割线
    //[self layoutIfNeeded];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_chargeAmount.frame)+27, SCREEN_WIDTH-40, 1)];
    lineView.backgroundColor = GrayBgColor;
    [self addSubview:lineView];
    
    // 查看详情
    _detailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //[_detailBtn setTitle:NSLocalizedString(@"查看详情", nil) forState:0];
    _detailBtn.frame = CGRectMake(0, 0, 120, 14);
    [_detailBtn setTitleColor:MainThemeColor forState:0];
    _detailBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    _detailBtn.centerX = SCREEN_WIDTH/2;
    _detailBtn.y = CGRectGetMaxY(lineView.frame)+12;
    [self addSubview:_detailBtn];
    
    UIButton *bigDetailBtn = [UIButton new];
    bigDetailBtn.frame = CGRectMake(0, lineView.bottom, SCREEN_WIDTH, 36);
    [bigDetailBtn addTarget:self action:@selector(detailBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:bigDetailBtn];
    
    //没有订单视图
    _noTradeView = [[UIView alloc] initWithFrame:CGRectMake(0, lineView1.bottom, self.width, self.height-lineView1.bottom)];
    _noTradeView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_noTradeView];
    
    UIImageView *noImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 54)];
    noImage.image = [UIImage imageNamed:@"main_no_order"];
    noImage.center = CGPointMake(self.width/2, 25+noImage.height/2);
    [_noTradeView addSubview:noImage];
    
    UILabel *noLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, noImage.bottom+12, self.width, 14)];
    noLabel.text = NSLocalizedString(@"暂无订单", nil);
    noLabel.textColor = UIColorFromRGB(0x4A90E2);
    noLabel.textAlignment = NSTextAlignmentCenter;
    noLabel.font = [UIFont systemFontOfSize:12];
    [_noTradeView addSubview:noLabel];
}

- (void)setTradeModel:(TradeModel *)tradeModel{
    _noTradeView.hidden = YES;
    _tradeModel = tradeModel;
    _payType.text = tradeModel.merName;
    [_payType sizeToFit];
    _payType.origin = CGPointMake(CGRectGetMaxX(_markIV.frame)+15, _markIV.y-3);
    
    _payTime.text = [self getFormatterTimeStr:tradeModel.orderTime];
    [_payTime sizeToFit];
    _payTime.origin = CGPointMake(_payType.x, CGRectGetMaxY(_payType.frame)+5);
    
//    _productAmount.text = [NSString stringWithFormat:@"%@  %@ %.2f", NSLocalizedString(@"订单金额", nil), [SmallUtils transformCurrencyNum2SymbolString:tradeModel.txnCurr], [tradeModel.txnAmt doubleValue]/100];
//    [_productAmount sizeToFit];
//    _productAmount.centerX = self.width/2;
    
//    _chargeAmount.text = [NSString stringWithFormat:@"%@  %@ %.2f", NSLocalizedString(@"支付金额", nil), [SmallUtils transformCurrencyNum2SymbolString:tradeModel.billingCurr], [tradeModel.billingAmt doubleValue]/100];
    _chargeAmount.text = [NSString stringWithFormat:@"-%@ %.2f", [SmallUtils transformCurrencyNum2SymbolString:tradeModel.billingCurr], [tradeModel.billingAmt doubleValue]/100];
    [_chargeAmount sizeToFit];
    _chargeAmount.centerX = self.width/2;
    
    [_detailBtn setTitle:NSLocalizedString(@"查看详情", nil) forState:0];
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
//    NSArray *timeArr = [dateStr componentsSeparatedByString:@" "];
//    NSArray *timeArr1 = [timeArr[0] componentsSeparatedByString:@"-"];
//    NSString *result = [NSString stringWithFormat:@"%@%@%@%@ %@", timeArr1[1], NSLocalizedString(@"月", nil), timeArr1[2], NSLocalizedString(@"日", nil), timeArr[1]];
    
    return dateStr;
}

#pragma mark -- 点击方法
/// 交易记录
- (void)recordBtnClicked {
    [self.delegate didClickTradeRecordBtn];
}

/// 查看详情
- (void)detailBtnClicked {
    if (!_tradeModel) {
        return;
    }
    [self.delegate didClickDetailsBtn];
}
@end
