//
//  ZFMainViewController.m
//  newupop
//
//  Created by Jellyfish on 2017/7/20.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFMainViewController.h"
#import "ZFRecentTradeView.h"
#import "MJRefresh.h"
#import "ZFMyBankCardViewController.h"
#import "DateUtils.h"
#import "ZFScanQrcodeController.h"
#import "ZFGenerateQRCodeController.h"
#import <AVFoundation/AVFoundation.h>
#import "ZFBankCardModel.h"
#import "ZFTradeRecordController.h"
#import "ZFTradeDetaiController.h"
#import "ZFOfflineQRCodeController.h"
#import "ZFIntegralController.h"
#import "ZFUPlanTableViewCell.h"
#import "ZFUplanModel.h"
#import "YYModel.h"
#import "ZFUplanModel.h"
#import "ZFUplanWebViewController.h"
#import "ZFValidatePwdController.h"
#import "ZFInputPwdController.h"
#import "ZFTabBarController.h"
#import "ZFNavigationController.h"
#import "ZFPayResultController.h"
#import "ZFSetFingerprintViewController.h"
#import "ZFPCPersonInfoViewController.h"
#import "ZFPCBankCard.h"
#import "ZFPCApprovalStatusViewController.h"

// 图片数量
#define PicCount 4
// 图片水平间距
#define HMargin 10.0
// 图片竖直间距
#define VMargin HMargin
// 图片宽度
#define PicWidth (SCREEN_WIDTH-3*HMargin)/2
// 图片高度
#define PicHeight PicWidth*0.8

typedef void(^MyBlock)(BOOL isOK);

@interface ZFMainViewController () <UITableViewDataSource, UITableViewDelegate, ZFRecentTradeViewDelegate>
/** 顶部蓝色背景 **/
@property(nonatomic, weak) UIView *topBgView;
/** 个人资料 **/
@property(nonatomic, strong) UIView *jifenView;

/** tableView */
@property (nonatomic, weak) UITableView *tableView;

///头像
@property (nonatomic, strong)UIImageView *avatar;
///最新交易记录
@property (nonatomic, strong)TradeModel *tradeModel;
///最新交易视图
@property (nonatomic, strong)ZFRecentTradeView *tradeView;

///
@property (nonatomic, strong)UILabel *jifenLabel;

/** 当前国家uplan */
@property(nonatomic, strong) NSArray<ZFUplanModel *> *uplanCArray;

@property (nonatomic, weak)MyBlock myBlock;
///支持的国家
@property (nonatomic, strong)NSArray *supportCountry;
@property (nonatomic, strong)UILabel *jifenNumLab;
@end

@implementation ZFMainViewController


#pragma mark -- 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTopView];
    //检查更新
    [self checkVersion];
    //获取银行卡列表
    [self getCardListData:0];
    //更新最新交易
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refereshRecordAndJifen) name:TRADE_SUCCESS object:nil];
    [self checkUserInfo];
    //获取支持的国家
    [self getSupportCountry];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark 防止姓名或证件号为null
- (void)checkUserInfo{
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:UserName];
    if ([name isKindOfClass:[NSNull class]]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:UserName];
    }
    NSString *userIdCard = [[NSUserDefaults standardUserDefaults] objectForKey:UserIdCardNum];
    if ([userIdCard isKindOfClass:[NSNull class]]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:UserIdCardNum];
    }
    
}

