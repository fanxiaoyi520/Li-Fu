//
//  ZFUPlanTableViewCell.m
//  newupop
//
//  Created by 中付支付 on 2017/11/3.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFUPlanTableViewCell.h"
#import "DateUtils.h"
#import "UIImageView+WebCache.h"

@interface ZFUPlanTableViewCell()
///图片
@property (nonatomic, strong)UIImageView *picImageView;
///名称
@property (nonatomic, strong)UILabel *nameLabel;
///内容
@property (nonatomic, strong)UILabel *contentLabel;
///时间
@property (nonatomic, strong)UILabel *timeLabel;

@end

@implementation ZFUPlanTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createView];
    }
    return self;
}

- (void)createView {
    _picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 15, 100, 60)];
    _picImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:_picImageView];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_picImageView.right+20, _picImageView.y, 120, 12)];
    _nameLabel.font = [UIFont systemFontOfSize:13];
    _nameLabel.textColor = ZFColor(83, 83, 83);
    [self addSubview:_nameLabel];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-85, _picImageView.y, 65, 12)];
    _timeLabel.textAlignment = NSTextAlignmentRight;
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textColor = UIColorFromRGB(0x313131);
    [self addSubview:_timeLabel];
    
    _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(_picImageView.right+20, _nameLabel.bottom+15, SCREEN_WIDTH-_picImageView.right-40, 35)];
    _contentLabel.numberOfLines = 0;
    _contentLabel.font = [UIFont boldSystemFontOfSize:12];
    _contentLabel.textColor = [UIColor blackColor];
    [self addSubview:_contentLabel];
}

- (void)setUplanModel:(ZFUplanModel *)uplanModel
{
    [_picImageView sd_setImageWithURL:[NSURL URLWithString:uplanModel.iconUrl] placeholderImage:[UIImage imageNamed:@"pic_youjihua_default"]];
    _nameLabel.text = uplanModel.merchantName;
    _timeLabel.text = [DateUtils formatDate:uplanModel.endTime symbol:@"."];
    _contentLabel.text = uplanModel.activityIntroduction;
}

@end
