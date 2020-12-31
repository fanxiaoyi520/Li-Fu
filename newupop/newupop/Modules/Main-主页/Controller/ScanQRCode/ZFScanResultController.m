//
//  ZFScanResultController.m
//  newupop
//
//  Created by 中付支付 on 2017/8/29.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFScanResultController.h"
#import "ZFPopTableView.h"
#import "ZFQuickPayPayInfo.h"
#import "ZFPwdInputView.h"
#import "TradeModel.h"
#import "IQKeyboardManager.h"
#import "ZFPayResultController.h"
#import "ZFSafeVerificationController.h"
#import "ZFCouponModel.h"
#import "ZFCouponTableView.h"
#import "YYModel.h"
#import "ZFAddCardNoViewController.h"
#import "ZFUPBankCardModel.h"
#import "ZFGetMSCodeController.h"

@interface ZFScanResultController ()<UITextFieldDelegate, ZFPopTableViewDelegate, ZFCouponTableDelegate>

///底部视图
@property (nonatomic, strong)UIView *backView;
///商户名
@property (nonatomic, strong)UILabel *merNameLabel;

///输入金额底部视图
@property (nonatomic, strong)UIView *backView1;
///付款类型
@property (nonatomic, strong)UILabel *txnCurrLabel;
///输入金额框
@property (nonatomic, strong)UITextField *moneyTextField;
///输入金额
@property (nonatomic, strong)NSString *moneyStr;
///币种
@property (nonatomic, strong)NSString *txnCurrStr;

///积分底部视图
@property (nonatomic, strong)UIView *integralBackView;
///是否使用积分标签
@property (nonatomic, strong)UILabel *integralLabel;
///使用积分提示
@property (nonatomic, strong)UILabel *integralTipLabel;
///积分按钮
@property (nonatomic, strong)UIButton *integralBtn;
///积分图片
@property (nonatomic, strong)UIImageView *integralImage;
///积分
@property (nonatomic, strong)NSString *jifen;
///积分足够支付 是否可以不用银行卡
@property (nonatomic, assign)BOOL isIntegralEnough;
///积分抵扣金额
@property (nonatomic, strong)NSString *integralMoney;

///优惠券底部视图
@property (nonatomic, strong)UIView *couponDesBackView;
///优惠券标签
@property (nonatomic, strong)UILabel *couponDesLabel;
///优惠券详情提示
@property (nonatomic, strong)UILabel *couponTipLabel;
///优惠券抵扣金额
@property (nonatomic, strong)NSString *couponMoney;
///优惠券列表
@property (nonatomic, strong)NSMutableArray *couponArray;
///优惠券model
@property (nonatomic, strong)ZFCouponModel *couponModel;
///优惠券列表
@property (nonatomic, strong)ZFCouponTableView *couponTableView;
///是否可以使用优惠券
@property (nonatomic, assign)BOOL isCanUseCoupon;

///交易结果
@property (nonatomic, strong)TradeModel *resultTradeModel;

///银行卡列表
@property (nonatomic, strong)NSMutableArray *cardArray;
///默认银行卡index
@property (nonatomic, assign)NSInteger defaultCardIndex;
///支付银行卡
@property (nonatomic, strong)ZFBankCardModel *cardModel;

///支付弹窗
@property (nonatomic, strong)ZFPopTableView *popView;
///密码
@property (nonatomic, strong)NSString *passWord;

/** 银联国际返回的cvm模型 */
@property(nonatomic, strong) ZFUPBankCardModel *upModel;
///认证之后返回需要交易
@property (nonatomic, assign)BOOL isNeedPay;
///
@property (nonatomic, assign)NSInteger checkCount;

@end

@implementation ZFScanResultController

- (void)dealloc{
    [ZFGlobleManager getGlobleManager].notNeedShowSuccess = NO;
    //清空余额不足标志
    for (ZFBankCardModel *model in [ZFGlobleManager getGlobleManager].bankCardArray) {
        model.underbalance = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myTitle = @"付款";
    self.view.backgroundColor = MainThemeColor;
    [self createView];
    //查询二维码信息
    [self getMerchantInfo];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear: animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    if ([self.quickPayPayInfo.QRType isEqualToString:@"1"] || [self.quickPayPayInfo.QRType isEqualToString:@"4"] || [self.quickPayPayInfo.QRType isEqualToString:@"6"]) {
        if (_moneyTextField.text.length == 0) {
            [_moneyTextField becomeFirstResponder];
        }
    }
    if ([ZFGlobleManager getGlobleManager].isChanged) {
        [self getCardListData];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    if (_popView) {
        [_popView dismiss];
    }
}

#pragma mark - 创建视图
- (void)createView{
    _backView = [[UIView alloc] initWithFrame:CGRectMake(20, 20+64, SCREEN_WIDTH-40, 240)];
    _backView.backgroundColor = [UIColor whiteColor];
    _backView.layer.cornerRadius = 5;
    [self.view addSubview:_backView];
    
    //商户名
    _merNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 18, _backView.width, 15)];
    _merNameLabel.font = [UIFont systemFontOfSize:15];
    _merNameLabel.textAlignment = NSTextAlignmentCenter;
    _merNameLabel.text = NSLocalizedString(@"查询中", nil);
    [_backView addSubview:_merNameLabel];
    
    //蓝色线
     UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(50, _merNameLabel.bottom+15, _backView.width-100, 2)];
    lineView.backgroundColor = MainThemeColor;
    [_backView addSubview:lineView];
    
    //输入金额底部视图
    _backView1 = [[UIView alloc] initWithFrame:CGRectMake(0, _merNameLabel.bottom+40, _backView.width, _backView.height-_merNameLabel.bottom-40)];
    [_backView addSubview:_backView1];
    
    //提示标签
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 120, 15)];
    tipLabel.text = NSLocalizedString(@"付款金额", nil);
    tipLabel.textColor = [UIColor grayColor];
    tipLabel.font = [UIFont systemFontOfSize:15];
    [_backView1 addSubview:tipLabel];
    
    //付款币种
    _txnCurrLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, tipLabel.bottom+20, 60, 30)];
    _txnCurrLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:20];
    [_backView1 addSubview:_txnCurrLabel];
    
    //输入框
    _moneyTextField = [[UITextField alloc] initWithFrame:CGRectMake(_txnCurrLabel.right+10, _txnCurrLabel.y-15, _backView.width-60-_txnCurrLabel.width, _txnCurrLabel.height+18)];
    _moneyTextField.delegate = self;
    _moneyTextField.font = [UIFont systemFontOfSize:25];
    _moneyTextField.placeholder = NSLocalizedString(@"请输入金额", nil);
    _moneyTextField.textAlignment = NSTextAlignmentRight;
    _moneyTextField.keyboardType = UIKeyboardTypeDecimalPad;
    [_backView1 addSubview:_moneyTextField];
    
    if ([self.quickPayPayInfo.QRType isEqualToString:@"1"] || [self.quickPayPayInfo.QRType isEqualToString:@"1"]) {//积分变化
        [_moneyTextField addTarget:self action:@selector(listenMoneyForIntegral) forControlEvents:UIControlEventAllEditingEvents];
    } else { //优惠券变化
        [_moneyTextField addTarget:self action:@selector(listenMoneyForCoupon) forControlEvents:UIControlEventAllEditingEvents];
    }
    
    //横线
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, _txnCurrLabel.bottom+5, _backView.width-20, 2)];
    lineLabel.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [_backView1 addSubview:lineLabel];
    
    //下一步按钮
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, lineLabel.bottom+30, _backView.width-40, 40)];
    button.layer.cornerRadius = 5;
    button.backgroundColor = MainThemeColor;
    [button setTitle:NSLocalizedString(@"下一步", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickNextStep) forControlEvents:UIControlEventTouchUpInside];
    [_backView1 addSubview:button];
    
    if ([self.quickPayPayInfo.QRType isEqualToString:@"1"] || [self.quickPayPayInfo.QRType isEqualToString:@"2"]) {
        [self createJiFenView];
    } else {
        //创建优惠券视图
        [self createCouponDesView];
    }
}

