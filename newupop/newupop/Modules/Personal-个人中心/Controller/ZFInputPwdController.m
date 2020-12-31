//
//  ZFInputPwdController.m
//  newupop
//
//  Created by 中付支付 on 2017/7/26.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFInputPwdController.h"
#import "ZFSuccessController.h"
#import "TripleDESUtils.h"
#import "ZFAddBankCardController.h"
#import "IQKeyboardManager.h"

@interface ZFInputPwdController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *point1;
@property (weak, nonatomic) IBOutlet UIImageView *point2;
@property (weak, nonatomic) IBOutlet UIImageView *point3;
@property (weak, nonatomic) IBOutlet UIImageView *point4;
@property (weak, nonatomic) IBOutlet UIImageView *point5;
@property (weak, nonatomic) IBOutlet UIImageView *point6;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *errorMessage;

@property (nonatomic, strong)NSArray *pointArray;

///输入的密码
@property (nonatomic, strong)NSString *pwdStr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

@end

@implementation ZFInputPwdController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _topConstraint.constant = IPhoneXTopHeight + 36;
    
    if (!_inputCount) {
        _inputCount = 1;
    }
    [self setTitleAndContent];
    
    _pointArray = [NSArray arrayWithObjects:_point1, _point2, _point3, _point4, _point5, _point6, nil];
    for (NSInteger i = 0; i < 6; i++) {
        [_pointArray[i] setHidden:YES];
    }
    
    [_textField addTarget:self action:@selector(inputPwd) forControlEvents:UIControlEventEditingChanged];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    if (!_pwdStr) {//从前面返回的不弹键盘
        [_textField becomeFirstResponder];
    }
    _pwdStr = nil;
    _textField.text = @"";
    [self showPoint];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
}

- (void)inputPwd{
    if (_inputType == 0) {
        [self setPayPwd];
    }
    
    if (_inputType == 1) {
        [self changePayPwd];
    }
    
    if (_inputType == 2) {
        [self findPayPwd];
    }
    
    if (_inputType == 3) {
        [self validationPwd];
    }
    
    if (_inputType == 4) {
        [self setPayPwd];
    }
    
    if (_inputType == 5) {
        [self setPayPwd];
    }
}

#pragma mark - 设置支付密码
- (void)setPayPwd{
    if (_textField.text.length <= 6) {
        _pwdStr = _textField.text;
        [self showPoint];
        if (_textField.text.length == 6) {//输入6位后
            if (_inputCount == 1) {
                [self performSelector:@selector(inputAgain) withObject:nil afterDelay:0.1];
            }
            
            if (_inputCount == 2) {
                [self passwordSetRequest];
            }
            [_textField resignFirstResponder];
        }
    } else {
        _textField.text = [_textField.text substringToIndex:6];
        [_textField resignFirstResponder];
    }
}

#pragma mark - 修改支付密码
- (void)changePayPwd{
    if (_textField.text.length <= 6) {
        _pwdStr = _textField.text;
        [self showPoint];
        if (_textField.text.length == 6) {//输入6位后
            if (_inputCount == 1) {
                //校验密码
                [self veriPwdCode];
            }
            
            if (_inputCount == 2) {
                [self performSelector:@selector(inputAgain) withObject:nil afterDelay:0.1];
            }
            
            if (_inputCount == 3) {
                [self passwordSetRequest];
            }
            [_textField resignFirstResponder];
        }
        
    } else {
        _textField.text = [_textField.text substringToIndex:6];
        [_textField resignFirstResponder];
    }
}

#pragma mark - 找回支付密码
- (void)findPayPwd{
    if (_textField.text.length <= 6) {
        _pwdStr = _textField.text;
        [self showPoint];
        if (_textField.text.length == 6) {//输入6位后
            if (_inputCount == 1) {
                [self performSelector:@selector(inputAgain) withObject:nil afterDelay:0.1];
            }
            
            if (_inputCount == 2) {
                [self passwordSetRequest];
            }
            [_textField resignFirstResponder];
        }
        
    } else {
        _textField.text = [_textField.text substringToIndex:6];
        [_textField resignFirstResponder];
    }
}

#pragma mark - 验证支付密码
- (void)validationPwd{
    if (_textField.text.length <= 6) {
        _pwdStr = _textField.text;
        [self showPoint];
        if (_textField.text.length == 6) {
            [self veriPwdCode];
            [_textField resignFirstResponder];
        }
    } else {
        _textField.text = [_textField.text substringToIndex:6];
        [_textField resignFirstResponder];
    }
}

#pragma mark - 验证支付密码 (修改密码要验证 绑卡要验证)
- (void)veriPwdCode{
    // 3DES加密
    NSString *passWord = [TripleDESUtils getEncryptWithString:_pwdStr keyString: [ZFGlobleManager getGlobleManager].securityKey ivString: @"01234567"];
    
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"payPassword": passWord,
                                 @"userKey":[ZFGlobleManager getGlobleManager].userKey,
                                 @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                                 @"txnType":@"42"};
    
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        
        //请求成功
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            if (_inputType == 3) {//二次绑卡
                ZFAddBankCardController *addVC = [[ZFAddBankCardController alloc] init];
                addVC.isFirst = NO;
                [self.navigationController pushViewController:addVC animated:YES];
                return ;
            }
            [self inputAgain];
        } else {
            _textField.text = @"";
            _pwdStr = @"";
            [self showPoint];
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
            [_textField becomeFirstResponder];
        }
        
    } failure:^(NSError *error) {
        //[[MBUtils sharedInstance] dismissMB];
        [_textField becomeFirstResponder];
    }];
}

