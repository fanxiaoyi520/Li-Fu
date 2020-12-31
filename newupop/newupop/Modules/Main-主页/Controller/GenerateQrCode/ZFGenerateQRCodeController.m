//
//  ZFGenerateQRCodeController.m
//  newupop
//
//  Created by 中付支付 on 2017/8/2.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFGenerateQRCodeController.h"
#import "SGQRCode.h"
#import "ZFScanQrcodeController.h"
#import "ZFPayTypeTableView.h"
#import "LocationUtils.h"
#import "ZFAddCardNoViewController.h"
#import "ZFPayResultController.h"
#import "YYModel.h"
#import "ZFSafeVerificationController.h"
#import "ZFGetMSCodeController.h"

#import "ZFAddBankCardController.h"

///重新生成时间
#define REFERESH_TIME 60
///查询时间
#define QURERY_TIME 5
///高度比
#define HEIGHT_RATE SCREEN_HEIGHT/667

@interface ZFGenerateQRCodeController ()<ZFPayTypeTableDelegate>
///上部视图底部背景
@property (nonatomic, strong)UIView *topBackView;
///条形码
@property (nonatomic, strong)UIImageView *txImageView;
/** 提示问题 */
@property(nonatomic, strong) UILabel *tipL;

///
@property (nonatomic, strong)UIImageView *qrImageView;
///改变支付方式底部视图 方便隐藏／显示
@property (nonatomic, strong)UIView *changeCardBack;
///支付方式
@property (nonatomic, strong)UILabel *payBankLabel;
///支付方式图标
@property (nonatomic, strong)UIImageView *logoImage;
///更改支付方式按钮
@property (nonatomic, strong)UIButton *changeBtn;
///点击放大后的视图
@property (nonatomic, strong)UIView *bigView;
///屏幕亮度
@property (nonatomic, assign)CGFloat brightness;
///银行卡数组
@property (nonatomic, strong)NSMutableArray *cardArray;
///付款类型列表
@property (nonatomic, strong)ZFPayTypeTableView *payTypeView;
///提示标签
@property (nonatomic, strong)UILabel *contentLabel;

///积分底部视图
@property (nonatomic, strong)UIView *integralBackView;
///是否使用积分标签
@property (nonatomic, strong)UILabel *integralLabel;
///积分按钮
@property (nonatomic, strong)UIButton *integralBtn;
///积分图片
@property (nonatomic, strong)UIImageView *integralImage;
///积分
@property (nonatomic, strong)NSString *jifen;

///付款方式 1 unionpay  2 sinopay
@property (nonatomic, assign)NSInteger payType;
///银联银行卡index
@property (nonatomic, assign)NSInteger unionIndex;
///中付默认银行卡
@property (nonatomic, assign)NSInteger sinoIndex;

///下面视图底部
@property (nonatomic, strong)UIView *bottomBackView;
///中付
@property (nonatomic, strong)UIImageView *sinoImageView;
///银联
@property (nonatomic, strong)UIImageView *unionImageView;
///中付显示文字
@property (nonatomic, strong)UILabel *sLabel;
///银联显示文字
@property (nonatomic, strong)UILabel *uLabel;

///去绑卡按钮
@property (nonatomic, strong)UIButton *toBandBtn;
///
@property (nonatomic, strong)UIImageView *noCardImageView;

///交易银行卡
@property (nonatomic, strong)ZFBankCardModel *cardModel;

///二维码字符串
@property (nonatomic, strong)NSString *qrCode;
///条形码字符串
@property (nonatomic, strong)NSString *brCode;
///生成二维码定时器
@property (nonatomic, strong)NSTimer *refershCodeTimer;
///查询结果定时器
@property (nonatomic, strong)NSTimer *queryTimer;

///交易结果
@property (nonatomic, strong)TradeModel *resulltTradeModel;
///中付被扫id
@property (nonatomic, strong)NSString *sinoPayID;
///银联被扫id
@property (nonatomic, strong)NSString *unionPayID;

///放大后底部
@property (nonatomic, strong)UIView *bigImageBack;
///放大后的条形码
@property (nonatomic, strong)UIImageView *bigTXImageView;
///放大后的二维码
@property (nonatomic, strong)UIImageView *bigQRImageView;
/** 条形码内容视图 */
@property(nonatomic, weak) UIView *txView;
/** 条形码字符串 */
@property(nonatomic, weak) UILabel *barcodeL;

///要去认证的银行卡
@property (nonatomic, strong)ZFBankCardModel *tempCardModel;
///是否是认证回来
@property (nonatomic, assign)BOOL isVerification;
///定位地区
@property (nonatomic, strong)NSString *ISOCountryCode;
/** 切换支付地区按钮 */
@property (nonatomic, strong) UIButton *switchAreaBtn;

@end

@implementation ZFGenerateQRCodeController

- (void)dealloc{
    [ZFGlobleManager getGlobleManager].notNeedShowSuccess = NO;
    //清空余额不足标志
    for (ZFBankCardModel *model in [ZFGlobleManager getGlobleManager].bankCardArray) {
        model.underbalance = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[UIScreen mainScreen] setBrightness:_brightness];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self destoryTimer];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self showOriginView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([ZFGlobleManager getGlobleManager].isChanged) {
        [self getCardListData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myTitle = @"付款码付款";
//    _payType = 2;
    _payType = 1;
    if (_fromType == 1) {
        _payType = 1;
    }
    self.view.backgroundColor = MainThemeColor;
    DLog(@"-----%.f---%.f", SCREEN_HEIGHT, SCREEN_WIDTH);
    _brightness = [UIScreen mainScreen].brightness;
    [self removeViewController];
    
    _ISOCountryCode = [LocationUtils sharedInstance].ISOCountryCode;
    
    [self createView];
    // 创建放大视图
    [self createBigView];
    if (_fromType != 1) {//也不需要查积分
        [self checkJiFen];
    }
}

#pragma mark 创建上部视图
- (void)createView{
    CGFloat topHeight = 360*HEIGHT_RATE;
    
    //底部白色背景
    _topBackView = [[UIView alloc] initWithFrame:CGRectMake(20, IPhoneXTopHeight+20, SCREEN_WIDTH-40, topHeight)];
    _topBackView.backgroundColor = [UIColor whiteColor];
    _topBackView.layer.cornerRadius = 5;
    [self.view addSubview:_topBackView];
    
    // 数字
    UILabel *tipL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _topBackView.width, 40)];
    tipL.textColor = [UIColor grayColor];
    tipL.textAlignment = NSTextAlignmentCenter;
    tipL.font = [UIFont systemFontOfSize:13.0];
    tipL.text = NSLocalizedString(@"点击可查看付款码数字", nil);
    [_topBackView addSubview:tipL];
    self.tipL = tipL;
    
    _txImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 40, _topBackView.width-60, 60)];
    _txImageView.hidden = YES;
    [_topBackView addSubview:_txImageView];
    
    _txImageView.tag = 1;
    _txImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImageView:)];
    [_txImageView addGestureRecognizer:tap1];
    
    
    //二维码
    _qrImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160*HEIGHT_RATE, 160*HEIGHT_RATE)];
    _qrImageView.center = CGPointMake(_topBackView.width/2, 60*HEIGHT_RATE+_qrImageView.height/2);
    [_topBackView addSubview:_qrImageView];
