//
//  ZFOfflineQRCodeController.m
//  newupop
//
//  Created by 中付支付 on 2017/10/25.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFOfflineQRCodeController.h"
#import "ZFPayTypeTableView.h"
#import "ZFPwdInputView.h"
#import "SGQRCodeTool.h"

@interface ZFOfflineQRCodeController ()<ZFPayTypeTableDelegate>
///上部视图底部背景
@property (nonatomic, strong)UIView *topBackView;
///二维码
@property (nonatomic, strong)UIImageView *qrImageView;
///提示标签
@property (nonatomic, strong)UILabel *contentLabel;
///改变支付方式底部视图 方便隐藏／显示
@property (nonatomic, strong)UIView *changeCardBack;
///支付方式
@property (nonatomic, strong)UILabel *payBankLabel;
///支付方式图标
@property (nonatomic, strong)UIImageView *logoImage;
///更改支付方式按钮
@property (nonatomic, strong)UIButton *changeBtn;

///定时刷新二维码
@property (strong, nonatomic) NSTimer *refreshTimer;
///付款类型列表
@property (nonatomic, strong)ZFPayTypeTableView *payTypeView;

///默认银行卡的坐标
@property (nonatomic, assign)NSInteger defaultIndex;

@property (nonatomic, strong) ZFBankCardModel *cardModel;
///定位地区
@property (nonatomic, strong)NSString *ISOCountryCode;

@end

@implementation ZFOfflineQRCodeController

- (void)dealloc{
    for (ZFBankCardModel *model in _payTypeView.dataArray) {
        model.isSelect = @"0";
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myTitle = @"付款";
    _ISOCountryCode = [LocationUtils sharedInstance].ISOCountryCode;
    [self removeViewController];
    [self createView];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [_refreshTimer invalidate];
    _refreshTimer = nil;
}

- (void)createView{
    self.view.backgroundColor = MainThemeColor;
    CGFloat heightRate = (SCREEN_HEIGHT/660);
    CGFloat topHeight = 360*heightRate;
    
    //底部白色背景
    _topBackView = [[UIView alloc] initWithFrame:CGRectMake(20, IPhoneXTopHeight+20, SCREEN_WIDTH-40, topHeight)];
    _topBackView.backgroundColor = [UIColor whiteColor];
    _topBackView.layer.cornerRadius = 5;
    [self.view addSubview:_topBackView];
    
    //二维码
    _qrImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160*heightRate, 160*heightRate)];
    _qrImageView.center = CGPointMake(_topBackView.width/2, 60*heightRate+_qrImageView.height/2);
    [_topBackView addSubview:_qrImageView];
    
    _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _qrImageView.bottom+10, _topBackView.width, 40)];
    _contentLabel.text = NSLocalizedString(@"请向商家提供此付款码付款", nil);
    _contentLabel.textAlignment = NSTextAlignmentCenter;
    _contentLabel.font = [UIFont systemFontOfSize:16];
    _contentLabel.numberOfLines = 0;
    [_topBackView addSubview:_contentLabel];
    
    //更改支付方式
    _changeCardBack = [[UIView alloc] initWithFrame:CGRectMake(0, topHeight-40, _topBackView.width, 20)];
    [_topBackView addSubview:_changeCardBack];
    
    _logoImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, 20, 20)];
    [_changeCardBack addSubview:_logoImage];
    
    _payBankLabel = [[UILabel alloc] initWithFrame:CGRectMake(_logoImage.right+5, 0, _changeCardBack.width-105, 20)];
    _payBankLabel.text = NSLocalizedString(@"请先绑定对应的银行卡", nil);
    _payBankLabel.font = [UIFont systemFontOfSize:15];
    [_changeCardBack addSubview:_payBankLabel];
    
    _changeBtn = [[UIButton alloc] initWithFrame:CGRectMake( _changeCardBack.width-80, 0, 60, 20)];
    _changeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    _changeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [_changeBtn setTitle:NSLocalizedString(@"更改", nil) forState:UIControlStateNormal];
    [_changeBtn setTitleColor:MainThemeColor forState:UIControlStateNormal];
    [_changeBtn addTarget:self action:@selector(changePayType) forControlEvents:UIControlEventTouchUpInside];
    [_changeCardBack addSubview:_changeBtn];
    
    //付款方式视图
    _payTypeView = [[ZFPayTypeTableView alloc] initWithFrame:CGRectMake(0, 140, SCREEN_WIDTH, SCREEN_HEIGHT-140-64)];
    _payTypeView.canAddCardType = 1;
    _payTypeView.delegate = self;
    _payTypeView.tipString = NSLocalizedString(@"扫码枪银行卡", nil);
    [self.view addSubview:_payTypeView];
    [self chooseBankCard];
}

- (void)changePayType{
    [_payTypeView show];
}

