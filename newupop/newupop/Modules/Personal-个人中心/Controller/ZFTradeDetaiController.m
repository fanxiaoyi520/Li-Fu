//
//  ZFTradeDetaiController.m
//  newupop
//
//  Created by 中付支付 on 2017/9/7.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFTradeDetaiController.h"
#import "YYModel.h"
#import "ZFReceiptsWebController.h"

@interface ZFTradeDetaiController ()

@property (nonatomic, assign) NSInteger checkCount;

@end

@implementation ZFTradeDetaiController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myTitle = @"付款详情";
    self.view.backgroundColor = GrayBgColor;

    if (_fromType == 1) {
        [self getData];
    } else {
        [self createView];
    }
}

#pragma mark 创建视图
- (void)createView{
    //txnCurr txnAmt creditAmt useCredit billingCurr billingAmt bankName cardNum orderTime merName merId termCode serialNumber orderId
    
    UIFont *labelFont = [UIFont systemFontOfSize:14];
    UIColor *labelColor = [UIColor grayColor];
    
    //交易币种
    NSString *billingCurr = [SmallUtils transformCurrencyNum2SymbolString:_tradeModel.billingCurr];
    //订单币种
    NSString *txnCurr = [SmallUtils transformCurrencyNum2SymbolString:_tradeModel.txnCurr];
    
    //扣款金额
//    NSString *moneyStr = [NSString stringWithFormat:@"-%@ %.2f", billingCurr, [_tradeModel.billingAmt doubleValue]/100];
    NSString *moneyStr = [NSString stringWithFormat:@"%@ %.2f", txnCurr, [_tradeModel.txnAmt doubleValue]/100];
    
    UIScrollView *backScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight)];
    backScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, 20+480+47);
    backScrollView.backgroundColor = GrayBgColor;
    backScrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:backScrollView];
    //底部视图
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, 480)];
    backView.backgroundColor = [UIColor whiteColor];
    [backScrollView addSubview:backView];
    
    //产品金额
    UILabel *produceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, backView.width, 14)];
    produceLabel.text = self.tradeModel.merName.length ? self.tradeModel.merName : @"";
    produceLabel.textColor = labelColor;
    produceLabel.font = labelFont;
    produceLabel.textAlignment = NSTextAlignmentCenter;
    [backView addSubview:produceLabel];
    
    //金额
    UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, produceLabel.bottom+20, backView.width, 24)];
    moneyLabel.textAlignment = NSTextAlignmentCenter;
    moneyLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:24];
    moneyLabel.text = moneyStr;
    [backView addSubview:moneyLabel];
    
    // 交易状态
    UILabel *statuLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, moneyLabel.bottom+20, backView.width, 20)];
    statuLabel.text = NSLocalizedString(@"交易成功", nil);
    statuLabel.textColor = MainThemeColor;
    statuLabel.font = [UIFont systemFontOfSize:15.0];
    statuLabel.textAlignment = NSTextAlignmentCenter;
    [backView addSubview:statuLabel];
    
    if ([_tradeModel.txnType isEqualToString:@"PVR"]) {
        statuLabel.text = NSLocalizedString(@"撤销成功", nil);
    }
    
    //横线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(20, statuLabel.bottom+22, backView.width-20, 2)];
    lineView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [backView addSubview:lineView];
    
    //优惠信息
    UILabel *yhLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, lineView.bottom+28, 200, 14)];
    yhLabel.textColor = labelColor;
    yhLabel.font = labelFont;
    yhLabel.text = NSLocalizedString(@"优惠信息", nil);
    [backView addSubview:yhLabel];
    //优惠券
    UILabel *preferential1 = [[UILabel alloc] initWithFrame:CGRectMake(20, yhLabel.bottom+14, SCREEN_WIDTH-40, 14)];
    preferential1.textColor = UIColorFromRGB(0xF6A623);
    preferential1.font = labelFont;
    preferential1.numberOfLines = 0;
    preferential1.text = NSLocalizedString(@"暂无优惠", nil);
    [backView addSubview:preferential1];
    
    if (_tradeModel.creditAmt.length == 0 || [_tradeModel.creditAmt isEqualToString:@"0"]) {
        preferential1.text = NSLocalizedString(@"暂无优惠", nil);
    } else {
        preferential1.height = 36;
        NSString *txnCurrTxnCreditAmt = @"";
        if (![_tradeModel.txnCurrCreditAmt isKindOfClass:[NSNull class]] && _tradeModel.txnCurrCreditAmt.length>0) {
            txnCurrTxnCreditAmt = [NSString stringWithFormat:@"%@-%.2f", txnCurr, [_tradeModel.txnCurrCreditAmt doubleValue]/100];
        }
        preferential1.text = [NSString stringWithFormat:@"%@%@(%@%.2f)\n(%@%@)", NSLocalizedString(@"积分抵扣", nil), txnCurrTxnCreditAmt, billingCurr, [_tradeModel.creditAmt doubleValue]/100, NSLocalizedString(@"使用积分", nil),  _tradeModel.useCredit];
        preferential1.adjustsFontSizeToFitWidth = YES;
    }
    
    //优惠券
    if (![_tradeModel.couponDes isKindOfClass:[NSNull class]] && _tradeModel.couponDes && _tradeModel.couponDes.length > 1) {
        NSString *billingCurrdiscountAmt = @"";
        if (![_tradeModel.billingCurrdiscountAmt isKindOfClass:[NSNull class]] && _tradeModel.billingCurrdiscountAmt.length>0) {
            billingCurrdiscountAmt = [NSString stringWithFormat:@"%@ -%.2f", txnCurr, [_tradeModel.billingCurrdiscountAmt doubleValue]/100];
        }
        preferential1.text = [NSString stringWithFormat:@"%@(%@)", billingCurrdiscountAmt, _tradeModel.couponDes];
        preferential1.adjustsFontSizeToFitWidth = YES;
    }
    
    //横线
    UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(20, preferential1.bottom+26, SCREEN_WIDTH-20, 2)];
    lineView2.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [backView addSubview:lineView2];
    
    CGFloat heightY = lineView2.bottom+23;
    
    NSArray *titleArr = [NSArray arrayWithObjects:NSLocalizedString(@"订单金额", nil), NSLocalizedString(@"付款银行", nil), NSLocalizedString(@"交易时间", nil), NSLocalizedString(@"商户号", nil), NSLocalizedString(@"终端号", nil), NSLocalizedString(@"交易参考号", nil), NSLocalizedString(@"订单号", nil), nil];
    
    NSString *billingCurrTxnAmt = @"";//交易币种订单金额
    if (![_tradeModel.billingCurrTxnAmt isKindOfClass:[NSNull class]] && _tradeModel.billingCurrTxnAmt.length>0) {
        billingCurrTxnAmt = [NSString stringWithFormat:@" (%@%.2f)", billingCurr, [_tradeModel.billingCurrTxnAmt doubleValue]/100];
    }
    //订单金额
    NSString *payedStr = [NSString stringWithFormat:@"%@ %.2f%@", txnCurr, [_tradeModel.txnAmt doubleValue]/100, billingCurrTxnAmt];
    if ([payedStr isKindOfClass:[NSNull class]] || !payedStr) {
        payedStr = @"";
    }
    
    //扣款银行
    NSString *payCardStr = [NSString stringWithFormat:@"%@(%@)", _tradeModel.bankName, [_tradeModel.cardNum substringFromIndex:_tradeModel.cardNum.length-4]];
    if ([payCardStr containsString:@"\n"]) {
        payCardStr = [payCardStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    if ([payCardStr isKindOfClass:[NSNull class]] || !payCardStr) {
        payCardStr = @"";
    }
    
    //交易时间
    NSString *payTimeStr = @"";
    if (![_tradeModel.orderTime isKindOfClass:[NSNull class]] && _tradeModel.orderTime.length > 0) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        NSDate *payDate = [formatter dateFromString:_tradeModel.orderTime];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        payTimeStr = [formatter stringFromDate:payDate];
    }
    
    NSString *merId = _tradeModel.merId;
    if (_fromType == 2) {
        merId = [TripleDESUtils getDecryptWithString:_tradeModel.merId keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    }
    if ([merId isKindOfClass:[NSNull class]] || !merId) {
        merId = @"";
    }
    
    NSString *merName = _tradeModel.merName;
    if ([merName isKindOfClass:[NSNull class]] || !merName) {
        merName = @"";
    }
    
    NSString *termCode =_tradeModel.termCode;
    if ([termCode isKindOfClass:[NSNull class]] || !termCode) {
        termCode = @"";
    }
    
    NSString *serialNumber = _tradeModel.serialNumber;
    if ([serialNumber isKindOfClass:[NSNull class]] || !serialNumber) {
        serialNumber = @"";
    }
    
    NSString *orderId = _tradeModel.orderId;
    if ([orderId isKindOfClass:[NSNull class]] || !orderId) {
        orderId = @"";
    }
    
    NSArray *widthArr = [NSArray arrayWithObjects:@"111", @"103", @"111", @"89", @"84", @"80", @"90", nil];
    
    NSArray *contentArr = [NSArray arrayWithObjects:payedStr, payCardStr, payTimeStr, merId, termCode, serialNumber, orderId, nil];
    for (NSInteger i = 0; i < titleArr.count; i++) {
        CGFloat width = [widthArr[i] floatValue];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, heightY+i*28, width, 14)];
        titleLabel.textColor = labelColor;
        titleLabel.font = labelFont;
        titleLabel.text = titleArr[i];
        [backView addSubview:titleLabel];
        
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.right, titleLabel.y, backView.width-titleLabel.right-20, 14)];
        contentLabel.text = contentArr[i];
        contentLabel.textAlignment = NSTextAlignmentRight;
        contentLabel.font = labelFont;
        [backView addSubview:contentLabel];
        backView.height = contentLabel.bottom+20;
    }
    
    //右侧小票按钮
