//
//  ZFBankCardDetailViewController.m
//  newupop
//
//  Created by Jellyfish on 2017/12/19.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFBankCardDetailViewController.h"
#import "ZFBankCardCell.h"
#import "ZFBankCardDetailViewController.h"
#import "ZFGetMSCodeController.h"
#import "ZFSafeVerificationController.h"
#import "ZFUPBankCardModel.h"
#import "YYModel.h"
#import "TradeModel.h"
#import "HBRSAHandler.h"
#import "ZFBankDetailTopView.h"
#import "YYModel.h"
#import "TradeSectionModel.h"
#import "MJRefresh.h"
#import "ZFTradeDetaiController.h"
#import "ZFTradingRecordCell.h"
#import "UIScrollView+EmptyDataSet.h"
#import "ZFPCPersonInfoViewController.h"
#import "ZFPCApprovalStatusViewController.h"

@interface ZFBankCardDetailViewController () <UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, strong)UITableView *tableView;
/** 传过来的银行卡模型 */
@property(nonatomic, strong) ZFBankCardModel *bcModel;
/** 开通地区状态数组 */
@property(nonatomic, strong) NSMutableArray<NSMutableDictionary *> *areaStatuArray;
/** 银联国际返回的cvm模型 */
@property(nonatomic, strong) ZFUPBankCardModel *upModel;
///卡详情信息视图
@property (nonatomic, strong)UIView *topView;

/** 按月区分 */
@property(nonatomic, strong) NSMutableArray<TradeSectionModel *> *sectionArray;
// 当前页数
@property (nonatomic, assign)NSInteger currentPage;

@property (nonatomic, weak)UIButton *btn2;
@property (nonatomic, strong) ZFPCBankCard *cardInfo;

@end

@implementation ZFBankCardDetailViewController

- (instancetype)initWithBankCardModel:(ZFBankCardModel *)bcModel {
    if (self = [super init]) {
        self.bcModel = bcModel;
    }
    return self;
}

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myTitle = NSLocalizedString(@"银行卡", nil);
    
    self.areaStatuArray = [NSMutableArray array];
    NSMutableDictionary *openDic = [NSMutableDictionary dictionary];
    [openDic setValue:NSLocalizedString(@"银联钱包", nil) forKey:@"description"];
    [openDic setValue:self.bcModel.openCountry.UP forKey:@"isOpen"];
    [openDic setValue:@"UP" forKey:@"countryCode"];
    [self.areaStatuArray addObject:openDic];
    
    _currentPage = 1;
    [self setupRightBtn];
    [self setupTopView];
    [self setupTableView];
    //[self getYufuCardCertificationStatus];
    [self getCardTradeRecord];
}

#pragma mark - 初始化视图
- (void)setupRightBtn {
    UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-60, IPhoneXStatusBarHeight, 60, 44)];
    [deleteBtn setTitle:NSLocalizedString(@"解绑", nil) forState:UIControlStateNormal];
    [deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    deleteBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [deleteBtn addTarget:self action:@selector(deleteBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteBtn];
}

- (void)setupTopView{
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, 251)];
    _topView.backgroundColor = GrayBgColor;
    [self.view addSubview:_topView];
    
    ZFBankDetailTopView *bankView = [[ZFBankDetailTopView alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, 80)];
    bankView.backgroundColor = [UIColor whiteColor];
    bankView.model = self.bcModel;
    [_topView addSubview:bankView];
    
