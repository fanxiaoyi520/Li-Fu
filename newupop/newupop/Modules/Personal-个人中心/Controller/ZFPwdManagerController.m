//
//  ZFPwdManagerController.m
//  newupop
//
//  Created by 中付支付 on 2017/7/24.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFPwdManagerController.h"
#import "ZFSetLoginPwdController.h"
#import "ZFGetVerCodeController.h"
#import "ZFInputPwdController.h"


@interface ZFPwdManagerController ()<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSArray *dataArray;
///指纹开关
@property (nonatomic, strong)UISwitch *fingerprintswitch;
///未设置支付密码 0   已设置支付密码 1
@property (nonatomic, assign)NSInteger managerType;

@end

@implementation ZFPwdManagerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myTitle = @"密码管理";

    if ([[NSUserDefaults standardUserDefaults] boolForKey:PayPwdAlreadySet]) {
        _managerType = 1;
        [self createView];
    } else {
        _managerType = 0;
        [self checkIsSetPayPwd];
    }
}

#pragma mark 查询是否设置支付密码
- (void)checkIsSetPayPwd{
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"userKey": [ZFGlobleManager getGlobleManager].userKey,
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"txnType": @"27"};
    
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            _managerType = 1;
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PayPwdAlreadySet];
        } else {
            _managerType = 0;
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:PayPwdAlreadySet];
        }
        [self createView];
    } failure:^(NSError *error) {
        //[[MBUtils sharedInstance] dismissMB];
        
    }];
}

#pragma mark 创建视图
- (void)createView{
    if (_managerType == 0) {
        _dataArray = [NSArray arrayWithObjects:NSLocalizedString(@"设置支付密码", nil), nil];
    } else {
        _dataArray = [NSArray arrayWithObjects:NSLocalizedString(@"修改支付密码", nil), NSLocalizedString(@"找回支付密码", nil), nil];
    }
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = GrayBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    [self.view addSubview:_tableView];
}

#pragma mark - tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_managerType == 1) {
        if (section == 2) {
            return 10;
         } else {
            return 20;
        }
    } else {
        if (section == 1) {
            return 10;
        } else {
            return 20;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = _dataArray[indexPath.section];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    if (indexPath.section == _dataArray.count - 1) {
//        cell.accessoryType = UITableViewCellAccessoryNone;
//        _fingerprintswitch = [[UISwitch alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 10, 30, 20)];
//        _fingerprintswitch.center = CGPointMake(SCREEN_WIDTH-50, cell.height/2);
//        BOOL isOn = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@fingerprint", [ZFGlobleManager getGlobleManager].userPhone]];
//        [_fingerprintswitch setOn:isOn];
//        [_fingerprintswitch addTarget:self action:@selector(clickSwitch:) forControlEvents:UIControlEventValueChanged];
//        [cell addSubview:_fingerprintswitch];
//    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DLog(@"%zd", indexPath.section);
    switch (indexPath.section) {
//        case 0:
//        {
//            ZFSetLoginPwdController *setPwdVC = [[ZFSetLoginPwdController alloc] init];
//            setPwdVC.type = 1;
//            [self.navigationController pushViewController:setPwdVC animated:YES];
//        }
//            break;
//
        case 0:
        {
            ZFInputPwdController *inputVC = [[ZFInputPwdController alloc] init];
            if (_managerType == 0) {//设置支付密码
                inputVC.inputType = 0;
            } else {//修改支付密码
                inputVC.inputType = 1;
            }
            [self.navigationController pushViewController:inputVC animated:YES];
        }
            break;
        case 1:
        {
            if (_managerType == 1) {//找回支付密码
                ZFGetVerCodeController *gcVC = [[ZFGetVerCodeController alloc] init];
                gcVC.getCodeType = 1;
                [self.navigationController pushViewController:gcVC animated:YES];
            } 
        }
            break;
        
        default:
            break;
    }
}

//- (void)clickSwitch:(UISwitch *)sender{
//    BOOL isOn = [sender isOn];
//    DLog(@"%zd", [sender isOn]);
//    if (isOn) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确定开启指纹解锁" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"开启", nil];
//        alert.tag = 100;
//        [alert show];
//    } else {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确定关闭指纹解锁" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"关闭", nil];
//        alert.tag = 101;
//        [alert show];
//    }
//}
//
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    if (alertView.tag == 100) {
//        if (buttonIndex == 0) {
//            [_fingerprintswitch setOn:NO];
//        } else {
//            [_fingerprintswitch setOn:YES];
//        }
//    }
//
//    if (alertView.tag == 101) {
//        if (buttonIndex == 0) {
//            [_fingerprintswitch setOn:YES];
//        } else {
//            [_fingerprintswitch setOn:NO];
//        }
//    }
//    //保存到本地 key为手机号+fingerprint
//    [[NSUserDefaults standardUserDefaults] setBool:_fingerprintswitch.isOn forKey:[NSString stringWithFormat:@"%@fingerprint", [ZFGlobleManager getGlobleManager].userPhone]];
//}


@end
