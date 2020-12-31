
//
//  ZDPayPopView.m
//  ReadingEarn
//
//  Created by FANS on 2020/4/15.
//  Copyright © 2020 FANS. All rights reserved.
//

#import "ZDPayPopView.h"

CGFloat getHeightForLableString(NSString *value,CGRect frame,UIFont * font)
{
    UILabel * lable=[[UILabel alloc]initWithFrame:frame];
    lable.text= value;
    lable.numberOfLines =  0;
    lable.font = font;
    return  [lable sizeThatFits:CGSizeMake(frame.size.width, MAXFLOAT)].height;
}

@interface ZDPayPopView()<UIGestureRecognizerDelegate>

@property (nonatomic ,weak)UIWindow *myWindow;
@property (nonatomic ,strong)UIView *coverView;
@property (nonatomic ,assign)ZDPayPopViewEnum type;
@property (nonatomic ,copy)NSString *data;

@end
@implementation ZDPayPopView

#pragma mark - private
- (instancetype)initWithFrame:(CGRect)frame withType:(ZDPayPopViewEnum)type
{
    self = [super initWithFrame:frame];
    if (self) {
        self.type = type;
        [self initialize];
    }
    return self;
}

- (void)initialize {

    self.myWindow = [UIApplication sharedApplication].keyWindow;
    self.coverView = [UIView new];
    [self.myWindow addSubview:self.coverView];
    self.coverView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeThePopupView)];
    [self.coverView addGestureRecognizer:tap];
    
    if (self.type == SetUpFingerprintPayment) {
        self.coverView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5];
        [self re_loadSetSetUpFingerprintPaymentUI];
    }
}

#pragma mark - UI
- (void)re_loadSetSetUpFingerprintPaymentUI {
    UIImageView *fingerprintImageView = [UIImageView new];
    [self addSubview:fingerprintImageView];
    fingerprintImageView.tag = 10;
    
    UILabel *isFingerprintLab = [UILabel new];
    isFingerprintLab.frame = CGRectMake(69, 363, 238, 16);
    isFingerprintLab.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16];
    isFingerprintLab.textColor = [UIColor colorWithRed:61/255.0 green:61/255.0 blue:61/255.0 alpha:1/1.0];
    [self addSubview:isFingerprintLab];
    isFingerprintLab.tag = 20;
    isFingerprintLab.textAlignment = NSTextAlignmentCenter;
    
    UILabel *contentLab = [[UILabel alloc] init];
    contentLab.frame = CGRectMake(69, 387, 238, 40);
    contentLab.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    contentLab.textColor = [UIColor colorWithRed:179/255.0 green:179/255.0 blue:179/255.0 alpha:1/1.0];
    [self addSubview:contentLab];
    contentLab.tag = 30;
    contentLab.numberOfLines = 0;
    contentLab.textAlignment = NSTextAlignmentCenter;
    
    UIButton *openBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:openBtn];
    openBtn.backgroundColor = [UIColor colorWithRed:74/255.0 green:144/255.0 blue:226/255.0 alpha:1/1.0];
    openBtn.layer.cornerRadius = 5;
    openBtn.layer.masksToBounds = YES;
    openBtn.tag = 40;
    [openBtn setTitleColor:[UIColor colorWithRed:253/255.0 green:253/255.0 blue:254/255.0 alpha:1/1.0] forState:UIControlStateNormal];
    openBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [openBtn addTarget:self action:@selector(openBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *offBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:offBtn];
    [offBtn setTitleColor:[UIColor colorWithRed:179/255.0 green:179/255.0 blue:179/255.0 alpha:1/1.0] forState:UIControlStateNormal];
    offBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    offBtn.tag = 50;
    [offBtn addTarget:self action:@selector(offBtnAction:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Layout
- (void)layoutAndLoadDataSetUpFingerprintPayment {
    UIImageView *fingerprintImageView = [self viewWithTag:10];
    fingerprintImageView.frame = CGRectMake((self.width - 94.4)/2, 23, 94.4, 59);
    fingerprintImageView.image = [UIImage imageNamed:@"icon_zhiwen2"];

    CGFloat conHeight1 = getHeightForLableString(NSLocalizedString(@"开通指纹登录", nil), CGRectMake(16, fingerprintImageView.bottom+16, self.width-32, 16), [UIFont fontWithName:@"PingFangSC-Semibold" size:16]);
    UILabel *isFingerprintLab = [self viewWithTag:20];
    isFingerprintLab.text = NSLocalizedString(@"开通指纹登录", nil);
    isFingerprintLab.frame = CGRectMake(16, fingerprintImageView.bottom+16, self.width-32, conHeight1);
    
    UILabel *contentLab = [self viewWithTag:30];
    contentLab.text = NSLocalizedString(@"推荐您使用指纹登录，享受更快捷的登录体验，快来试试吧", nil);
    contentLab.frame = CGRectMake(16, isFingerprintLab.bottom+8, self.width-32, 16);
    CGFloat conHeight = getHeightForLableString(NSLocalizedString(@"推荐您使用指纹登录，享受更快捷的登录体验，快来试试吧", nil), CGRectMake(16, isFingerprintLab.bottom+8, self.width-32, 1), [UIFont fontWithName:@"PingFangSC-Regular" size:14]);
    contentLab.frame = CGRectMake(16, isFingerprintLab.bottom+8, self.width-32, conHeight);
    [contentLab sizeToFit];
    
    UIButton *openBtn = [self viewWithTag:40];
    [openBtn setTitle:NSLocalizedString(@"现在开通", nil) forState:UIControlStateNormal];
    openBtn.frame = CGRectMake(16, contentLab.bottom+18, self.width-32, 36);
    
    UIButton *offBtn = [self viewWithTag:50];
    [offBtn setTitle:NSLocalizedString(@"暂不体验", nil) forState:UIControlStateNormal];
    offBtn.frame = CGRectMake(16, openBtn.bottom+16, self.width-32, 14);
}

#pragma mark - actions
- (void)openBtnAction:(UIButton *)sender {
    [self closeThePopupView];
    if (self.fingerprintOpenBlock) {
        self.fingerprintOpenBlock(sender);
    }
}

- (void)offBtnAction:(UIButton *)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"0" forKey:@"isFirstLogin"];
    [self closeThePopupView];
}

#pragma mark - public
+ (ZDPayPopView *)readingEarnPopupViewWithType:(ZDPayPopViewEnum)type {
    return [[ZDPayPopView alloc] initWithFrame:CGRectZero withType:type];
}

- (void)showPopupViewWithData:(__nullable id)model
                       isOpen:(void (^) (UIButton *sender))isOpen {
    self.fingerprintOpenBlock = isOpen;
    [self.myWindow addSubview:self];
    if (self.type == SetUpFingerprintPayment) {
        self.layer.cornerRadius = 14;
        self.backgroundColor = [UIColor whiteColor];
        self.frame = CGRectMake(52,(SCREEN_HEIGHT-263)/2, SCREEN_WIDTH-104, 263);
        
        [self layoutAndLoadDataSetUpFingerprintPayment];
    }
}

- (void)closeThePopupView {
    self.coverView.hidden = YES;
    self.hidden = YES;
    [self removeFromSuperview];
    [self.coverView removeFromSuperview];
}



@end