//    //点击放大
    _qrImageView.userInteractionEnabled = YES;
    _qrImageView.tag = 2;
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImageView:)];
    [_qrImageView addGestureRecognizer:tap2];
    
    //label
    _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _qrImageView.bottom+10, _topBackView.width, 40)];
    _contentLabel.text = NSLocalizedString(@"请向商家提供此付款码付款", nil);
    _contentLabel.textAlignment = NSTextAlignmentCenter;
    _contentLabel.font = [UIFont systemFontOfSize:16];
    _contentLabel.numberOfLines = 0;
    [_topBackView addSubview:_contentLabel];
    
    //切换支付地区按钮
    _switchAreaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_switchAreaBtn setTitleColor:MainThemeColor forState:UIControlStateNormal];
    _switchAreaBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    _switchAreaBtn.frame = CGRectMake(30, topHeight-20, _topBackView.width-60, 30);
    [_switchAreaBtn setTitle:NSLocalizedString(@"切换非中国大陆支付", nil) forState:UIControlStateNormal];
    [_switchAreaBtn setTitle:NSLocalizedString(@"切换中国大陆支付", nil) forState:UIControlStateSelected];
    [_switchAreaBtn addTarget:self action:@selector(switchAreaBtnClick) forControlEvents:UIControlEventTouchUpInside];
    _switchAreaBtn.selected = ![[ZFGlobleManager getGlobleManager].areaNum isEqualToString:@"86"];//选中即非中国大陆
    _txImageView.hidden = _switchAreaBtn.selected;
    self.tipL.hidden = _txImageView.hidden;
    [_topBackView addSubview:_switchAreaBtn];
    
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
    
    [self createJifenView];
    [self createBottomView];
    
    //无卡时显示
    _noCardImageView = [[UIImageView alloc] initWithFrame:_qrImageView.frame];
    _noCardImageView.image = [UIImage imageNamed:@"nocard_icon_light"];
    _noCardImageView.hidden = YES;
    [_topBackView addSubview:_noCardImageView];
    
    _toBandBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    [_toBandBtn setTitle:NSLocalizedString(@"去绑卡", nil) forState:UIControlStateNormal];
    [_toBandBtn setTitleColor:MainThemeColor forState:UIControlStateNormal];
    _toBandBtn.layer.borderWidth = 1;
    _toBandBtn.layer.cornerRadius = 5;
    _toBandBtn.layer.borderColor = MainThemeColor.CGColor;
    _toBandBtn.hidden = YES;
    [_toBandBtn addTarget:self action:@selector(toAddCard) forControlEvents:UIControlEventTouchUpInside];
    [_topBackView addSubview:_toBandBtn];
    
    [self getDefaultCard];
}

- (void)switchAreaBtnClick {
    _switchAreaBtn.selected = !_switchAreaBtn.selected;
    _txImageView.hidden = _switchAreaBtn.selected;
    self.tipL.hidden = _txImageView.hidden;
    [self updateImageVFrame];
}

- (void)updateImageVFrame {
    if (_txImageView.hidden) {
        _txImageView.frame = CGRectMake(30, 5*HEIGHT_RATE, _topBackView.width-60, 60*HEIGHT_RATE);
        [self generateQrCode:_qrCode];
    } else {
        _txImageView.frame = CGRectMake(30, 40*HEIGHT_RATE, _topBackView.width-60, 60*HEIGHT_RATE);
        [self generateQrCode:_brCode];
    }
    _qrImageView.size = CGSizeMake(160*HEIGHT_RATE, 160*HEIGHT_RATE);
    _qrImageView.center = CGPointMake(_topBackView.width/2, _txImageView.bottom+30+_qrImageView.height/2);
    _contentLabel.frame = CGRectMake(0, _qrImageView.bottom+10, _topBackView.width, 40);
}

#pragma mark 创建积分和付款方式选择视图
- (void)createJifenView{
    //积分
    _integralBackView = [[UIView alloc] initWithFrame:CGRectMake(20, _topBackView.bottom+20, SCREEN_WIDTH-40, 50)];
    _integralBackView.backgroundColor = [UIColor whiteColor];
    _integralBackView.layer.cornerRadius = 5;
    _integralBackView.hidden = YES;
    [self.view addSubview:_integralBackView];
    //积分标签
    _integralLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, _integralBackView.width-40, 20)];
    _integralLabel.centerY = _integralBackView.height/2;
    //_integralLabel.text = NSLocalizedString(@"积分查询中", nil);
    _integralLabel.textColor = UIColorFromRGB(0xFF2640);
    _integralLabel.font = [UIFont systemFontOfSize:14];
    [_integralBackView addSubview:_integralLabel];
    //积分图片
    _integralImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    _integralImage.image = [UIImage imageNamed:@"icon_confirm_normal"];
    _integralImage.center = CGPointMake(_integralBackView.width-25, _integralLabel.centerY);
    [_integralBackView addSubview:_integralImage];
    
    //积分按钮
    _integralBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _integralBtn.frame = CGRectMake(0, 0, _integralBackView.width, _integralBackView.height);
    [_integralBtn addTarget:self action:@selector(clickIntegralBtn) forControlEvents:UIControlEventTouchUpInside];
    [_integralBackView addSubview:_integralBtn];
}

