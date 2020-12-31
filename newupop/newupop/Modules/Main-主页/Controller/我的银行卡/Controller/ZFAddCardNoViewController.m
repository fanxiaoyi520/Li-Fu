//
//  ZFAddCardNoViewController.m
//  newupop
//
//  Created by Jellyfish on 2017/12/19.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFAddCardNoViewController.h"
#import "UITextField+Format.h"
#import "ZFAddCardDetailViewController.h"
#import "ZFPCBankCard.h"
#import "ZFPCApprovalStatusViewController.h"
#import "ZFPCPersonInfoViewController.h"

@interface ZFAddCardNoViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

/** 卡号 */
@property(nonatomic, weak) UITextField *cardNoTF;


@end

@implementation ZFAddCardNoViewController

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myTitle = NSLocalizedString(@"添加银行卡", nil);
    
    [self setupTableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.cardNoTF becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

#pragma mark - 初始化方法
- (void)setupTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.backgroundColor = GrayBgColor;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.scrollEnabled = NO;
    tableView.tableFooterView = [UIView new];
    [self.view addSubview:tableView];
}

#pragma mark -- UITableViewDataSourece&UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MYCELL"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.textLabel.textColor = ZFAlpColor(0, 0, 0, 0.8);
    cell.textLabel.text = NSLocalizedString(@"卡号", nil);
    
    // 右边
    UITextField *textField = [UITextField new];
    textField.placeholder = NSLocalizedString(@"请输入银行卡号", nil);
    textField.textAlignment = NSTextAlignmentLeft;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.textColor = ZFAlpColor(0, 0, 0, 0.6);
    textField.returnKeyType = UIReturnKeyDone;
    textField.font = [UIFont systemFontOfSize:15.0];
    textField.size = CGSizeMake(SCREEN_WIDTH-120, 44);
    textField.x = 100;
    textField.y = 0;
    textField.delegate = self;
    self.cardNoTF = textField;
    [cell addSubview:textField];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 45+44+45)];
    bgView.backgroundColor = GrayBgColor;
    
    // 提交按钮
    UIButton *commitBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 45, SCREEN_WIDTH-40, 44)];
    [commitBtn setTitle:NSLocalizedString(@"下一步", nil) forState:UIControlStateNormal];
    [commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [commitBtn setTitleColor:ZFAlpColor(255, 255, 255, 0.7) forState:UIControlStateHighlighted];
    commitBtn.layer.cornerRadius = 5.0f;
    commitBtn.backgroundColor = MainThemeColor;
    [commitBtn addTarget:self action:@selector(commitBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:commitBtn];
    
    return bgView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 45*2+44;
}

#pragma mark - 点击方法
- (void)commitBtnClicked {
    if (self.cardNoTF.text.length == 0) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"请输入银行卡号", nil) inView:self.view];
        return;
    } else if (self.cardNoTF.text.length < 9) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"卡号有误", nil) inView:self.view];
        return;
    }
    
    [self.view endEditing:YES];
    [self getCardType];
    
//    ZFLogOffIDViewController *vc = [ZFLogOffIDViewController new];
//    [self pushViewController:vc];
    
}

// 判断卡类型
- (void)getCardType {
    
    NSString *cardNum = [TripleDESUtils getEncryptWithString:[self.cardNoTF.text stringByReplacingOccurrencesOfString:@" " withString:@""] keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"cardNum":cardNum,
                                 @"txnType": @"51"};
    [[MBUtils sharedInstance] showMBInView:self.view];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
            [[MBUtils sharedInstance] dismissMB];
            if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
                NSString *type = [requestResult objectForKey:@"cardType"];
                NSString *bankName = [requestResult objectForKey:@"bankName"];
                if ([bankName isEqualToString:@"Sinopay"]) {
                    [self getCardStatus:cardNum andType:type];
                } else {
                    if ([type isEqualToString:@"1"]) { // 借记卡
                        ZFAddCardDetailViewController *vc = [[ZFAddCardDetailViewController alloc] initWithBankCardType:BankCardTypeDebit cardNo:self.cardNoTF.text];
                        [self pushViewController:vc];
                    } else {// 信用卡
                        ZFAddCardDetailViewController *vc = [[ZFAddCardDetailViewController alloc] initWithBankCardType:BankCardTypeCredit cardNo:self.cardNoTF.text];
                        [self pushViewController:vc];
                    }
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
                });
            }
            
        } failure:^(NSError *error) {
            
        }];
    });
}

- (void)getCardStatus:(NSString *)cardNo andType:(NSString *)type {
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
            if ([[requestResult objectForKey:@"origStatus"] isEqualToString:@"1"]) {
                if ([type isEqualToString:@"1"]) { // 借记卡
                    ZFAddCardDetailViewController *vc = [[ZFAddCardDetailViewController alloc] initWithBankCardType:BankCardTypeDebit cardNo:self.cardNoTF.text];
                    [self pushViewController:vc];
                } else {// 信用卡
                    ZFAddCardDetailViewController *vc = [[ZFAddCardDetailViewController alloc] initWithBankCardType:BankCardTypeCredit cardNo:self.cardNoTF.text];
                    [self pushViewController:vc];
                }
            } else if ([[requestResult objectForKey:@"origStatus"] isEqualToString:@"3"]) {
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"温馨提示",nil)
                                                                               message:NSLocalizedString(@"该银行卡未提交认证资料，是否提交认证资料?",nil)
                                                                        preferredStyle:UIAlertControllerStyleAlert];

                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消",nil) style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {

                                                                      }];
                UIAlertAction* sureAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确认",nil) style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {
                                                                    [ZFGlobleManager getGlobleManager].applyType = @"1";
                                                                    ZFPCPersonInfoViewController *infoView = [[ZFPCPersonInfoViewController alloc] init];
                                                                    infoView.enCardNum = [requestResult objectForKey:@"cardNum"];
                                                                    [self pushViewController:infoView];
                                                                    [ZFGlobleManager getGlobleManager].isChanged = YES;
                                                                      }];
                [defaultAction setValue:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0] forKey:@"_titleTextColor"];
                [alert addAction:defaultAction];
                [alert addAction:sureAction];
                [self presentViewController:alert animated:YES completion:nil];
            } else {
                ZFPCBankCard *card = [ZFPCBankCard yy_modelWithJSON:requestResult];
                ZFPCApprovalStatusViewController *approval = [[ZFPCApprovalStatusViewController alloc] initWithCardInfo:card];
                [self pushViewController:approval];
            }
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
    }];
}

#pragma mark - 其他方法
// 格式化卡号
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [textField formatBankCardNoWithString:string range:range];
    return NO;
}

// return按钮
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self commitBtnClicked];
    
    return YES;
}

@end
