//
//  ZFValidatePwdController.m
//  newupop
//
//  Created by 中付支付 on 2017/11/8.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFValidatePwdController.h"
#import "ZFPwdInputView.h"
#import "ZFGenerateQRCodeController.h"
#import "ZFOfflineQRCodeController.h"
#import "IQKeyboardManager.h"
#import "ZFGetVerCodeController.h"
#import "ZFAddCardNoViewController.h"

@interface ZFValidatePwdController ()<InputPwdDelegate>

///输入密码控件
@property (nonatomic, strong)ZFPwdInputView *pwdView;
///密码
@property (nonatomic, strong)NSString *passWord;

@end

@implementation ZFValidatePwdController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myTitle = @"安全验证";
    self.view.backgroundColor = GrayBgColor;
    [self createView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [_pwdView.textField becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
}

- (void)createView{
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 60+64, SCREEN_WIDTH-40, 40)];
    tipLabel.text = NSLocalizedString(@"请输入支付密码，以验证身份", nil);
    tipLabel.font = [UIFont systemFontOfSize:15];
    tipLabel.numberOfLines = 0;
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipLabel];
    
    _pwdView = [[ZFPwdInputView alloc] initWithFrame:CGRectMake(40, tipLabel.bottom+30, SCREEN_WIDTH-80, 45)];
    _pwdView.delegate = self;
    [self.view addSubview:_pwdView];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-140, _pwdView.bottom+20, 100, 20)];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [button setTitle:NSLocalizedString(@"忘记密码", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickForgetBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)clickForgetBtn{
    ZFGetVerCodeController *gcVC = [[ZFGetVerCodeController alloc] init];
    gcVC.getCodeType = 1;
    [self.navigationController pushViewController:gcVC animated:YES];
}

- (void)inputString:(NSString *)password{
    if (password.length == 6) {
        
//        BOOL isOK = [[NSUserDefaults standardUserDefaults] boolForKey:NETWORK_ISOK];
        _passWord = password;
        if (_fromType == 1 || _fromType == 2 || _fromType == 3) {
            [self veriPwdCode];
        } else {
//            if (isOK) {//有网络
                [self veriPwdCode];
//            } else {
//                ZFOfflineQRCodeController *offVC = [[ZFOfflineQRCodeController alloc] init];
//                offVC.passWord = password;
//                [self.navigationController pushViewController:offVC animated:YES];
//            }
        }
    }
}

#pragma mark - 验证支付密码 (修改密码要验证 绑卡要验证)
- (void)veriPwdCode{
    // 3DES加密
    NSString *passWord = [TripleDESUtils getEncryptWithString:_passWord keyString: [ZFGlobleManager getGlobleManager].securityKey ivString: @"01234567"];
    
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
            if (_fromType == 2 || _fromType == 3) {
                [self addBankCard];
                return ;
            }
            
            ZFGenerateQRCodeController *generateVC = [[ZFGenerateQRCodeController alloc] init];
            generateVC.passWord = passWord;
            generateVC.couponID = @"";
            if (_fromType == 1) {
                generateVC.fromType = 1;
                generateVC.couponID = _couponID;
            }
            [self.navigationController pushViewController:generateVC animated:YES];
        } else {
            _pwdView.textField.text = @"";
            [_pwdView inputPwd];
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
            [_pwdView.textField becomeFirstResponder];
        }
        
    } failure:^(NSError *error) {
        _pwdView.textField.text = @"";
        [_pwdView inputPwd];
    }];
}


// 添加银行卡
- (void)addBankCard {
//    ZFSelectCardTypeController *selVC = [[ZFSelectCardTypeController alloc] init];
//    [self.navigationController pushViewController:selVC animated:YES];
    
    ZFAddCardNoViewController *acnvc = [[ZFAddCardNoViewController alloc] init];
    [self pushViewController:acnvc];
    
    // 移除当前控制前
    NSMutableArray *tempMArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [tempMArray removeObject:self];
    [self.navigationController setViewControllers:tempMArray animated:NO];
}

@end