#pragma mark 创建底部支付方式视图
- (void)createBottomView{
   
    _bottomBackView = [[UIView alloc] initWithFrame:CGRectMake(40, SCREEN_HEIGHT-90, SCREEN_WIDTH-80, 90)];
    _bottomBackView.backgroundColor = MainThemeColor;
    [self.view addSubview:_bottomBackView];
    
    if (_fromType == 1) {
        _bottomBackView.hidden = YES;
    }
    //test 先隐藏
    _bottomBackView.hidden = YES;
    
    UIView *backView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _bottomBackView.width/2, _bottomBackView.height)];
    backView2.backgroundColor = MainThemeColor;
    backView2.tag = 2;
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeSinoOrUnion:)];
    [backView2 addGestureRecognizer:tap2];
    [_bottomBackView addSubview:backView2];
    
    _sinoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 28, 28)];
    _sinoImageView.center = CGPointMake(backView2.width/2, 14);
    _sinoImageView.image = [UIImage imageNamed:@"btn_qrcode_sinopay_highlight"];
    [backView2 addSubview:_sinoImageView];
    _sLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _sinoImageView.bottom+10, backView2.width, 15)];
    _sLabel.font = [UIFont systemFontOfSize:15];
    _sLabel.textColor = [UIColor whiteColor];
    _sLabel.textAlignment = NSTextAlignmentCenter;
    _sLabel.text = NSLocalizedString(@"扫码枪", nil);
    [backView2 addSubview:_sLabel];
    
    
    UIView *backView1 = [[UIView alloc] initWithFrame:CGRectMake(backView2.right, backView2.y, backView2.width, backView2.height)];
    backView1.backgroundColor = MainThemeColor;
    backView1.tag = 1;
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeSinoOrUnion:)];
    [backView1 addGestureRecognizer:tap1];
    [_bottomBackView addSubview:backView1];
    
    _unionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 28, 28)];
    _unionImageView.center = CGPointMake(backView1.width/2, 14);
    _unionImageView.image = [UIImage imageNamed:@"btn_qrcode_unionpay_normal"];
    [backView1 addSubview:_unionImageView];
    _uLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _unionImageView.bottom+10, backView1.width, 15)];
    _uLabel.font = [UIFont systemFontOfSize:15];
    _uLabel.textColor = [UIColor whiteColor];
    _uLabel.textAlignment = NSTextAlignmentCenter;
    _uLabel.text = NSLocalizedString(@"银联钱包", nil);
    [backView1 addSubview:_uLabel];
    
    
    if (_payType == 1) {
        _sLabel.alpha = 0.7;
    } else {
        _uLabel.alpha = 0.7;
    }
    
    //付款方式视图
    _payTypeView = [[ZFPayTypeTableView alloc] initWithFrame:CGRectMake(0, 200, SCREEN_WIDTH, SCREEN_WIDTH-200)];
    _payTypeView.delegate = self;
//    _payTypeView.tipString = NSLocalizedString(@"银联国际银行卡", nil);
    [self.view addSubview:_payTypeView];
    
}

#pragma mark 放大后的视图
- (void)createBigView{
    _bigImageBack = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _bigImageBack.backgroundColor = [UIColor whiteColor];
    _bigImageBack.hidden = YES;
    _bigImageBack.alpha = 0;
    [self.view addSubview:_bigImageBack];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOriginView)];
    [_bigImageBack addGestureRecognizer:tap];
    
    UIView *txView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH-40, 200)];
    txView.hidden = YES;
    txView.alpha = 0;
    txView.centerY = SCREEN_HEIGHT/2;
    [_bigImageBack addSubview:txView];
    self.txView = txView;
    
    // 数字
    UILabel *barcodeL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, txView.width, 50)];
    barcodeL.textColor = [UIColor blackColor];
    barcodeL.textAlignment = NSTextAlignmentCenter;
    barcodeL.numberOfLines = 1;
    barcodeL.font = [UIFont systemFontOfSize:25.0];
    barcodeL.adjustsFontSizeToFitWidth = YES;
    [txView addSubview:barcodeL];
    self.barcodeL = barcodeL;
    
    // 条形码
    _bigTXImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, barcodeL.height, txView.width, txView.height-barcodeL.height)];
    [txView addSubview:_bigTXImageView];
    
    _bigQRImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 180*HEIGHT_RATE, 180*HEIGHT_RATE)];
    _bigQRImageView.center = self.view.center;
    _bigQRImageView.hidden = YES;
    _bigQRImageView.alpha = 0;
    [_bigImageBack addSubview:_bigQRImageView];
}

#pragma mark 点击条形码或二维码
- (void)clickImageView:(UITapGestureRecognizer *)tap{
    NSInteger tag = tap.view.tag;
    [self showBigViewWithType:tag];
}

#pragma mark 放大 1 放大条形码  2 放大二维码
- (void)showBigViewWithType:(NSInteger)type{
    _bigImageBack.hidden = NO;
    if (type == 1) {
        self.txView.hidden = NO;
        [UIView animateWithDuration:0.5 animations:^{
            _bigImageBack.alpha = 1;
            self.txView.alpha = 1;
            self.txView.transform = CGAffineTransformMakeRotation((90.0f * M_PI) / 180.0f);
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
            
        } completion:^(BOOL finished) {
            
        }];
    } else {
        _bigQRImageView.hidden = NO;
        [UIView animateWithDuration:0.5 animations:^{
            _bigImageBack.alpha = 1;
            _bigQRImageView.alpha = 1;
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
        } completion:^(BOOL finished) {
            
        }];
    }
}