- (void)refereshRecordAndJifen{
    [ZFGlobleManager getGlobleManager].totalCredit = nil;
    [self getRecentPayRecord];
    [self checkJiFen];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 状态栏颜色
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    self.view.backgroundColor = GrayBgColor;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isFirstLogin"] isEqualToString:@"1"] && [SmallUtils supportTouchsDevicesAndSystem] == YES ) {
        ZDPayPopView *popView = [ZDPayPopView readingEarnPopupViewWithType:SetUpFingerprintPayment];
        [popView showPopupViewWithData:nil isOpen:^(UIButton * _Nonnull sender) {
            ZFSetFingerprintViewController *vc = [ZFSetFingerprintViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        }];
    }
    if ([[NetworkEngine getCurrentLanguage] isEqualToString:@"1"]) [self englishModeView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([ZFGlobleManager getGlobleManager].isChanged) {
        [self getCardListData:0];
    }
}

#pragma mark - 如果是英文模式
- (void)englishModeView {
    [_topBgView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj) {
            [obj removeFromSuperview];
        }
    }];
    _topBgView.backgroundColor = [UIColor whiteColor];
    
    self.topBgView.frame = CGRectMake(0, -20, SCREEN_WIDTH, 230+IPhoneXStatusBarHeight);
    self.tableView.frame = CGRectMake(0, _topBgView.bottom, SCREEN_WIDTH, self.view.height-_topBgView.bottom-44);

    UIView *statusBgView = [[UIView alloc] init];
    statusBgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, IPhoneXStatusBarHeight+20);
    statusBgView.backgroundColor = MainThemeColor;
    [self.topBgView addSubview:statusBgView];
    
    UIView *titleBgView = [[UIView alloc] init];
    titleBgView.frame = CGRectMake(0, statusBgView.bottom, SCREEN_WIDTH, 50);
    titleBgView.backgroundColor = [UIColor whiteColor];
    [self.topBgView addSubview:titleBgView];
    
    UIImageView *headerView = [UIImageView new];
    [titleBgView addSubview:headerView];
    headerView.frame = CGRectMake(20, 11, 28, 28);
    headerView.image = [UIImage imageNamed:@"icon_caozuo"];
    
    UILabel *titleLab = [UILabel new];
    [titleBgView addSubview:titleLab];
    titleLab.text = NSLocalizedString(@"操作服务", nil);
    titleLab.font = [UIFont systemFontOfSize:16];
    titleLab.frame = CGRectMake(headerView.right + 15, 17, 200, 16);
    
    UIView *lineView = [UIView new];
    [_topBgView addSubview:lineView];
    lineView.frame = CGRectMake(0, titleBgView.bottom, SCREEN_WIDTH, 2);
    lineView.backgroundColor = GrayBgColor;
    
    NSArray *imageArr = @[@"icon_saoyisao", @"icon_fukuanma", @"icon_daibika",@"icon_shenqingka1"];
    NSArray *titleArr = @[NSLocalizedString(@"扫一扫付款", nil), NSLocalizedString(@"付款码付款", nil),NSLocalizedString(@"代币卡绑卡", nil), NSLocalizedString(@"申请卡", nil)];
    
    for (int i = 0; i < imageArr.count; i++) {
        UIButton *bgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        bgBtn.tag = i;
        [_topBgView addSubview:bgBtn];
        int index = i%2;
        int page = i/2;
        bgBtn.frame = CGRectMake(index * (SCREEN_WIDTH/2 + 10), page * (66 + 12)+lineView.bottom+12, SCREEN_WIDTH/2, 66);
        [bgBtn addTarget:self action:@selector(backgroundViewClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *imageView = [UIImageView new];
        [bgBtn addSubview:imageView];
        imageView.frame = CGRectMake(20, 8, 50, 50);
        imageView.image = [UIImage imageNamed:imageArr[i]];

        CGSize labsize = [titleArr[i] boundingRectWithSize:CGSizeMake(SCREEN_WIDTH, 14) options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil].size;
        UILabel *lab = [UILabel new];
        [bgBtn addSubview:lab];
        lab.text = titleArr[i];
        lab.font = [UIFont systemFontOfSize:16];
        lab.textColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1/1.0];
        lab.frame = CGRectMake(imageView.right+15, (bgBtn.height-labsize.height)/2, labsize.width, labsize.height);
    }
}

