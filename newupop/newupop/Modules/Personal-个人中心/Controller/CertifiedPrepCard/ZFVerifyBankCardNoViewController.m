//
//  ZFVerifyBankCardNoViewController.m
//  newupop
//
//  Created by Jellyfish on 2020/1/6.
//  Copyright © 2020 中付支付. All rights reserved.
//

#import "ZFVerifyBankCardNoViewController.h"
#import "ZFPCPersonInfoViewController.h"
#import "WLCardNoFormatter.h"

@interface ZFVerifyBankCardNoViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topMargin;
@property (weak, nonatomic) IBOutlet UILabel *bankNoLabel;
@property (weak, nonatomic) IBOutlet UILabel *bankcardPwdLabe;
@property (weak, nonatomic) IBOutlet UITextField *cardNoTF;
@property (weak, nonatomic) IBOutlet UITextField *cardPwdTF;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMargin;

@end

@implementation ZFVerifyBankCardNoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myTitle = NSLocalizedString(@"验证银行卡号", nil);
    
    self.view.backgroundColor = GrayBgColor;
    _topMargin.constant = IPhoneXTopHeight;
    _bottomMargin.constant = IPhoneXTabBarHeight - 30;
    
    _bankNoLabel.text = NSLocalizedString(@"银行卡号", nil);
    _cardNoTF.placeholder = NSLocalizedString(@"输入银行卡号", nil);
    _bankcardPwdLabe.text = NSLocalizedString(@"银行卡密码", nil);
    _cardPwdTF.placeholder = NSLocalizedString(@"输入银行卡密码", nil);
    _cardNoTF.delegate = self;
    [_cardNoTF limitTextLength:23];
    [_cardPwdTF limitTextLength:6];
    _nextBtn.backgroundColor = MainThemeColor;
    [_nextBtn setTitle:NSLocalizedString(@"下一步", nil) forState:UIControlStateNormal];
}

- (IBAction)nextStrpBtnAction:(id)sender {
    NSString *cardNo = [_cardNoTF.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (!cardNo.length) {
        [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"请输入银行卡号", nil) inView:self.view];
        return;
    }
    if (!_cardPwdTF.text.length) {
        [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"输入银行卡密码", nil) inView:self.view];
        return;
    }
    
    NSString *cardNum = [TripleDESUtils getEncryptWithString:cardNo keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    NSString *authPass = [TripleDESUtils getEncryptWithString:_cardPwdTF.text keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                                 @"cardNum": cardNum,
                                 @"authPass": authPass,
                                 @"txnType": @"88"};
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [ZFGlobleManager getGlobleManager].applyType = @"1";
            ZFPCPersonInfoViewController *infoView = [[ZFPCPersonInfoViewController alloc] init];
            infoView.enCardNum = cardNum;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[MBUtils sharedInstance] dismissMB];
                [self pushViewController:infoView];
            });
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
    }];
}

#pragma mark -- 网络请求
- (void)verifyCardNo {
}


#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == _cardNoTF) {
        [[WLCardNoFormatter sharedManager] bankNoField:textField shouldChangeCharactersInRange:range replacementString:string];
        return NO;
    }
    return YES;
}

@end