#pragma mark 缩小回原来
- (void)showOriginView{
    [UIView animateWithDuration:0.5 animations:^{
        _bigImageBack.alpha = 0;
        self.txView.alpha = 0;
        self.txView.alpha = 0;
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
    } completion:^(BOOL finished) {
        _bigImageBack.hidden = YES;
        _bigQRImageView.hidden = YES;
        self.txView.hidden = YES;
        self.txView.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark 没有绑定银行卡页面
- (void)viewForNoCard:(BOOL)canChange{
    CGFloat topHeight = 410*HEIGHT_RATE;
    
    [[UIScreen mainScreen] setBrightness:_brightness];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    _bigQRImageView.userInteractionEnabled = NO;
    _bigTXImageView.userInteractionEnabled = NO;
    
    _txImageView.hidden = YES;
    self.tipL.hidden = YES;
    _txImageView.image = nil;
    _changeCardBack.hidden = YES;
    _integralBackView.hidden = YES;
    _qrImageView.hidden = YES;
    _qrImageView.image = nil;
    _switchAreaBtn.hidden = YES;
    _topBackView.size = CGSizeMake(_topBackView.width, topHeight);
    
    _noCardImageView.hidden = NO;
    _noCardImageView.size = CGSizeMake(100*HEIGHT_RATE, 100*HEIGHT_RATE);
    _noCardImageView.center = CGPointMake(_topBackView.width/2, IPhoneXTopHeight+_noCardImageView.width/2);
    _noCardImageView.image = [UIImage imageNamed:@"nocard_icon_light"];
    
    _contentLabel.frame = CGRectMake(0, _noCardImageView.bottom+40*HEIGHT_RATE, _topBackView.width, 40);
    _contentLabel.numberOfLines = 0;
    _contentLabel.textColor = [UIColor grayColor];
    _contentLabel.text = NSLocalizedString(@"暂未绑定银行卡\n请绑定银行卡后重试", nil);
    if (_payType == 2) {
        _contentLabel.text = NSLocalizedString(@"暂未绑定当前城市的银行卡\n请绑定银行卡后重试", nil);
    }
    
    if (canChange) {//有卡 但是没有当前地区的卡
        _noCardImageView.size = CGSizeMake(120*HEIGHT_RATE, 120*HEIGHT_RATE);
        _noCardImageView.center = CGPointMake(_topBackView.width/2, IPhoneXTopHeight+_noCardImageView.width/2);
        _noCardImageView.image = [UIImage imageNamed:@"icon_nosupport_card"];
        _toBandBtn.hidden = YES;
        _contentLabel.text = NSLocalizedString(@"请选择支付银行卡", nil);
        _contentLabel.textColor = [UIColor blackColor];
        _changeCardBack.frame = CGRectMake(0, topHeight-40, _topBackView.width, 20);
        _changeCardBack.hidden = NO;
        _logoImage.image = [UIImage imageNamed:@"icon_add_card_image"];
        _payBankLabel.text = NSLocalizedString(@"请选择银行卡", nil);
        [_changeBtn setTitle:NSLocalizedString(@"选择", nil) forState:UIControlStateNormal];
        return;
    }
    _toBandBtn.center = CGPointMake(_topBackView.width/2, _contentLabel.bottom+50*HEIGHT_RATE);
    _toBandBtn.hidden = NO;
}

#pragma mark 更改支付方式 更改视图
- (void)changeViewWith:(ZFBankCardModel *)cardModel{
    _cardModel = cardModel;
    _toBandBtn.hidden = YES;
    _noCardImageView.hidden = YES;
    _qrImageView.hidden = NO;
    [_changeBtn setTitle:NSLocalizedString(@"更改", nil) forState:UIControlStateNormal];
    
    if (_payType == 1) {
        [self unionFrame];
        [self getUnionQRCodeInfo];
    } else {
        [self sinoFrame];
        [self getSinoQRCodeInfo];
    }
}

#pragma mark 银联有卡页面
- (void)unionFrame{
    CGFloat topHeight = 417*HEIGHT_RATE;
    
//    self.tipL.hidden = NO;
//    _txImageView.hidden = NO;
    _txImageView.hidden = ![[ZFGlobleManager getGlobleManager].areaNum isEqualToString:@"86"];
    self.tipL.hidden = _txImageView.hidden;
    _topBackView.size = CGSizeMake(_topBackView.width, topHeight);
    if (_txImageView.hidden) {
        _txImageView.frame = CGRectMake(30, 10*HEIGHT_RATE, _topBackView.width-60, 60*HEIGHT_RATE);
    } else {
        _txImageView.frame = CGRectMake(30, 40*HEIGHT_RATE, _topBackView.width-60, 60*HEIGHT_RATE);
    }
    _qrImageView.size = CGSizeMake(160*HEIGHT_RATE, 160*HEIGHT_RATE);
    _qrImageView.center = CGPointMake(_topBackView.width/2, _txImageView.bottom+30+_qrImageView.height/2);
    _contentLabel.frame = CGRectMake(0, _qrImageView.bottom+10, _topBackView.width, 40);
    _changeCardBack.frame = CGRectMake(0, topHeight-40, _topBackView.width, 20);
    
    _contentLabel.text = NSLocalizedString(@"请向商家提供此付款码付款", nil);
    _changeCardBack.hidden = NO;
    _logoImage.image = [UIImage imageNamed:_cardModel.logoStr];
    NSString *cardNum = [_cardModel.cardNo substringFromIndex:_cardModel.cardNo.length-4];
    NSString *language = [NetworkEngine getCurrentLanguage];
    NSString *bankName = [language isEqualToString:@"2"]?_cardModel.bankName:_cardModel.bankNameLog;
    _payBankLabel.text = [NSString stringWithFormat:@"%@(%@)", bankName, cardNum];
    _integralBackView.hidden = YES;
}

#pragma mark 中付有卡页面
- (void)sinoFrame{
    CGFloat topHeight = 360*HEIGHT_RATE;
    
    _txImageView.hidden = YES;
    self.tipL.hidden = YES;
    _txImageView.image = nil;
    _topBackView.size = CGSizeMake(_topBackView.width, topHeight);
    _qrImageView.size = CGSizeMake(160*HEIGHT_RATE, 160*HEIGHT_RATE);
    _qrImageView.center = CGPointMake(_topBackView.width/2, 60*HEIGHT_RATE+_qrImageView.height/2);
    _contentLabel.frame = CGRectMake(0, _qrImageView.bottom+10, _topBackView.width, 40);
    _changeCardBack.frame = CGRectMake(0, topHeight-40, _topBackView.width, 20);
    
    _contentLabel.text = NSLocalizedString(@"请向商家提供此付款码付款", nil);
    _changeCardBack.hidden = NO;
    _logoImage.image = [UIImage imageNamed:_cardModel.logoStr];
    NSString *cardNum = [_cardModel.cardNo substringFromIndex:_cardModel.cardNo.length-4];
    NSString *language = [NetworkEngine getCurrentLanguage];
    NSString *bankName = [language isEqualToString:@"2"]?_cardModel.bankName:_cardModel.bankNameLog;
    _payBankLabel.text = [NSString stringWithFormat:@"%@(%@)", bankName, cardNum];
    
    if (_jifen) {
        _integralBackView.hidden = NO;
    }
}

#pragma mark 去绑卡
- (void)toAddCard{
    if (_payType == 1) {
        //test
        ZFAddBankCardController *abVC = [[ZFAddBankCardController alloc] init];
        abVC.addType = 2;
        [self pushViewController:abVC];
        return;
    }
    
    ZFAddCardNoViewController *vc = [ZFAddCardNoViewController new];
    [self pushViewController:vc];
}

#pragma mark 更改支付方式
- (void)changePayType{
    [_payTypeView show];
}

#pragma mark 付款方式代理
- (void)chooseCard:(ZFBankCardModel *)cardModel index:(NSInteger)index{
    if (_payType == 1) {
        [_cardArray[_unionIndex] setIsSelect:@"0"];
        _unionIndex = index;
    }
    if (_payType == 2) {
        [_cardArray[_sinoIndex] setIsSelect:@"0"];
        _sinoIndex = index;
    }
    [_cardArray[index] setIsSelect:@"1"];
    _payTypeView.showType = _payType;
    _payTypeView.dataArray = _cardArray;
    [self changeViewWith:cardModel];
    
    //保存交易卡号
    [[ZFGlobleManager getGlobleManager] saveTradeCardWith:cardModel];
}

- (void)payTypeTableViewClickAdd{
    [self toAddCard];
}

- (void)verificationBankCard:(ZFBankCardModel *)cardModel index:(NSInteger)index{
    _tempCardModel = cardModel;
    [self certificationBankCard:_ISOCountryCode];
}

#pragma mark 改变银联或中付
- (void)changeSinoOrUnion:(UITapGestureRecognizer *)tap{
    NSInteger tag = tap.view.tag;
    if (_payType == tag) {
        return;
    }
    [self destoryTimer];
    _payType = tag;
    if (tag == 1) {
//        _payTypeView.tipString = NSLocalizedString(@"银联国际银行卡", nil);
        _unionImageView.image = [UIImage imageNamed:@"btn_qrcode_unionpay_highlight"];
        _sinoImageView.image = [UIImage imageNamed:@"btn_qrcode_sinopay_normal"];
        _uLabel.alpha = 1;
        _sLabel.alpha = 0.7;
    } else {
//        _payTypeView.tipString = NSLocalizedString(@"扫码枪银行卡", nil);
        _unionImageView.image = [UIImage imageNamed:@"btn_qrcode_unionpay_normal"];
        _sinoImageView.image = [UIImage imageNamed:@"btn_qrcode_sinopay_highlight"];
        _uLabel.alpha = 0.7;
        _sLabel.alpha = 1;
    }
    _qrImageView.image = nil;
    [self getDefaultCard];
}

#pragma mark 点击积分优惠
- (void)clickIntegralBtn{
    _integralBtn.selected = !_integralBtn.selected;
    if (!_integralBtn.selected) {
        _integralImage.image = [UIImage imageNamed:@"icon_confirm_normal"];
    } else {
        _integralImage.image = [UIImage imageNamed:@"icon_confirm_highlight"];
    }
    [self getSinoQRCodeInfo];
}

#pragma mark 获取默认银行卡
- (void)getDefaultCard{
    if (_cardArray) {
        _cardArray = nil;
    }
    
    if (_payType == 2) {//中付支付
        _cardArray = [[ZFGlobleManager getGlobleManager] getCardListWithType:1];
        if (_cardArray.count == 0) {
            [self viewForNoCard:NO];
        } else {
            if (_cardModel) {
                _sinoIndex = [_cardArray indexOfObject:_cardModel];
                _cardModel = nil;
            }
            _payTypeView.showType = 2;
            _payTypeView.dataArray = _cardArray;
            ZFBankCardModel *cardModel ;
            NSString *countryId = _ISOCountryCode;
            if (_sinoIndex && _cardArray.count > _sinoIndex) {
                ZFBankCardModel *model = _cardArray[_sinoIndex];
                if ([[ZFGlobleManager getGlobleManager] isSupportTheCity:countryId cardModel:model]) {
                    cardModel = model;
                }
            } else {
                for (ZFBankCardModel *model in _cardArray) {
                    if ([[ZFGlobleManager getGlobleManager] isSupportTheCity:countryId cardModel:model]) {
                        cardModel = model;
                        _sinoIndex = [_cardArray indexOfObject:model];
                        [_cardArray[_sinoIndex] setIsSelect:@"1"];
                        break;
                    }
                }
            }
            
            if (cardModel) {
                [self changeViewWith:cardModel];
                
            } else {//列表里没有当前地区的卡 去认证
                _tempCardModel = _cardArray[0];
                _sinoIndex = 0;
                [self viewForNoCard:YES];
            }
            
            for (NSInteger i = 0; i < _cardArray.count; i++) {//只有一个选择
                if (i == _sinoIndex) {
                    continue;
                } else {
                    [_cardArray[i] setIsSelect:@"0"];
                }
            }
        }
    } else {//银联支付
        _cardArray = [[ZFGlobleManager getGlobleManager] getCardListWithType:2];
        _cardModel = nil;
        if (_cardArray.count == 0) {
            [self viewForNoCard:NO];
        } else {
            _payTypeView.showType = 1;
            _payTypeView.dataArray = _cardArray;
            ZFBankCardModel *cardModel;
            if (!_unionIndex) {
                _unionIndex = 0;
            }
            cardModel = _cardArray[_unionIndex];
            [_cardArray[_unionIndex] setIsSelect:@"1"];
            [self changeViewWith:cardModel];
            
            for (NSInteger i = 0; i < _cardArray.count; i++) {//只有一个选择按钮
                if (i == _unionIndex) {
                    continue;
                } else {
                    [_cardArray[i] setIsSelect:@"0"];
                }
            }
        }
    }
}

#pragma mark 生成二维码
- (void)generateQrCode:(NSString *)qrCode{
//    _qrCode = qrCode;
    if (_brightness < 0.8) {
        [[UIScreen mainScreen] setBrightness: 0.8];
    }
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    _qrImageView.image = [SGQRCodeTool SG_generateWithDefaultQRCodeData:qrCode imageViewWidth:300];
    
    if (_payType == 1) {
        [self generateBrCode:_brCode];
    }
    
    //大二维码
    _bigQRImageView.image = [SGQRCodeTool SG_generateWithDefaultQRCodeData:qrCode imageViewWidth:300];
    _bigQRImageView.userInteractionEnabled = YES;
    
    [self configTimer];
}

#pragma mark 生成条形码
- (void)generateBrCode:(NSString *)brCode{
    _txImageView.image = [self generateBarCodeWith:brCode size:_txImageView.size];
    
    //大条形码
    _bigTXImageView.image = [self generateBarCodeWith:brCode size:_bigTXImageView.size];
    _bigTXImageView.userInteractionEnabled = YES;
}

#pragma mark 获取中付二维码信息
-(void)getSinoQRCodeInfo{
    DLog(@"preOrderId = %@", self.sinoPayID);
    NSDictionary * paramSign = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"payPassword" : _passWord,
                                 @"cardNum": _cardModel.encryCardNo,
                                 @"sysareaId":_ISOCountryCode,
                                 @"credit":_integralBtn.isSelected?@"1":@"0",
                                 @"upopOrderId":self.sinoPayID,
                                 @"txnType": @"33"};
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    
    [NetworkEngine singlePostWithParmas:paramSign success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[MBUtils sharedInstance] dismissMB];
            NSString *qrCode = [requestResult objectForKey:@"qrCode"];
            //NSString *expireTime = [requestResult objectForKey:@"expireTime"];
            _qrCode = qrCode;
            [self generateQrCode:qrCode];
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        [[MBUtils sharedInstance] showMBMomentWithText:NetRequestError inView:self.view];
    }];
}