//    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//    rightBtn.frame = CGRectMake(SCREEN_WIDTH-120, IPhoneXStatusBarHeight, 110, 44);
//    [rightBtn setTitle:NSLocalizedString(@"小票", nil) forState:UIControlStateNormal];
//    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    rightBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
//    rightBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
//    [rightBtn addTarget:self action:@selector(clickRightBtn) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:rightBtn];
}

- (void)clickRightBtn{
    ZFReceiptsWebController *rwVC = [[ZFReceiptsWebController alloc] init];
    rwVC.orderID = _tradeModel.orderId;
    [self pushViewController:rwVC];
}

#pragma mark 获取筛选数据
- (void)getData {
    NSString *year = [_tradeModel.tradeMonth substringToIndex:4];
    NSString *month = [_tradeModel.tradeMonth substringFromIndex:4];
    
    NSDictionary *parameters = @{
                                 @"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"startDate":[[year stringByAppendingString:@"-"] stringByAppendingString:month],
                                 @"userKey":[ZFGlobleManager getGlobleManager].userKey,
                                 @"orderId":_tradeModel.orderId,
                                 @"beginNum":@"1",
                                 @"queryRows":@"5000",
                                 @"txnType": @"12",
                                 @"version": @"version2.1"
                                 };
    
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            self.tradeModel = [[NSArray yy_modelArrayWithClass:[TradeModel class] json:[requestResult objectForKey:@"list"]] firstObject];
            
            [self createView];
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
            return ;
        }
        
    } failure:^(NSError *error) {
        
    }];
}

@end
