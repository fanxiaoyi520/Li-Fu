//
//  ZFPopTableView.h
//  newupop
//
//  Created by Jellyfish on 2017/8/4.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFBankCardModel.h"
#import "ZFPwdInputView.h"

typedef NS_ENUM(NSInteger, PopTVType) {
    PopTVTypeMiMa = 0,     // 密码支付
    PopTVTypeCardList,     // 银行卡列表
    PopTVTypeIntegralOnly, // 只用积分
};

@protocol ZFPopTableViewDelegate <NSObject>

@optional

///输入密码
- (void)popTableViewInputPwd:(NSString *)pwString;
///更改付款银行卡
- (void)popTableViewChangePayType:(ZFBankCardModel *)cardModel;
///点击添加银行卡
- (void)popTableViewAddBankCard;

@end


@interface ZFPopTableView : UIView


/** 弹框类型 **/
@property(nonatomic, assign) PopTVType pType;

/** 标题 **/
@property(nonatomic, copy) NSString *title;

/** 金额信息 HKD 20.00 **/
@property(nonatomic, copy) NSString *amount;
/** 商户信息 向个人用户“张三”转账 **/
@property (nonatomic, copy)NSString *tipLabelString;

/** 银行卡模型数组 **/
@property(nonatomic, strong) NSArray<ZFBankCardModel *> *bcmArray;
///支付银行卡
@property (nonatomic, strong)ZFBankCardModel *cardModel;
///密码输入框
@property (nonatomic, strong)ZFPwdInputView *pwdView;

@property (nonatomic, weak)id<ZFPopTableViewDelegate>delegate;

/// 显示控件
- (void)showWithView:(UIView *)parentView;
/// 隐藏控件
- (void)dismiss;

@end
