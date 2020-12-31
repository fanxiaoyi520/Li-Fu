//
//  ZFPopTableView.m
//  newupop
//
//  Created by Jellyfish on 2017/8/4.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFPopTableView.h"


// 视图宽度
#define XLPTVWIDTH SCREEN_WIDTH*0.8
// 视图高度
#define XLPTVHEIGHT 256

@interface ZFPopTableView() <UITableViewDataSource, UITableViewDelegate, InputPwdDelegate>

/** 容器 */
@property (nonatomic, weak) UIView *contentView;
/** title视图 **/
@property(nonatomic, weak) UIView *headView;
/** tableView */
@property (nonatomic, weak) UITableView *tableView;
/** 交易方式 */
@property (nonatomic, weak) UILabel *transferTypeL;

///
@property (nonatomic, weak) UIImageView *closeImage;
///
@property (nonatomic, weak) UIButton *closeBtn;

@end


@implementation ZFPopTableView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:[UIScreen mainScreen].bounds]) {
        [self setupSubviews];
    }
    return self;
}


#pragma mark -- 初始化子控件
- (void)setupSubviews {
    // 遮罩
    UIView *darkView = [[UIView alloc] init];
    darkView.alpha = 0.5;
    darkView.backgroundColor = ZFColor(46, 49, 50);
    darkView.frame = self.bounds;
    [self addSubview:darkView];
    
    // 容器
    UIView *contentView = [[UIView alloc] init];
    contentView.layer.cornerRadius = 8.0f;
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.frame = CGRectMake((SCREEN_WIDTH-XLPTVWIDTH)/2, 106, XLPTVWIDTH, XLPTVHEIGHT);
    [self addSubview:contentView];
    self.contentView = contentView;
    
    // titleView
    UIView *headView = [[UIView alloc] init];
    headView.backgroundColor = [UIColor clearColor];
    headView.frame = CGRectMake(0, 0, XLPTVWIDTH, 44);
    [contentView addSubview:headView];
    self.headView = headView;
    
    // 关闭按钮
//    UIImageView *closeImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 11, 20, 20)];
//    closeImage.image = [UIImage imageNamed:@"delete_btn"];
//    [headView addSubview:closeImage];
//    self.closeImage = closeImage;
    
    UIButton *closeBtn = [UIButton new];
    closeBtn.frame = CGRectMake(0, 0, 60, 44);
    [closeBtn setImage:[UIImage imageNamed:@"delete_btn"] forState:UIControlStateNormal];
    [closeBtn setImage:[UIImage imageNamed:@"delete_btn"] forState:UIControlStateHighlighted];
    [closeBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:closeBtn];
    self.closeBtn = closeBtn;
    
    // 交易方式
    UILabel *transferTypeL = [UILabel new];
    transferTypeL.frame = CGRectMake(XLPTVWIDTH*0.2, 0, XLPTVWIDTH*0.6, 44);
    transferTypeL.text = NSLocalizedString(@"支付密码", nil);
    transferTypeL.textColor = [UIColor blackColor];
    transferTypeL.font = [UIFont boldSystemFontOfSize:18.0];
    transferTypeL.textAlignment = NSTextAlignmentCenter;
    transferTypeL.adjustsFontSizeToFitWidth = YES;
    [headView addSubview:transferTypeL];
    self.transferTypeL = transferTypeL;
    
    // 分割线
    UIView *spliteView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, XLPTVWIDTH, 2.0)];
    spliteView.backgroundColor = UIColorFromRGB(0x979797);//4990E2
    spliteView.alpha = 0.2;
    [contentView addSubview:spliteView];
    
    [self setupCustomView];
}

/// 弹框类型的区别
- (void)setupCustomView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.tableFooterView = [UIView new];
    tableView.layer.cornerRadius = 8;
    [self.contentView addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(46, 0, 0, 0));
    }];
    self.tableView = tableView;
}

- (void)setPType:(PopTVType)pType {
    _pType = pType;
    
    // 设置是否可以滑动
    if (self.pType == PopTVTypeCardList) {
        if (_bcmArray.count > 5) {
            self.tableView.scrollEnabled = YES;
        }
    } else if (self.pType == PopTVTypeIntegralOnly){
        self.contentView.frame = CGRectMake((SCREEN_WIDTH-XLPTVWIDTH)/2, 106, XLPTVWIDTH, XLPTVHEIGHT-50);
        self.tableView.scrollEnabled = NO;
        [_tableView reloadData];
    } else {
        self.tableView.scrollEnabled = NO;
    }
}

