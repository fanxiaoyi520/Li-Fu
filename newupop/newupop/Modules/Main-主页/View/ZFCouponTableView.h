//
//  ZFCouponTableView.h
//  newupop
//
//  Created by 中付支付 on 2017/12/25.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCouponModel.h"

@protocol ZFCouponTableDelegate <NSObject>

- (void)chooseCoupon:(ZFCouponModel *)couponModel index:(NSInteger)index;

@end

@interface ZFCouponTableView : UIView<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSMutableArray *dataArray;

@property (nonatomic, assign)CGFloat tableHeight;
///选中标识
@property (nonatomic, assign)NSInteger selectIndex;

@property (nonatomic, weak)id<ZFCouponTableDelegate>delegate;

- (void)show;
- (void)dismiss;

@end