#pragma mark 获取银联二维码信息
- (void)getUnionQRCodeInfo{
    NSDictionary * paramSign = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"payPassword" : _passWord,
                                 @"cardNum": _cardModel.encryCardNo,
                                 @"userKey":[ZFGlobleManager getGlobleManager].userKey,
                                 @"couponInfo":_couponID,
                                 @"upopOrderId":self.unionPayID,
                                 @"txnType": @"57"};
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    
    [NetworkEngine singlePostWithParmas:paramSign success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[MBUtils sharedInstance] dismissMB];
            NSString *qrCode = [requestResult objectForKey:@"emvcode"];//非中国大陆
            NSString *brCode = [requestResult objectForKey:@"barcode"];//中国大陆
            _qrCode = qrCode;
            _brCode = brCode;
            if (_txImageView.hidden ==  YES) {
                [self generateQrCode:qrCode];
            } else {
                [self generateQrCode:_brCode];
            }
            
            self.barcodeL.text = [NSString stringWithFormat:@"%@  %@  %@  %@  %@", [_brCode substringWithRange:NSMakeRange(0, 4)], [_brCode substringWithRange:NSMakeRange(4, 4)], [_brCode substringWithRange:NSMakeRange(8, 4)], [_brCode substringWithRange:NSMakeRange(12, 4)], [_brCode substringWithRange:NSMakeRange(16, _brCode.length-16)]];
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        [[MBUtils sharedInstance] showMBMomentWithText:NetRequestError inView:self.view];
    }];
}

