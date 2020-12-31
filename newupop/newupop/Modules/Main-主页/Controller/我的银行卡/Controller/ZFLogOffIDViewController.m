//
//  ZFLogOffIDViewController.m
//  newupop
//
//  Created by Jellyfish on 2017/12/20.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFLogOffIDViewController.h"
#import "ZFLogOffResultViewController.h"

@interface ZFLogOffIDViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation ZFLogOffIDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myTitle = NSLocalizedString(@"注销实名信息", nil);
    
    [self setupTableView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

#pragma mark - 初始化方法
- (void)setupTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.backgroundColor = GrayBgColor;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.rowHeight = 60;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.scrollEnabled = NO;
    [self.view addSubview:tableView];
}

#pragma mark -- UITableViewDataSourece&UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MYCELL"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.textLabel.textColor = ZFAlpColor(0, 0, 0, 0.8);
    cell.textLabel.text = NSLocalizedString(@"解绑所有银行卡", nil);
    
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
    cell.detailTextLabel.textColor = ZFAlpColor(0, 0, 0, 0.6);
    cell.detailTextLabel.text = NSLocalizedString(@"系统将为你清空当前账户的绑卡信息", nil);
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *contentView  = [UIView new];
    contentView.backgroundColor = [UIColor clearColor];
    contentView.frame = CGRectMake(20, 0, SCREEN_WIDTH, 44);
    
    UILabel *textLabel = [UILabel new];
    textLabel.x = 15;
    textLabel.y = 15;
    textLabel.text = NSLocalizedString(@"注销成功后账户信息将产生以下变更", nil);
    [textLabel sizeToFit];
    textLabel.textColor = [UIColor grayColor];
    textLabel.font = [UIFont systemFontOfSize:13.0];
    textLabel.textAlignment = NSTextAlignmentLeft;
    [contentView addSubview:textLabel];
    
    return contentView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 45+44+45)];
    bgView.backgroundColor = GrayBgColor;
    
    // 提交按钮
    UIButton *logoffBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 45, SCREEN_WIDTH-40, 44)];
    [logoffBtn setTitle:NSLocalizedString(@"确认注销", nil) forState:UIControlStateNormal];
    [logoffBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [logoffBtn setTitleColor:ZFAlpColor(255, 255, 255, 0.7) forState:UIControlStateHighlighted];
    logoffBtn.layer.cornerRadius = 5.0f;
    logoffBtn.backgroundColor = MainThemeColor;
    [logoffBtn addTarget:self action:@selector(logoffBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:logoffBtn];
    
    return bgView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 45*2+44;
}

#pragma mark - 点击方法
- (void)logoffBtnClicked {
    [self unBoudUserName];
}

-(void)unBoudUserName {
    NSDictionary *parameters = @{
                                 @"countryCode" : [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile" : [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID" : [ZFGlobleManager getGlobleManager].sessionID,
                                 @"userKey" : [ZFGlobleManager getGlobleManager].userKey,
                                 @"txnType" : @"60",
                                 };
    [[MBUtils sharedInstance] showMBInView:self.view];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
            if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
                // 清楚缓存
                [self deleteUserInfo];
                ZFLogOffResultViewController *vc = [ZFLogOffResultViewController new];
                [self pushViewController:vc];
                
                NSMutableArray<ZFBaseViewController *> *tempMArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                // 移除中间的控制器,下个页面可以直接回到银行卡列表页
                [tempMArray removeObjectsInRange:NSMakeRange(2, tempMArray.count-3)];
                [self.navigationController setViewControllers:tempMArray animated:NO];
            } else {
                [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
            }
        } failure:^(NSError *error) {
            
        }];
    });
}

- (void)deleteUserInfo {
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:UserName];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:UserIdCardNum];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:IdType];
}

@end
