//
//  ZFBankCardCell.h
//  newupop
//
//  Created by Jellyfish on 2017/7/25.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFBankCardModel.h"

@interface ZFBankCardCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;

/** 银行卡模型 **/
@property(nonatomic, strong) ZFBankCardModel *model;

/** 卡号 */
@property (nonatomic, weak) UILabel *cardNoLabel;
/** 余额 */
@property (nonatomic, weak) UILabel *balanceLabel;

@property (nonatomic, assign)BOOL isCanShowNum;

@property(nonatomic, copy)void(^showNumBlock)(BOOL isSelect, NSString *cardNum, NSString *cardName);

@end
