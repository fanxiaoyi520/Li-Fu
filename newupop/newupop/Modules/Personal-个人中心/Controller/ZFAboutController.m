//
//  ZFAboutController.m
//  newupop
//
//  Created by 中付支付 on 2017/7/24.
//  Copyright © 2017年 中付支付. All rights reserved.
//

//@"1243270659"
#define APPID @"1286958200"

#import "ZFAboutController.h"
#import "ZFAboutDetailController.h"

@interface ZFAboutController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSArray *dataArray;
@property (nonatomic, strong)NSDictionary *telDict;

@end

@implementation ZFAboutController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myTitle = @"关于SinoPay";
    
    [self createView];
}

- (void)createView{
    _dataArray = [NSArray arrayWithObjects:NSLocalizedString(@"关于我们", nil), NSLocalizedString(@"给我们评分", nil), NSLocalizedString(@"中国客服热线", nil), NSLocalizedString(@"新加坡客服热线", nil), NSLocalizedString(@"香港客服热线", nil), NSLocalizedString(@"澳门客服热线", nil), nil];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = GrayBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    [self.view addSubview:_tableView];
    
    [self getTelNum];
}

- (void)getTelNum{
    _telDict = [[NSDictionary alloc] init];
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                                 @"txnType": @"71"};
    
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            _telDict = requestResult;
            [_tableView reloadData];
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

#pragma mark - tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    if (section == 0) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        imageView.center = CGPointMake(SCREEN_WIDTH/2, 80);
        imageView.image = [UIImage imageNamed:@"other_logo"];
        [view addSubview:imageView];
        
        UILabel *verLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageView.x, imageView.bottom+5, imageView.width, 20)];
        verLabel.text = [NSString stringWithFormat:@"V %@", [[ZFGlobleManager getGlobleManager] getCurrentVersion]];
        verLabel.textColor = [UIColor grayColor];
        verLabel.textAlignment = NSTextAlignmentCenter;
        [view addSubview:verLabel];
    }
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 180;
    }
    if (section == 1) {
        return 20;
    }
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH-220, 44)];
    titleLabel.text = _dataArray[indexPath.section];
    titleLabel.font = [UIFont systemFontOfSize:15];
    [cell addSubview:titleLabel];
    if (indexPath.section == 0 || indexPath.section == 1) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, cell.height)];
        phoneLabel.center = CGPointMake(SCREEN_WIDTH-130, cell.center.y);
        phoneLabel.textAlignment = NSTextAlignmentRight;
        phoneLabel.textColor = [UIColor grayColor];
        [cell addSubview:phoneLabel];
        NSString *phoneNum = @"-";
        if (indexPath.section == 2) {
            phoneNum = [_telDict objectForKey:@"CNHotline"];
        }
        if (indexPath.section == 3) {
            phoneNum = [_telDict objectForKey:@"SGHotline"];
        }
        if (indexPath.section == 4) {
            phoneNum = [_telDict objectForKey:@"HKHtline"];
        }
        if (indexPath.section == 5) {
            phoneNum = [_telDict objectForKey:@"MACHotline"];
        }
        
        if (![phoneNum isKindOfClass:[NSNull class]] && [phoneNum length] > 1) {
            phoneLabel.text = phoneNum;
        } else {
            phoneLabel.text = @"-";
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DLog(@"%zd", indexPath.section);
    switch (indexPath.section) {
        case 0:
        {
            ZFAboutDetailController *abVC = [[ZFAboutDetailController alloc] init];
            [self.navigationController pushViewController:abVC animated:YES];
        }
            break;
        case 1:
        {
            NSString *urlStr = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@&pageNumber=0&sortOrdering=2&mt=8", APPID];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
        }
            break;
        case 2:
        {
            NSString  *num = [_telDict objectForKey:@"CNHotline"];
            if (![num isKindOfClass:[NSNull class]] && num.length > 1) {
                num = [num stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSString *phoneNum = [[NSString alloc] initWithFormat:@"telprompt://%@", num];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNum]]; //拨号
            }
        }
            break;
        case 3:
        {
            NSString  *num = [_telDict objectForKey:@"SGHotline"];
            if (![num isKindOfClass:[NSNull class]] && num.length > 1) {
                num = [num stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSString *phoneNum = [NSString stringWithFormat:@"telprompt://%@", num];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNum]]; //拨号
            }
        }
            break;
        case 4:
        {
            NSString  *num = [_telDict objectForKey:@"HKHtline"];
            if (![num isKindOfClass:[NSNull class]] && num.length > 1) {
                num = [num stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSString *phoneNum = [[NSString alloc] initWithFormat:@"telprompt://%@", num];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNum]]; //拨号
            }
        }
            break;
        case 5:
        {
            NSString  *num = [_telDict objectForKey:@"MACHotline"];
            if (![num isKindOfClass:[NSNull class]] && num.length > 1) {
                num = [num stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSString *phoneNum = [[NSString alloc] initWithFormat:@"telprompt://%@", num];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNum]]; //拨号
            }
//            NSString *num = [[NSString alloc] initWithFormat:@"telprompt://%@", [_telDict objectForKey:@"MACHotline"]];
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]]; //拨号
        }
            break;
        
        default:
            break;
    }
}


@end