#pragma mark 创建积分和付款方式选择视图
- (void)createJiFenView{
    //积分
    _integralBackView = [[UIView alloc] initWithFrame:CGRectMake(20, _backView.bottom+20, SCREEN_WIDTH-40, 60)];
    _integralBackView.backgroundColor = [UIColor whiteColor];
    _integralBackView.layer.cornerRadius = 5;
    _integralBackView.hidden = YES;
    [self.view addSubview:_integralBackView];
    
    //积分标签
    _integralLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, _integralBackView.width-70, 20)];
    _integralLabel.centerY = _integralBackView.height/2-10;
    _integralLabel.font = [UIFont systemFontOfSize:14];
    [_integralBackView addSubview:_integralLabel];
    
    _integralTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(_integralLabel.x, _integralLabel.bottom+5, _integralLabel.width, 20)];
    _integralTipLabel.textColor = UIColorFromRGB(0xFF2640);
    _integralTipLabel.font = [UIFont systemFontOfSize:12];
    _integralTipLabel.adjustsFontSizeToFitWidth = YES;
    [_integralBackView addSubview:_integralTipLabel];
    
    //积分图片
    _integralImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    _integralImage.image = [UIImage imageNamed:@"icon_confirm_normal"];
    _integralImage.center = CGPointMake(_integralBackView.width-35, _integralBackView.height/2);
    [_integralBackView addSubview:_integralImage];
    
    //积分按钮
    _integralBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _integralBtn.frame = CGRectMake(0, 0, _integralBackView.width, _integralBackView.height);
    [_integralBtn addTarget:self action:@selector(clickIntegralBtn) forControlEvents:UIControlEventTouchUpInside];
    [_integralBackView addSubview:_integralBtn];
}

#pragma mark 创建优惠券视图
- (void)createCouponDesView{
    //底部
    _couponDesBackView = [[UIView alloc] initWithFrame:CGRectMake(20, _backView.bottom+20, SCREEN_WIDTH-40, 100)];
    _couponDesBackView.backgroundColor = self.view.backgroundColor;
    _couponDesBackView.hidden = YES;
    [self.view addSubview:_couponDesBackView];
    
    //半透明视图
    UIView *btmView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _couponDesBackView.width, _couponDesBackView.height+30)];
    btmView.backgroundColor = [UIColor whiteColor];
    btmView.alpha = 0.2;
    btmView.layer.cornerRadius = 5;
    [_couponDesBackView addSubview:btmView];
    
    // 图片
    UIImageView *backImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _couponDesBackView.width, _couponDesBackView.height)];
    backImage.image = [UIImage imageNamed:@"pic_background_discount"];
    [_couponDesBackView addSubview:backImage];
    
    //红色标签
    UILabel *colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 6, 18)];
    colorLabel.backgroundColor = UIColorFromRGB(0xE44949);
    [_couponDesBackView addSubview:colorLabel];
    
    //提示标签
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(colorLabel.right+10, colorLabel.y, 100, 16)];
    tipLabel.text = NSLocalizedString(@"商家优惠信息", nil);
    [tipLabel sizeToFit];
    tipLabel.font = [UIFont systemFontOfSize:15];
    [_couponDesBackView addSubview:tipLabel];
    
    //查看更多按钮
    UIButton *checkMoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    checkMoreBtn.frame = CGRectMake(_couponDesBackView.width-100, 0, 80, 35);
    checkMoreBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    checkMoreBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [checkMoreBtn setTitle:NSLocalizedString(@"查看更多", nil) forState:UIControlStateNormal];
    [checkMoreBtn setTitleColor:UIColorFromRGB(0x4A90E2) forState:UIControlStateNormal];
    [checkMoreBtn addTarget:self action:@selector(showCouponTV) forControlEvents:UIControlEventTouchUpInside];
    [_couponDesBackView addSubview:checkMoreBtn];
    
    //优惠详情提示
    _couponTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, colorLabel.bottom+17, _couponDesBackView.width-40, 36)];
    _couponTipLabel.alpha = 0.5;
    _couponTipLabel.numberOfLines = 0;
    _couponTipLabel.font = [UIFont systemFontOfSize:14];
    [_couponDesBackView addSubview:_couponTipLabel];
    
    //优惠金额信息
    _couponDesLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, _couponDesBackView.height+7, _couponDesBackView.width-40, 15)];
    _couponDesLabel.textColor = [UIColor whiteColor];
    _couponDesLabel.font = [UIFont systemFontOfSize:12];
    _couponDesLabel.adjustsFontSizeToFitWidth = YES;
    [_couponDesBackView addSubview:_couponDesLabel];
    
    //优惠券列表
    _couponTableView = [[ZFCouponTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _couponTableView.delegate = self;
    [self.view addSubview:_couponTableView];
}
//选择优惠券
- (void)chooseCoupon:(ZFCouponModel *)couponModel index:(NSInteger)index{
    _couponModel = couponModel;
    [self listenMoneyForCoupon];
}
//显示优惠券列表
- (void)showCouponTV{
    if (_couponArray.count > 1) {
        [_couponTableView show];
    } else {
        [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"没有更多优惠券", nil) inView:self.view];
    }
}

#pragma mark 点击积分优惠
- (void)clickIntegralBtn{
    _integralBtn.selected = !_integralBtn.selected;
    if (!_integralBtn.selected) {
        _integralImage.image = [UIImage imageNamed:@"icon_confirm_normal"];
    } else {
        _integralImage.image = [UIImage imageNamed:@"icon_confirm_highlight"];
    }
}

#pragma mark 点击添加银行卡
- (void)addBankCard{
    ZFAddCardNoViewController *vc = [ZFAddCardNoViewController new];
    [self pushViewController:vc];
}

#pragma mark 输入金额后下一步
- (void)clickNextStep{
    if (![self checkMoney]) {
        return;
    }
    _moneyStr = _moneyTextField.text;
    self.quickPayPayInfo.payMoney = _moneyStr;
    [_moneyTextField resignFirstResponder];
    self.quickPayPayInfo.payMoney_Transformed = [NSString stringWithFormat:@"%.f", [_moneyStr floatValue] * 100];
    
    if ([self.quickPayPayInfo.QRType isEqualToString:@"1"]) {//中付支付
        [self readyPay];
    } else {//银联卡
        [self showPopView];
    }
}

