//
//  ZFMyCouponCell.h
//  newupop
//
//  Created by Jellyfish on 2017/11/6.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFUplanModel.h"
#import "ZFMyCouponViewController.h"

@protocol ZFMyCouponCellDelegate <NSObject>

@optional
- (void)didClickuseBtn:(UIButton *)sender;

@end

@interface ZFMyCouponCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;

/** ZFMyCouponCellDelegate 代理 */
@property (nonatomic, weak) id <ZFMyCouponCellDelegate> delegate;

/** 计划模型 */
@property(nonatomic, strong) ZFUplanModel *uplanModel;
/** 使用类型 */
@property(nonatomic, assign) ZFCouponUseType useType;

@end