#pragma mark -- 初始化方法
- (void)setupTopView {
    NSArray *imageArr = @[@"home_scan", @"home_qrcode", @"icon_bangka",@"home_bankcard"];
    NSArray *titleArr = @[NSLocalizedString(@"扫一扫付款", nil), NSLocalizedString(@"付款码付款", nil),NSLocalizedString(@"代币卡绑卡", nil), NSLocalizedString(@"申请卡", nil)];
    // 顶部蓝色背景视图
    UIView *topBgView = [UIView new];
    topBgView.backgroundColor = MainThemeColor;
    topBgView.frame = CGRectMake(0, -20, SCREEN_WIDTH, 190);
    [self.view addSubview:topBgView];
    self.topBgView = topBgView;
    
    NSInteger count = 4;
    // 顶部工具栏按钮
    for (int i = 0; i < count; i++) {
        UIView *backgroundView = [UIView new];
        backgroundView.tag = i;
        CGFloat originX = (i%count)*(SCREEN_WIDTH/count);
        
        backgroundView.frame = CGRectMake(originX, 30, SCREEN_WIDTH/count, 140);
        [self.topBgView addSubview:backgroundView];
        
        UITapGestureRecognizer *tap = [UITapGestureRecognizer new];
        [tap addTarget:self action:@selector(backgroundViewClicked:)];
        [backgroundView addGestureRecognizer:tap];
        
        CGFloat bWidth = backgroundView.frame.size.width;
        UIImageView *imageView = [UIImageView new];
        imageView.frame = CGRectMake(bWidth*0.2, 20, 32, 32);
        imageView.image = [UIImage imageNamed:imageArr[i]];
        imageView.center = CGPointMake(backgroundView.frame.size.width/2, backgroundView.frame.size.height/2);
        [backgroundView addSubview:imageView];
        
        CGRect contentRect = [titleArr[i] boundingRectWithSize:CGSizeMake(bWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0]} context:nil];
        UILabel *titleL = [UILabel new];
        titleL.frame = CGRectMake(0, CGRectGetMaxY(imageView.frame)+14, bWidth, contentRect.size.height);
        titleL.text = titleArr[i];
        titleL.textColor = [UIColor whiteColor];
        titleL.textAlignment = NSTextAlignmentCenter;
        titleL.font = [UIFont systemFontOfSize:15.0];
        [backgroundView addSubview:titleL];
        titleL.numberOfLines = 0;
    }
    
    [self createRecentTradeView];
}

#pragma mark 最新交易记录
- (void)createRecentTradeView{
    _tradeView = [[ZFRecentTradeView alloc] initWithFrame:CGRectMake(0, 10, SCREEN_WIDTH, 170)];
    _tradeView.delegate = self;
//    [self.view addSubview:_tradeView];
    
    //[self getRecentPayRecord];
    [self setupJifenView];
}

- (void)setupJifenView {
    _jifenView = [[UIView alloc] initWithFrame:CGRectMake(0, _tradeView.bottom+10, SCREEN_WIDTH, 50)];
    _jifenView.backgroundColor = [UIColor whiteColor];
    //[self.view addSubview:jifenView];
    
    // 添加点击手势
    UITapGestureRecognizer *jifenViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpToJifen)];
    _jifenView.userInteractionEnabled = YES;
    [_jifenView addGestureRecognizer:jifenViewTap];
    
    // 头像
    _avatar = [UIImageView new];
    _avatar.image = [UIImage imageNamed:@"icon_jifen"];
    _avatar.size = CGSizeMake(32, 32);
    _avatar.clipsToBounds = YES;
    _avatar.x = 20;
    _avatar.centerY = _jifenView.height/2;
    [_jifenView addSubview:_avatar];
    
    // 用户名
    _jifenLabel = [UILabel new];
    _jifenLabel.text = NSLocalizedString(@"我的积分", nil);
    _jifenLabel.size = CGSizeMake(200, 21);
    _jifenLabel.x = CGRectGetMaxX(_avatar.frame)+15;
    _jifenLabel.centerY = _avatar.centerY;
    _jifenLabel.font = [UIFont systemFontOfSize:16];
    _jifenLabel.textAlignment = NSTextAlignmentLeft;
    [_jifenView addSubview:_jifenLabel];
    
    // 箭头
    UIImageView *arrow = [UIImageView new];
    arrow.image = [UIImage imageNamed:@"btn_right"];
    arrow.size = CGSizeMake(14, 22);
    arrow.x = SCREEN_WIDTH-arrow.width*2;
    arrow.centerY = _jifenView.height/2;
    [_jifenView addSubview:arrow];
    
    _jifenNumLab = [UILabel new];
    _jifenNumLab.font = [UIFont systemFontOfSize:16];
    _jifenNumLab.textAlignment = NSTextAlignmentLeft;
    [_jifenView addSubview:_jifenNumLab];
    _jifenNumLab.textColor = ZFColor(153, 153, 153);
    
    [self setupTableView];
    //[self checkJiFen];
}

