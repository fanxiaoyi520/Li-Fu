//
//  ZFMyBankCardViewController.m
//  newupop
//
//  Created by Jellyfish on 2017/7/25.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFMyBankCardViewController.h"
#import "UIScrollView+EmptyDataSet.h"
#import "ZFValidatePwdController.h"
#import "ZFBankCardCell.h"
#import "ZFBankCardDetailViewController.h"
#import "ZFAddCardNoViewController.h"
#import "YYModel.h"
#import "ZFLogOffIDViewController.h"
#import "ZFLogOffResultViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "ZFPCPersonInfoViewController.h"

@interface ZFMyBankCardViewController () <UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

/** tableView */
@property (nonatomic, weak) UITableView *tableView;
/** 银行卡数组 */
@property(nonatomic, strong) NSArray<ZFBankCardModel *> *bankCardArray;

///是否可以申请中付卡 0 未申请  1 已申请
@property (nonatomic, strong)NSString *applyType;

@end

@implementation ZFMyBankCardViewController

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myTitle = NSLocalizedString(@"银行卡", nil);
    
    [self setupRightBtn];
    [self setupTableView];
    
    // 获取银行卡列表
    [self getBankCardList];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([ZFGlobleManager getGlobleManager].isChanged) {
        [self getBankCardList];
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
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = GrayBgColor;
//    tableView.rowHeight = 100;
    tableView.rowHeight = 80;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

#pragma mark -- UITableViewDataSourece&UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.bankCardArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ZFBankCardCell *cell = [ZFBankCardCell cellWithTableView:tableView];
    cell.model = self.bankCardArray[indexPath.section];
    @weakify(cell)
    cell.showNumBlock = ^(BOOL isSelect, NSString *cardNum, NSString *cardName) {
        if (isSelect) {
            weak_cell.cardNoLabel.text = cardNum;
            if ([cardName isEqualToString:@"Sinopay"]) {
                [self queryBalanceWithCardNum:cardNum selectCell:weak_cell];
            }
        } else {
            // 截取后4位
            NSString *sub = [cardNum substringFromIndex:cardNum.length-4];
            weak_cell.cardNoLabel.text = [NSString stringWithFormat:@"**** **** **** %@", sub];
            weak_cell.balanceLabel.text = [NSString stringWithFormat:@"%@****", NSLocalizedString(@"余额：", nil)];
        }
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DLog(@"%ld", (long)indexPath.section);
    if (indexPath.section == self.bankCardArray.count) {
        return;
    }
    ZFBankCardDetailViewController *bdvc = [[ZFBankCardDetailViewController alloc] initWithBankCardModel:self.bankCardArray[indexPath.section]];
    [self pushViewController:bdvc];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 20;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == self.bankCardArray.count-1) {
        if ([_applyType isEqualToString:@"0"]) {
            return 80;
        }
        return 10;
    }
    return 0.00001;
}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//    if (section == self.bankCardArray.count-1 && [_applyType isEqualToString:@"0"]) {
//
//        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80)];
//        UIButton *applyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        applyBtn.frame = CGRectMake(20, 30, SCREEN_WIDTH-40, 40);
//        [applyBtn setTitle:NSLocalizedString(@"申请中付银联预付卡", nil) forState:UIControlStateNormal];
//        [applyBtn setBackgroundImage:[UIImage imageNamed:@"btn_background_clickable"] forState:UIControlStateNormal];
//        [applyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [applyBtn addTarget:self action:@selector(applySinoCard) forControlEvents:UIControlEventTouchUpInside];
//        [backView addSubview:applyBtn];
//
//        return backView;
//    }
//    return nil;
//}

#pragma mark -- DZNEmptyDataSetSource
// 设置空白页展示图片
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"pic_card"];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView{
    NSString *text = [NSString stringWithFormat:@"%@\n\n", NSLocalizedString(@"暂未绑定支付卡，请点击右上角图标“+”添加重试。", nil)];
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:13.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

//- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state{
//    NSString *text = NSLocalizedString(@"申请中付银联预付卡", nil);
//    
//    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:15.0f],
//                                 NSForegroundColorAttributeName: [UIColor whiteColor]};
//    
//    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
//}

- (UIImage *)buttonBackgroundImageForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state{
    return [UIImage imageNamed:@"btn_background_clickable"];
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return -100;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button{
    [self applySinoCard];
}

#pragma mark -- 点击方法
- (void)addBankCard {
    
//    ZFLogOffIDViewController *vc = [ZFLogOffIDViewController new];
//    [self pushViewController:vc];
    
    ZFValidatePwdController *generateVC = [[ZFValidatePwdController alloc] init];
    generateVC.fromType = 2;
    [self.navigationController pushViewController:generateVC animated:YES];
}

#pragma mark - 网络请求
- (void)getBankCardList {
    if (![ZFGlobleManager getGlobleManager].isChanged) {
        [[MBUtils sharedInstance] showMBInView:self.view];
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary *parameters = @{
                                     @"countryCode" : [ZFGlobleManager getGlobleManager].areaNum,
                                     @"mobile" : [ZFGlobleManager getGlobleManager].userPhone,
                                     @"cardType" : @"0",
                                     @"userKey" : [ZFGlobleManager getGlobleManager].userKey,
                                     @"sessionID" : [ZFGlobleManager getGlobleManager].sessionID,
                                     @"txnType": @"11",
                                     @"version" : @"version2.1",
                                     };
        [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
            _tableView.emptyDataSetSource = self;
            _tableView.emptyDataSetDelegate = self;
            // 将状态清空
            [ZFGlobleManager getGlobleManager].isChanged = NO;
            [[MBUtils sharedInstance] dismissMB];
            _applyType = [requestResult objectForKey:@"totalCredit"];
            if ([_applyType isKindOfClass:[NSNull class]]) {
                _applyType = @"";
            }
            if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
                self.bankCardArray = [NSArray yy_modelArrayWithClass:[ZFBankCardModel class] json:requestResult[@"list"]];

                self.bankCardArray = [[ZFGlobleManager getGlobleManager] sortBankArrayWith:self.bankCardArray];

                [ZFGlobleManager getGlobleManager].bankCardArray = [NSMutableArray arrayWithArray:_bankCardArray];
            } else {
                self.bankCardArray = [NSArray array];
                [ZFGlobleManager getGlobleManager].bankCardArray = nil;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        } failure:^(NSError *error) {
            
        }];
    });
}

