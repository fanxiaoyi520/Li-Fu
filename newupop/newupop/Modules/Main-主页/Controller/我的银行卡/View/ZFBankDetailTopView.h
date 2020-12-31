//
//  ZFBankDetailTopView.h
//  newupop
//
//  Created by 中付支付 on 2018/6/14.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFBankCardModel.h"

@interface ZFBankDetailTopView : UIView

/** 银行卡模型 **/
@property(nonatomic, strong) ZFBankCardModel *model;

@property (nonatomic, assign)BOOL isCanShowNum;

- (instancetype)initWithFrame:(CGRect)frame;

@end