- (void)setupTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _topBgView.bottom, SCREEN_WIDTH, self.view.height-_topBgView.bottom-44) style:UITableViewStyleGrouped];
    tableView.backgroundColor = GrayBgColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.showsVerticalScrollIndicator = YES;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.estimatedSectionHeaderHeight = 0;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    [self setupRefresh];
}

#pragma mark 检查更新
- (void)checkVersion{
    //检测本地版本
    NSString *currVersion = [[ZFGlobleManager getGlobleManager] getCurrentVersion];
    currVersion = [currVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    DLog(@"version = %zd", [currVersion integerValue]);
    
    //检测服务器版本
    NSDictionary * paramSign = @{@"appType":@"IOS",
                                 @"txnType": @"38"};
    
    [NetworkEngine singlePostWithParmas:paramSign success:^(id responseObject) {
        NSDictionary *resultDic = (NSDictionary *)responseObject;
        if([[resultDic objectForKey:@"status"] isEqualToString:@"0"]){
            NSString *serviceVersion = [resultDic objectForKey:@"versionNumber"];
            serviceVersion = [serviceVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
            
            //服务器有新版本
            if ([serviceVersion integerValue] > [currVersion integerValue]) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"发现新版本", nil) message:NSLocalizedString(@"推荐更新", nil) preferredStyle:UIAlertControllerStyleAlert];
                NSString *urlStr = [resultDic objectForKey:@"versionUrl"];
                
                UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
                    exit(0);
                }];
                
                [alert addAction:confirmAction];
                //是否强制更新
                if ([[resultDic objectForKey:@"forceUpdate"] isEqualToString:@"0"]) {//不强制
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil];
                    
                    [alert addAction:cancelAction];
                }
                [self.navigationController presentViewController:alert animated:YES completion:nil];
            }
        }
    } failure:^(NSString *errorMessage) {
        
    }];
}

#pragma mark 最新交易
- (void)getRecentPayRecord{
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"txnType": @"40"};
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        if (![[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
            return ;
        }
        NSDictionary *dict = requestResult;
        _tradeModel = [[TradeModel alloc] init];
        @try{
            [_tradeModel setValuesForKeysWithDictionary:dict];
        }@catch(NSException *exception){
            DLog(@"%@", exception);
            return;
        }
        _tradeView.tradeModel = _tradeModel;
        
        //获取当前最新交易最新年份月份
        [ZFGlobleManager getGlobleManager].recentTradeTime = _tradeModel.orderTime;
        
    } failure:^(NSError *error) {
        //[[MBUtils sharedInstance] dismissMB];
    }];
}

