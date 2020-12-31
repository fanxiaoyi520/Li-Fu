//
//  ZFPayTypeTableView.h
//  newupop
//
//  Created by 中付支付 on 2017/9/4.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFBankCardModel.h"

@protocol ZFPayTypeTableDelegate <NSObject>

- (void)chooseCard:(ZFBankCardModel *)cardModel index:(NSInteger)index;
- (void)payTypeTableViewClickAdd;
@optional
///认证银行卡
- (void)verificationBankCard:(ZFBankCardModel *)cardModel index:(NSInteger)index;

@end


@interface ZFPayTypeTableView : UIView<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSMutableArray *dataArray;
///1 银联卡  2 upop卡
@property (nonatomic, assign)NSInteger showType;
///是否可以添加银行卡 0 可添加(默认)  1 不可添加
@property (nonatomic, assign)NSInteger canAddCardType;
///提示文字
@property (nonatomic, strong)NSString *tipString;
///提示标签
@property (nonatomic, strong)UILabel *tipLabel;

@property (nonatomic, assign)CGFloat tableHeight;

@property (nonatomic, weak)id<ZFPayTypeTableDelegate>delegate;

- (void)show;
- (void)dismiss;
@end