//    if (![self.bcModel.cardNo hasPrefix:@"6234151"]) {
//        _topView.height = 100;
//        return;
//    }
    //改为通过名称判断
    if (![self.bcModel.bankName isEqualToString:@"Sinopay"]) {
        _topView.height = 100;
        return;
    }
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, bankView.bottom, SCREEN_WIDTH, 50)];;
    textLabel.text = NSLocalizedString(@"温馨提示：开通认证，提升消费安全性", nil);
    textLabel.numberOfLines = 0;
    textLabel.textColor = UIColorFromRGB(0x313131);
    textLabel.font = [UIFont systemFontOfSize:12.0];
    textLabel.textAlignment = NSTextAlignmentLeft;
    [_topView addSubview:textLabel];
    
    UIView *statuView = [[UIView alloc] initWithFrame:CGRectMake(0, textLabel.bottom, SCREEN_WIDTH, 50)];
    statuView.backgroundColor = [UIColor whiteColor];
    [_topView addSubview:statuView];
    
    UILabel *titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 50)];
    titlelabel.text = [self.areaStatuArray[0] objectForKey:@"description"];
    titlelabel.textColor = ZFAlpColor(0, 0, 0, 0.8);
    titlelabel.font = [UIFont systemFontOfSize:15.0];
    [statuView addSubview:titlelabel];
    
    UIButton *btn = [[UIButton alloc] init];
    btn.tag = 0;
    btn.frame = CGRectMake(SCREEN_WIDTH-75, 10, 60, 30);
    btn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [btn setTitle:NSLocalizedString(@"去认证", nil) forState:UIControlStateNormal];
    [btn setTitle:NSLocalizedString(@"已认证", nil) forState:UIControlStateDisabled];
//    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:ZFAlpColor(0, 0, 0, 0.6) forState:UIControlStateDisabled];
    [btn setTitleColor:ZFAlpColor(255, 255, 255, 0.7) forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 4.0f;
    if ([[self.areaStatuArray[0] objectForKey:@"isOpen"] isEqualToString:@"0"]) { // 已开通
        btn.enabled = NO;
        btn.backgroundColor = [UIColor clearColor];
    } else { // 未开通
        btn.enabled = YES;
        btn.backgroundColor = MainThemeColor;
    }
    [statuView addSubview:btn];
    
    UIView *statuView2 = [[UIView alloc] initWithFrame:CGRectMake(0, statuView.bottom+1, SCREEN_WIDTH, 50)];
    statuView2.backgroundColor = [UIColor whiteColor];
    //[_topView addSubview:statuView2];
    
    UILabel *titlelabel2 = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 50)];
    titlelabel2.text = NSLocalizedString(@"代币卡绑卡", nil);
    titlelabel2.textColor = ZFAlpColor(0, 0, 0, 0.8);
    titlelabel2.font = [UIFont systemFontOfSize:15.0];
    //[statuView2 addSubview:titlelabel2];
    
    UIButton *btn2 = [[UIButton alloc] init];
    btn2.frame = CGRectMake(SCREEN_WIDTH-175, 10, 160, 30);
    btn2.titleLabel.font = [UIFont systemFontOfSize:15.0];
    btn2.enabled = NO;
    btn2.layer.cornerRadius = 5.0f;
    [btn2 addTarget:self action:@selector(btn2Clicked:) forControlEvents:UIControlEventTouchUpInside];
    //[statuView2 addSubview:btn2];
    _btn2 = btn2;
}

- (void)setupTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _topView.bottom, SCREEN_WIDTH, SCREEN_HEIGHT-_topView.bottom) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 66;
    _tableView.backgroundColor = GrayBgColor;
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    [self setupRefresh];
}

/** 添加刷新控件 */
-(void)setupRefresh {
    // 头部刷新,设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewStatus方法）
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _currentPage++;
        [self getCardTradeRecord];
    }];
    [footer setTitle:NSLocalizedString(@"上拉加载更多数据", nil) forState:MJRefreshStateIdle];
    [footer setTitle:NSLocalizedString(@"正在加载", nil) forState:MJRefreshStateRefreshing];
    [footer setTitle:NSLocalizedString(@"加载完毕", nil) forState:MJRefreshStateNoMoreData];
    footer.stateLabel.font = [UIFont systemFontOfSize:13.0];
    footer.automaticallyHidden = NO;
    footer.automaticallyRefresh = YES;
    self.tableView.mj_footer = footer;
    // 开始隐藏
    [self.tableView.mj_footer setHidden:YES];
}