#pragma mark 积分查询
- (void)checkJiFen{
    
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
                //_jifenLabel.text = [NSString stringWithFormat:@"%@  %@", NSLocalizedString(@"我的积分", nil), jifen];
                CGSize size = [jifen boundingRectWithSize:CGSizeMake(MAXFLOAT, 21) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName :[UIFont systemFontOfSize:16]} context:nil].size;
                _jifenNumLab.frame = CGRectMake(SCREEN_WIDTH-14*2-size.width-12, (50-21)/2, size.width, 21);
                _jifenNumLab.text = jifen;
                [ZFGlobleManager getGlobleManager].totalCredit = jifen;
            } else {
                CGSize size = [@"0" boundingRectWithSize:CGSizeMake(MAXFLOAT, 21) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName :[UIFont systemFontOfSize:16]} context:nil].size;
                _jifenNumLab.frame = CGRectMake(SCREEN_WIDTH-14*2-size.width-12, (50-21)/2, size.width, 21);
                _jifenNumLab.text = @"0";
                //_jifenLabel.text = [NSString stringWithFormat:@"%@  %@", NSLocalizedString(@"我的积分", nil), @"0"];
            }
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

#pragma mark 获取银行卡列表
- (void)getCardListData:(NSInteger)type{
    
    NSDictionary *parameters = @{
                                 @"countryCode" : [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile" : [ZFGlobleManager getGlobleManager].userPhone,
                                 @"cardType" : @"0",
                                 @"userKey" : [ZFGlobleManager getGlobleManager].userKey,
                                 @"sessionID" : [ZFGlobleManager getGlobleManager].sessionID,
                                 @"txnType": @"11",
                                 @"version" : @"version2.1"
                                 };
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        
        [[MBUtils sharedInstance] dismissMB];
        if (![[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            
            if ([[requestResult objectForKey:@"status"] isEqualToString:@"2"]) {
                [ZFGlobleManager getGlobleManager].bankCardArray = nil;
                [ZFGlobleManager getGlobleManager].isChanged = NO;
                if (type != 0) {//消费时 无卡提示去绑卡
                    ZFMyBankCardViewController *mbcvc = [ZFMyBankCardViewController new];
                    [self pushViewController:mbcvc];
//                    [XLAlertController acWithTitle:NSLocalizedString(@"提示", nil) msg:NSLocalizedString(@"暂未绑定银行卡,不能消费", nil) confirmBtnTitle:NSLocalizedString(@"去绑卡", nil) cancleBtnTitle:NSLocalizedString(@"取消", nil) confirmAction:^(UIAlertAction *action) {
//                        [ZFGlobleManager getGlobleManager].addCardFromType = 1;
//                        ZFValidatePwdController *generateVC = [[ZFValidatePwdController alloc] init];
//                        generateVC.fromType = 3;
//                        [self.navigationController pushViewController:generateVC animated:YES];
//                    }];
                    
                    return ;
                }
            }
            return ;
        }
        
        NSArray *bankCardArray = [NSArray new];
        bankCardArray = [NSArray yy_modelArrayWithClass:[ZFBankCardModel class] json:requestResult[@"list"]];
        bankCardArray = [[ZFGlobleManager getGlobleManager] sortBankArrayWith:bankCardArray];
        // 将状态清空
        [ZFGlobleManager getGlobleManager].isChanged = NO;
        [ZFGlobleManager getGlobleManager].bankCardArray = [NSMutableArray arrayWithArray:bankCardArray];
            
        if (type != 0) {//有卡去消费
            [self goMethedWith:type-1];
        }
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark 获取的支持国家
- (void)getSupportCountry{
    NSDictionary * paramSign = @{
                                 @"txnType": @"84"
                                 };
    [NetworkEngine singlePostWithParmas:paramSign success:^(id requestResult) {
        NSDictionary *resultDic = (NSDictionary *)requestResult;
        if([[resultDic objectForKey:@"status"] isEqualToString:@"0"]){
            self.supportCountry = [requestResult objectForKey:@"contryMsg"];
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

#pragma mark 是否设置支付密码
- (void)checkPayPwdAlreadySet:(MyBlock)block{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:PayPwdAlreadySet]) {
        block(YES);
        return;
    }
    
    NSDictionary * paramSign = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"userKey": [ZFGlobleManager getGlobleManager].userKey,
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"txnType": @"27"};
    
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    [NetworkEngine singlePostWithParmas:paramSign success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {//已设置
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PayPwdAlreadySet];
            block(YES);
        } else {//未设置
            [XLAlertController acWithTitle:NSLocalizedString(@"提示", nil) msg:NSLocalizedString(@"未设置支付密码", nil) confirmBtnTitle:NSLocalizedString(@"去设置", nil) cancleBtnTitle:NSLocalizedString(@"取消", nil) confirmAction:^(UIAlertAction *action) {
                ZFInputPwdController *inputVC = [[ZFInputPwdController alloc] init];
                inputVC.inputType = 4;
                [self.navigationController pushViewController:inputVC animated:YES];
            }];
        }
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - 获取uplan信息
- (void)getUplanInfoWithCurrentCountry:(NSString *)country
{
    NSString *countryID;
    if ([country isEqualToString:@"SG"]) {
        countryID = @"SG";
    } else if ([country isEqualToString:@"MY"]) {
        countryID = @"MY";
    } else if ([country isEqualToString:@"HK"]) {
        countryID = @"HK";
    } else if ([country isEqualToString:@"US"]) {
        countryID = @"US";
    } else {
        countryID = @"SG";
    }
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sysareaID": countryID,
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"txnType": @"65"};
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        DLog(@"%@", requestResult);
        if ([requestResult[@"status"] isEqualToString:@"0"]) {
            self.uplanCArray = [NSArray yy_modelArrayWithClass:[ZFUplanModel class] json:requestResult[@"UPlanList"]];
            // 刷新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.tableView.mj_header endRefreshing];
            });
        } else {
            [self.tableView.mj_header endRefreshing];
            [XLAlertController acWithMessage:requestResult[@"msg"] confirmBtnTitle:@"OK"];
            return ;
        }
        
    } failure:^(id error) {
        [[MBUtils sharedInstance] dismissMB];
        [self.tableView.mj_header endRefreshing];
    }];
}

#pragma mark -- UITableViewDataSourece
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.uplanCArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZFUPlanTableViewCell *cell = [[ZFUPlanTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"uplanCell"];
    cell.uplanModel = self.uplanCArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZFUplanWebViewController *web = [[ZFUplanWebViewController alloc] initWithActivityUrl:self.uplanCArray[indexPath.row].activityUrl activityID:self.uplanCArray[indexPath.row].activityId  myTitle:NSLocalizedString(@"优计划详情", nil)];
    [self pushViewController:web];
}

#pragma mark -- UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CGFloat height = 10+_tradeView.height+10+_jifenView.height+10+50;
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
    headView.backgroundColor = GrayBgColor;
    [headView addSubview:_tradeView];
    [headView addSubview:_jifenView];
    
    //优计划
    UIView *UplanView = [[UIView alloc] initWithFrame:CGRectMake(0, _jifenView.bottom+10, SCREEN_WIDTH, 50)];
    UplanView.backgroundColor = [UIColor whiteColor];
    [headView addSubview:UplanView];
    
    // 标志
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, (UplanView.height-32)/2, 32, 32)];
    //logoImageView.backgroundColor = UIColorFromRGB(0xE44949);
    logoImageView.image = [UIImage imageNamed:@"icon_youjihua1"];
    [UplanView addSubview:logoImageView];
    headView.size = CGSizeMake(SCREEN_WIDTH, UplanView.bottom);
    
    // 优计划
    UILabel *adLabel = [UILabel new];
    adLabel.text = NSLocalizedString(@"优计划", nil);
    adLabel.size = CGSizeMake(100, 20);
    adLabel.x = CGRectGetMaxX(logoImageView.frame)+15;
    adLabel.centerY = logoImageView.centerY;
    adLabel.textColor = [UIColor blackColor];
    adLabel.font = [UIFont systemFontOfSize:16];
    adLabel.textAlignment = NSTextAlignmentLeft;
    [UplanView addSubview:adLabel];
    
    // 背景
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(SCREEN_WIDTH-25-30, 0, 40, 50);
    [btn addTarget:self action:@selector(moreTipTap) forControlEvents:UIControlEventTouchUpInside];
    [UplanView addSubview:btn];
    
    // 更多优惠计划
    UIImageView *moreTipImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-25-20, 0, 25, 5)];
    moreTipImage.image = [UIImage imageNamed:@"home_more"];
    moreTipImage.centerY = logoImageView.centerY;
    [UplanView addSubview:moreTipImage];
    
    // 添加点击手势
    UITapGestureRecognizer *moreTipTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moreTipTap)];
    moreTipImage.userInteractionEnabled = YES;
    [moreTipImage addGestureRecognizer:moreTipTap];
    
    return headView;
}