#pragma mark 查询中付交易结果
- (void)checkSinoPayResult{
    
    if (_payType == 1) {
        return;
    }
    NSDictionary * paramSign = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"qrCode":_qrCode,
                                 @"upopOrderId":self.sinoPayID,
                                 @"txnType": @"34"};
    
    [NetworkEngine singlePostWithParmas:paramSign success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [self destoryTimer];
            //保存交易银行卡国家编码
            [[NSUserDefaults standardUserDefaults] setObject:_ISOCountryCode forKey:ISOCOUNTRYCODELASTPAY];
             _resulltTradeModel = [[TradeModel alloc] init];
            _resulltTradeModel.txnAmt = [requestResult objectForKey:@"txnAmt"];
            _resulltTradeModel.billingCurr = [requestResult objectForKey:@"billingCurr"];
            _resulltTradeModel.creditAmt = [requestResult objectForKey:@"creditAmt"];
            _resulltTradeModel.useCredit = [requestResult objectForKey:@"useCredit"];
            _resulltTradeModel.merName = [requestResult objectForKey:@"merName"];
            _resulltTradeModel.billingAmt = [requestResult objectForKey:@"billingAmt"];
            _resulltTradeModel.txnCurr = [requestResult objectForKey:@"txnCurr"];
            _resulltTradeModel.orderId = [requestResult objectForKey:@"orderId"];
            _resulltTradeModel.termCode = [requestResult objectForKey:@"termCode"];
            _resulltTradeModel.bankName = _cardModel.bankName;
            _resulltTradeModel.merId = [requestResult objectForKey:@"merId"];
            _resulltTradeModel.orderTime = [requestResult objectForKey:@"txnTime"];
            _resulltTradeModel.cardNum = _cardModel.cardNo;
            _resulltTradeModel.serialNumber = [requestResult objectForKey:@"queryId"];
            _resulltTradeModel.billingCurrTxnAmt = [requestResult objectForKey:@"billingCurrTxnAmt"];
            _resulltTradeModel.txnCurrCreditAmt = [requestResult objectForKey:@"txnCurrCreditAmt"];
            [self jumpToPayResult:YES message:@""];
        }
        //交易失败
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"1"]) {
            [self jumpToPayResult:NO message:[requestResult objectForKey:@"msg"]];
            //[[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
            [self destoryTimer];
        }
        
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"64"]) {
            [self destoryTimer];
            [self showToUserMessage:[requestResult objectForKey:@"msg"]];
        }
        
    } failure:^(id error) {
        
    }];
}