#pragma mark 显示弹窗
- (void)showPopView{
    PopTVType type = PopTVTypeMiMa;
    NSString *payMoney = _moneyStr;
    
    NSString *txnCurr = [SmallUtils transformCurrencyNum2SymbolString:self.quickPayPayInfo.txnCurr];
    NSString *amountShow = [NSString stringWithFormat:@"%@ %@", txnCurr, payMoney];
    
    if ([self.quickPayPayInfo.QRType isEqualToString:@"1"] || [self.quickPayPayInfo.QRType isEqualToString:@"2"]) {
        if (_integralBtn.isSelected) {//使用积分
            //抵扣完积分后的钱
            payMoney = [NSString stringWithFormat:@"%.2f", [_moneyStr doubleValue]-[_integralMoney doubleValue]];
            amountShow = [NSString stringWithFormat:@"%@ %@", txnCurr, payMoney];
            
            if (_isIntegralEnough) {//不需要卡支付
                type = PopTVTypeIntegralOnly;
                amountShow = [NSString stringWithFormat:@"%@ %@ %@", NSLocalizedString(@"积分抵扣", nil), txnCurr, _integralMoney];
            }
        }
    } else {
        if (_couponModel) {//使用优惠券
            //抵扣完优惠券后的钱
            payMoney = [NSString stringWithFormat:@"%.2f", [_moneyStr doubleValue]-[_couponMoney doubleValue]];
            amountShow = [NSString stringWithFormat:@"%@ %@", txnCurr, payMoney];
        }
    }
    
    //支付弹窗
    _popView = [[ZFPopTableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _popView.pType = type;
    _popView.amount = amountShow;
    _popView.bcmArray = _cardArray;
    _popView.tipLabelString = _merNameLabel.text;
    _popView.cardModel = _cardModel;
    _popView.delegate = self;
    [_popView showWithView:self.view];
}

#pragma mark 监听金额变化改变积分
- (void)listenMoneyForIntegral{
    if (!_jifen) {
        return;
    }
    NSInteger integral = [_jifen integerValue];
    
    NSString *money = _moneyTextField.text;
    NSString *integralMoney = @"";
    _isIntegralEnough = NO;
    if ([money doubleValue] > 0) {
        //转换成CNY的分
        NSInteger moneyInt = [money doubleValue] *100 *[self.quickPayPayInfo.billingRate doubleValue];
        if (integral >= moneyInt) {//积分可全额抵扣
            _isIntegralEnough = YES;
            _integralMoney = [NSString stringWithFormat:@"%.2f", [money doubleValue]];
        } else {//不能全额抵扣
            _isIntegralEnough = NO;
            _integralMoney = [NSString stringWithFormat:@"%.2f", integral/[self.quickPayPayInfo.billingRate doubleValue]/100];
        }
        integralMoney = [NSString stringWithFormat:@"%@ %@", _txnCurrLabel.text, _integralMoney];
    }
    _integralTipLabel.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"积分最高抵扣", nil), integralMoney];
}

#pragma mark 监听金额变化改变优惠券
- (void)listenMoneyForCoupon{
    if (!_couponArray || _couponArray.count == 0 || !_couponModel) {
        return;
    }
    _couponTipLabel.text = _couponModel.activityIntroduction;
    
    NSString *money = _moneyTextField.text;
    _isCanUseCoupon = NO;
    
    if ([money doubleValue] > 0) {
        NSString *discountMoney = @"";//优惠金额
        if ([money doubleValue]*100 < [_couponModel.maxAmt doubleValue]){//不满足抵扣条件
            _couponDesLabel.text = @"";
            _couponMoney = @"";
            return;
        }
        _isCanUseCoupon = YES;
        if ([_couponModel.discountType isEqualToString:@"1"]) {//满减类型
            discountMoney = _couponModel.discountAmt;
        }
        
        if ([_couponModel.discountType isEqualToString:@"2"]) {//打折有上限类型
            CGFloat disAmt = [_couponModel.discountAmt doubleValue] * [money doubleValue]*100;//折扣乘金额
            if (disAmt >= [_couponModel.maxDiscount doubleValue]) {//判断最高抵扣
                disAmt = [_couponModel.maxDiscount doubleValue];
            }
            discountMoney = [NSString stringWithFormat:@"%.f", disAmt];
        }
        
        //显示优惠金额
        _couponMoney = [NSString stringWithFormat:@"%.2f", [discountMoney doubleValue]/100];
        _couponDesLabel.text = [NSString stringWithFormat:@"%@ %@ -%@", NSLocalizedString(@"优惠", nil), _txnCurrLabel.text, _couponMoney];
    } else {
        _couponDesLabel.text = @"";
        _couponMoney = @"";
    }
}

#pragma mark 判断金额
- (BOOL)checkMoney{
    // 判断金额是否填写正确
    NSString *tempMoney = _moneyTextField.text;
    if([tempMoney doubleValue] == 0){
        [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"请输入付款金额", nil) inView:self.view];
        return NO;
    }
    return YES;
}

#pragma mark - 解析二维码获取交易信息
#pragma mark 获取商户交易信息（扫描付款）接口
-(void) getMerchantInfo{
    
    // 设置显示的币种符号
    _txnCurrLabel.text = [SmallUtils transformCurrencyNum2SymbolString:self.quickPayPayInfo.txnCurr];
    // 显示在界面
    NSString *str = NSLocalizedString(@"向..付款", nil);
    if ([str hasPrefix:@"向"]) {
        str = [NSString stringWithFormat:@"向'%@'付款",self.quickPayPayInfo.merName];
    } else {
        str = [NSString stringWithFormat:@"%@'%@'", str, self.quickPayPayInfo.merName];
    }
    _merNameLabel.text = str;
    
    //固定金额
    if ([self.quickPayPayInfo.QRType isEqualToString:@"2"] || [self.quickPayPayInfo.QRType isEqualToString:@"3"] || [self.quickPayPayInfo.QRType isEqualToString:@"5"]) {    
        NSString *moneyYuan = [NSString stringWithFormat:@"%0.2f", [self.quickPayPayInfo.payMoney doubleValue]];
        _moneyTextField.text = moneyYuan;
        _moneyTextField.enabled = NO;
    }
    
    [self getDefaultCard];
    
    if ([self.quickPayPayInfo.QRType isEqualToString:@"1"] || [self.quickPayPayInfo.QRType isEqualToString:@"2"]) {
        if ([self.quickPayPayInfo.QRType isEqualToString:@"1"]) {//获取汇率
            [self getExchangeRate];
        }
        [self checkJiFen];
    } else {
        [self checkCouponDes];
    }
}

#pragma mark 获取汇率（扫描付款）接口
-(void) getExchangeRate{
    [[MBUtils sharedInstance] showMBInView:self.view];
    // 生成签名字段
    NSDictionary *paramSign = @{@"merId": self.quickPayPayInfo.QRCodeMerchantInfoEncrypted,
                                @"txnAmt": @"1",//self.quickPayPayInfo.payMoney_Transformed,
                                @"txnCurr":  self.quickPayPayInfo.txnCurr,
                                @"billingCurr": self.quickPayPayInfo.billingCurr,
                                @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                @"txnType": @"21"};
    [NetworkEngine singlePostWithParmas:paramSign success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[MBUtils sharedInstance] dismissMB];
            self.quickPayPayInfo.billingRate = [requestResult objectForKey:@"billingRate"];
        } else {
            [[MBUtils sharedInstance] dismissMB];
            [self requestErrorWith:[requestResult objectForKey:@"msg"]];
        }
    } failure:^(id error) {
        [self requestErrorWith:NetRequestError];
    }];
}

