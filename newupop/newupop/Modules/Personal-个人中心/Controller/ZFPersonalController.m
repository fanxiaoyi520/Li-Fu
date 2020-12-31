//
//  ZFPersonalController.m
//  newupop
//
//  Created by 中付支付 on 2017/7/21.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFPersonalController.h"
#import "ZFUserSetController.h"
#import "ZFPwdManagerController.h"
#import "ZFAboutController.h"
#import "ZFTradeRecordController.h"
#import "ZFChangeLanguageController.h"
#import "DateUtils.h"
#import "NSBundle+Language.h"
#import "ZFTabBarController.h"
#import "ZFMyCouponViewController.h"
#import "ZFInputPwdController.h"
#import "ZFHeadScrollviewViewController.h"
#import "ZFPromoteAwardController.h"
#import "ZFPrepaidCardListViewController.h"
#import "ZFSetFingerprintViewController.h"
#import "ZFMyBankCardViewController.h"

@interface ZFPersonalController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSArray *dataArray;
@property (nonatomic, strong)NSArray *imageArray;

@end

@implementation ZFPersonalController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isHiddenBack = YES;
    self.myTitle = @"我的";
    
    [self createView];
}

- (NSArray *)dataArray{
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:UserName];
    if ([userName isKindOfClass:[NSNull class]] || !userName) {
        userName = @"";
    }
    NSString *userStr = [NSString stringWithFormat:@"%@ %@", [DateUtils getCurrentTimePeriodGreetings], userName];
//    LAContext *context = [[LAContext alloc] init];
//    NSError *error = nil;
    //[context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error] &&
    if ([SmallUtils supportTouchsDevicesAndSystem] == YES) {
        _dataArray = [NSArray arrayWithObjects:userStr, NSLocalizedString(@"交易记录", nil), NSLocalizedString(@"我的优惠券", nil), NSLocalizedString(@"密码管理", nil), NSLocalizedString(@"代币卡绑卡", nil),NSLocalizedString(@"指纹设置", nil), NSLocalizedString(@"推广有奖", nil), NSLocalizedString(@"多语言", nil), NSLocalizedString(@"关于SinoPay", nil), nil];
        _imageArray = [NSArray arrayWithObjects:[ZFGlobleManager getGlobleManager].headImage, @"list_reord", @"list_coupon", @"list_password", @"icon_yufuka", @"icon_zhiwen",@"list_popularize", @"list_others", @"list_about", nil];
    } else {
        _dataArray = [NSArray arrayWithObjects:userStr, NSLocalizedString(@"交易记录", nil), NSLocalizedString(@"我的优惠券", nil), NSLocalizedString(@"密码管理", nil), NSLocalizedString(@"代币卡绑卡", nil), NSLocalizedString(@"推广有奖", nil), NSLocalizedString(@"多语言", nil), NSLocalizedString(@"关于SinoPay", nil), nil];
        _imageArray = [NSArray arrayWithObjects:[ZFGlobleManager getGlobleManager].headImage, @"list_reord", @"list_coupon", @"list_password", @"icon_yufuka",@"list_popularize", @"list_others", @"list_about", nil];
    }
    return _dataArray;
}


- (void)createView{
//    LAContext *context = [[LAContext alloc] init];
//    NSError *error = nil;
//    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error] && [SmallUtils supportTouchsDevicesAndSystem] == YES) {
//        _imageArray = [NSArray arrayWithObjects:[ZFGlobleManager getGlobleManager].headImage, @"list_reord", @"list_coupon", @"list_password", @"icon_yufuka", @"icon_zhiwen",@"list_popularize", @"list_others", @"list_about", nil];
//    } else {
//        _imageArray = [NSArray arrayWithObjects:[ZFGlobleManager getGlobleManager].headImage, @"list_reord", @"list_coupon", @"list_password", @"icon_yufuka",@"list_popularize", @"list_others", @"list_about", nil];
//    }

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = GrayBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    [self.view addSubview:_tableView];
    
    [self getUserInfo];
}

- (void)getUserInfo{
    NSDictionary *parameters = @{@"txnType": @"73",
                                 @"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID":[ZFGlobleManager getGlobleManager].sessionID
                                 };
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            NSData *decodedImageData  = [[NSData alloc] initWithBase64EncodedString:[requestResult objectForKey:@"image"] options:(NSDataBase64DecodingIgnoreUnknownCharacters)];
            UIImage *headImage = [UIImage imageWithData:decodedImageData];
            NSString *imageUrl = [requestResult objectForKey:@"image"];
            [[ZFGlobleManager getGlobleManager] saveHeadImageWithUrl:imageUrl];
            if (![[requestResult objectForKey:@"idNo"] isKindOfClass:[NSNull class]] && [requestResult objectForKey:@"idNo"]) {
                [[NSUserDefaults standardUserDefaults] setObject:[requestResult objectForKey:@"idNo"] forKey:UserIdCardNum];
            }
            if (![[requestResult objectForKey:@"userName"] isKindOfClass:[NSNull class]] && [requestResult objectForKey:@"userName"]) {
                [[NSUserDefaults standardUserDefaults] setObject:[requestResult objectForKey:@"userName"] forKey:UserName];
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ZFGlobleManager getGlobleManager].headImage = headImage;
                [_tableView reloadData];
            });
        } else {
            //[[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(NSError *error) {
        //[[MBUtils sharedInstance] dismissMB];
        
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [_tableView reloadData];
}