#pragma mark -- 点击方法
- (void)backgroundViewClicked:(id)gesr {
    //判断银行卡和支付密码
    NSInteger tag;
    if ([gesr isKindOfClass:[UIButton class]]) {
        UIButton *d = (UIButton *)gesr;
        tag = d.tag;
    } else {
        UIGestureRecognizer *d = (UIGestureRecognizer *)gesr;
        tag = d.view.tag;
    }

    //先判断地区 马来西亚和新加坡 才能交易
    if (tag == 0 || tag == 1) {
        if (!_supportCountry) {
            [self getSupportCountry];
            return ;
        }
        if (![self isCanPay]) {
            [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"目前不支持本地区交易", nil) inView:self.view];
            return;
        }
    }

    [self checkPayPwdAlreadySet:^(BOOL isOK) {
        if (isOK) {
            [self goMethedWith:tag];
        }
    }];
}

//判断是否支持该地区
- (BOOL)isCanPay{
    
    NSString *currentCountry = [LocationUtils sharedInstance].mustCode;
    if (!currentCountry) {
        [[LocationUtils sharedInstance] startLocation];
        return NO;
    }
    if (![_supportCountry containsObject:currentCountry]) {
        return NO;
    }
    return YES;
}

- (void)goMethedWith:(NSInteger)tag{
    
    if (tag == 0 || tag == 1) {//扫码和被扫要判断银行卡
//    if (tag == 0) {//扫码和被扫要判断银行卡
        if ([ZFGlobleManager getGlobleManager].bankCardArray.count == 0) {
            [self getCardListData:tag+1];
            
            return;
        }
    }
    switch (tag) {
            
        case 0:{
            [self scanQRCode];
        }
            break;
            
        case 1:{
            ZFValidatePwdController *vaVC = [[ZFValidatePwdController alloc] init];
            [self.navigationController pushViewController:vaVC animated:YES];
        }
            break;

        case 2:{
            ZFMyBankCardViewController *mbcvc = [ZFMyBankCardViewController new];
            [self pushViewController:mbcvc];
        }
            break;
        case 3:{
            UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                  UIAlertAction *cancle = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消",nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action) {
                      
                  }];
            
                  UIAlertAction *camera = [UIAlertAction actionWithTitle:NSLocalizedString(@"虚拟卡", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                      [ZFGlobleManager getGlobleManager].applyType = @"2";
                      [self isAppearCardNetWorking:@"2"];
                  }];
                  
                  UIAlertAction *picture = [UIAlertAction actionWithTitle:NSLocalizedString(@"实体卡",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                      [ZFGlobleManager getGlobleManager].applyType = @"3";
                      [self isAppearCardNetWorking:@"3"];
                  }];
                  [alertVc addAction:cancle];
                  [alertVc addAction:camera];
                  [alertVc addAction:picture];
                  [self presentViewController:alertVc animated:YES completion:nil];
        }
            break;