#pragma mark - 设置密码网络请求
- (void)passwordSetRequest{
    if (![_firstPwd isEqualToString:_pwdStr]) {
        [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"两次输入的密码不一致", nil) inView:[UIApplication sharedApplication].keyWindow];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
        return;
    }
    
    // 3DES加密
    NSString *passWord = [TripleDESUtils getEncryptWithString:_firstPwd keyString: [ZFGlobleManager getGlobleManager].securityKey ivString: @"01234567"];
    NSString *confirmPwd = [TripleDESUtils getEncryptWithString:_pwdStr keyString: [ZFGlobleManager getGlobleManager].securityKey ivString: @"01234567"];
    
    NSDictionary *parameters;
    
    if (_inputType == 0 || _inputType == 4 || _inputType == 5) {//设置支付密码
        parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                       @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                       @"payPassword": passWord,
                       @"confirmPayPassword":confirmPwd,
                       @"userKey":[ZFGlobleManager getGlobleManager].userKey,
                       @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                       @"txnType":@"28"};
    } else {// 修改 和 找回 支付密码
        parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                       @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                       @"newPayPassword": confirmPwd,
                       @"userKey":[ZFGlobleManager getGlobleManager].userKey,
                       @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                       @"txnType":@"18"};
    }
    
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        
        //请求成功
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PayPwdAlreadySet];
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:[[UIApplication sharedApplication].windows firstObject]];
            if (_inputType == 4) {
                [self.navigationController popToRootViewControllerAnimated:YES];
                return ;
            }
            if (_inputType == 2) {
                NSMutableArray *vcArr = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];
                [self.navigationController popToViewController:vcArr[1] animated:YES];
                return;
            }
            if (_inputType == 5) {
                NSMutableArray *vcArr = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];
                [self.navigationController popToViewController:vcArr[vcArr.count-3] animated:YES];
                return;
            }
            
            [self jumpToSuccess];
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
        
    } failure:^(NSError *error) {
        //[[MBUtils sharedInstance] dismissMB];
    }];

}

#pragma mark 重新跳转此页面输入
- (void)inputAgain{
    ZFInputPwdController *inputVC = [[ZFInputPwdController alloc] init];
    inputVC.inputType = _inputType;
    inputVC.inputCount = _inputCount+1;
    inputVC.firstPwd = _pwdStr;
    [self.navigationController pushViewController:inputVC animated:NO];
}

#pragma mark 跳转到成功页
- (void)jumpToSuccess{
    ZFSuccessController *suVC = [[ZFSuccessController alloc] init];
    suVC.successType = _inputType;
    [self.navigationController pushViewController:suVC animated:YES];
}

#pragma mark 显示和隐藏黑点
- (void)showPoint{
    NSInteger i = _textField.text.length;
    for (NSInteger j = 0; j < 6; j++) {
        if (j < i) {
            [_pointArray[j] setHidden:NO];
        } else {
            [_pointArray[j] setHidden:YES];
        }
    }
}

#pragma mark 设置标题和显示内容
- (void)setTitleAndContent{
    if (_inputType == 0) {//设置支付密码
        if (_inputCount == 1) {
            self.myTitle = NSLocalizedString(@"设置支付密码", nil);
            self.messageLabel.text = NSLocalizedString(@"请输入6位支付密码", nil);
        } else {
            self.myTitle = NSLocalizedString(@"确认支付密码", nil);
            self.messageLabel.text = NSLocalizedString(@"请再次输入支付密码", nil);
        }
    }
    
    if (_inputType == 1) {//修改支付密码
        if (_inputCount == 1) {
            self.myTitle = NSLocalizedString(@"安全验证", nil);
            self.messageLabel.text = NSLocalizedString(@"请输入原支付密码，以验证身份", nil);
        }
        if (_inputCount == 2) {
            self.myTitle = NSLocalizedString(@"设置支付密码", nil);
            self.messageLabel.text = NSLocalizedString(@"请输入6位支付密码", nil);
        }
        if (_inputCount == 3) {
            self.myTitle = NSLocalizedString(@"确认支付密码", nil);
            self.messageLabel.text = NSLocalizedString(@"请再次输入支付密码", nil);
        }
    }
    
    if (_inputType == 2) {//找回支付密码
        if (_inputCount == 1) {
            self.myTitle = NSLocalizedString(@"设置支付密码", nil);
            self.messageLabel.text = NSLocalizedString(@"请输入6位支付密码", nil);
        } else {
            self.myTitle = NSLocalizedString(@"确认支付密码", nil);
            self.messageLabel.text = NSLocalizedString(@"请再次输入支付密码", nil);
        }
    }
    
    if (_inputType == 3) {
        self.myTitle = NSLocalizedString(@"安全验证", nil);
        self.messageLabel.text = NSLocalizedString(@"请输入支付密码，以验证身份", nil);
    }
    
    if (_inputType == 4 || _inputType == 5) {//首页和使用优惠券
        if (_inputCount == 1) {
            self.myTitle = NSLocalizedString(@"设置支付密码", nil);
            self.messageLabel.text = NSLocalizedString(@"请输入6位支付密码", nil);
        } else {
            self.myTitle = NSLocalizedString(@"确认支付密码", nil);
            self.messageLabel.text = NSLocalizedString(@"请再次输入支付密码", nil);
        }
    }
}


@end