#pragma mark - tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 70;
    }
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0 || section == 1 || section == 6) {
        return 20;
    }
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
   
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 15, 20, 20)];
    if (indexPath.section == 0) {
        imageView.image = _imageArray[0];
    } else {
        imageView.image = [UIImage imageNamed:_imageArray[indexPath.section]];
    }
    
    if (indexPath.section == 0) {
        imageView.frame = CGRectMake(20, 11, 48, 48);
        imageView.layer.cornerRadius = imageView.width/2.0;
        imageView.clipsToBounds = YES;
        imageView.image = [ZFGlobleManager getGlobleManager].headImage;
    }
    [cell addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.right+15, 0, 210, 20)];
    label.centerY = imageView.centerY;
    label.text = self.dataArray[indexPath.section];
    label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
    [cell addSubview:label];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DLog(@"%zd", indexPath.section);
//    LAContext *context = [[LAContext alloc] init];
//    NSError *error = nil;
    //[context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error] &&
    if ([SmallUtils supportTouchsDevicesAndSystem] == YES) {
        switch (indexPath.section) {
            case 0://我的
            {
                ZFUserSetController *usVC = [[ZFUserSetController alloc] init];
                [self.navigationController pushViewController:usVC animated:YES];
            }
                break;
            case 1://交易记录
            {
                ZFTradeRecordController *tradeVC = [[ZFTradeRecordController alloc] init];
                [self.navigationController pushViewController:tradeVC animated:YES];
            }
                break;
            case 2://我的优惠券
            {
                ZFHeadScrollviewViewController *mcvc = [[ZFHeadScrollviewViewController alloc] initWithHeadType:ZFHeadScrollviewTypeMyCoupon];
                [self pushViewController:mcvc];
            }
                break;
            case 3://密码管理
            {
                ZFPwdManagerController *pwdMVC = [[ZFPwdManagerController alloc] init];
                [self.navigationController pushViewController:pwdMVC animated:YES];
            }
                break;
            case 4://认证预付卡
            {
                ZFMyBankCardViewController *mbcvc = [ZFMyBankCardViewController new];
                [self pushViewController:mbcvc];
//                [ZFGlobleManager getGlobleManager].applyType = @"1";
//                ZFPrepaidCardListViewController *prepaidListVC = [[ZFPrepaidCardListViewController alloc] init];
//                [self.navigationController pushViewController:prepaidListVC animated:YES];
            }
                break;
            case 5://指纹设置
            {
                ZFSetFingerprintViewController *vc = [[ZFSetFingerprintViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 6://推广有奖
            {
                ZFPromoteAwardController *paVC = [[ZFPromoteAwardController alloc] init];
                [self.navigationController pushViewController:paVC animated:YES];
            }
                break;
            case 7://多语言
            {
                ZFChangeLanguageController *chVC = [[ZFChangeLanguageController alloc] init];
                [self.navigationController pushViewController:chVC animated:YES];
            }
                break;
            case 8://关于SinoPay
            {
                ZFAboutController *aboutVC = [[ZFAboutController alloc] init];
                [self.navigationController pushViewController:aboutVC animated:YES];
            }
                break;
            default:
                break;
        }
    } else {
        switch (indexPath.section) {
            case 0://我的
            {
                ZFUserSetController *usVC = [[ZFUserSetController alloc] init];
                [self.navigationController pushViewController:usVC animated:YES];
            }
                break;
            case 1://交易记录
            {
                ZFTradeRecordController *tradeVC = [[ZFTradeRecordController alloc] init];
                [self.navigationController pushViewController:tradeVC animated:YES];
            }
                break;
            case 2://我的优惠券
            {
                ZFHeadScrollviewViewController *mcvc = [[ZFHeadScrollviewViewController alloc] initWithHeadType:ZFHeadScrollviewTypeMyCoupon];
                [self pushViewController:mcvc];
            }
                break;
            case 3://密码管理
            {
                ZFPwdManagerController *pwdMVC = [[ZFPwdManagerController alloc] init];
                [self.navigationController pushViewController:pwdMVC animated:YES];
            }
                break;
            case 4://认证预付卡
            {
                ZFMyBankCardViewController *mbcvc = [ZFMyBankCardViewController new];
                [self pushViewController:mbcvc];
                
//                [ZFGlobleManager getGlobleManager].applyType = @"1";
//                ZFPrepaidCardListViewController *prepaidListVC = [[ZFPrepaidCardListViewController alloc] init];
//                [self.navigationController pushViewController:prepaidListVC animated:YES];
            }
                break;
            case 5://推广有奖
            {
                ZFPromoteAwardController *paVC = [[ZFPromoteAwardController alloc] init];
                [self.navigationController pushViewController:paVC animated:YES];
            }
                break;
            case 6://多语言
            {
                ZFChangeLanguageController *chVC = [[ZFChangeLanguageController alloc] init];
                [self.navigationController pushViewController:chVC animated:YES];
            }
                break;
            case 7://关于SinoPay
            {
                ZFAboutController *aboutVC = [[ZFAboutController alloc] init];
                [self.navigationController pushViewController:aboutVC animated:YES];
            }
                break;
            default:
                break;
        }
    }
}

@end