#pragma mark 查询银联交易结果
- (void)checkUnionPayResult{
    if (_payType == 2) {
        return;
    }
    NSDictionary * paramSign = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"cardNum": _cardModel.encryCardNo,
                                 @"userKey":[ZFGlobleManager getGlobleManager].userKey,
                                 @"upopOrderId":self.unionPayID,
                                 @"txnType": @"75"};
    
    [NetworkEngine singlePostWithParmas:paramSign success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            _resulltTradeModel = [[TradeModel alloc] init];
            _resulltTradeModel.merName = [requestResult objectForKey:@"merName"];
            _resulltTradeModel.billingAmt = [requestResult objectForKey:@"billingAmt"];
            _resulltTradeModel.termCode = [requestResult objectForKey:@"termCode"];
            _resulltTradeModel.bankName = [requestResult objectForKey:@"bankName"];
            _resulltTradeModel.orderTime = [requestResult objectForKey:@"payTime"];
            _resulltTradeModel.serialNumber = [requestResult objectForKey:@"queryId"];
            _resulltTradeModel.creditAmt = @"";
            _resulltTradeModel.useCredit = @"";//银联 没有积分
            _resulltTradeModel.billingCurr = [requestResult objectForKey:@"billingCurr"];
            _resulltTradeModel.orderId = [requestResult objectForKey:@"orderId"];
            _resulltTradeModel.txnAmt = [requestResult objectForKey:@"txnAmt"];
            _resulltTradeModel.txnCurr = [requestResult objectForKey:@"txnCurr"];
            _resulltTradeModel.merId = [requestResult objectForKey:@"merId"];
            _resulltTradeModel.cardNum = _cardModel.cardNo;
            _resulltTradeModel.couponDes = [requestResult objectForKey:@"couponDes"];
            _resulltTradeModel.billingCurrTxnAmt = [requestResult objectForKey:@"billingCurrTxnAmt"];
            _resulltTradeModel.billingCurrdiscountAmt = [requestResult objectForKey:@"billingCurrdiscountAmt"];
            [self jumpToPayResult:YES message:@""];
            return ;
        }
        //交易失败
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"1"]) {
            [self jumpToPayResult:NO message:[requestResult objectForKey:@"msg"]];
            //[[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
            [self destoryTimer];
        }
        
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"64"]) {
            [self destoryTimer];
            [self showToUserMessage:[requestResult objectForKey:@"msg"]];
        }
        
        //附加处理
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"2"]) {
            //先关闭定时器
            [self destoryTimer];
            [XLAlertController acWithTitle:@"" message:[requestResult objectForKey:@"msg"] confirmBtnTitle:NSLocalizedString(@"确认付款", nil) cancleBtnTitle:NSLocalizedString(@"取消", nil) confirmAction:^(UIAlertAction *action) {
                [self additionalIsAgree:YES emvcode:[requestResult objectForKey:@"emvCode"]];
            } cancleAction:^(UIAlertAction *action) {
                [self additionalIsAgree:NO emvcode:[requestResult objectForKey:@"emvCode"]];
            }];
        }
        
    } failure:^(id error) {
        
    }];
}

//余额不足
- (void)showToUserMessage:(NSString *)message{
    [self destoryTimer];
    [XLAlertController acWithMessage:message confirmBtnTitle:NSLocalizedString(@"确定", nil) confirmAction:^(UIAlertAction *action) {
        _cardModel.underbalance = @"1";
        [_payTypeView.tableView reloadData];
    }];
}

#pragma mark 附加处理
- (void)additionalIsAgree:(BOOL)isAgree emvcode:(NSString *)emvcode{
    
    NSString *code = emvcode;
    if ([code isKindOfClass:[NSNull class]] || !code) {
        code = @"";
    }
    
    [[MBUtils sharedInstance] showMBInView:self.view];
    NSDictionary * paramSign = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"emvcode": code,
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"cardNum": _cardModel.encryCardNo,
                                 @"userKey":[ZFGlobleManager getGlobleManager].userKey,
                                 @"paymentStatus":isAgree?@"0":@"1",
                                 @"rejectionReason":@"other",
                                 @"txnType": @"77"};
    
    [NetworkEngine singlePostWithParmas:paramSign success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        NSDictionary *resultDic = (NSDictionary *)requestResult;
        if([[resultDic objectForKey:@"status"] isEqualToString:@"0"]){
            if (isAgree) {
                [self configTimer];
            } else {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
            [self configTimer];
        }
    } failure:^(id error) {
        [self configTimer];
    }];
}


#pragma mark 获取积分
- (void)checkJiFen{
    //已在首页请求成功
    NSString *jfStr = [ZFGlobleManager getGlobleManager].totalCredit;
    if (jfStr) {
        _jifen = jfStr;
        _integralLabel.text = [NSString stringWithFormat:@"%@(%@)", NSLocalizedString(@"是否使用积分优惠", nil), jfStr];
        if (_cardModel && _payType == 2) {
            _integralBackView.hidden = NO;
        }
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
                if (_cardModel && _payType == 2) {
                    _integralBackView.hidden = NO;
                }
            } else {
                _integralBackView.hidden = YES;
            }
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
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
                [self getDefaultCard];
            }
            return ;
        }
        
        NSArray *bankCardArray = [NSArray new];
        bankCardArray = [NSArray yy_modelArrayWithClass:[ZFBankCardModel class] json:requestResult[@"list"]];
        bankCardArray = [[ZFGlobleManager getGlobleManager] sortBankArrayWith:bankCardArray];
        [ZFGlobleManager getGlobleManager].bankCardArray = [NSMutableArray arrayWithArray:bankCardArray];
        [self getDefaultCard];
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark 生成条形码
- (UIImage *)generateBarCodeWith:(NSString *)str size:(CGSize)size {
    CIImage *ciImage = [self generateBarCodeImage:str];
    UIImage *image = [self resizeCodeImage:ciImage withSize:size];
    return image;
}
/**
 *  生成条形码
 */
- (CIImage *) generateBarCodeImage:(NSString *)source{
    // iOS 8.0以上的系统才支持条形码的生成，iOS8.0以下使用第三方控件生成
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 注意生成条形码的编码方式
        NSData *data = [source dataUsingEncoding: NSASCIIStringEncoding];
        CIFilter *filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
        [filter setValue:data forKey:@"inputMessage"];
        // 设置生成的条形码的上，下，左，右的margins的值
        [filter setValue:[NSNumber numberWithInteger:0] forKey:@"inputQuietSpace"];
        return filter.outputImage;
    }else{
        return nil;
    }
}