#pragma mark 消费类交易-下单（扫描付款）接口
-(void)readyPay{
    //通过汇率转换
    CGFloat billingMoney = [self.quickPayPayInfo.payMoney_Transformed doubleValue] * [self.quickPayPayInfo.billingRate doubleValue];
    self.quickPayPayInfo.billingAmt = [NSString stringWithFormat:@"%.f", billingMoney];
    
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    // 生成签名字段
    NSDictionary *paramSign = @{@"merId": self.quickPayPayInfo.QRCodeMerchantInfoEncrypted,
                                @"txnAmt": self.quickPayPayInfo.payMoney_Transformed,
                                @"txnCurr": self.quickPayPayInfo.txnCurr,
                                @"billingAmt": self.quickPayPayInfo.billingAmt,
                                @"billingCurr": self.quickPayPayInfo.billingCurr,
                                @"billingRate" : self.quickPayPayInfo.billingRate,
                                @"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                @"mobile":[ZFGlobleManager getGlobleManager].userPhone,
                                @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                @"txnType": @"23"};
    
    [NetworkEngine singlePostWithParmas:paramSign success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[MBUtils sharedInstance] dismissMB];
            self.quickPayPayInfo.inTradeOrderNo = [requestResult objectForKey:@"orderId"];
            self.quickPayPayInfo.payTimeout = [requestResult objectForKey:@"payTimeout"];
            dispatch_async(dispatch_get_main_queue(), ^{            
                [self showPopView];
            });
            
        } else {
            [[MBUtils sharedInstance] dismissMB];
            [self requestErrorWith:[requestResult objectForKey:@"msg"]];
        }
    } failure:^(id error) {
        [self requestErrorWith:NetRequestError];
    }];
}

#pragma mark 判断银行卡是否支持
- (BOOL)checkoutBankCard{
    if ([self.quickPayPayInfo.QRType isEqualToString:@"1"] || [self.quickPayPayInfo.QRType isEqualToString:@"2"]) {//支持upop
        if (_integralBtn.isSelected && _isIntegralEnough) {//积分支付
            return YES;
        } else {
            BOOL isSupport = [[ZFGlobleManager getGlobleManager] isSupportTheCity:self.quickPayPayInfo.sysareaId cardModel:_cardModel];
            
            if (!isSupport) {
                [self bandingOtherArea:self.quickPayPayInfo.sysareaId];
            }
            
            return isSupport;
        }
    } else {//支持银联
        if (![_cardModel.openCountry.UP isEqualToString:@"0"]) {
//            [self bandingOtherArea:@"UP"];
            
            if ([_cardModel.openCountry.SG isEqualToString:@"0"]) { // 已认证新加坡地区，直接走虚拟卡交易
                [self addVirtualCard];
            } else { // 未认证
                [self bandingOtherArea:@"SG"];
            }
            return NO;
        }
    }
    
    return YES;
}

// TODO 测试添加虚拟卡
- (void)addVirtualCard {
    // 3des加密支付密码
    NSString *encryptPayPassword = [TripleDESUtils getEncryptWithString:_passWord keyString: [ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    
    NSDictionary *paramSign = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                @"mobile":  [ZFGlobleManager getGlobleManager].userPhone,
                                @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                @"txnCurr":self.quickPayPayInfo.txnCurr,
                                @"billingCurr": @"156",
                                @"txnAmt":self.quickPayPayInfo.payMoney_Transformed,
                                @"sysArea" : self.quickPayPayInfo.txnCurr,
                                @"cardNum":self.quickPayPayInfo.cardNumEncrypted,
                                @"userKey":[ZFGlobleManager getGlobleManager].userKey,
                                @"emvcode":_resultStr,
                                @"payPassword":encryptPayPassword,
                                @"txnType": @"04"};
    
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    
    [NetworkEngine postWtihURL:BASEURL_XUNI parmas:paramSign outTime:70.0 success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        NSString *status = [requestResult objectForKey:@"status"];
        if ([status isEqualToString:@"1"] || [status isEqualToString:@"2"] || [status isEqualToString:@"64"] || [status isEqualToString:@"55"]) {//1失败、2待支付、64余额不足、55支付密码错误
            [self showToUser:[requestResult objectForKey:@"status"] message:[requestResult objectForKey:@"msg"]];
        } else {
            _resultTradeModel = [[TradeModel alloc] init];
            _resultTradeModel.orderId = self.quickPayPayInfo.inTradeOrderNo;
            _resultTradeModel.cardNum = self.quickPayPayInfo.accNo;
            _resultTradeModel.merId = self.quickPayPayInfo.merId;
            
            if ([[requestResult objectForKey:@"status"] isEqualToString:@"3"]) {
                if ([requestResult[@"orderId"] isKindOfClass:[NSNull class]] || [requestResult[@"billingAmt"] isKindOfClass:[NSNull class]] || [requestResult[@"billingCurr"] isKindOfClass:[NSNull class]] || [requestResult[@"billingRate"] isKindOfClass:[NSNull class]] || [requestResult[@"merId"] isKindOfClass:[NSNull class]]) {
                    [self requestErrorWith:NetRequestError];
                    return ;
                }
                _resultTradeModel.orderId = [requestResult objectForKey:@"orderId"];
                self.quickPayPayInfo.billingAmt = [requestResult objectForKey:@"billingAmt"];
                self.quickPayPayInfo.billingCurr = [requestResult objectForKey:@"billingCurr"];
                self.quickPayPayInfo.billingRate = [requestResult objectForKey:@"billingRate"];
                self.quickPayPayInfo.QRCodeMerchantInfoEncrypted = [TripleDESUtils getEncryptWithString:requestResult[@"merId"] keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
                
                _resultTradeModel.txnAmt = self.quickPayPayInfo.payMoney_Transformed;
                _resultTradeModel.cardSerialNumber = self.quickPayPayInfo.cardSerialNum;
                _resultTradeModel.bankName = self.quickPayPayInfo.cardName;
                _resultTradeModel.cardType = self.quickPayPayInfo.cardType;
                _checkCount = 0;
                
                [self checkSinoPayResult];
                return ;
            }
            
            if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
                [self dealData:requestResult];
            }
            [self jumpToPayResult:YES message:@""];
        }
    } failure:^(id error) {
        [self requestErrorWith:NetRequestError];
    }];
    
//    [NetworkEngine singlePostWithParmas:paramSign success:^(id requestResult) {
//        [[MBUtils sharedInstance] dismissMB];
//
//
//    } failure:^(id error) {
//        [self requestErrorWith:NetRequestError];
//    }];
}

//去认证其他区域
- (void)bandingOtherArea:(NSString *)sysareaId{
    //先验证支付密码
    // 3DES加密
    NSString *passWord = [TripleDESUtils getEncryptWithString:_passWord keyString: [ZFGlobleManager getGlobleManager].securityKey ivString: TRIPLEDES_IV];
    
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"payPassword": passWord,
                                 @"userKey":[ZFGlobleManager getGlobleManager].userKey,
                                 @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                                 @"txnType":@"42"};
    
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        //请求成功
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            _isNeedPay = YES;
            [ZFGlobleManager getGlobleManager].notNeedShowSuccess = YES;
            [self certificationBankCard:sysareaId];
        } else {
            [self showToUser:@"55" message:NSLocalizedString(@"支付密码输入错误", nil)];//支付密码输入错误
        }
    } failure:^(NSError *error) {
        [self requestErrorWith:NetRequestError];
    }];
    
}

