//
//  ZFBankCardCell.m
//  newupop
//
//  Created by Jellyfish on 2017/7/25.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFBankCardCell.h"

@interface ZFBankCardCell ()

/** logo */
@property (nonatomic, weak) UIImageView *logoIV;
/** 银行名称 */
@property (nonatomic, weak) UILabel *bankNameLabel;
/** 卡类型 */
@property (nonatomic, weak) UILabel *cardTypeLabel;
///城市
@property (nonatomic, weak) UILabel *cityLabel;
///显示/隐藏卡号按钮
@property (nonatomic, strong)UIButton *showNumBtn;

@end

@implementation ZFBankCardCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *ID = @"ZFBankCardCell";
    ZFBankCardCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
//    if (!cell) {
        cell = [[ZFBankCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
//    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor whiteColor];
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
    cardNoLabel.frame = CGRectMake(SCREEN_WIDTH*0.4, logoIV.y+5, SCREEN_WIDTH*0.6-40, 25);
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
    [self.contentView addSubview:_showNumBtn];
    
    // 余额
    UILabel *balanceLabel = [[UILabel alloc] init];
    balanceLabel.frame = CGRectMake(SCREEN_WIDTH*0.2-40, CGRectGetMaxY(cardNoLabel.frame), SCREEN_WIDTH*0.8, 27);
    balanceLabel.textColor = ZFAlpColor(0, 0, 0, 0.8);
    balanceLabel.textAlignment = NSTextAlignmentRight;
    balanceLabel.font = [UIFont systemFontOfSize:12];
//    [balanceLabel sizeToFit];
    balanceLabel.hidden = YES;
    [self addSubview:balanceLabel];
    self.balanceLabel = balanceLabel;
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
    
    if ([self.model.cardNo hasPrefix:@"623415"]) {//显示
        self.balanceLabel.hidden = NO;
        self.balanceLabel.text = [NSString stringWithFormat:@"%@****", NSLocalizedString(@"余额：", nil)];
    }
    
    if ([model.channelType isEqualToString:@"000001"]) {
        self.cityLabel.text = [SmallUtils transformSymbolString2CountryString:model.sysareaId];
        [_cityLabel sizeToFit];
    }
    
    
//    // 开通地区
//    NSUInteger i = 0;
//    if ([model.openCountry.UP isEqualToString:@"0"]) { // 已开通
//        UIImageView *openAreaIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_card_unionpay"]];
//        openAreaIV.frame = CGRectMake(self.cardTypeLabel.x+i*(32+15), CGRectGetMaxY(self.cardTypeLabel.frame)+12, 32, 32);
//        [self addSubview:openAreaIV];
//        i += 1;
//    }
//
//    if ([model.openCountry.SG isEqualToString:@"0"]) { // 已开通
//        UIImageView *openAreaIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_card_singapore"]];
//        openAreaIV.frame = CGRectMake(self.cardTypeLabel.x+i*(32+15), CGRectGetMaxY(self.cardTypeLabel.frame)+12, 32, 32);
//        [self addSubview:openAreaIV];
//        i += 1;
//    }
//
//    if ([model.openCountry.MY isEqualToString:@"0"]) { // 已开通
//        UIImageView *openAreaIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_card_malaysia"]];
//        openAreaIV.frame = CGRectMake(self.cardTypeLabel.x+i*(32+15), CGRectGetMaxY(self.cardTypeLabel.frame)+12, 32, 32);
//        [self addSubview:openAreaIV];
//        i += 1;
//    }
//
//    if ([model.openCountry.HK isEqualToString:@"0"]) { // 已开通
//        for (int j = 0; j < 2; j++) {
//            UIImageView *openAreaIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:j == 0 ? @"icon_card_hongkong" : @"icon_card_macau"]];
//            openAreaIV.frame = CGRectMake(self.cardTypeLabel.x+i*(32+15), CGRectGetMaxY(self.cardTypeLabel.frame)+12, 32, 32);
//            [self addSubview:openAreaIV];
//            i += 1;
//        }
//    }
}

- (void)setIsCanShowNum:(BOOL)isCanShowNum{
    if (isCanShowNum) {
        _showNumBtn.hidden = NO;
        [_showNumBtn addTarget:self action:@selector(clickShowBtn) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)clickShowBtn{
    _showNumBtn.selected = !_showNumBtn.selected;
    if (self.showNumBlock) {
        self.showNumBlock(_showNumBtn.selected, self.model.cardNo, self.model.bankName);
    }
//    
//    if (_showNumBtn.selected) {
//        self.cardNoLabel.text = self.model.cardNo;
//    } else {
//        // 截取后4位
//        NSString *sub = [self.model.cardNo substringFromIndex:_model.cardNo.length-4];
//        self.cardNoLabel.text = [NSString stringWithFormat:@"**** **** **** %@", sub];
//    }
}


@end
