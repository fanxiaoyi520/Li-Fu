//
//  ZFPrepaidCardListViewController.m
//  newupop
//
//  Created by Jellyfish on 2020/1/6.
//  Copyright © 2020 中付支付. All rights reserved.
//

#import "ZFPrepaidCardListViewController.h"
#import "UIScrollView+EmptyDataSet.h"
#import "ZFVerifyBankCardNoViewController.h"
#import "ZFPCBankCard.h"
#import "ZFPrepaidCardListCell.h"
#import "ZFPCApprovalStatusViewController.h"
#import "ZFPCPersonInfoViewController.h"

@interface ZFPrepaidCardListViewController () <UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

/** tableView */
@property (nonatomic, weak) UITableView *tableView;
/** 银行卡数组 */
@property(nonatomic, strong) NSArray<ZFPCBankCard *> *bankCardArray;


@end

@implementation ZFPrepaidCardListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myTitle = NSLocalizedString(@"银行卡", nil);
    _bankCardArray = [[NSArray alloc] init];
    [self setupRightBtn];
    [self setupTableView];
    [self getCardList];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([ZFGlobleManager getGlobleManager].pcCommitSuccess) {//提交成功之后刷新一下
        [self getCardList];
    }
}

#pragma mark - 初始化视图
- (void)setupRightBtn {
    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-60, IPhoneXStatusBarHeight, 60, 44)];
    [addBtn setImage:[UIImage imageNamed:@"icon_add_card"] forState:UIControlStateNormal];
    [addBtn setImage:[UIImage imageNamed:@"icon_add_card"] forState:UIControlStateHighlighted];
    [addBtn addTarget:self action:@selector(addBankCard) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addBtn];
}


- (void)setupTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    [tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ZFPrepaidCardListCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ZFPrepaidCardListCell class])];
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

#pragma mark -- UITableViewDataSourece&UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _bankCardArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFPrepaidCardListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ZFPrepaidCardListCell class]) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *cardNum = [TripleDESUtils getDecryptWithString:_bankCardArray[indexPath.section].cardNum keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    if (cardNum.length > 10) {
        NSString *preNum = [cardNum substringToIndex:6];
        NSString *sufNum = [cardNum substringFromIndex:cardNum.length-4];
        cell.cardNum.text = [NSString stringWithFormat:@"%@ **** **** %@", preNum, sufNum];
    } else {
        cell.cardNum.text = cardNum;
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self getCardStatus:_bankCardArray[indexPath.section].cardNum];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 35)];
        headView.backgroundColor = [UIColor whiteColor];
        UILabel *monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 7, SCREEN_WIDTH, 20)];
        monthLabel.font = [UIFont systemFontOfSize:13];
        monthLabel.textColor = UIColorFromRGB(0x313131);
        monthLabel.text = _bankCardArray.count ? NSLocalizedString(@"点击银行卡查看审核状态", nil) : @"";
        [headView addSubview:monthLabel];
        
        return headView;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 35 : 10;
}


#pragma mark -- 网络请求
- (void)getCardList {
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                                 @"txnType": @"87"};
    
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        self.tableView.emptyDataSetSource = self;
        self.tableView.emptyDataSetDelegate = self;
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            _bankCardArray = [NSArray yy_modelArrayWithClass:[ZFPCBankCard class] json:requestResult[@"cardList"]];
            [_tableView reloadData];
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
        [ZFGlobleManager getGlobleManager].pcCommitSuccess = NO;
    } failure:^(id error) {
        [ZFGlobleManager getGlobleManager].pcCommitSuccess = NO;
    }];
}

- (void)getCardStatus:(NSString *)cardNo {
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                                 @"cardNum": cardNo,
                                 @"txnType": @"86",
                                 @"applyType":@"1"};
    
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            ZFPCBankCard *card = [ZFPCBankCard yy_modelWithJSON:requestResult];
            ZFPCApprovalStatusViewController *approval = [[ZFPCApprovalStatusViewController alloc] initWithCardInfo:card];
            [self pushViewController:approval];
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
        
    } failure:^(id error) {
    }];
}

#pragma mark -- 点击方法
- (void)addBankCard {
    ZFVerifyBankCardNoViewController *verifyVC = [[ZFVerifyBankCardNoViewController alloc] init];
    [self pushViewController:verifyVC];
}

#pragma mark -- DZNEmptyDataSetSource
// 设置空白页展示图片
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"pic_card"];
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return -100;
}

@end
