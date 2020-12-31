//
//  ZFAddCreditCardController.m
//  newupop
//
//  Created by 中付支付 on 2017/9/11.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFAddCreditCardController.h"
#import "ZFGetMSCodeController.h"

@interface ZFAddCreditCardController ()

@property (nonatomic, strong)UITextField *cvnTextField;
@property (nonatomic, strong)UITextField *expiredTextField;

@end

@implementation ZFAddCreditCardController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.myTitle = @"补充信用卡信息";
    self.view.backgroundColor = GrayBgColor;
    [self createView];
}

- (void)createView{
    //CVN底部视图
    UIView *backView1 = [[UIView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight+20, SCREEN_WIDTH, 40)];
    backView1.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backView1];
    
    UILabel *cvnLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 40)];
    cvnLabel.text = @"CVN";
    cvnLabel.font = [UIFont systemFontOfSize:15];
    [backView1 addSubview:cvnLabel];
    
    //cvn输入框
    _cvnTextField = [[UITextField alloc] initWithFrame:CGRectMake(cvnLabel.right+10, 0, SCREEN_WIDTH-150, 40)];
    _cvnTextField.placeholder = NSLocalizedString(@"卡背后三位数字", nil);
    _cvnTextField.font = [UIFont systemFontOfSize:14];
    [_cvnTextField limitTextLength:3];
    _cvnTextField.keyboardType = UIKeyboardTypeNumberPad;
    _cvnTextField.textAlignment = NSTextAlignmentRight;
    [backView1 addSubview:_cvnTextField];
    
    _cvnTextField.rightViewMode = UITextFieldViewModeAlways;
    UIView *rightView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    rightView1.tag = 100;
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickDetail:)];
    [rightView1 addGestureRecognizer:tap1];
    UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(15, 8, 24, 24)];
    imageView1.image = [UIImage imageNamed:@"icon_tips"];
    [rightView1 addSubview:imageView1];
    _cvnTextField.rightView = rightView1;
    
    //有效期地步视图
    UIView *backView2 = [[UIView alloc] initWithFrame:CGRectMake(0, backView1.bottom+1, SCREEN_WIDTH, 40)];
    backView2.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backView2];
    
    UILabel *expiredLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 110, 40)];
    expiredLabel.text = NSLocalizedString(@"有效期", nil);
    expiredLabel.font = [UIFont systemFontOfSize:15];
    [backView2 addSubview:expiredLabel];
    
    //有效期输入框
    _expiredTextField = [[UITextField alloc] initWithFrame:CGRectMake(_cvnTextField.x+10, 0, _cvnTextField.width-10, 40)];
    _expiredTextField.placeholder = @"MM/YY";
    _expiredTextField.font = [UIFont systemFontOfSize:14];
    _expiredTextField.textAlignment = NSTextAlignmentRight;
    _expiredTextField.keyboardType = UIKeyboardTypeNumberPad;
    [_expiredTextField limitTextLength:4];
    [backView2 addSubview:_expiredTextField];
    
    _expiredTextField.rightViewMode = UITextFieldViewModeAlways;
    UIView *rightView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    rightView2.tag = 101;
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickDetail:)];
    [rightView2 addGestureRecognizer:tap2];
    UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(15, 8, 24, 24)];
    imageView2.image = [UIImage imageNamed:@"icon_tips"];
    [rightView2 addSubview:imageView2];
    _expiredTextField.rightView = rightView2;
    
    //下一步按钮
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.frame = CGRectMake(20, backView2.bottom+45, SCREEN_WIDTH-40, 40);
    nextBtn.layer.cornerRadius = 5;
    nextBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    nextBtn.backgroundColor = MainThemeColor;
    [nextBtn setTitle:NSLocalizedString(@"下一步", nil) forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(clickNextStepBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
}

- (void)clickNextStepBtn{
    
    [self.view endEditing:YES];
    NSString *cvnStr = _cvnTextField.text;
    NSString *expiredStr = _expiredTextField.text;
    
    //安全码
    if(!cvnStr || cvnStr.length < 3){
        [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"银行卡安全码输入有误", nil) inView:self.view];
        return ;
    }
    
    //有效期
    if(!expiredStr || expiredStr.length < 4){
        [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"银行卡有效期输入有误", nil) inView:self.view];
        return ;
    }
    
    //后台有效期格式 年月
    NSString *exchange = [NSString stringWithFormat:@"%@%@", [expiredStr substringFromIndex:2], [expiredStr substringToIndex:2]];
    
    NSString *encryCvn = [TripleDESUtils getEncryptWithString:cvnStr keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    NSString *encryEx = [TripleDESUtils getEncryptWithString:exchange keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    
    [ZFGlobleManager getGlobleManager].cvn2 = encryCvn;
    [ZFGlobleManager getGlobleManager].expired = encryEx;
    
    ZFGetMSCodeController *getVC = [[ZFGetMSCodeController alloc] init];
    getVC.cardType = 1;
    [self.navigationController pushViewController:getVC animated:YES];
}

#pragma mark 点击有效期详情
- (void)clickDetail:(UITapGestureRecognizer *)tap{
    NSInteger tag = tap.view.tag;
    
    NSString *title = @"";
    NSString *message = @"";
    if (tag == 100) {
        title = NSLocalizedString(@"CVN说明", nil);
        message = NSLocalizedString(@"卡背面三位数字", nil);
    } else {
        title = NSLocalizedString(@"有效期说明", nil);
        message = NSLocalizedString(@"卡正面有效期", nil);
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    // 确定
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:confirmAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
