//
//  ZFPCApprovalStatusViewController.m
//  newupop
//
//  Created by Jellyfish on 2020/1/7.
//  Copyright © 2020 中付支付. All rights reserved.
//

#import "ZFPCApprovalStatusViewController.h"
#import "ZFVerifyBankCardNoViewController.h"
#import "ZFPCPersonInfoViewController.h"

@interface ZFPCApprovalStatusViewController ()

@property (weak, nonatomic) IBOutlet UILabel *approvalStatus;
@property (weak, nonatomic) IBOutlet UILabel *failureReasonLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *failureViewHeight;
@property (weak, nonatomic) IBOutlet UIView *failureView;
@property (weak, nonatomic) IBOutlet UIButton *btn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topMargin;
@property (nonatomic, strong) ZFPCBankCard *cardInfo;

//银行卡视图系列
@property (weak, nonatomic) IBOutlet UILabel *cardNoLabel;
@property (weak, nonatomic) IBOutlet UIView *cardBgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cardBgView_Height;

@end

@implementation ZFPCApprovalStatusViewController

- (instancetype)initWithCardInfo:(ZFPCBankCard *)cardInfo {
    if (self = [super init]) {
        _cardInfo = cardInfo;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myTitle = NSLocalizedString(@"银行卡状态", nil);
    _topMargin.constant = IPhoneXTopHeight;
    self.view.backgroundColor = GrayBgColor;
    
    _btn.backgroundColor = MainThemeColor;
    [_btn setTitle:NSLocalizedString(@"重新认证", nil) forState:UIControlStateNormal];
    
    NSString *cardNum = [TripleDESUtils getDecryptWithString:_cardInfo.cardNum keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    if (cardNum.length > 10) {
        NSString *preNum = [cardNum substringToIndex:6];
        NSString *sufNum = [cardNum substringFromIndex:cardNum.length-4];
        _cardNoLabel.text = [NSString stringWithFormat:@"%@ **** **** %@", preNum, sufNum];
    } else {
        _cardNoLabel.text = cardNum;
    }

    if (![cardNum isEqualToString:@""]) {
        self.cardBgView_Height.constant = 50;
        self.cardBgView.hidden = NO;
    }else{
        self.cardBgView_Height.constant = 0;
        self.cardBgView.hidden = YES;
    }
    
    NSString *origStatus = _cardInfo.origStatus;
    if ([origStatus isEqualToString:@"0"]) {
        _approvalStatus.text = NSLocalizedString(@"待审核", nil);
    } else if ([origStatus isEqualToString:@"1"]) {
        _approvalStatus.text = NSLocalizedString(@"审核通过", nil);
    } else if ([origStatus isEqualToString:@"2"]) {
        _approvalStatus.text = NSLocalizedString(@"审核不通过", nil);
    }
    if (![origStatus isEqualToString:@"2"]) {
        _failureView.hidden = YES;
        _failureViewHeight.constant = 0;
        _btn.hidden = YES;
    } else { //审核不通过
        _failureReasonLabel.text = _cardInfo.failReasons;
    }
}

- (IBAction)reApprovalAction:(id)sender {
//    if (_isVirtualCard) {
//        ZFPCPersonInfoViewController *infoView = [[ZFPCPersonInfoViewController alloc] init];
//        infoView.enCardNum = _cardInfo.cardNum;
//        [self pushViewController:infoView];
//    } else {
//        ZFVerifyBankCardNoViewController *verifyVC = [[ZFVerifyBankCardNoViewController alloc] init];
//        [self pushViewController:verifyVC];
//    }
    ZFPCPersonInfoViewController *infoView = [[ZFPCPersonInfoViewController alloc] init];
    infoView.enCardNum = _cardInfo.cardNum;
    if ([_cardType isEqualToString:@"2"]) {
        [ZFGlobleManager getGlobleManager].applyType = @"2";
    } else if ([_cardType isEqualToString:@"3"]){
        [ZFGlobleManager getGlobleManager].applyType = @"3";
    } else {
        [ZFGlobleManager getGlobleManager].applyType = @"1";
    }
    [self pushViewController:infoView];
}

@end