#pragma mark - 支付
- (void)pay{
    if (![self checkoutBankCard]) {
        return;
    }
    
    _resultTradeModel = [[TradeModel alloc] init];
    if ([self.quickPayPayInfo.QRType isEqualToString:@"3"] || [self.quickPayPayInfo.QRType isEqualToString:@"4"]) {//银联支付
        [self unionPay];
    } else if ([self.quickPayPayInfo.QRType isEqualToString:@"5"] || [self.quickPayPayInfo.QRType isEqualToString:@"6"]){
        [self unionUrlPay];
    } else {//中付支付
       [self sinopay];
    }
}

#pragma mark 中付支付
- (void)sinopay{
    
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    // 3des加密支付密码
    NSString *encryptPayPassword = [TripleDESUtils getEncryptWithString:_passWord keyString: [ZFGlobleManager getGlobleManager].securityKey ivString: TRIPLEDES_IV_QUICKPAYABROAD];
    
    // 生成签名字段
    NSDictionary *paramSign = @{@"orderId": self.quickPayPayInfo.inTradeOrderNo,
                                @"txnAmt": self.quickPayPayInfo.payMoney_Transformed,
                                @"txnCurr": self.quickPayPayInfo.txnCurr,
                                @"payPassword" : encryptPayPassword,
                                @"billingAmt": self.quickPayPayInfo.billingAmt,
                                @"billingCurr": self.quickPayPayInfo.billingCurr,
                                @"billingRate" : self.quickPayPayInfo.billingRate,
                                @"merId": self.quickPayPayInfo.QRCodeMerchantInfoEncrypted,
                                @"cardNum": [self.quickPayPayInfo.cardNumEncrypted stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
                                @"cardSerialNum": self.quickPayPayInfo.cardSerialNum,
                                @"cardName": self.quickPayPayInfo.cardName,
                                @"cardType": self.quickPayPayInfo.cardType,
                                @"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                @"credit":_integralBtn.isSelected?@"1":@"0",
                                @"txnType": @"24"};
    [NetworkEngine singlePostWithParmas:paramSign success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"] || [[requestResult objectForKey:@"status"] isEqualToString:@"3"]) {
            //保存交易银行卡国家编码
            [[NSUserDefaults standardUserDefaults] setObject:self.quickPayPayInfo.sysareaId forKey:ISOCOUNTRYCODELASTPAY];
            _resultTradeModel = [[TradeModel alloc] init];
            
            _resultTradeModel.status = [requestResult objectForKey:@"status"];
            _resultTradeModel.merName = [requestResult objectForKey:@"merName"];
            _resultTradeModel.termCode = [requestResult objectForKey:@"termCode"];
            _resultTradeModel.orderTime = [requestResult objectForKey:@"payTime"];
            _resultTradeModel.serialNumber = [requestResult objectForKey:@"queryId"];
            _resultTradeModel.useCredit = [requestResult objectForKey:@"useCredit"];
            _resultTradeModel.billingAmt = [requestResult objectForKey:@"billingAmt"];
            _resultTradeModel.bankName = self.quickPayPayInfo.cardName;
            _resultTradeModel.billingCurr = self.quickPayPayInfo.billingCurr;
            _resultTradeModel.orderId = self.quickPayPayInfo.inTradeOrderNo;
            _resultTradeModel.txnAmt = self.quickPayPayInfo.payMoney_Transformed;
            _resultTradeModel.txnCurr = self.quickPayPayInfo.txnCurr;
            _resultTradeModel.cardNum = self.quickPayPayInfo.accNo;
            _resultTradeModel.merId = self.quickPayPayInfo.QRCodeMerchantInfoNoEncrypt;
            _resultTradeModel.billingRate = self.quickPayPayInfo.billingRate;
            _resultTradeModel.cardSerialNumber = self.quickPayPayInfo.cardSerialNum;
            _resultTradeModel.cardType = self.quickPayPayInfo.cardType;
            _resultTradeModel.creditAmt = [requestResult objectForKey:@"creditAmt"];
            _resultTradeModel.billingCurrTxnAmt = [requestResult objectForKey:@"billingCurrTxnAmt"];
            _resultTradeModel.txnCurrCreditAmt = [requestResult objectForKey:@"txnCurrCreditAmt"];
            if ([[requestResult objectForKey:@"status"] isEqualToString:@"3"]) {
                [self checkSinoPayResult];
                return ;
            }
            [self jumpToPayResult:YES message:@""];
        } else {//1失败、2待支付、64余额不足、55支付密码错误
            [self showToUser:[requestResult objectForKey:@"status"] message:[requestResult objectForKey:@"msg"]];
        }
    } failure:^(id error) {
        [self requestErrorWith:NetRequestError];
    }];
}

#pragma mark 银联国际支付
- (void)unionPay{
    NSString *couponID = @"";
    if (_couponModel && _isCanUseCoupon) {
        couponID = [TripleDESUtils getEncryptWithString:_couponModel.couponId keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    }
    
    // 3des加密支付密码
    NSString *encryptPayPassword = [TripleDESUtils getEncryptWithString:_passWord keyString: [ZFGlobleManager getGlobleManager].securityKey ivString: TRIPLEDES_IV_QUICKPAYABROAD];
    
    NSDictionary *paramSign = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                @"mobile":  [ZFGlobleManager getGlobleManager].userPhone,
                                @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                @"cardNum":self.quickPayPayInfo.cardNumEncrypted,
                                @"userKey":[ZFGlobleManager getGlobleManager].userKey,
                                @"cardName":self.quickPayPayInfo.cardName,
                                @"cardType":self.quickPayPayInfo.cardType,
                                @"emvcode":_resultStr,
                                @"upopOrderId":self.quickPayPayInfo.inTradeOrderNo,
                                @"payPassword":encryptPayPassword,
                                @"txnAmt":self.quickPayPayInfo.payMoney_Transformed,
                                @"couponId":couponID,
                                @"txnType": @"56"};
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    [NetworkEngine singlePostWithParmas:paramSign success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        NSString *status = [requestResult objectForKey:@"status"];
        if ([status isEqualToString:@"1"] || [status isEqualToString:@"2"] || [status isEqualToString:@"64"] || [status isEqualToString:@"55"]) {//1失败、2待支付、64余额不足、55支付密码错误
            [self showToUser:[requestResult objectForKey:@"status"] message:[requestResult objectForKey:@"msg"]];
        } else {
            _resultTradeModel = [[TradeModel alloc] init];
            _resultTradeModel.orderId = self.quickPayPayInfo.inTradeOrderNo;
            _resultTradeModel.cardNum = self.quickPayPayInfo.accNo;
            _resultTradeModel.merId = self.quickPayPayInfo.merId;
            
            if ([[requestResult objectForKey:@"status"] isEqualToString:@"3"]) {
                [self checkUnionPayResult];
                _checkCount = 0;
                return ;
            }
            
            if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
                [self dealData:requestResult];
            }
            [self jumpToPayResult:YES message:@""];
        }
    } failure:^(id error) {
        [self requestErrorWith:NetRequestError];
    }];
}