- (UIImage *) resizeCodeImage:(CIImage *)image withSize:(CGSize)size{
    if (image) {
        CGRect extent = CGRectIntegral(image.extent);
        CGFloat scaleWidth = size.width/CGRectGetWidth(extent);
        CGFloat scaleHeight = size.height/CGRectGetHeight(extent);
        size_t width = CGRectGetWidth(extent) * scaleWidth;
        size_t height = CGRectGetHeight(extent) * scaleHeight;
        CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
        CGContextRef contentRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpaceRef, (CGBitmapInfo)kCGImageAlphaNone);
        CIContext *context = [CIContext contextWithOptions:nil];
        CGImageRef imageRef = [context createCGImage:image fromRect:extent];
        CGContextSetInterpolationQuality(contentRef, kCGInterpolationNone);
        CGContextScaleCTM(contentRef, scaleWidth, scaleHeight);
        CGContextDrawImage(contentRef, extent, imageRef);
        CGImageRef imageRefResized = CGBitmapContextCreateImage(contentRef);
        CGContextRelease(contentRef);
        CGImageRelease(imageRef);
        return [UIImage imageWithCGImage:imageRefResized];
    }else{
        return nil;
    }
}

#pragma mark 刷新定时器
- (void)configTimer{
    //先销毁
    [self destoryTimer];

    if (_payType == 1) {
        if (_refershCodeTimer == nil) {
            _refershCodeTimer = [NSTimer scheduledTimerWithTimeInterval:REFERESH_TIME target:self selector:@selector(getUnionQRCodeInfo) userInfo:nil repeats:YES];
        }
        if (_queryTimer == nil) {
            _queryTimer = [NSTimer scheduledTimerWithTimeInterval:QURERY_TIME target:self selector:@selector(checkUnionPayResult) userInfo:nil repeats:YES];
        }
    } else {
        if (_refershCodeTimer == nil) {
            _refershCodeTimer = [NSTimer scheduledTimerWithTimeInterval:REFERESH_TIME target:self selector:@selector(getSinoQRCodeInfo) userInfo:nil repeats:YES];
        }
        if (_queryTimer == nil) {
            _queryTimer = [NSTimer scheduledTimerWithTimeInterval:QURERY_TIME target:self selector:@selector(checkSinoPayResult) userInfo:nil repeats:YES];
        }
    }
}

- (void)jumpToPayResult:(BOOL)isSuccess message:(NSString *)errorMsg{
    ZFPayResultController *payResultVC = [[ZFPayResultController alloc] init];
    payResultVC.resultType = isSuccess?0:1;
    if (isSuccess) {
        payResultVC.tradeModel = _resulltTradeModel;
    } else {
        payResultVC.errorMsg = errorMsg;
    }
    [self.navigationController pushViewController:payResultVC animated:YES];
}

- (NSString *)unionPayID{
    if (_unionPayID) {
        return _unionPayID;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMddHHmmss"];
    NSString *str = [formatter stringFromDate:[NSDate date]];
    _unionPayID = [NSString stringWithFormat:@"%@%@", [ZFGlobleManager getGlobleManager].userPhone, str];
    return _unionPayID;
}

- (NSString *)sinoPayID{
    if (_sinoPayID) {
        return _sinoPayID;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMddHHmmss"];
    NSString *str = [formatter stringFromDate:[NSDate date]];
    _sinoPayID = [NSString stringWithFormat:@"%@%@", [ZFGlobleManager getGlobleManager].userPhone, str];
    return _sinoPayID;
}

#pragma mark - 认证银行卡
- (void)certificationBankCard:(NSString *)sysareaid {
    _isVerification = YES;
    [ZFGlobleManager getGlobleManager].notNeedShowSuccess = YES;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[ZFGlobleManager getGlobleManager].areaNum forKey:@"countryCode"];
    [parameters setObject:[ZFGlobleManager getGlobleManager].userPhone forKey:@"mobile"];
    [parameters setObject:[ZFGlobleManager getGlobleManager].sessionID forKey:@"sessionID"];
    [parameters setObject:sysareaid forKey:@"sysareaid"];
    [parameters setObject:_tempCardModel.encryCardNo forKey:@"cardNum"];
    [parameters setObject:@"yes" forKey:@"isAgain"];
    [parameters setObject:@"20" forKey:@"txnType"];
        
    if ([_cardModel.cardType isEqualToString:@"2"]) { // 其他地区信用卡,不需要请求，直接跳转
        ZFSafeVerificationController *vc = [[ZFSafeVerificationController alloc] initWithParams:parameters];
        vc.phoneNumber = _tempCardModel.phoneNumber;
        [self pushViewController:vc];
        return;
    }
    // 发送请求
    [[MBUtils sharedInstance] showMBInView:self.view];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
            [[MBUtils sharedInstance] dismissMB];
            
            if ([[requestResult objectForKey:@"status"] isEqualToString:@"79"]) {//79时不需要验证码 直接调绑卡
                // 验证码界面
                ZFGetMSCodeController *vc = [[ZFGetMSCodeController alloc] initWithParams:parameters];
                vc.phoneNumber = _tempCardModel.phoneNumber;
                vc.orderId = [requestResult objectForKey:@"orderId"];
                vc.status = [requestResult objectForKey:@"status"];
                [self pushViewController:vc];
                return ;
            }
            
            if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) { // 成功
                
                ZFGetMSCodeController *vc = [[ZFGetMSCodeController alloc] initWithParams:parameters];
                vc.phoneNumber = _tempCardModel.phoneNumber;
                vc.orderId = [requestResult objectForKey:@"orderId"];
                [self pushViewController:vc];
                
            } else {
                [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
                return ;
            }
        } failure:^(NSError *error) {
            
        }];
    });
}

#pragma mark 销毁定时器
- (void)destoryTimer{
    [_queryTimer invalidate];
    _queryTimer = nil;
    [_refershCodeTimer invalidate];
    _refershCodeTimer = nil;
}

#pragma mark 删除输入密码页面
- (void)removeViewController {
    NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];
    [navigationArray removeObjectAtIndex:([self.navigationController.viewControllers count] - 2)]; // You can pass your index here
    self.navigationController.viewControllers = navigationArray;
}


@end
