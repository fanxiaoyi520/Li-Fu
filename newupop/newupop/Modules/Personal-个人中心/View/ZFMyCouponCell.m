//
//  ZFMyCouponCell.m
//  newupop
//
//  Created by Jellyfish on 2017/11/6.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFMyCouponCell.h"
#import "UIImageView+WebCache.h"

@interface ZFMyCouponCell()
///背景图片
@property (nonatomic, strong)UIImageView *bgImageView;
///图片
@property (nonatomic, strong)UIImageView *picImageView;
///名称
@property (nonatomic, strong)UILabel *nameLabel;
///内容
@property (nonatomic, strong)UILabel *contentLabel;
///立即使用
@property (nonatomic, strong)UIButton *useBtn;


@end

@implementation ZFMyCouponCell


+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *ID = @"ZFMyCouponCell";
    ZFMyCouponCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[ZFMyCouponCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        [self createView];
    }
    return self;
}

- (void)createView {
   _bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-20, 90)];
    _bgImageView.userInteractionEnabled = YES;
    [self addSubview:_bgImageView];
    
    _picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, SCREEN_WIDTH*0.18, 50)];
    [self addSubview:_picImageView];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_picImageView.right+20, _picImageView.y, 150, 12)];
    _nameLabel.font = [UIFont systemFontOfSize:13];
    _nameLabel.textColor = ZFColor(83, 83, 83);
    [self addSubview:_nameLabel];
    
    _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(_picImageView.right+20, _nameLabel.bottom+15, 0.52*SCREEN_WIDTH, 35)];
    _contentLabel.numberOfLines = 0;
    _contentLabel.font = [UIFont boldSystemFontOfSize:12];
    _contentLabel.textColor = [UIColor blackColor];
    [self addSubview:_contentLabel];
    
//    _useBtn = [[UIButton alloc] initWithFrame:CGRectMake(_contentLabel.right, _picImageView.y, SCREEN_WIDTH-_contentLabel.right-SCREEN_WIDTH*0.028, _picImageView.height)];
    _useBtn = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-20)*0.9, _picImageView.y, (SCREEN_WIDTH-20)*0.08, _picImageView.height)];
    _useBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    _useBtn.titleLabel.numberOfLines = 0;
    [_useBtn setTitle:NSLocalizedString(@"立\n即\n使\n用", nil) forState:UIControlStateNormal];
    [_useBtn setTitleColor:MainThemeColor forState:UIControlStateNormal];
    [_useBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [_useBtn setTitleColor:ZFColor(206, 206, 206) forState:UIControlStateDisabled];
    [_useBtn addTarget:self action:@selector(didClickuseBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_useBtn];
}

- (void)setUplanModel:(ZFUplanModel *)uplanModel{
    if (self.useType == ZFCouponUseTypeNotUse) {
        _bgImageView.image = [UIImage imageNamed:@"pic_coupon"];

        _useBtn.enabled = YES;
        [_useBtn setTitle:NSLocalizedString(@"立\n即\n使\n用", nil) forState:UIControlStateNormal];
    } else if (self.useType == ZFCouponUseTypeUsed)
    {
        _bgImageView.image = [UIImage imageNamed:@"pic_coupon_useless"];
        _contentLabel.textColor = ZFColor(206, 206, 206);
        _nameLabel.textColor = ZFColor(206, 206, 206);
        _useBtn.enabled = NO;
        [_useBtn setTitle:NSLocalizedString(@"已\n使\n用", nil) forState:UIControlStateNormal];
    } else
    {
        _bgImageView.image = [UIImage imageNamed:@"pic_coupon_useless"];
        _contentLabel.textColor = ZFColor(206, 206, 206);
        _nameLabel.textColor = ZFColor(206, 206, 206);
        _useBtn.enabled = NO;
        _useBtn.titleLabel.font = [UIFont systemFontOfSize:11];
        [_useBtn setTitle:NSLocalizedString(@"已\n过\n期", nil) forState:UIControlStateNormal];
    }
        
    [_picImageView sd_setImageWithURL:[NSURL URLWithString:uplanModel.iconUrl] placeholderImage:[UIImage imageNamed:@"pic_youjihua_default"]];
    _nameLabel.text = uplanModel.merchantName;
    _contentLabel.text = uplanModel.activityIntroduction;
}

#pragma mark -- 点击方法
- (void)didClickuseBtn:(UIButton *)sender
{
    [self.delegate didClickuseBtn:sender];
}


@end

