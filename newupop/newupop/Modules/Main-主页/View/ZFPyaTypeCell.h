//
//  ZFPyaTypeCell.h
//  newupop
//
//  Created by 中付支付 on 2017/9/4.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFPyaTypeCell : UITableViewCell

@property (nonatomic, strong)UIImageView *logoImageView;
@property (nonatomic, strong)UILabel *nameLabel;
@property (nonatomic, strong)UILabel *cityLabel;
@property (nonatomic, strong)UIImageView *selectImage;

///0 默认  1 不支持该地区  2 余额不足
@property (nonatomic, assign)NSInteger cellType;

@end
