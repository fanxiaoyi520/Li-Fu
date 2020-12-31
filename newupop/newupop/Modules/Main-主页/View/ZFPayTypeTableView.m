//
//  ZFPayTypeTableView.m
//  newupop
//
//  Created by 中付支付 on 2017/9/4.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFPayTypeTableView.h"
#import "ZFPyaTypeCell.h"

@implementation ZFPayTypeTableView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
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

- (void)setTipString:(NSString *)tipString{
    _tipString = tipString;
    _tipLabel.text = tipString;
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
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 45)];
    backView.backgroundColor = [UIColor whiteColor];
    
    // titleView
    UIView *headView = [[UIView alloc] init];
    headView.backgroundColor = [UIColor whiteColor];
    headView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 47);
    [backView addSubview:headView];
    
    // 关闭按钮
    UIImageView *closeImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 11, 20, 20)];
    closeImage.image = [UIImage imageNamed:@"hidden_icon"];
    [headView addSubview:closeImage];
    
    UIButton *closeBtn = [UIButton new];
    closeBtn.frame = CGRectMake(0, 0, 60, 45);
    [closeBtn addTarget:self action:@selector(hideView) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:closeBtn];
    
    // 选择优先付款方式
    UILabel *transferTypeL = [UILabel new];
    transferTypeL.frame = CGRectMake(60, 0, SCREEN_WIDTH-120, 45);
    transferTypeL.text = NSLocalizedString(@"选择付款方式", nil);
    transferTypeL.textColor = [UIColor blackColor];
    transferTypeL.font = [UIFont systemFontOfSize:18.0];
    transferTypeL.textAlignment = NSTextAlignmentCenter;
    [headView addSubview:transferTypeL];
    
    UIView *grayView = [[UIView alloc] initWithFrame:CGRectMake(0, headView.bottom, SCREEN_WIDTH, 2)];
    grayView.backgroundColor = UIColorFromRGB(0xF6F6F6);
    [backView addSubview:grayView];
//
//    _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 18, grayView.width-40, 15)];
//    _tipLabel.numberOfLines = 0;
//    _tipLabel.text = _tipString;
//    _tipLabel.font =  [UIFont fontWithName:@"Helvetica-Bold" size:15];
////    _tipLabel.textColor = UIColorFromRGB(0x313131);
//    [grayView addSubview:_tipLabel];
    
    return backView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_canAddCardType == 1) {
        return _dataArray.count;
    }
    return _dataArray.count+1;
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
    ZFPyaTypeCell *cell = [[ZFPyaTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row < _dataArray.count) {
        
        ZFBankCardModel *model = _dataArray[indexPath.row];
        if ([model.isSelect isEqualToString:@"1"]) {
            cell.selectImage.hidden = NO;
        }
        
        if (_showType == 1) {
            if (![model.openCountry.UP isEqualToString:@"0"]) {
                cell.cellType = 1;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        } else {
            if (![[ZFGlobleManager getGlobleManager] isSupportTheCity:[LocationUtils sharedInstance].ISOCountryCode cardModel:model]) {//不支持该地区
                cell.cellType = 1;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
        if ([model.underbalance isEqualToString:@"1"]) {
            cell.cellType = 2;
            cell.userInteractionEnabled = NO;
        }
        
        cell.logoImageView.image = [UIImage imageNamed:model.logoStr];
        NSString *cardNum = [model.cardNo substringFromIndex:model.cardNo.length-4];
        NSString *language = [NetworkEngine getCurrentLanguage];
        NSString *bankName = [language isEqualToString:@"2"]?model.bankName:model.bankNameLog;
        cell.nameLabel.text = [NSString stringWithFormat:@"%@(%@)", bankName, cardNum];
    }
    
    if (indexPath.row == _dataArray.count) {
        cell.logoImageView.image = [UIImage imageNamed:@"icon_add_card_image"];
        cell.nameLabel.text = NSLocalizedString(@"添加新的银行卡", nil);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < _dataArray.count) {
        //self.hidden = YES;
        [self dismiss];
        ZFBankCardModel *model = _dataArray[indexPath.row];
        if (_showType == 1) {
            if (![model.openCountry.UP isEqualToString:@"0"]) {
                [self.delegate verificationBankCard:model index:indexPath.row];
                return;
            }
        } else {
            if (![[ZFGlobleManager getGlobleManager] isSupportTheCity:[LocationUtils sharedInstance].ISOCountryCode cardModel:model]) {
                [self.delegate verificationBankCard:model index:indexPath.row];
                return;
            }
        }
        [self.delegate chooseCard:_dataArray[indexPath.row] index:indexPath.row];
    }
    if (indexPath.row == _dataArray.count) {
        [self dismiss];
        [self.delegate payTypeTableViewClickAdd];
    }
}

- (void)hideView{
    [self dismiss];
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