#pragma mark -- UITableViewDataSourece&UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.00001;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.sectionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.sectionArray[section].currentMonthArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ZFTradingRecordCell *cell = [ZFTradingRecordCell cellWithTableView:tableView];
    cell.tradeModel = self.sectionArray[indexPath.section].currentMonthArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ZFTradeDetaiController *detailVC = [[ZFTradeDetaiController alloc] init];
    detailVC.tradeModel = self.sectionArray[indexPath.section].currentMonthArray[indexPath.row];
    detailVC.fromType = 1;
    [self pushViewController:detailVC];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 35)];
    headView.backgroundColor = GrayBgColor;
    
    //时间
    UILabel *monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 7, 70, 20)];
    monthLabel.font = [UIFont systemFontOfSize:13];
    monthLabel.textColor = UIColorFromRGB(0x313131);
    [headView addSubview:monthLabel];
    
    NSString *monthStr = self.sectionArray[section].month;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMM"];
    NSDate *monthDate = [formatter dateFromString:monthStr];
    [formatter setDateFormat:@"yyyy-MM"];
    monthStr = [formatter stringFromDate:monthDate];
    monthLabel.text = monthStr;
    
    //笔数
    UILabel *totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(monthLabel.right, 10, SCREEN_WIDTH-110, 14)];;
    totalLabel.font = [UIFont systemFontOfSize:13];
    totalLabel.textColor = [UIColor grayColor];
    totalLabel.textAlignment = NSTextAlignmentRight;
    totalLabel.text = [NSString stringWithFormat:@"%@: %zd%@", NSLocalizedString(@"交易", nil), self.sectionArray[section].currentMonthArray.count, NSLocalizedString(@"笔", nil)];
    [headView addSubview:totalLabel];
    
    return headView;
}

// 设置分割线偏移
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPat{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 60, 0, 0)];
    }
}

#pragma mark -- DZNEmptyDataSetSource
// 设置空白页展示图片
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView{
    return [UIImage imageNamed:@"norecord_pic_box"];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView{
    NSString *text = NSLocalizedString(@"暂无交易记录", nil);
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:13.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return -80;
}
// 不影响刷新
- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView{
    return YES;
}

#pragma mark - 点击方法
- (void)btnClicked:(UIButton *)sender {
    DLog(@"%@", [self.areaStatuArray[sender.tag] objectForKey:@"countryCode"]);
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[ZFGlobleManager getGlobleManager].areaNum forKey:@"countryCode"];
    [parameters setObject:[ZFGlobleManager getGlobleManager].userPhone forKey:@"mobile"];
    [parameters setObject:[ZFGlobleManager getGlobleManager].sessionID forKey:@"sessionID"];
    [parameters setObject:[self.areaStatuArray[sender.tag] objectForKey:@"countryCode"] forKey:@"sysareaid"];
    [parameters setObject:self.bcModel.encryCardNo forKey:@"cardNum"];
    [parameters setObject:@"yes" forKey:@"isAgain"];
    
    if ([[self.areaStatuArray[sender.tag] objectForKey:@"countryCode"] isEqualToString:@"UP"]) {// 银联国际传特殊字段
        [parameters setObject:[ZFGlobleManager getGlobleManager].userKey forKey:@"userKey"];
        [parameters setObject:@"52" forKey:@"txnType"];
        
    } else { //其他地区
        [parameters setObject:@"20" forKey:@"txnType"];
        
        if ([self.bcModel.cardType isEqualToString:@"2"]) { // 其他地区信用卡,不需要请求，直接跳转
            ZFSafeVerificationController *vc = [[ZFSafeVerificationController alloc] initWithParams:parameters];
            vc.phoneNumber = self.bcModel.phoneNumber;
            [self pushViewController:vc];
            return;
        }
    }
    
    // 发送请求
    [[MBUtils sharedInstance] showMBInView:self.view];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
            [[MBUtils sharedInstance] dismissMB];
            NSString *countryCode = [self.areaStatuArray[sender.tag] objectForKey:@"countryCode"];
            
            if ([[requestResult objectForKey:@"status"] isEqualToString:@"79"] && ![countryCode isEqualToString:@"UP"]) {//79时不需要验证码 直接调绑卡
                // 验证码界面
                ZFGetMSCodeController *vc = [[ZFGetMSCodeController alloc] initWithParams:parameters];
                vc.phoneNumber = self.bcModel.phoneNumber;
                vc.orderId = [requestResult objectForKey:@"orderId"];
                vc.status = [requestResult objectForKey:@"status"];
                [self pushViewController:vc];
                return ;
            }
            
            if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) { // 成功
                if ([countryCode isEqualToString:@"UP"]) { // 银联国际
                    
                    self.upModel = [ZFUPBankCardModel yy_modelWithJSON:requestResult];
                    if ([self.upModel.cvm containsObject:@"expiryDate"] || [self.upModel.cvm containsObject:@"cvn2"]) { // 有cvm要求：输入cvn、有效期等信息
                        ZFSafeVerificationController *vc = [[ZFSafeVerificationController alloc] initWithParams:parameters];
                        vc.bcModel = self.bcModel;
                        vc.upModel = self.upModel;
                        [self pushViewController:vc];
                    } else { // 无cvm要求
                        // 直接查otp结果
                        [self getOtpList];
                    }
                } else { // 其他地区借记卡
                    ZFGetMSCodeController *vc = [[ZFGetMSCodeController alloc] initWithParams:parameters];
                    vc.phoneNumber = self.bcModel.phoneNumber;
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


- (void)deleteBtnClicked {
    [self presentActionSheet];
}

- (void)presentActionSheet {
    UIAlertController *alertDialog = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"解除绑定", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        // 二次确认
        [XLAlertController acWithTitle:NSLocalizedString(@"确认解绑银行卡", nil) msg:nil confirmBtnTitle:NSLocalizedString(@"确定", nil) cancleBtnTitle:NSLocalizedString(@"取消", nil) confirmAction:^(UIAlertAction *action) {
            [self unboundAction];
        }];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // 取消按键
        DLog(@"cancelAction");
    }];
    
    // 添加操作（顺序就是呈现的上下顺序）
    [alertDialog addAction:deleteAction];
    [alertDialog addAction:cancelAction];
    // 呈现警告视图
    [self presentViewController:alertDialog animated:YES completion:nil];
}