#pragma mark 银联URL格式支付
- (void)unionUrlPay{
    // 3des加密支付密码
    NSString *encryptPayPassword = [TripleDESUtils getEncryptWithString:_passWord keyString: [ZFGlobleManager getGlobleManager].securityKey ivString: TRIPLEDES_IV_QUICKPAYABROAD];
    
    NSDictionary *paramSign = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                @"mobile":  [ZFGlobleManager getGlobleManager].userPhone,
                                @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                @"cardNum":self.quickPayPayInfo.cardNumEncrypted,
                                @"userKey":[ZFGlobleManager getGlobleManager].userKey,
                                @"cardType":self.quickPayPayInfo.cardType,
                                @"urlcode":_resultStr,
                                @"orderId":self.quickPayPayInfo.inTradeOrderNo,
                                @"payPassword":encryptPayPassword,
                                @"txnAmt":self.quickPayPayInfo.payMoney_Transformed,
                                @"txnCurr":self.quickPayPayInfo.txnCurr,
                                @"merName":self.quickPayPayInfo.merName,
                                @"upopOrderId":self.quickPayPayInfo.upopOrderId,
                                @"txnType": @"79"};
    
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    [NetworkEngine singlePostWithParmas:paramSign success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        NSString *status = [requestResult objectForKey:@"status"];
        if ([status isEqualToString:@"1"] || [status isEqualToString:@"2"] || [status isEqualToString:@"64"] || [status isEqualToString:@"55"]) {//1失败、2待支付、64余额不足、55支付密码错误
            [self showToUser:[requestResult objectForKey:@"status"] message:[requestResult objectForKey:@"msg"]];
        } else {
            _resultTradeModel = [[TradeModel alloc] init];
            _resultTradeModel.orderId = self.quickPayPayInfo.inTradeOrderNo;
            _resultTradeModel.cardNum = self.quickPayPayInfo.accNo;
            _resultTradeModel.merId = self.quickPayPayInfo.merId;
            if ([[requestResult objectForKey:@"status"] isEqualToString:@"3"]) {
                [self checkUnionPayResult];
                _checkCount = 0;
                return ;
            }
            
            if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
                [self dealData:requestResult];
            }
            [self jumpToPayResult:YES message:@""];
        }
    } failure:^(id error) {
        [self requestErrorWith:NetRequestError];
    }];
}

- (void)dealData:(NSDictionary *)requestResult{
    _resultTradeModel.merName = [requestResult objectForKey:@"merName"];
    _resultTradeModel.billingAmt = [requestResult objectForKey:@"billingAmt"];
    _resultTradeModel.termCode = [requestResult objectForKey:@"termCode"];
    _resultTradeModel.bankName = [requestResult objectForKey:@"bankName"];
    _resultTradeModel.orderTime = [requestResult objectForKey:@"txnTime"];
    _resultTradeModel.serialNumber = [requestResult objectForKey:@"queryId"];
    _resultTradeModel.creditAmt = @"";
    _resultTradeModel.useCredit = @"";//银联 没有积分
    _resultTradeModel.billingCurr = [requestResult objectForKey:@"billingCurr"];
    _resultTradeModel.orderId = [requestResult objectForKey:@"orderId"];
    _resultTradeModel.txnAmt = [requestResult objectForKey:@"txnAmt"];
    _resultTradeModel.txnCurr = [requestResult objectForKey:@"txnCurr"];
    _resultTradeModel.merId = [requestResult objectForKey:@"merId"];
    _resultTradeModel.couponDes = [requestResult objectForKey:@"couponDes"];
    _resultTradeModel.billingCurrTxnAmt = [requestResult objectForKey:@"billingCurrTxnAmt"];
    _resultTradeModel.billingCurrdiscountAmt = [requestResult objectForKey:@"billingCurrdiscountAmt"];
}

#pragma mark 没有直接返回 查询获取交易结果
#pragma mark 查询中付交易结果
-(void)checkSinoPayResult{
    NSString *cardNumEncry = [TripleDESUtils getEncryptWithString:_resultTradeModel.cardNum keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    // 生成签名字段
    NSDictionary *paramSign = @{@"orderId": _resultTradeModel.orderId,
                                @"txnAmt": _resultTradeModel.txnAmt,
                                @"txnCurr": self.quickPayPayInfo.txnCurr,
                                @"billingAmt": self.quickPayPayInfo.billingAmt,
                                @"billingCurr": self.quickPayPayInfo.billingCurr,
                                @"billingRate" : self.quickPayPayInfo.billingRate,
                                @"merId": self.quickPayPayInfo.QRCodeMerchantInfoEncrypted,
                                @"cardNum": cardNumEncry,
                                @"cardSerialNum": _resultTradeModel.cardSerialNumber,
                                @"cardName":  _resultTradeModel.bankName,
                                @"cardType": _resultTradeModel.cardType,
                                @"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                @"txnType": @"25"};
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    [NetworkEngine singlePostWithParmas:paramSign success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[MBUtils sharedInstance] dismissMB];
            _resultTradeModel.billingAmt = [requestResult objectForKey:@"billingAmt"];
            _resultTradeModel.creditAmt = [requestResult objectForKey:@"creditAmt"];
            _resultTradeModel.merName = [requestResult objectForKey:@"merName"];
            _resultTradeModel.termCode = [requestResult objectForKey:@"termCode"];
            _resultTradeModel.orderTime = [requestResult objectForKey:@"payTime"];
            _resultTradeModel.serialNumber = [requestResult objectForKey:@"queryId"];
            _resultTradeModel.useCredit = [requestResult objectForKey:@"useCredit"];
            _resultTradeModel.billingCurrTxnAmt = [requestResult objectForKey:@"billingCurrTxnAmt"];
            _resultTradeModel.txnCurrCreditAmt = [requestResult objectForKey:@"txnCurrCreditAmt"];
            [self jumpToPayResult:YES message:@""];
        } else if ([[requestResult objectForKey:@"status"] isEqualToString:@"3"]){
            if (_checkCount < 3) {
                [self checkSinoPayResult];
                // TODO _checkCount = 0？？
                _checkCount++;
            } else {
                [[MBUtils sharedInstance] dismissMB];
                [self jumpToPayResult:NO message:NSLocalizedString(@"请稍后查询交易结果", nil)];
            }
        } else {
            [[MBUtils sharedInstance] dismissMB];
            [self showToUser:[requestResult objectForKey:@"status"] message:[requestResult objectForKey:@"msg"]];
        }
    } failure:^(id error) {
        [[MBUtils sharedInstance] showMBMomentWithText:NetRequestError inView:self.view];
    }];
}

#pragma mark 查询银联交易结果
- (void)checkUnionPayResult{
    NSString *cardNumEncry = [TripleDESUtils getEncryptWithString:_resultTradeModel.cardNum keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    NSDictionary * paramSign = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"cardNum": cardNumEncry,
                                 @"userKey":[ZFGlobleManager getGlobleManager].userKey,
                                 @"orderId":_resultTradeModel.orderId,
                                 @"txnType": @"58"};
    
    [NetworkEngine singlePostWithParmas:paramSign success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[MBUtils sharedInstance] dismissMB];
            [self dealData:requestResult];
            [self jumpToPayResult:YES message:@""];
        } else if ([[requestResult objectForKey:@"status"] isEqualToString:@"3"]){
            if (_checkCount < 3) {
                [self checkUnionPayResult];
                _checkCount++;
            } else {
                [[MBUtils sharedInstance] dismissMB];
                [self jumpToPayResult:NO message:NSLocalizedString(@"请稍后查询交易结果", nil)];
            }
        } else {//交易失败
            [[MBUtils sharedInstance] dismissMB];
            [self showToUser:[requestResult objectForKey:@"status"] message:[requestResult objectForKey:@"msg"]];
        }
    } failure:^(id error) {
        [[MBUtils sharedInstance] showMBMomentWithText:NetRequestError inView:self.view];
    }];
}