#pragma mark 付款方式代理
- (void)chooseCard:(ZFBankCardModel *)cardModel index:(NSInteger)index{
    
    [[ZFGlobleManager getGlobleManager].bankCardArray[_defaultIndex] setIsSelect:@"0"];
    _defaultIndex = index;
    [[ZFGlobleManager getGlobleManager].bankCardArray[_defaultIndex] setIsSelect:@"1"];
    _payTypeView.dataArray = [ZFGlobleManager getGlobleManager].bankCardArray;
    
    [self changeViewWith:cardModel];
}
- (void)payTypeTableViewClickAdd{
    
}

#pragma mark 更改支付方式 更改视图
- (void)changeViewWith:(ZFBankCardModel *)cardModel{
    _logoImage.image = [UIImage imageNamed:cardModel.logoStr];
    NSString *cardNum = [cardModel.cardNo substringFromIndex:cardModel.cardNo.length-4];
    NSString *language = [NetworkEngine getCurrentLanguage];
    NSString *bankName = [language isEqualToString:@"2"]?cardModel.bankName:cardModel.bankNameLog;
    _payBankLabel.text = [NSString stringWithFormat:@"%@(%@)", bankName, cardNum];
    
    self.cardModel = cardModel;
    [self generateQRCode];
}

#pragma mark 从银行卡列表中获取默认银行卡
- (void)chooseBankCard{
    // 已绑卡数量
    _cardModel = [[ZFBankCardModel alloc] init];

    NSMutableArray *arr = [ZFGlobleManager getGlobleManager].bankCardArray;
    NSMutableArray *cardArray = [[NSMutableArray alloc] init];
    for (ZFBankCardModel *model in arr) {
        if ([[ZFGlobleManager getGlobleManager] isSupportTheCity:_ISOCountryCode cardModel:model]) {
            [cardArray addObject:model];
        }
    }
    if (cardArray.count == 0) {
        [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"未找到当前城市的银行卡,暂不能无网络支付", nil) inView:[UIApplication sharedApplication].keyWindow];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    _payTypeView.dataArray = cardArray;
    
    // 显示用来支付的银行卡信息
    ZFBankCardModel *cardModel = cardArray[0];
    _defaultIndex = 0;
    [cardModel setIsSelect:@"1"];
    _payTypeView.dataArray = [ZFGlobleManager getGlobleManager].bankCardArray;
   
    [self changeViewWith:cardModel];
    
    for (NSInteger i = 1; i < cardArray.count; i++) {
        ZFBankCardModel *info = cardArray[i];
        [info setIsSelect:@"0"];
    }
}

#pragma mark 生成二维码
- (void)generateQRCode{
    //offline=sessionId&3des(手机区号&注册手机号&国家代码&银行卡号&产生二维码时间&sessionId&随机数&支付密码)
    NSString *countryCode = [ZFGlobleManager getGlobleManager].areaNum;
    NSString *phoneNum = [ZFGlobleManager getGlobleManager].userPhone;
    NSString *sessionID = [ZFGlobleManager getGlobleManager].sessionID;
    NSString *randomNo = [ZFGlobleManager getGlobleManager].ramdom;
    NSString *securityKey = [ZFGlobleManager getGlobleManager].securityKey;
    
    //随机数每次加一
    [ZFGlobleManager getGlobleManager].ramdom = [NSString stringWithFormat:@"%zd", [[ZFGlobleManager getGlobleManager].ramdom integerValue]+1];
    NSString *timeStr = [self getTimeStr];
    
    //密码加密
    NSString *pwdEncryStr = [TripleDESUtils getEncryptWithString:_passWord keyString:securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    //卡号加密
    NSString *cardNmuEncryStr = [TripleDESUtils getEncryptWithString:self.cardModel.cardNo keyString:securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    
    NSString *encryStr = [NSString stringWithFormat:@"%@&%@&%@&%@&%@&%@&%@&%@", countryCode, phoneNum, _ISOCountryCode, cardNmuEncryStr, timeStr, sessionID, randomNo, pwdEncryStr];
    NSLog(@"加密之前 = %@", encryStr);
    encryStr = [TripleDESUtils getEncryptWithString:encryStr keyString:securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    
    NSString *qrcodeStr = [NSString stringWithFormat:@"offline=%@&%@", sessionID, encryStr];
    _qrImageView.image = [SGQRCodeTool SG_generateWithDefaultQRCodeData:qrcodeStr imageViewWidth:300];
    _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(generateQRCode) userInfo:nil repeats:YES];
}

- (NSString *)getTimeStr{
    NSString*timeSp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[ZFGlobleManager getGlobleManager].timeDiff+[timeSp integerValue]];
    
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    
    return confromTimespStr;
}

#pragma mark 删除输入密码页面
- (void)removeViewController {
    NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];
    [navigationArray removeObjectAtIndex:([self.navigationController.viewControllers count] - 2)]; // You can pass your index here
    self.navigationController.viewControllers = navigationArray;
}
@end