- (void)btn2Clicked:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:NSLocalizedString(@"去认证", nil)]) {
        ZFPCPersonInfoViewController *infoView = [[ZFPCPersonInfoViewController alloc] init];
        [ZFGlobleManager getGlobleManager].applyType = @"1";
        infoView.enCardNum = self.bcModel.encryCardNo;
        [self pushViewController:infoView];
    } else if ([sender.titleLabel.text isEqualToString:[NSString stringWithFormat:@"%@", NSLocalizedString(@"查看详情", nil)]]) {
        ZFPCApprovalStatusViewController *approval = [[ZFPCApprovalStatusViewController alloc] initWithCardInfo:_cardInfo];
        approval.isVirtualCard = YES;
        [self pushViewController:approval];
    }
}

#pragma mark - 网络请求
- (void)unboundAction {
    NSDictionary *parameters = @{
                                 @"countryCode" : [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile" : [ZFGlobleManager getGlobleManager].userPhone,
                                 @"cardType" : self.bcModel.cardType,
                                 @"cardNum" : self.bcModel.encryCardNo,
                                 @"userKey" : [ZFGlobleManager getGlobleManager].userKey,
                                 @"sessionID" : [ZFGlobleManager getGlobleManager].sessionID,
                                 @"txnType": @"61",
                                 @"version" : @"version2.1",
                                 };
    [[MBUtils sharedInstance] showMBInView:self.view];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
            
            [[MBUtils sharedInstance] dismissMB];
            if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
                [[MBUtils sharedInstance] showMBSuccessdWithText:NSLocalizedString(@"解绑成功", nil) inView:self.view];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(AUTOTIPDISMISSTIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    // 返回上一层页面，刷新列表
                    [ZFGlobleManager getGlobleManager].isChanged = YES;
                    [self.navigationController popViewControllerAnimated:YES];
                });
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
                                 @"cardNum": self.bcModel.encryCardNo,
                                 @"tncID":self.upModel.tncID,
                                 @"otpValue":@"",
                                 @"txnType": @"55"};
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self bondSuccess];
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
        
        ZFGetMSCodeController *vc = [[ZFGetMSCodeController alloc] initWithBankCardModel:self.bcModel UPBankCardModel:self.upModel];
        vc.otpMethod = otpMethod;
        [self pushViewController:vc];
    } failure:^(NSError *error) {

    }];
}

