//
//  ZFPyaTypeCell.m
//  newupop
//
//  Created by 中付支付 on 2017/9/4.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFPyaTypeCell.h"

@implementation ZFPyaTypeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createView];
    }
    return self;
}

- (void)createView{
    _logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, 20, 20)];
    _logoImageView.centerY = self.height/2;
    [self.contentView addSubview:_logoImageView];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_logoImageView.right+10, _logoImageView.y, 150, 20)];
    _nameLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_nameLabel];
    
    _cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-180, _logoImageView.y, 130, 20)];
    _cityLabel.textAlignment = NSTextAlignmentRight;
    _cityLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_cityLabel];
    
    _selectImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-40, _logoImageView.y, 20, 20)];
    _selectImage.image = [UIImage imageNamed:@"select_card"];
    _selectImage.hidden = YES;
    [self.contentView addSubview:_selectImage];
}

- (void)layoutSubviews{
    [super layoutSubviews];

    _logoImageView.centerY = self.height/2;
    _nameLabel.centerY = _logoImageView.centerY;
    _selectImage.centerY = _logoImageView.centerY;
    
    if (_cellType == 1) {
        _nameLabel.centerY = 20;
        _nameLabel.alpha = 0.3;
        _cityLabel.frame = CGRectMake(_logoImageView.right+10, _nameLabel.bottom+5, 220, 15);
        _cityLabel.textAlignment = NSTextAlignmentLeft;
        _cityLabel.font = [UIFont systemFontOfSize:12];
        _cityLabel.text = NSLocalizedString(@"点击开通认证，提升消费安全性", nil);
        _cityLabel.textColor = UIColorFromRGB(0xE24A4A);
        _selectImage.hidden = YES;
    }
    if (_cellType == 2) {
        _nameLabel.alpha = 0.3;
        _cityLabel.text = NSLocalizedString(@"余额不足", nil);
        _cityLabel.alpha = 0.3;
    }
}


@end
