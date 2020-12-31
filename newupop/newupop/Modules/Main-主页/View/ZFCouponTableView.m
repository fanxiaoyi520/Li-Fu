//
//  ZFCouponTableView.m
//  newupop
//
//  Created by 中付支付 on 2017/12/25.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFCouponTableView.h"

@implementation ZFCouponTableView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        _selectIndex = 0;
        [self createTableView];
        self.hidden = YES;
    }
    return self;
}

- (void)createTableView{
    // 遮罩
    UIView *darkView = [[UIView alloc] init];
    darkView.alpha = 0.5;
    darkView.backgroundColor = ZFColor(46, 49, 50);
    //    darkView.backgroundColor = [UIColor clearColor];
    darkView.frame = [UIScreen mainScreen].bounds;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [darkView addGestureRecognizer:tap];
    
    [self addSubview:darkView];
    
    _tableView = [[UITableView alloc] initWithFrame:self.frame style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self addSubview:_tableView];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.alpha = 1;
    _tableView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, _tableHeight);
}

- (void)setDataArray:(NSMutableArray *)dataArray{
    NSInteger count = 0;
    if (dataArray.count > 5) {
        count = 6;
    } else if (dataArray.count < 2){
        count = 2;
    } else {
        count = dataArray.count + 1;
    }
    _tableHeight = 45+50+60*count;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _tableView.frame = CGRectMake(0, SCREEN_HEIGHT-_tableHeight, SCREEN_WIDTH, _tableHeight);
    });
    
    _dataArray = dataArray;
    [_tableView reloadData];
}

- (UIView *)getHeadView{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 47)];
    backView.backgroundColor = [UIColor whiteColor];
    
    // titleView
    UIView *headView = [[UIView alloc] init];
    headView.backgroundColor = [UIColor whiteColor];
    headView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 45);
    [backView addSubview:headView];
    
    // 关闭按钮
    UIButton *closeBtn = [UIButton new];
    closeBtn.frame = CGRectMake(0, 0, 60, 45);
    [closeBtn setImage:[UIImage imageNamed:@"hidden_icon"] forState:UIControlStateNormal];
    [closeBtn setImage:[UIImage imageNamed:@"hidden_icon"] forState:UIControlStateHighlighted];
    [closeBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:closeBtn];
    
    // 选择优先付款方式
    UILabel *transferTypeL = [UILabel new];
    transferTypeL.frame = CGRectMake(60, 0, SCREEN_WIDTH-120, 45);
    transferTypeL.text = NSLocalizedString(@"选择优惠", nil);
    transferTypeL.textColor = [UIColor blackColor];
    transferTypeL.font = [UIFont systemFontOfSize:18.0];
    transferTypeL.textAlignment = NSTextAlignmentCenter;
    [headView addSubview:transferTypeL];
    
    UIView *grayView = [[UIView alloc] initWithFrame:CGRectMake(0, headView.bottom, SCREEN_WIDTH, 2)];
    grayView.backgroundColor = UIColorFromRGB(0xF6F6F6);
    [backView addSubview:grayView];
    
    return backView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 47;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [self getHeadView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"paytypecell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row < _dataArray.count) {
        ZFCouponModel *model = _dataArray[indexPath.row];
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, SCREEN_WIDTH-70, 40)];
        tipLabel.font = [UIFont systemFontOfSize:14];
        tipLabel.alpha = 0.8;
        tipLabel.numberOfLines = 0;
        tipLabel.text = model.activityIntroduction;
        [cell addSubview:tipLabel];
        
        if (indexPath.row == _selectIndex) {
            UIImageView *selectImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-40, 20, 20, 20)];
            selectImage.image = [UIImage imageNamed:@"select_card"];
            [cell addSubview:selectImage];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < _dataArray.count) {
        [self dismiss];
        _selectIndex = indexPath.row;
        [_tableView reloadData];
        [self.delegate chooseCoupon:_dataArray[indexPath.row] index:indexPath.row];
    }
}

- (void)show{
    self.tableView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, _tableHeight);
    self.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.tableView.frame = CGRectMake(0, SCREEN_HEIGHT-_tableHeight, SCREEN_WIDTH, _tableHeight);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismiss{
    [UIView animateWithDuration:0.5 animations:^{
        self.tableView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, _tableHeight);
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

@end
