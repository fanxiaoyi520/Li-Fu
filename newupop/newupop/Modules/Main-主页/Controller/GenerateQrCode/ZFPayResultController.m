//
//  ZFPayResultController.m
//  newupop
//
//  Created by 中付支付 on 2017/11/13.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFPayResultController.h"
#import "ZFTradeDetaiController.h"
#import "YYModel.h"

@interface ZFPayResultController ()

@property (nonatomic, assign) NSInteger checkCount;

@end

@implementation ZFPayResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myTitle = @"交易结果";
    if (_resultType == 0) {
        if (!_tradeModel) {
            [self createFailedViewWith:NSLocalizedString(@"交易查询失败", nil)];
        } else {
            [self createSuccessView];
        }
//        [self createSuccessView];
    } else if (_resultType == 1) {//失败
        [self createFailedViewWith:_errorMsg];
    } else if (_resultType == 2) {//order查询
        [self getData];
    } else {
        [self createFailedViewWith:NSLocalizedString(@"交易查询失败", nil)];
    }
    if (!_notRemoveVC) {
        [self removeController];
    }
}

#pragma mark 交易成功
- (void)createSuccessView{
    
    //通知首页刷新最新交易记录
    [[NSNotificationCenter defaultCenter] postNotificationName:TRADE_SUCCESS object:nil];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    imageView.center = CGPointMake(SCREEN_WIDTH/2, IPhoneXTopHeight+50+50);
    imageView.image = [UIImage imageNamed:@"paySuccess_icon"];
//    imageView.backgroundColor = [UIColor redColor];
    [self.view addSubview:imageView];
    
    //成功标签
    UILabel *sLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, imageView.bottom+20, SCREEN_WIDTH-40, 17)];
    sLabel.text = NSLocalizedString(@"付款成功", nil);
    sLabel.textColor = UIColorFromRGB(0x4990E2);
    sLabel.font = [UIFont systemFontOfSize:17];
    sLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:sLabel];
    
    //扣款金额
    UILabel *payLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, sLabel.bottom+30, SCREEN_WIDTH-40, 15)];
    payLabel.text = NSLocalizedString(@"支付金额", nil);
    payLabel.font = [UIFont systemFontOfSize:15];
    payLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:payLabel];
    
    //交易币种
    NSString *billingCurr = [SmallUtils transformCurrencyNum2SymbolString:_tradeModel.billingCurr];
    //订单币种
    NSString *txnCurr = [SmallUtils transformCurrencyNum2SymbolString:_tradeModel.txnCurr];
    
    NSString *payedStr = [NSString stringWithFormat:@"%@ %.2f", billingCurr, [_tradeModel.billingAmt doubleValue]/100];
    //扣款金额
    UILabel *billLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, payLabel.bottom+10, SCREEN_WIDTH-40, 30)];
    billLabel.font = [UIFont boldSystemFontOfSize:30];
    billLabel.text = payedStr;
    billLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:billLabel];
    
    //商家名称
    UILabel *merName = [[UILabel alloc] initWithFrame:CGRectMake(20, billLabel.bottom+30, SCREEN_WIDTH-40, 17)];
    merName.textAlignment = NSTextAlignmentCenter;
    merName.font = [UIFont systemFontOfSize:15];
    merName.text = _tradeModel.merName;
    [self.view addSubview:merName];
    
    NSString *billingCurrTxnAmt = @"";//交易币种订单金额
    if (![_tradeModel.billingCurrTxnAmt isKindOfClass:[NSNull class]] && _tradeModel.billingCurrTxnAmt.length>0) {
        billingCurrTxnAmt = [NSString stringWithFormat:@" (%@%.2f)", billingCurr, [_tradeModel.billingCurrTxnAmt doubleValue]/100];
    }
    //产品金额 商品信息
    NSString *moneyStr = [NSString stringWithFormat:@"%@ %@ %.2f%@", NSLocalizedString(@"订单金额", nil), txnCurr, [_tradeModel.txnAmt doubleValue]/100, billingCurrTxnAmt];
    //订单金额
    UILabel *txnLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, merName.bottom+20, SCREEN_WIDTH-40, 12)];
    txnLabel.textAlignment = NSTextAlignmentCenter;
    txnLabel.alpha = 0.6;
    txnLabel.font = [UIFont systemFontOfSize:12];
    txnLabel.text = moneyStr;
    [self.view addSubview:txnLabel];
    
    //优惠信息
    UILabel *discountVLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, txnLabel.bottom+10, SCREEN_WIDTH-40, 30)];
    discountVLabel.font = [UIFont systemFontOfSize:12];
    discountVLabel.numberOfLines = 0;
    discountVLabel.textAlignment = NSTextAlignmentCenter;
    discountVLabel.textColor = UIColorFromRGB(0xF6A623);
    discountVLabel.text = @"";
    [self.view addSubview:discountVLabel];
    if (_tradeModel.creditAmt.length != 0 && ![_tradeModel.creditAmt isEqualToString:@"0"]) {
        NSString *txnCurrTxnCreditAmt = @"";
        if (![_tradeModel.txnCurrCreditAmt isKindOfClass:[NSNull class]] && _tradeModel.txnCurrCreditAmt.length>0) {
            txnCurrTxnCreditAmt = [NSString stringWithFormat:@"%@-%.2f", txnCurr, [_tradeModel.txnCurrCreditAmt doubleValue]/100];
        }
        discountVLabel.text = [NSString stringWithFormat:@"%@ %@%@(%@%.2f)\n(%@%@)", NSLocalizedString(@"优惠信息", nil), NSLocalizedString(@"积分抵扣", nil), txnCurrTxnCreditAmt, billingCurr, [_tradeModel.creditAmt doubleValue]/100, NSLocalizedString(@"使用积分", nil),  _tradeModel.useCredit];
    }
    
    if (![_tradeModel.couponDes isKindOfClass:[NSNull class]] && _tradeModel.couponDes && _tradeModel.couponDes.length > 1) {
        NSString *billingCurrdiscountAmt = @"";
        if (![_tradeModel.billingCurrdiscountAmt isKindOfClass:[NSNull class]] && _tradeModel.billingCurrdiscountAmt.length>0) {
            billingCurrdiscountAmt = [NSString stringWithFormat:@"%@ -%@", txnCurr, _tradeModel.billingCurrdiscountAmt];
        }
        discountVLabel.text = [NSString stringWithFormat:@"%@(%@)", billingCurrdiscountAmt, _tradeModel.couponDes];
    }
    
    //查看详情按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(40, imageView.bottom+284, SCREEN_WIDTH-80, 40);
    [button setTitle:NSLocalizedString(@"查看详情", nil) forState:UIControlStateNormal];
    [button setTitleColor:MainThemeColor forState:UIControlStateNormal];
    button.layer.borderWidth = 1;
    button.layer.cornerRadius = 5;
    button.layer.borderColor = MainThemeColor.CGColor;
    [button addTarget:self action:@selector(checkDetail) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

#pragma mark 交易失败
- (void)createFailedViewWith:(NSString *)reasonStr{
    //图标
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    imageView.center = CGPointMake(SCREEN_WIDTH/2, 100+64);
    imageView.image = [UIImage imageNamed:@"payfail_icon"];
    [self.view addSubview:imageView];
    
    //付款失败
    UILabel *failedLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, imageView.bottom+20, SCREEN_WIDTH-40, 17)];
    failedLabel.text = NSLocalizedString(@"付款失败", nil);
    failedLabel.textAlignment = NSTextAlignmentCenter;
    failedLabel.textColor = UIColorFromRGB(0xE3494A);
    failedLabel.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:failedLabel];
    
    //失败原因
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, failedLabel.bottom+20, SCREEN_WIDTH-40, 40)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor grayColor];
    label.font = [UIFont systemFontOfSize:15];
    label.numberOfLines = 0;
    label.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"失败原因", nil), reasonStr];
    [self.view addSubview:label];
    
    //完成按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(40, imageView.bottom+284, SCREEN_WIDTH-80, 40);
    [button setTitle:NSLocalizedString(@"完成", nil) forState:UIControlStateNormal];
    [button setTitleColor:MainThemeColor forState:UIControlStateNormal];
    button.layer.borderWidth = 1;
    button.layer.cornerRadius = 5;
    button.layer.borderColor = MainThemeColor.CGColor;
    [button addTarget:self action:@selector(popBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)checkDetail{
    ZFTradeDetaiController *deVC = [[ZFTradeDetaiController alloc] init];
    deVC.tradeModel = _tradeModel;
    [self.navigationController pushViewController:deVC animated:YES];
}

- (void)popBack{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 获取筛选数据
- (void)getData {
    NSDictionary *parameters = @{
                                 @"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"startDate":@"2017-12",
                                 @"userKey":[ZFGlobleManager getGlobleManager].userKey,
                                 @"orderId":_orderId,
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
            
            [self createSuccessView];
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
            return ;
        }
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark 删除前面的控制器
- (void)removeController{
    NSArray *vcArr = self.navigationController.viewControllers;
    NSMutableArray *navigationArray = [NSMutableArray arrayWithObjects:vcArr[0], self, nil];
    self.navigationController.viewControllers = navigationArray;
}

@end