///输入密码后错误提示
- (void)showToUser:(NSString *)status message:(NSString *)message{
    if ([status isEqualToString:@"1"] || [status isEqualToString:@"2"]) {
        [self jumpToPayResult:NO message:message];
    } else if ([status isEqualToString:@"64"]){//余额不足
        [XLAlertController acWithMessage:message confirmBtnTitle:NSLocalizedString(@"确定", nil) confirmAction:^(UIAlertAction *action) {
            _cardModel.underbalance = @"1";
            if (_popView) {
                _popView.bcmArray = _cardArray;
            }
        }];
    } else if ([status isEqualToString:@"55"]){//支付密码错误
        [XLAlertController acWithMessage:message confirmBtnTitle:NSLocalizedString(@"确定", nil) confirmAction:^(UIAlertAction *action) {
            _popView.pwdView.textField.text = @"";
            [_popView.pwdView inputPwd];
            [_popView.pwdView.textField becomeFirstResponder];
        }];
    }
}

#pragma mark 跳转到支付结果页
- (void)jumpToPayResult:(BOOL)isSuccess message:(NSString *)errorMsg{
    ZFPayResultController *payResultVC = [[ZFPayResultController alloc] init];
    payResultVC.resultType = isSuccess?0:1;
    if (isSuccess) {
        payResultVC.tradeModel = _resultTradeModel;
    } else {
        payResultVC.errorMsg = errorMsg;
    }
    [self.navigationController pushViewController:payResultVC animated:YES];
}

#pragma mark - other
#pragma mark 获取默认银行卡
- (void)getDefaultCard{
    if (_cardArray) {
        _cardArray = nil;
    }
    
    _cardArray = [ZFGlobleManager getGlobleManager].bankCardArray;
    if (_cardModel) {
        if (![_cardArray containsObject:_cardModel] && _cardArray.count > _defaultCardIndex) {
            _cardModel = _cardArray[_defaultCardIndex];
        }
    } else {
        _cardModel = _cardArray[0];
        _defaultCardIndex = 0;
    }
    
    [self changeViewWith:_cardModel];
}

#pragma mark 更改支付方式 更改视图
- (void)changeViewWith:(ZFBankCardModel *)cardModel{
    _cardModel = cardModel;
    _defaultCardIndex = [_cardArray indexOfObject:cardModel];
    self.quickPayPayInfo.accNo            = cardModel.cardNo;// 此值在后面用于判断是否已选择银行卡
    self.quickPayPayInfo.cardNumEncrypted = cardModel.encryCardNo;
    self.quickPayPayInfo.cardName         = cardModel.bankName;
    self.quickPayPayInfo.cardType         = cardModel.cardType;
    self.quickPayPayInfo.cardSerialNum    = cardModel.serialNumber;
}

#pragma mark 获取积分
- (void)checkJiFen{
    //已在首页请求成功
    NSString *jfStr = [ZFGlobleManager getGlobleManager].totalCredit;
    if (jfStr) {
        _jifen = jfStr;
        _integralLabel.text = [NSString stringWithFormat:@"%@(%@)", NSLocalizedString(@"是否使用积分优惠", nil), jfStr];
        _integralBackView.hidden = NO;
        [self listenMoneyForIntegral];
        return;
    }
    
    NSDictionary * paramSign = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"isCredit": @"1",
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"txnType": @"46"};
    [NetworkEngine singlePostWithParmas:paramSign success:^(id requestResult) {
        NSDictionary *resultDic = (NSDictionary *)requestResult;
        if([[resultDic objectForKey:@"status"] isEqualToString:@"0"]){
            NSString *jifen = [resultDic objectForKey:@"totalCredit"];
            if (![jifen isKindOfClass:[NSNull class]] && jifen.integerValue > 0) {
                _jifen = jifen;
                _integralLabel.text = [NSString stringWithFormat:@"%@(%@)", NSLocalizedString(@"是否使用积分优惠", nil), jifen];
                _integralBackView.hidden = NO;
                [self listenMoneyForIntegral];
            } else {
                _integralBackView.hidden = YES;
            }
        }
    } failure:^(id error) {
        
    }];
}

#pragma mark 获取优惠券信息
- (void)checkCouponDes{
    
    NSString *merCode = [TripleDESUtils getEncryptWithString:self.quickPayPayInfo.merId keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:@"01234567"];
    NSDictionary * paramSign = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"merCode":merCode,//self.quickPayPayInfo.merId,
                                 @"txnType": @"81"};
    [NetworkEngine singlePostWithParmas:paramSign success:^(id requestResult) {
        
        if([[requestResult objectForKey:@"status"] isEqualToString:@"0"]){
            _couponArray = [[NSMutableArray alloc] init];
            NSArray *list = [requestResult objectForKey:@"couponList"];
            
            for (NSDictionary *dict in list) {
                ZFCouponModel *model = [[ZFCouponModel alloc] init];
                [model setValuesForKeysWithDictionary:dict];
                [_couponArray addObject:model];
            }
            if (_couponArray.count > 0) {
                _couponTableView.dataArray = _couponArray;
                _couponDesBackView.hidden = NO;
                _couponModel = _couponArray[0];
                [self listenMoneyForCoupon];
            } else {
                _couponDesBackView.hidden = YES;
            }
        }
    } failure:^(id error) {
        
    }];
}

