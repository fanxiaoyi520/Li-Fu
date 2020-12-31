//
//  ZFGetVerCodeController.m
//  newupop
//
//  Created by 中付支付 on 2017/7/25.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFGetVerCodeController.h"
#import "ZFSetLoginPwdController.h"
#import "ZFInputPwdController.h"
#import "UniversallyUniqueIdentifier.h"
#import "UITextField+Format.h"

@interface ZFGetVerCodeController ()<UITextFieldDelegate>
@property (strong, nonatomic) UILabel *topLabel;
@property (strong, nonatomic) IBOutlet ZFBaseTextField *codeTextField;
@property (strong, nonatomic) IBOutlet UIButton *getCodeBtn;
///
@property (nonatomic, strong) ZFBaseTextField *pwdTextField1;
@property (nonatomic, strong) ZFBaseTextField *pwdTextField2;

@property (nonatomic, strong)NSTimer *timer;
@property (nonatomic, assign)NSInteger downCount;

///姓名
@property (nonatomic, strong)UITextField *nameTextField;
///卡号
@property (nonatomic, strong)UITextField *cardNumTextField;

@end

@implementation ZFGetVerCodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *titleStr = @"找回登录密码";
    if (_getCodeType == 1) {
        titleStr = @"找回支付密码";
    }
    
    self.myTitle = titleStr;
    
    [self createView];
    
    if (_getCodeType == 1) {
        if ([ZFGlobleManager getGlobleManager].bankCardArray.count == 1) {
            [self getVeriCode];
        }
    } else {
        _topLabel.text = [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"请输入收到的短信验证码", nil), [[ZFGlobleManager getGlobleManager].userPhone stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"]];
        _getCodeBtn.enabled = NO;
        _downCount = 60;
        [self retextBtn];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(retextBtn) userInfo:nil repeats:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_codeTextField becomeFirstResponder];
        });
    }
}

#pragma mark 创建视图
- (void)createView{
    if (_getCodeType == 1 && [ZFGlobleManager getGlobleManager].bankCardArray.count > 0) {//有卡忘记支付密码
        [self getPayPWView];
        return;
    }
    //顶部提示信息
    _topLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, IPhoneXTopHeight+10, SCREEN_WIDTH - 40, 30)];
    _topLabel.font = [UIFont systemFontOfSize:12];
    _topLabel.textColor = [UIColor grayColor];
    _topLabel.numberOfLines = 0;
    _topLabel.text = [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"请输入收到的短信验证码", nil), [[ZFGlobleManager getGlobleManager].userPhone stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"]];
    [self.view addSubview:_topLabel];
    
    //验证码输入框
    _codeTextField = [[ZFBaseTextField alloc] initWithFrame:CGRectMake(20, _topLabel.bottom+10, SCREEN_WIDTH-215, 40)];
    _codeTextField.keyboardType = UIKeyboardTypeNumberPad;
    _codeTextField.delegate = self;
    _codeTextField.placeholder = NSLocalizedString(@"验证码", nil);
    [self.view addSubview:_codeTextField];
    
    //获取验证码按钮
    _getCodeBtn = [[UIButton alloc] initWithFrame:CGRectMake(_codeTextField.right+15, _codeTextField.y, 160, 40)];
    _getCodeBtn.backgroundColor = MainThemeColor;
    _getCodeBtn.layer.cornerRadius = 5;
    _getCodeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_getCodeBtn setTitle:NSLocalizedString(@"获取验证码", nil) forState:UIControlStateNormal];
    [_getCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_getCodeBtn addTarget:self action:@selector(getVeriCode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_getCodeBtn];
    
    //密码
    _pwdTextField1 = [[ZFBaseTextField alloc] initWithFrame:CGRectMake(20, _getCodeBtn.bottom+20, SCREEN_WIDTH-40, 40)];
    _pwdTextField1.clearButtonMode = UITextFieldViewModeWhileEditing;
    _pwdTextField1.secureTextEntry = YES;
    _pwdTextField1.delegate = self;
    _pwdTextField1.placeholder = NSLocalizedString(@"请输入6-20位登录密码", nil);
    [self.view addSubview:_pwdTextField1];
    
    _pwdTextField2 = [[ZFBaseTextField alloc] initWithFrame:CGRectMake(20, _pwdTextField1.bottom+10, _pwdTextField1.width, _pwdTextField1.height)];
    _pwdTextField2.clearButtonMode = UITextFieldViewModeWhileEditing;
    _pwdTextField2.secureTextEntry = YES;
    _pwdTextField2.delegate = self;
    _pwdTextField2.placeholder = NSLocalizedString(@"请再次输入", nil);
    [self.view addSubview:_pwdTextField2];
    
    //确定按钮
    UIButton *confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, _pwdTextField2.bottom+40, SCREEN_WIDTH-40, 40)];
    confirmBtn.backgroundColor = MainThemeColor;
    confirmBtn.layer.cornerRadius = 5;
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [confirmBtn setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(confirmBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmBtn];
    
    if (_getCodeType == 1) {//找回支付密码 隐藏
        _pwdTextField1.hidden = YES;
        _pwdTextField2.hidden = YES;
        confirmBtn.y = _codeTextField.bottom+25;
        [confirmBtn setTitle:NSLocalizedString(@"下一步", nil) forState:UIControlStateNormal];
    }
}

