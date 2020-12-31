//
//  ZFSetLoginPwdController.m
//  newupop
//
//  Created by 中付支付 on 2017/7/21.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFSetLoginPwdController.h"
#import "SmallUtils.h"
#import "TripleDESUtils.h"
#import "UniversallyUniqueIdentifier.h"
#import "HBRSAHandler.h"
#import "ZFSuccessController.h"
#import "ZFNavigationController.h"

@interface ZFSetLoginPwdController ()
///原密码
@property (nonatomic, strong)UITextField *passWord;
///密码
@property (nonatomic, strong)UITextField *passWord1;
///确认密码
@property (nonatomic, strong)UITextField *passWord2;
///确认按钮
@property (nonatomic, strong)UIButton *confirmBtn;
///错误提示标签
@property (nonatomic, strong)UILabel *tipLabel;

@end

@implementation ZFSetLoginPwdController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myTitle = @"设置登录密码";
    if (_type == 1) {
        self.myTitle = @"修改登录密码";
    }
    self.view.backgroundColor = GrayBgColor;
    [self createView];
}

- (void)createView{
    
    //底部背景
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight+20, SCREEN_WIDTH, 81)];
    backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backView];
    
    //原密码label
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 25)];
    view1.backgroundColor = GrayBgColor;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 15)];
    label.text = NSLocalizedString(@"原密码", nil);
    label.font = [UIFont systemFontOfSize:15];
    [view1 addSubview:label];
    
    //原密码
    _passWord = [[UITextField alloc] initWithFrame:CGRectMake(20, label.bottom+10, SCREEN_WIDTH-40, 40)];
    _passWord.placeholder = NSLocalizedString(@"请输入原密码", nil);
    _passWord.clearButtonMode = UITextFieldViewModeWhileEditing;
    _passWord.font = [UIFont systemFontOfSize:15];
    _passWord.secureTextEntry = YES;
    
    //新密码label
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, _passWord.bottom, SCREEN_WIDTH, 45)];
    view2.backgroundColor = GrayBgColor;
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 200, 15)];
    label2.text = NSLocalizedString(@"新密码", nil);
    label2.font = [UIFont systemFontOfSize:15];
    [view2 addSubview:label2];
    
    CGFloat y1 = 0;
    if (_type == 1) {
        [backView addSubview:view1];
        [backView addSubview:_passWord];
        [backView addSubview:view2];
        y1 = view2.bottom;
        backView.size = CGSizeMake(SCREEN_WIDTH, 190);
    }
    
    //密码
    _passWord1 = [[UITextField alloc] initWithFrame:CGRectMake(20, y1, SCREEN_WIDTH-40, 40)];
    _passWord1.placeholder = NSLocalizedString(@"请输入登录密码", nil);
    _passWord1.clearButtonMode = UITextFieldViewModeWhileEditing;
    _passWord1.secureTextEntry = YES;
    _passWord1.font = [UIFont systemFontOfSize:15];
    [backView addSubview:_passWord1];
    
    //中间横线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, _passWord1.bottom, SCREEN_WIDTH, 1)];
    lineView.backgroundColor = GrayBgColor;
    [backView addSubview:lineView];
    
    //确认密码
    _passWord2 = [[UITextField alloc] initWithFrame:CGRectMake(_passWord1.x, _passWord1.bottom+1, _passWord1.width, _passWord1.height)];
    _passWord2.placeholder = NSLocalizedString(@"请再次输入", nil);
    _passWord2.clearButtonMode = UITextFieldViewModeWhileEditing;
    _passWord2.secureTextEntry = YES;
    _passWord2.font = [UIFont systemFontOfSize:15];
    [backView addSubview:_passWord2];
    
    //错误提示标签
    _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, backView.bottom+5, _passWord2.width, 20)];
    _tipLabel.textColor = [UIColor grayColor];
    _tipLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:_tipLabel];

    //确认按钮
    _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _confirmBtn.frame = CGRectMake(20, backView.bottom+44, SCREEN_WIDTH-40, 40);
    [_confirmBtn setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
    [_confirmBtn addTarget:self action:@selector(clickCOnfirmBtn) forControlEvents:UIControlEventTouchUpInside];
    _confirmBtn.layer.cornerRadius = 5.0;
    [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _confirmBtn.backgroundColor = MainThemeColor;
    [self.view addSubview:_confirmBtn];
}

- (void)clickCOnfirmBtn{
    if (_type == 1) {
        if (_passWord.text.length < 6 || _passWord.text.length > 20) {
            _tipLabel.text = NSLocalizedString(@"原密码输入错误", nil);
            return;
        }
    }
    
    if (_passWord1.text.length < 6 || _passWord1.text.length > 20) {
        _tipLabel.text = NSLocalizedString(@"请输入6-20位登录密码", nil);
        return;
    }
    
    if (![_passWord1.text isEqualToString:_passWord2.text]) {
        _tipLabel.text = NSLocalizedString(@"两次输入的密码不一致", nil);
        return;
    }
    _tipLabel.text = @"";
    
    [self resetPwd];
}

#pragma mark 修改密码
- (void)resetPwd{
    UniversallyUniqueIdentifier *uuid = [UniversallyUniqueIdentifier sharedInstance];
    
    // 3DES加密
    NSString *password = _passWord1.text;
    
    //登录前和登录后的key不一样 
    NSString *key = [ZFGlobleManager getGlobleManager].tempSecurityKey;
    if (_type == 1) {
        key = [ZFGlobleManager getGlobleManager].securityKey;
    }
    
    //原密码
    NSString *originPwd = [TripleDESUtils getEncryptWithString:_passWord.text keyString:key ivString:@"01234567"];
    
    NSString *encrypptpasswordString = [TripleDESUtils getEncryptWithString:password keyString: key ivString: @"01234567"];
    
    NSDictionary *parameters ;
    if (_type == 0) {//注册时设置密码
        parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                       @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                       @"txnType": @"45",
                       @"password":encrypptpasswordString,
                       @"signType":@"1",
                       @"tempSessionID":[ZFGlobleManager getGlobleManager].tempSessionID};
    }
    if (_type == 1) {//个人中心设置密码
        parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                       @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                       @"txnType": @"09",
                       @"password":originPwd,
                       @"newPassword":encrypptpasswordString,
                       @"userKey":uuid.uuid,
                       @"sessionID":[ZFGlobleManager getGlobleManager].sessionID};
    }
    if (_type == 2) {//忘记密码设置密码
        parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                       @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                       @"txnType": @"05",
                       @"newPassword":encrypptpasswordString,
                       @"userKey":uuid.uuid,
                       @"tempSessionID":[ZFGlobleManager getGlobleManager].tempSessionID};
    }
    
    
    [[MBUtils sharedInstance] showMBInView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        //[[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[MBUtils sharedInstance] dismissMB];
            if (_type == 0) {
                [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:[[UIApplication sharedApplication].windows firstObject]];
                [self.navigationController popToRootViewControllerAnimated:YES];
                return ;
            }
            
            if (_type == 1) {//修改成功后退出登录
                [self exitLogin];
                return ;
            }
            ZFSuccessController *suVC = [[ZFSuccessController alloc] init];
            suVC.successType = 3;
            [self.navigationController pushViewController:suVC animated:YES];
            
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
        
    } failure:^(NSError *error) {
        //[[MBUtils sharedInstance] dismissMB];
        
    }];
}

//退出登录
- (void)exitLogin{
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                                 @"txnType": @"26"};
    
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            //清空信息
            [[ZFGlobleManager getGlobleManager] clearInfo];
            //清除密码
            [[ZFGlobleManager getGlobleManager] saveLoginPwd:@""];
            //[ZFGlobleManager getGlobleManager].loginVC.pwdTextField.text = @"";
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            window.rootViewController = [[ZFNavigationController alloc] initWithRootViewController:[ZFGlobleManager getGlobleManager].loginVC];
            [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"修改密码成功", nil) inView:[[UIApplication sharedApplication].windows firstObject]];
            
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(NSError *error) {
        //[[MBUtils sharedInstance] dismissMB];
        
    }];
}

@end
