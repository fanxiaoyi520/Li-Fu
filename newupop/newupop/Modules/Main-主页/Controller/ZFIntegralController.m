//
//  ZFIntegralController.m
//  newupop
//
//  Created by 中付支付 on 2017/11/3.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFIntegralController.h"
#import "ZFIntegtalTableViewCell.h"

@interface ZFIntegralController ()<UITableViewDelegate, UITableViewDataSource>

///积分
@property (nonatomic, strong)UILabel *integralLabel;
///列表数组
@property (nonatomic, strong)NSMutableArray *dataArray;
///列表
@property (nonatomic, strong)UITableView *tableView;

@end

@implementation ZFIntegralController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.myTitle = @"我的积分";
    [self createView];
}

- (void)createView{
    //顶部图片
    UIImageView *topImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic_integral"]];
    
    topImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT == 812.0 ? SCREEN_HEIGHT*0.38 : SCREEN_HEIGHT*0.45);
    [self.view addSubview:topImageView];
    
    [self createTopView];
    
    //积分
    _integralLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, topImageView.height-64)];
//    _integralLabel.backgroundColor = [UIColor cyanColor];
    _integralLabel.text = @"--";
    _integralLabel.font = [UIFont boldSystemFontOfSize:28];
    _integralLabel.textColor = [UIColor blackColor];
    _integralLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_integralLabel];
    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(_integralLabel.x, _integralLabel.bottom+8, _integralLabel.width, 18)];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.font = [UIFont systemFontOfSize:18];
//    label.text = NSLocalizedString(@"积分", nil);
//    label.textColor = UIColorFromRGB(0x5eb1e3);
//    [self.view addSubview:label];
    
    //tableView
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, topImageView.height, SCREEN_WIDTH, SCREEN_HEIGHT-topImageView.height) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    _dataArray = [[NSMutableArray alloc] init];
    [self checkJiFen];
}

- (void)createTopView{
    //标题
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, IPhoneXStatusBarHeight, SCREEN_WIDTH, 44)];
    title.text = NSLocalizedString(@"我的积分", nil);
    title.backgroundColor = [UIColor clearColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont boldSystemFontOfSize:18.0];
    [self.view addSubview:title];
    
    // 返回按钮
    UIImageView *backImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 33+IPhoneXStatusBarHeightInterval, 12, 20)];
    backImage.image = [UIImage imageNamed:@"nave_back"];
    [self.view addSubview:backImage];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, IPhoneXStatusBarHeight, 80, 44);
    [backBtn setTitle:@"" forState:UIControlStateNormal];
    [backBtn setTitleColor:MainFontColor forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
}

- (void)popViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 查询积分
- (void)checkJiFen{
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    
    NSDictionary * paramSign = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"isCredit": @"0",
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"txnType": @"46"};
    [NetworkEngine singlePostWithParmas:paramSign success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        NSDictionary *resultDic = (NSDictionary *)requestResult;
        if([[resultDic objectForKey:@"status"] isEqualToString:@"0"]){
            NSString *jifen = [resultDic objectForKey:@"totalCredit"];
            _integralLabel.text = [jifen isKindOfClass:[NSNull class]] ? @"0":jifen;
            NSArray *listArr = [resultDic objectForKey:@"list"];

            if (![listArr isKindOfClass:[NSNull class]]) {

                [self dealWithList:listArr];
            }

        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

- (void)dealWithList:(NSArray *)list{
    for (NSDictionary *dict in list) {
        IntegralModel *model = [[IntegralModel alloc] init];
        model.useCredit = [dict objectForKey:@"useCredit"];
        model.recCreateTm = [dict objectForKey:@"recCreateTm"];
        [_dataArray addObject:model];
    }
    [_tableView reloadData];
}

#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    headView.backgroundColor = [UIColor whiteColor];
    
    UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(20, 16, 6, 18)];
    colorView.backgroundColor = UIColorFromRGB(0x4990E2);
    [headView addSubview:colorView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(colorView.right+10, 18, 150, 20)];
    titleLabel.centerY = colorView.centerY;
    titleLabel.font = [UIFont boldSystemFontOfSize:15];
    titleLabel.text = NSLocalizedString(@"使用记录", nil);
//    titleLabel.textColor = UIColorFromRGB(0x2d90ce);
    [headView addSubview:titleLabel];
    
    return headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"integralCell";
    ZFIntegtalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[ZFIntegtalTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if (indexPath.row < _dataArray.count) {
        cell.integralModel = _dataArray[indexPath.row];
    }
    return cell;
}

@end
