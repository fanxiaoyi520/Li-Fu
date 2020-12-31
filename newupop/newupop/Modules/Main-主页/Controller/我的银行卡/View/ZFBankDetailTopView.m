//
//  ZFBankDetailTopView.m
//  newupop
//
//  Created by 中付支付 on 2018/6/14.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "ZFBankDetailTopView.h"

@interface ZFBankDetailTopView()
/** logo */
@property (nonatomic, weak) UIImageView *logoIV;
/** 银行名称 */
@property (nonatomic, weak) UILabel *bankNameLabel;
/** 卡类型 */
@property (nonatomic, weak) UILabel *cardTypeLabel;
/** 卡号 */
@property (nonatomic, weak) UILabel *cardNoLabel;
///城市
@property (nonatomic, weak) UILabel *cityLabel;
///显示/隐藏卡号按钮
@property (nonatomic, strong)UIButton *showNumBtn;

@end

@implementation ZFBankDetailTopView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

/** 添加子控件 */
- (void)setupSubviews {
    // 银行logo
    UIImageView *logoIV = [[UIImageView alloc] init];
    logoIV.frame = CGRectMake(22, 20, 35, 35);
    logoIV.image = [UIImage imageNamed:@"bk_bcm_l"];
    [self addSubview:logoIV];
    self.logoIV = logoIV;
    
    // 银行名称
    UILabel *bankNameLabel = [[UILabel alloc] init];
    bankNameLabel.frame = CGRectMake(CGRectGetMaxX(logoIV.frame)+10, logoIV.y, SCREEN_WIDTH*0.4, 15);
    bankNameLabel.text = @"交通银行";
    bankNameLabel.textColor = UIColorFromRGB(0x313131);
    bankNameLabel.textAlignment = NSTextAlignmentLeft;
    bankNameLabel.font = [UIFont systemFontOfSize:14.0];
    bankNameLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:bankNameLabel];
    self.bankNameLabel = bankNameLabel;
    
    // 卡类型
    UILabel *cardTypeLabel = [[UILabel alloc] init];
    cardTypeLabel.frame = CGRectMake(bankNameLabel.x, CGRectGetMaxY(logoIV.frame)-13, SCREEN_WIDTH*0.2, 13);
    cardTypeLabel.text = @"信用卡";
    cardTypeLabel.textColor = UIColorFromRGB(0x313131);
    cardTypeLabel.textAlignment = NSTextAlignmentLeft;
    cardTypeLabel.font = [UIFont systemFontOfSize:12.0];
    [self addSubview:cardTypeLabel];
    self.cardTypeLabel = cardTypeLabel;
    
    // 卡号
    UILabel *cardNoLabel = [[UILabel alloc] init];
    cardNoLabel.frame = CGRectMake(SCREEN_WIDTH*0.4, logoIV.y+5, SCREEN_WIDTH*0.6-40, 35);
    cardNoLabel.text = @"**** **** **** 1234";
    cardNoLabel.textColor = ZFAlpColor(0, 0, 0, 0.8);
    cardNoLabel.textAlignment = NSTextAlignmentRight;
    cardNoLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:cardNoLabel];
    self.cardNoLabel = cardNoLabel;
    
    _showNumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _showNumBtn.frame = CGRectMake(cardNoLabel.right+10, 0, 20, 20);
    _showNumBtn.centerY = cardNoLabel.centerY;
    //    _showNumBtn.hidden = YES;
    [_showNumBtn addTarget:self action:@selector(clickShowBtn) forControlEvents:UIControlEventTouchUpInside];
    [_showNumBtn setImage:[UIImage imageNamed:@"showpassword_no"] forState:UIControlStateNormal];
    [_showNumBtn setImage:[UIImage imageNamed:@"showpassword_yes"] forState:UIControlStateSelected];
    [self addSubview:_showNumBtn];
}

- (void)setModel:(ZFBankCardModel *)model {
    _model = model;
    
    // logo
    UIImage *logoImage = [UIImage imageNamed:model.logoStr];
    if (!logoImage) {
        logoImage = [UIImage imageNamed:@"icon_bank_normal"];
    }
    self.logoIV.image = logoImage;
    // 银行名称
    NSString *language = [NetworkEngine getCurrentLanguage];
    self.bankNameLabel.text = [language isEqualToString:@"2"] ? model.bankName : model.bankNameLog;
    // 卡类型
    self.cardTypeLabel.text = [model.cardType isEqualToString:@"1"] ? NSLocalizedString(@"借记卡", nil) : NSLocalizedString(@"信用卡", nil);
    
    // 卡号
    // 截取后4位
    NSString *sub = [model.cardNo substringFromIndex:model.cardNo.length-4];
    self.cardNoLabel.text = [NSString stringWithFormat:@"**** **** **** %@", sub];
    
    if ([model.channelType isEqualToString:@"000001"]) {
        self.cityLabel.text = [SmallUtils transformSymbolString2CountryString:model.sysareaId];
        [_cityLabel sizeToFit];
    }
}

- (void)setIsCanShowNum:(BOOL)isCanShowNum{
    if (isCanShowNum) {
        _showNumBtn.hidden = NO;
        [_showNumBtn addTarget:self action:@selector(clickShowBtn) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)clickShowBtn{
    _showNumBtn.selected = !_showNumBtn.selected;
    if (_showNumBtn.selected) {
        self.cardNoLabel.text = self.model.cardNo;
    } else {
        // 截取后4位
        NSString *sub = [self.model.cardNo substringFromIndex:_model.cardNo.length-4];
        self.cardNoLabel.text = [NSString stringWithFormat:@"**** **** **** %@", sub];
    }
}

@end