- (void)getPayPWView{
    self.view.backgroundColor = UIColorFromRGB(0xeeeeee);
    
    //姓名
    UIView *backView1 = [[UIView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight+20, SCREEN_WIDTH, 40)];
    backView1.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backView1];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 70, 40)];
    nameLabel.text = NSLocalizedString(@"姓名", nil);
    nameLabel.font = [UIFont systemFontOfSize:15];
    [backView1 addSubview:nameLabel];
    
    _nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(nameLabel.right+10, 0, SCREEN_WIDTH-120, 40)];
    _nameTextField.font = [UIFont systemFontOfSize:14];
    _nameTextField.placeholder = NSLocalizedString(@"请输入绑卡所填姓名", nil);
    _nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [backView1 addSubview:_nameTextField];
    
    //卡号
    UIView *backView2 = [[UIView alloc] initWithFrame:CGRectMake(0, backView1.bottom+10, SCREEN_WIDTH, 40)];
    backView2.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backView2];
    
    UILabel *cardLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 70, 40)];
    cardLabel.text = NSLocalizedString(@"卡号", nil);
    cardLabel.font = [UIFont systemFontOfSize:15];
    [backView2 addSubview:cardLabel];
    
    _cardNumTextField = [[UITextField alloc] initWithFrame:CGRectMake(cardLabel.right+10, 0, SCREEN_WIDTH-120, 40)];
    _cardNumTextField.delegate = self;
    _cardNumTextField.font = [UIFont systemFontOfSize:14];
    _cardNumTextField.placeholder = NSLocalizedString(@"请输入绑卡所填银联卡号", nil);
    _cardNumTextField.keyboardType = UIKeyboardTypeNumberPad;
    _cardNumTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [backView2 addSubview:_cardNumTextField];
    
    //验证码
    UIView *backView3 = [[UIView alloc] initWithFrame:CGRectMake(0, backView2.bottom+10, SCREEN_WIDTH, 40)];
    backView3.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backView3];
    
//    UILabel *codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 70, 40)];
//    codeLabel.text = NSLocalizedString(@"验证码", nil);
//    codeLabel.font = [UIFont systemFontOfSize:15];
//    [backView3 addSubview:codeLabel];
    
    _codeTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH-40-160, 40)];
    _codeTextField.placeholder = NSLocalizedString(@"验证码", nil);
    _codeTextField.font = [UIFont systemFontOfSize:14];
    _codeTextField.keyboardType = UIKeyboardTypeNumberPad;
    _codeTextField.clearButtonMode = UITextFieldViewModeAlways;
    [_codeTextField limitTextLength:6];
    [backView3 addSubview:_codeTextField];
    
    _getCodeBtn = [[UIButton alloc] initWithFrame:CGRectMake(_codeTextField.right, 0, 160, 40)];
    _getCodeBtn.backgroundColor = [UIColor whiteColor];
    _getCodeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