// 设置标题
- (void)setTitle:(NSString *)title {
    self.transferTypeL.text = title;
}

- (void)setAmount:(NSString *)amount {
    _amount = amount;
    [self.tableView reloadData];
}

- (void)setTipLabelString:(NSString *)tipLabelString{
    _tipLabelString = tipLabelString;
    [self.tableView reloadData];
}

- (void)setBcmArray:(NSArray<ZFBankCardModel *> *)bcmArray {
    _bcmArray = bcmArray;
    [_tableView reloadData];
}

- (void)setCardModel:(ZFBankCardModel *)cardModel{
    _cardModel = cardModel;
}

#pragma mark -- UITableViewDataSourece
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.pType == PopTVTypeMiMa) {
        return 3;
    } else if (self.pType == PopTVTypeIntegralOnly) {
        return 2;
    } else {
        return self.bcmArray.count+1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"MYCELL";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (self.pType == PopTVTypeCardList) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (indexPath.row == self.bcmArray.count) { // 固定 最后一行
            cell.textLabel.text = NSLocalizedString(@"添加新的银行卡", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            ZFBankCardModel *cardModel = _bcmArray[indexPath.row];
            NSString *cardNum = [cardModel.cardNo substringFromIndex:cardModel.cardNo.length-4];
            cell.imageView.image = [UIImage imageNamed:self.bcmArray[indexPath.row].logoStr];
            
            if ([cardModel.underbalance isEqualToString:@"1"]) {
                cell.userInteractionEnabled = NO;
                UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 6, cell.width-cell.textLabel.x-26, 17)];
                nameLabel.text = [NSString stringWithFormat:@"%@(%@)", cardModel.bankName, cardNum];
                nameLabel.font = cell.textLabel.font;
                nameLabel.alpha = 0.3;
                nameLabel.adjustsFontSizeToFitWidth = YES;
                [cell addSubview:nameLabel];
                
                UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.x, nameLabel.bottom+6, nameLabel.width, 15)];
                tipLabel.text = NSLocalizedString(@"余额不足", nil);
                tipLabel.font = [UIFont systemFontOfSize:14];
                tipLabel.alpha = 0.3;
                [cell addSubview:tipLabel];
                
                return cell;
            }
            cell.textLabel.text = [NSString stringWithFormat:@"%@(%@)", cardModel.bankName, cardNum];
            cell.textLabel.x = 54;
            cell.textLabel.alpha = 0.8;
        }
    } else { //密码
        if (indexPath.row == 0) {
            UILabel *topLabel = [UILabel new];
            topLabel.text = _tipLabelString;
            topLabel.textColor = [UIColor blackColor];
            topLabel.textAlignment = NSTextAlignmentCenter;
            topLabel.font = [UIFont systemFontOfSize:16.0];
            topLabel.frame = CGRectMake(0, 15, XLPTVWIDTH, 17);
            topLabel.adjustsFontSizeToFitWidth = YES;
            [cell addSubview:topLabel];
            
            UILabel *bottomLabel = [UILabel new];
            bottomLabel.text = _amount;
            bottomLabel.textColor = [UIColor blackColor];
            bottomLabel.textAlignment = NSTextAlignmentCenter;
            bottomLabel.font = [UIFont boldSystemFontOfSize:30.0];
            if (_pType == PopTVTypeIntegralOnly) {
                bottomLabel.font = [UIFont boldSystemFontOfSize:18];
                bottomLabel.adjustsFontSizeToFitWidth = YES;
            }
            bottomLabel.frame = CGRectMake(0, topLabel.bottom+12, XLPTVWIDTH, 30);
            [cell addSubview:bottomLabel];
        } else {
            if (self.pType == PopTVTypeIntegralOnly){
                // 密码框
                _pwdView = [[ZFPwdInputView alloc] initWithFrame:CGRectMake(20, 15, XLPTVWIDTH-40, 40)];
                _pwdView.delegate = self;
                [cell addSubview:_pwdView];
            } else {
                if (indexPath.row == 1) {
                    if (_cardModel) {
                        NSString *cardNum = [_cardModel.cardNo substringFromIndex:_cardModel.cardNo.length-4];
                        cell.imageView.image = [UIImage imageNamed:_cardModel.logoStr];
                        cell.textLabel.text = [NSString stringWithFormat:@"%@(%@)", _cardModel.bankName, cardNum];
                    }
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.textLabel.alpha = 0.8;
                } else {
                    // 密码框
                    _pwdView = [[ZFPwdInputView alloc] initWithFrame:CGRectMake(20, 15, XLPTVWIDTH-40, 40)];
                    _pwdView.delegate = self;
                    [cell addSubview:_pwdView];
                }
            }
        }
    }
    
    return cell;
}