//        case 1:{
//            ZFMyBankCardViewController *mbcvc = [ZFMyBankCardViewController new];
//            [self pushViewController:mbcvc];
//        }
//            break;
    }
}

#pragma mark 扫描二维码
- (void)scanQRCode{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // 检查打开相机的权限是否打开 ·
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
        {
            NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
            NSString *title = [appName stringByAppendingString:NSLocalizedString(@"不能访问您的相机", nil)];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:NSLocalizedString(@"请前往“设置”打开相机访问权限", nil) preferredStyle:UIAlertControllerStyleAlert];
            // 取消
            UIAlertAction *cancle = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:0 handler:nil];
            [alert addAction:cancle];
            
            // 确定
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"打开", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
            }];
            [alert addAction:confirmAction];
            
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            ZFScanQrcodeController *scanVC = [[ZFScanQrcodeController alloc] init];
            [self.navigationController pushViewController:scanVC animated:YES];
        }
    } else {
        [XLAlertController acWithMessage:NSLocalizedString(@"该设备不支持相机", nil) confirmBtnTitle:NSLocalizedString(@"确定", nil)];
    }
}

/// 交易记录
- (void)didClickTradeRecordBtn {
    ZFTradeRecordController *tradeVC = [[ZFTradeRecordController alloc] init];
    [self.navigationController pushViewController:tradeVC animated:YES];
}