//    _getCodeBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    _getCodeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [_getCodeBtn setTitle:NSLocalizedString(@"获取验证码", nil) forState:UIControlStateNormal];
    [_getCodeBtn setTitleColor:MainThemeColor forState:UIControlStateNormal];
    [_getCodeBtn addTarget:self action:@selector(getVeriCode) forControlEvents:UIControlEventTouchUpInside];
    [backView3 addSubview:_getCodeBtn];
    
    //确定按钮
    UIButton *confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, backView3.bottom+70, SCREEN_WIDTH-40, 40)];
    confirmBtn.backgroundColor = MainThemeColor;
    confirmBtn.layer.cornerRadius = 5;
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [confirmBtn setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(confirmBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmBtn];
}

//验证姓名和卡号
- (BOOL)checkInfo{
    if (_nameTextField.text.length < 1) {
        [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"持卡人姓名不能为空", nil) inView:self.view];
        return NO;
    }
    if (_cardNumTextField.text.length < 9) {
        [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"银行卡号输入有误", nil) inView:self.view];
        return NO;
    }
    
    return YES;
}

- (IBAction)getVeriCode{
    
    NSDictionary *parameters ;
    
    if (_getCodeType == 1) {//找回支付密码
        if ([ZFGlobleManager getGlobleManager].bankCardArray.count > 0) {
            if (![self checkInfo]) {
                return;
            }
        }
        parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                       @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                       @"txnType": @"16",
                       @"sessionID":[ZFGlobleManager getGlobleManager].sessionID};
    } else {//找回登录密码
        parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                       @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                       @"txnType": @"03",
                       @"tempSessionID":[ZFGlobleManager getGlobleManager].tempSessionID};
    }
    [_codeTextField becomeFirstResponder];
    [[MBUtils sharedInstance] showMBInView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
           _topLabel.text = [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"请输入收到的短信验证码", nil), [[ZFGlobleManager getGlobleManager].userPhone stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"]];
            _getCodeBtn.enabled = NO;
            _downCount = 60;
            [self retextBtn];
            _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(retextBtn) userInfo:nil repeats:YES];
            //[_codeTextField becomeFirstResponder];
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
        
    } failure:^(NSError *error) {
        //[[MBUtils sharedInstance] dismissMB];
        
    }];
}

- (void)retextBtn{
    _downCount--;
    NSString *str = NSLocalizedString(@"后重新获取", nil);
    if ([str hasPrefix:@"后"]) {
        [_getCodeBtn setTitle:[NSString stringWithFormat:@"%zds后重新获取", _downCount] forState:UIControlStateNormal];
    } else {
        [_getCodeBtn setTitle:[NSString stringWithFormat:@"%@ %zds", str, _downCount] forState:UIControlStateNormal];
    }
    if (_downCount == 0) {
        _getCodeBtn.enabled = YES;
        [_getCodeBtn setTitle:NSLocalizedString(@"重新获取", nil) forState:UIControlStateNormal];
        [_timer invalidate];
        _timer = nil;
    }
}

- (IBAction)confirmBtn:(id)sender {
    //找回登录密码
    if (_getCodeType == 0) {
        if (_pwdTextField1.text.length < 6 || _pwdTextField1.text.length > 20) {
            [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"请输入6-20位登录密码", nil) inView:self.view];
            return;
        }
        
        if (![_pwdTextField1.text isEqualToString:_pwdTextField2.text]) {
            [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"两次输入的密码不一致", nil) inView:self.view];
            return;
        }
    }
    
    if (_codeTextField.text.length != 6) {
        [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"验证码输入错误", nil) inView:self.view];
        return;
    }
    
    [self verificationCode];
}