//申请中付卡
- (void)applySinoCard{
    
    NSDictionary *parameters = @{@"countryCode" : [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile" : [ZFGlobleManager getGlobleManager].userPhone,
                                 @"userKey" : [ZFGlobleManager getGlobleManager].userKey,
                                 @"sessionID" : [ZFGlobleManager getGlobleManager].sessionID,
                                 @"txnType": @"63",
                                 };
    [[MBUtils sharedInstance] showMBWithText:@"" inView:self.view];
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [ZFGlobleManager getGlobleManager].applyType = @"1";
            ZFPCPersonInfoViewController *infoView = [[ZFPCPersonInfoViewController alloc] init];
            infoView.enCardNum = [requestResult objectForKey:@"cardNum"];
            [self pushViewController:infoView];
            [ZFGlobleManager getGlobleManager].isChanged = YES;
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(NSError *error) {
        
    }];
}



- (void)queryBalanceWithCardNum:(NSString *)cardNo selectCell:(ZFBankCardCell *)cell {
    NSString *cardNum = [TripleDESUtils getEncryptWithString:[cardNo stringByReplacingOccurrencesOfString:@" " withString:@""] keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV];
    NSDictionary *parameters = @{
                                 @"countryCode" : [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile" : [ZFGlobleManager getGlobleManager].userPhone,
                                 @"cardNum" : cardNum,
                                 @"userKey" : [ZFGlobleManager getGlobleManager].userKey,
                                 @"sessionID" : [ZFGlobleManager getGlobleManager].sessionID,
                                 @"txnType": @"89",
                                 };
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine singlePostWithParmas:parameters success:^(NSDictionary *requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            NSArray *balanceArray = [requestResult objectForKey:@"balance"];
            NSString *xb = @"";
            NSString *rmb = @"";
            NSString *gb = @"";
            for (NSDictionary *balance in balanceArray) {
                if ([[balance objectForKey:@"currency"] isEqualToString:@"156"]) {
                    rmb = [balance objectForKey:@"amount"];
                } else if ([[balance objectForKey:@"currency"] isEqualToString:@"702"]) {
                    xb = [balance objectForKey:@"amount"];
                } else if ([[balance objectForKey:@"currency"] isEqualToString:@"344"]) {
                    gb = [balance objectForKey:@"amount"];
                }
                
                NSString *isLocationType = [requestResult objectForKey:@"isLocationType"];
                
                NSString *displayBalnaceString = @"";
                if ([isLocationType isEqualToString:@"yes"]) {
                    NSString *country = [LocationUtils sharedInstance].BalanceISOCountryCode;
                    NSLog(@"当前国家--- %@", country);
                    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
                    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
                        if ([country isEqualToString:@"SG"]) {
                            displayBalnaceString = [NSString stringWithFormat:@"%@%@ %.2f", NSLocalizedString(@"余额：", nil), NSLocalizedString(@"新币", nil), [xb doubleValue]];
                        } else if ([country isEqualToString:@"HK"]) {
                            displayBalnaceString = [NSString stringWithFormat:@"%@%@ %.2f", NSLocalizedString(@"余额：", nil), NSLocalizedString(@"港币", nil), [gb doubleValue]];
                        } else if ([country isEqualToString:@"CN"]) {
                            displayBalnaceString = [NSString stringWithFormat:@"%@ %.2f", NSLocalizedString(@"余额：人民币", nil), [rmb doubleValue]];
                        }
                    }
                }
                
                cell.balanceLabel.text = displayBalnaceString.length ? displayBalnaceString : [NSString stringWithFormat:@"%@%@ %.2f", NSLocalizedString(@"余额：", nil), NSLocalizedString(@"港币", nil), [gb doubleValue]];
            }
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
            cell.balanceLabel.text = [NSString stringWithFormat:@"%@ ****", NSLocalizedString(@"余额：", nil)];
        }
    } failure:^(NSError *error) {
    }];
}


#pragma mark - 其他方法
- (NSArray<ZFBankCardModel *> *)bankCardArray {
    if (!_bankCardArray) {
        _bankCardArray = [NSArray array];
    }
    return _bankCardArray;
}


@end