//获取此卡交易列表
- (void)getCardTradeRecord{
    // 检查此处的RSA算法是否存在（公钥长度引起的）内存问题
    NSString *MD5Data = [[HBRSAHandler sharedInstance] encryptWithPublicKey: [ZFGlobleManager getGlobleManager].securityKey];
    MD5Data = [MD5Data stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    MD5Data = [MD5Data stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSString *encrypCardNum = [TripleDESUtils getEncryptWithString:self.bcModel.cardNo keyString: [ZFGlobleManager getGlobleManager].securityKey ivString: @"01234567"];
    
    NSDictionary *parameters = @{
                                 @"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"beginNum":[NSString stringWithFormat:@"%zd", self.currentPage],
                                 @"cardNum":encrypCardNum,
                                 @"MD5Data":MD5Data,
                                 @"txnType": @"64",
                                 };
    
    [[MBUtils sharedInstance] showMBInView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        self.tableView.emptyDataSetSource = self;
        self.tableView.emptyDataSetDelegate = self;
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            
            // 当前查询出来的交易数据
            NSArray <TradeModel *> *tradeMArray = [NSArray yy_modelArrayWithClass:[TradeModel class] json:[requestResult objectForKey:@"list"]];

            if (self.sectionArray.count) { // 第二次以上查询
                for (int i = 0; i < tradeMArray.count; i++) {
                    if (![tradeMArray[i].tradeMonth isEqualToString:self.sectionArray.lastObject.month]) {
                        TradeSectionModel *sectiomModel = [[TradeSectionModel alloc] init];
                        sectiomModel.month = tradeMArray[i].tradeMonth;
                        sectiomModel.currentMonthArray = [NSMutableArray arrayWithObjects:tradeMArray[i], nil];
                        [self.sectionArray addObject:sectiomModel];

                        continue ;
                    }

                    [self.sectionArray.lastObject.currentMonthArray addObject:tradeMArray[i]];
                }
            } else { // 第一次查询
                // 按月归类
                NSMutableArray<TradeModel *> *currentMonthArray = [NSMutableArray array];
                // 默认添加第一条
                [currentMonthArray addObject:tradeMArray[0]];

                if (tradeMArray.count == 1) { // 当月只有一条数据时
                    TradeSectionModel *sectiomModel = [[TradeSectionModel alloc] init];
                    sectiomModel.month = [currentMonthArray lastObject].tradeMonth;
                    sectiomModel.currentMonthArray = [NSMutableArray arrayWithArray:currentMonthArray];
                    [self.sectionArray addObject:sectiomModel];
                } else { // 多余一条数据时
                    for (int i = 1; i < tradeMArray.count; i++) {

                        if (![tradeMArray[i].tradeMonth isEqualToString:[currentMonthArray lastObject].tradeMonth]) {
                            TradeSectionModel *sectiomModel = [[TradeSectionModel alloc] init];
                            sectiomModel.month = [currentMonthArray lastObject].tradeMonth;
                            sectiomModel.currentMonthArray = [NSMutableArray arrayWithArray:currentMonthArray];
                            [self.sectionArray addObject:sectiomModel];

                            [currentMonthArray removeAllObjects];
                            [currentMonthArray addObject:tradeMArray[i]];

                            if (i == tradeMArray.count-1) {
                                TradeSectionModel *sectiomModel = [[TradeSectionModel alloc] init];
                                sectiomModel.month = [currentMonthArray lastObject].tradeMonth;
                                sectiomModel.currentMonthArray = [NSMutableArray arrayWithArray:currentMonthArray];
                                [self.sectionArray addObject:sectiomModel];
                            }

                            continue ;
                        }

                        [currentMonthArray addObject:tradeMArray[i]];

                        if (i == tradeMArray.count-1) {
                            TradeSectionModel *sectiomModel = [[TradeSectionModel alloc] init];
                            sectiomModel.month = [currentMonthArray lastObject].tradeMonth;
                            sectiomModel.currentMonthArray = [NSMutableArray arrayWithArray:currentMonthArray];
                            [self.sectionArray addObject:sectiomModel];
                        }
                    }
                }
            }

            // 获取数据之后的刷新处理
            // 第一次获取决定是否隐藏尾部刷新控件
            if (tradeMArray.count >= 8) {
                [self.tableView.mj_footer setHidden:NO];
            }
            // 统一结束刷新
            [self.tableView.mj_footer endRefreshing];

            [self.tableView reloadData];

        } else {
            [self.tableView.mj_footer endRefreshing];

            if ([[requestResult objectForKey:@"status"] isEqualToString:@"2"]) {//没有交易记录
                if (self.currentPage > 1) { // 查过一次显示没有更多数据
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                } else { // 第一页都没有隐藏
                    [self.tableView.mj_footer setHidden:YES];
                    [self.tableView reloadData];
                }
            } else {
                [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
            }
        }
    } failure:^(NSError *error) {
        [self.tableView.mj_footer endRefreshing];
    }];
}


- (void)getYufuCardCertificationStatus {
    NSString *encrypCardNum = [TripleDESUtils getEncryptWithString:self.bcModel.cardNo keyString: [ZFGlobleManager getGlobleManager].securityKey ivString:@"01234567"];
    
    NSDictionary *parameters = @{
                                 @"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"cardNum":encrypCardNum,
                                 @"txnType": @"91",
                                 };
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            NSString *origStatus = [requestResult objectForKey:@"origStatus"];
            NSString *status = @"";
            if ([origStatus isEqualToString:@"0"]) {
                status = NSLocalizedString(@"待审核", nil);
            }
            else if ([origStatus isEqualToString:@"1"]) {
                status = NSLocalizedString(@"审核通过", nil);
            }
            else if ([origStatus isEqualToString:@"2"]) {
                status = [NSString stringWithFormat:@"%@", NSLocalizedString(@"查看详情", nil)];
                _btn2.enabled = YES;
                _cardInfo = [ZFPCBankCard yy_modelWithJSON:requestResult];
            }
            else if ([origStatus isEqualToString:@"3"]) {
                status = NSLocalizedString(@"不需要认证", nil);
            }
            else if ([origStatus isEqualToString:@"4"]) {
                status = NSLocalizedString(@"去认证", nil);
                _btn2.enabled = YES;
            }
            
            [_btn2 setTitleColor:_btn2.enabled ? [UIColor whiteColor] : ZFAlpColor(0, 0, 0, 0.6) forState:UIControlStateNormal];
            _btn2.contentHorizontalAlignment = _btn2.enabled ? 0 : 2;
            [_btn2 setBackgroundImage:_btn2.enabled ? [UIImage imageNamed:@"btn_background_clickable"] : nil forState:UIControlStateNormal];
            [_btn2 setBackgroundImage:_btn2.enabled ? [UIImage imageNamed:@"btn_background_clickable"] : nil forState:UIControlStateHighlighted];
            [_btn2 setTitle:status forState:UIControlStateNormal];
            CGSize titleSize = [status sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:_btn2.titleLabel.font.fontName size:_btn2.titleLabel.font.pointSize]}];
            titleSize.height = 30;
            titleSize.width += 15;
            _btn2.frame = CGRectMake(SCREEN_WIDTH-titleSize.width-15, 10, titleSize.width, titleSize.height);
        }
    } failure:^(id error) {
        
    }];
}

- (NSMutableArray<TradeSectionModel *> *)sectionArray {
    if (!_sectionArray) {
        _sectionArray = [NSMutableArray array];
    }
    return _sectionArray;
}

// 绑定成功，返回
- (void)bondSuccess {
    [[MBUtils sharedInstance] showMBSuccessdWithText:NSLocalizedString(@"认证成功", nil) inView:self.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(AUTOTIPDISMISSTIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 返回银行卡列表页面
        [ZFGlobleManager getGlobleManager].isChanged = YES;
        [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
    });
}

@end