#pragma mark 获取银行卡列表
- (void)getCardListData{
    NSDictionary *parameters = @{
                                 @"countryCode" : [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile" : [ZFGlobleManager getGlobleManager].userPhone,
                                 @"cardType" : @"0",
                                 @"userKey" : [ZFGlobleManager getGlobleManager].userKey,
                                 @"sessionID" : [ZFGlobleManager getGlobleManager].sessionID,
                                 @"txnType": @"11",
                                 @"version" : @"version2.1",
                                 };
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        
        [[MBUtils sharedInstance] dismissMB];
        // 将状态清空
        [ZFGlobleManager getGlobleManager].isChanged = NO;
        if (![[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:[UIApplication sharedApplication].keyWindow];
            if ([[requestResult objectForKey:@"status"] isEqualToString:@"2"]) {
                [ZFGlobleManager getGlobleManager].bankCardArray = nil;
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            return ;
        }
        
        NSArray *bankCardArray = [NSArray new];
        bankCardArray = [NSArray yy_modelArrayWithClass:[ZFBankCardModel class] json:requestResult[@"list"]];
        bankCardArray = [[ZFGlobleManager getGlobleManager] sortBankArrayWith:bankCardArray];
        [ZFGlobleManager getGlobleManager].bankCardArray = [NSMutableArray arrayWithArray:bankCardArray];
        [self getDefaultCard];
        if (_isNeedPay) {//认证完成去支付
            _popView.bcmArray = _cardArray;
            [self pay];
        }
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark 网络请求失败
- (void)requestErrorWith:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                    {
                                        [self.navigationController popViewControllerAnimated:YES];
                                    }];
    [alert addAction:confirmAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 代理方法
#pragma mark popView delegate
//输入密码
- (void)popTableViewInputPwd:(NSString *)pwString{
    if (pwString.length == 6) {
        _passWord = pwString;
        [self pay];
    }
}
///更改付款银行卡
- (void)popTableViewChangePayType:(ZFBankCardModel *)cardModel{
    //保存交易卡号
    [[ZFGlobleManager getGlobleManager] saveTradeCardWith:cardModel];
    [self changeViewWith:cardModel];
}
///点击添加银行卡
- (void)popTableViewAddBankCard{
    [self addBankCard];
}

#pragma mark - 认证银行卡
- (void)certificationBankCard:(NSString *)sysareaid {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[ZFGlobleManager getGlobleManager].areaNum forKey:@"countryCode"];
    [parameters setObject:[ZFGlobleManager getGlobleManager].userPhone forKey:@"mobile"];
    [parameters setObject:[ZFGlobleManager getGlobleManager].sessionID forKey:@"sessionID"];
    [parameters setObject:sysareaid forKey:@"sysareaid"];
    [parameters setObject:_cardModel.encryCardNo forKey:@"cardNum"];
    [parameters setObject:@"yes" forKey:@"isAgain"];
    
    if ([sysareaid isEqualToString:@"UP"]) {// 银联国际传特殊字段
        // TODO 测试写死6234154000000018
//        NSString *encryCardNo = [TripleDESUtils getEncryptWithString:@"6234154000000018" keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
//        [parameters setObject:encryCardNo forKey:@"cardNum"];
        [parameters setObject:[ZFGlobleManager getGlobleManager].userKey forKey:@"userKey"];
        [parameters setObject:@"52" forKey:@"txnType"];
        
    } else { //其他地区
        [parameters setObject:@"20" forKey:@"txnType"];
        
        if ([_cardModel.cardType isEqualToString:@"2"]) { // 其他地区信用卡,不需要请求，直接跳转
            ZFSafeVerificationController *vc = [[ZFSafeVerificationController alloc] initWithParams:parameters];
            vc.phoneNumber = _cardModel.phoneNumber;
            [self pushViewController:vc];
            return;
        }
    }
    
    // 发送请求
    [[MBUtils sharedInstance] showMBInView:self.view];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
            [[MBUtils sharedInstance] dismissMB];
            
            if ([[requestResult objectForKey:@"status"] isEqualToString:@"79"] && ![sysareaid isEqualToString:@"UP"]) {//79时不需要验证码 直接调绑卡
                // 验证码界面
                ZFGetMSCodeController *vc = [[ZFGetMSCodeController alloc] initWithParams:parameters];
                vc.phoneNumber = _cardModel.phoneNumber;
                vc.orderId = [requestResult objectForKey:@"orderId"];
                vc.status = [requestResult objectForKey:@"status"];
                [self pushViewController:vc];
                return ;
            }
            
            if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) { // 成功
                if ([sysareaid isEqualToString:@"UP"]) { // 银联国际

                    self.upModel = [ZFUPBankCardModel yy_modelWithJSON:requestResult];
                    if ([self.upModel.cvm containsObject:@"expiryDate"] || [self.upModel.cvm containsObject:@"cvn2"]) { // 有cvm要求：输入cvn、有效期等信息
                        ZFSafeVerificationController *vc = [[ZFSafeVerificationController alloc] initWithParams:parameters];
                        vc.bcModel = _cardModel;
                        vc.upModel = self.upModel;
                        [self pushViewController:vc];
                    } else { // 无cvm要求
                        // 直接查otp结果
                        [self getOtpList];
                    }
                } else { // 其他地区借记卡
                    ZFGetMSCodeController *vc = [[ZFGetMSCodeController alloc] initWithParams:parameters];
                    vc.phoneNumber = _cardModel.phoneNumber;
                    vc.orderId = [requestResult objectForKey:@"orderId"];
                    [self pushViewController:vc];
                }
            } else {
                [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
                return ;
            }
        } failure:^(NSError *error) {
            
        }];
    });
}

// 银联国际：cvm没有要求输入有效期、支付密码等，直接走这里  53
- (void)getOtpList {
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"userKey": [ZFGlobleManager getGlobleManager].userKey,
                                 @"enrolID":self.upModel.enrolID,
                                 @"expired":@"",
                                 @"cvn2":@"",
                                 @"idType":@"",
                                 @"idCard":@"",
                                 @"name":@"",
                                 @"phoneNo":@"",
                                 @"payPassword":@"",
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"isAgain":@"yes",
                                 @"cvm":self.upModel.cvm,
                                 @"txnType": @"53"};
    
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            // 判断otp是否为空
            if ([[requestResult objectForKey:@"otpMethod"] isKindOfClass:[NSNull class]]) {
                // 验证码也不需要，直接查绑定结果
                [self addUNCard];
            } else {
                // 获取验证码
                [self getUNMessageCode:[[requestResult objectForKey:@"otpMethod"] firstObject]];
            }
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
            return ;
        }
        
    } failure:^(id error) {
        
    }];
}

// 银联国际：不需要验证码,直接绑定  55
- (void)addUNCard {
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"userKey":[ZFGlobleManager getGlobleManager].userKey,
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"enrolID":self.upModel.enrolID,
                                 @"cardNum": _cardModel.encryCardNo,
                                 @"tncID":self.upModel.tncID,
                                 @"otpValue":@"",
                                 @"txnType": @"55"};
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self getCardListData];
            });
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
            return ;
        }
    } failure:^(id error) {
        
    }];
}

// 银联国际：获取验证码 54
- (void)getUNMessageCode:(NSString *)otpMethod {
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"userKey":[ZFGlobleManager getGlobleManager].userKey,
                                 @"enrolID":self.upModel.enrolID,
                                 @"otpMethod":otpMethod,
                                 @"txnType": @"54"};
    
    [[MBUtils sharedInstance] showMBInView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if (![[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
            return ;
        }
        
        ZFGetMSCodeController *vc = [[ZFGetMSCodeController alloc] initWithBankCardModel:_cardModel UPBankCardModel:self.upModel];
        vc.otpMethod = otpMethod;
        [self pushViewController:vc];
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark textfield 代理
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    BOOL isHaveDian= NO;
    if ([textField.text containsString:@"."]) {
        isHaveDian = YES;
    }else{
        isHaveDian = NO;
    }
    NSString *str = [NSString stringWithFormat:@"%@%@", _moneyTextField.text, string];
    if ([str doubleValue] > 9999999.99) {
        [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"消费金额不能超出9999999.99元", nil) inView:self.view];
        return NO;
    }
    if (string.length > 0) {
        
        //当前输入的字符
        unichar single = [string characterAtIndex:0];
        // 不能输入.0-9以外的字符
        if (!((single >= '0' && single <= '9') || single == '.')) {
            return NO;
        }
        
        // 只能有一个小数点
        if (isHaveDian && single == '.') {
            return NO;
        }
        
        // 如果第一位是.则前面加上0.
        if ((textField.text.length == 0) && (single == '.')) {
            textField.text = @"0";
        }
        
        // 如果第一位是0则后面必须输入点，否则不能输入。
        if ([textField.text hasPrefix:@"0"]) {
            if (textField.text.length > 1) {
                NSString *secondStr = [textField.text substringWithRange:NSMakeRange(1, 1)];
                if (![secondStr isEqualToString:@"."]) {
                    return NO;
                }
            }else{
                if (![string isEqualToString:@"."]) {
                    return NO;
                }
            }
        }
        
        // 小数点后最多能输入两位
        if (isHaveDian) {
            NSRange ran = [textField.text rangeOfString:@"."];
            // 由于range.location是NSUInteger类型的，所以这里不能通过(range.location - ran.location)>2来判断
            if (range.location > ran.location) {
                if ([textField.text pathExtension].length > 1) {
                    return NO;
                }
            }
        }
    }
    
    return YES;
}

@end