#pragma mark 验证 验证码
- (void)verificationCode{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:[ZFGlobleManager getGlobleManager].areaNum forKey:@"countryCode"];
    [parameters setObject:[ZFGlobleManager getGlobleManager].userPhone forKey:@"mobile"];
    [parameters setObject:_codeTextField.text forKey:@"mailVerifyCode"];
    
    if (_getCodeType == 0) {//登录密码
        [parameters setObject:@"04" forKey:@"txnType"];
        [parameters setObject:[ZFGlobleManager getGlobleManager].tempSessionID forKey:@"tempSessionID"];
    } else {//支付密码
        [parameters setObject:@"17" forKey:@"txnType"];
        [parameters setObject:[ZFGlobleManager getGlobleManager].sessionID forKey:@"sessionID"];
        [parameters setObject:@"" forKey:@"name"];
        [parameters setObject:@"" forKey:@"cardNum"];
        
        if ([ZFGlobleManager getGlobleManager].bankCardArray.count > 0) {
            if (![self checkInfo]) {
                return;
            }
            NSString *cardNum = [TripleDESUtils getEncryptWithString:[_cardNumTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV];
            [parameters setObject:_nameTextField.text forKey:@"name"];
            [parameters setObject:cardNum forKey:@"cardNum"];
        }
    }
    
    [[MBUtils sharedInstance] showMBInView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            if (_getCodeType == 0) {//登录密码
//                ZFSetLoginPwdController *setVC = [[ZFSetLoginPwdController alloc] init];
//                setVC.type = 2;
//                [self.navigationController pushViewController:setVC animated:YES];
                [self setLoginPwd];
            } else if (_getCodeType == 1) {//支付密码
                
                ZFInputPwdController *inputVC = [[ZFInputPwdController alloc] init];
                inputVC.inputType = 2;
                [self.navigationController pushViewController:inputVC animated:YES];
            }
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
        
    } failure:^(NSError *error) {
        //[[MBUtils sharedInstance] dismissMB];
        
    }];
}

#pragma mark 修改密码
- (void)setLoginPwd{
    UniversallyUniqueIdentifier *uuid = [UniversallyUniqueIdentifier sharedInstance];
    // 3DES加密
    NSString *password = _pwdTextField1.text;
    //登录前和登录后的key不一样
    NSString *key = [ZFGlobleManager getGlobleManager].tempSecurityKey;
    NSString *encrypptpasswordString = [TripleDESUtils getEncryptWithString:password keyString: key ivString: @"01234567"];
    
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                       @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                       @"txnType": @"05",
                       @"newPassword":encrypptpasswordString,
                       @"userKey":uuid.uuid,
                       @"tempSessionID":[ZFGlobleManager getGlobleManager].tempSessionID};
    
    [[MBUtils sharedInstance] showMBInView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [XLAlertController acWithMessage:NSLocalizedString(@"密码设置成功", nil) confirmBtnTitle:NSLocalizedString(@"确定", nil) confirmAction:^(UIAlertAction *action) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }];
        } else {
            [XLAlertController acWithMessage:[requestResult objectForKey:@"msg"] confirmBtnTitle:NSLocalizedString(@"确定", nil) confirmAction:^(UIAlertAction *action) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }];
        }
        
    } failure:^(NSError *error) {
        [[MBUtils sharedInstance] dismissMB];
        
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == _cardNumTextField) {
        [textField formatBankCardNoWithString:string range:range];
        return NO;
    }
    if (textField == _codeTextField) {
        if (textField.text.length >= 6 && ![string isEqualToString:@""]) {
            return NO;
        }
    }
    if (textField == _pwdTextField1 || textField == _pwdTextField2) {
        if (textField.text.length >= 20 && ![string isEqualToString:@""]) {
            return NO;
        }
    }
    return YES;
}

@end