#pragma mark inputPwdDelegate
- (void)inputString:(NSString *)password{
    DLog(@"--%@", password);
    [self.delegate popTableViewInputPwd:password];
}

#pragma mark -- UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
 
    if (self.pType == PopTVTypeMiMa) {
        if (indexPath.row == 1) {
            self.pType = PopTVTypeCardList;
            self.transferTypeL.text = NSLocalizedString(@"选择支付银行卡", nil);
            [_closeBtn setImage:[UIImage imageNamed:@"popview_back_icon"] forState:UIControlStateNormal];
            [_closeBtn setImage:[UIImage imageNamed:@"popview_back_icon"] forState:UIControlStateHighlighted];
            [self.closeBtn removeTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
            [self.closeBtn addTarget:self action:@selector(popBack) forControlEvents:UIControlEventTouchUpInside];
            CGFloat height = 46+(_bcmArray.count+1)*50;
            if (height+_contentView.y > SCREEN_HEIGHT-50) {
                height = SCREEN_HEIGHT-50-_contentView.y;
            }
            [UIView animateWithDuration:0.5 animations:^{
                _contentView.size = CGSizeMake(XLPTVWIDTH, height);
            }];
            [self.tableView reloadData];
        }
    } else if (self.pType == PopTVTypeIntegralOnly) {
        return;
    } else {
        if (indexPath.row < _bcmArray.count) {
            [self.delegate popTableViewChangePayType:_bcmArray[indexPath.row]];
            _cardModel = _bcmArray[indexPath.row];
            [self popBack];
        } else {
            [self.delegate popTableViewAddBankCard];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_pType == PopTVTypeMiMa) {
        if (indexPath.row == 0) {
            return 90;
        }
        if (indexPath.row == 2) {
            return 72;
        }
    }
    if (_pType == PopTVTypeIntegralOnly) {
        if (indexPath.row == 0) {
            return 90;
        }
        if (indexPath.row == 1) {
            return 72;
        }
    }
    
    return 50;
}

// 设置分割线偏移
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPat{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}

#pragma mark 返回到输入密码
- (void)popBack{
    _pType = PopTVTypeMiMa;
    self.transferTypeL.text = NSLocalizedString(@"支付密码", nil);
    [_closeBtn setImage:[UIImage imageNamed:@"delete_btn"] forState:UIControlStateNormal];
    [_closeBtn setImage:[UIImage imageNamed:@"delete_btn"] forState:UIControlStateHighlighted];
    [self.closeBtn removeTarget:self action:@selector(popBack) forControlEvents:UIControlEventTouchUpInside];
    [self.closeBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    
    [UIView animateWithDuration:0.5 animations:^{
        _contentView.size = CGSizeMake(XLPTVWIDTH, XLPTVHEIGHT);
        _tableView.contentOffset = CGPointMake(0, 0);
    }];
    
    [_tableView reloadData];
}

#pragma mark -- 展示方法
- (void)showWithView:(UIView *)parentView {
    
    self.contentView.alpha = 0;
    [parentView addSubview:self];
    
    self.contentView.transform = CGAffineTransformMakeScale(0, 0);
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:1.0
          initialSpringVelocity:1
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.contentView.alpha = 1.0f;
                         self.contentView.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished) {
                         [self.pwdView.textField becomeFirstResponder];
                     }];
}

- (void)dismiss {
    
    for (ZFBankCardModel *model in _bcmArray) {
        model.underbalance = nil;
    }
    [self.pwdView.textField resignFirstResponder];
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.contentView.alpha = 0.0;
                         self.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}


@end