/// 查看详情
- (void)didClickDetailsBtn {
    if (_tradeModel) {
        ZFTradeDetaiController *detailVC = [[ZFTradeDetaiController alloc] init];
        detailVC.tradeModel = _tradeModel;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

// 积分
- (void)jumpToJifen {
    ZFIntegralController  *inVC = [[ZFIntegralController alloc] init];
    [self.navigationController pushViewController:inVC animated:YES];
}

// 更多优惠计划
- (void)moreTipTap {
    self.tabBarController.selectedIndex = 1;
}


#pragma mark -- 其他方法
/** 添加刷新控件 */
-(void)setupRefresh {
    // 头部刷新,设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewStatus方法）
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadNewStatus];
    }];
    [header setTitle:NSLocalizedString(@"下拉刷新数据", nil) forState:MJRefreshStateIdle];
    [header setTitle:NSLocalizedString(@"松开立即刷新", nil) forState:MJRefreshStatePulling];
    [header setTitle:NSLocalizedString(@"正在加载", nil) forState:MJRefreshStateRefreshing];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.font = [UIFont systemFontOfSize:13.0];
    [header isAutomaticallyChangeAlpha];
    self.tableView.mj_header = header;
    [self.tableView.mj_header beginRefreshing];
}

/** 下拉刷新 */
- (void)loadNewStatus {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self getUplanInfoWithCurrentCountry:[LocationUtils sharedInstance].ISOCountryCode];
        [self getRecentPayRecord];
        [self checkJiFen];
    });
}

#pragma mark - 判断用户是否有申请预付卡
- (void)isAppearCardNetWorking:(NSString *)type {
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"applyType": type,
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"txnType": @"92"};
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([requestResult[@"status"] isEqualToString:@"0"]) {
            if ([requestResult[@"origStatus"] isEqualToString:@"3"]){
                ZFPCPersonInfoViewController *infoView = [[ZFPCPersonInfoViewController alloc] init];
                infoView.enCardNum = [requestResult objectForKey:@"cardNum"];
                [self pushViewController:infoView];
                [ZFGlobleManager getGlobleManager].isChanged = YES;
            } else {
                ZFPCBankCard *card = [ZFPCBankCard yy_modelWithJSON:requestResult];
                ZFPCApprovalStatusViewController *approval = [[ZFPCApprovalStatusViewController alloc] initWithCardInfo:card];
                if ([type isEqualToString:@"2"]) {
                    approval.cardType = @"2";
                } else {
                    approval.cardType = @"3";
                }
                [self pushViewController:approval];
            }
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
        
    } failure:^(id error) {
        [[MBUtils sharedInstance] dismissMB];
    }];
}

@end
