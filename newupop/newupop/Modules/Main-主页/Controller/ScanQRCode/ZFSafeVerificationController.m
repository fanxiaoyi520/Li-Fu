//
//  ZFSafeVerificationController.m
//  newupop
//
//  Created by 中付支付 on 2017/12/20.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFSafeVerificationController.h"
#import "ZFGetMSCodeController.h"

@interface ZFSafeVerificationController ()
///提示标签
@property (strong, nonatomic) UILabel *tipLabel;
///cvn
@property (nonatomic, strong)ZFBaseTextField *cvnTextField;
///有效期
@property (nonatomic, strong)ZFBaseTextField *expiredTextField;
///密码
@property (nonatomic, strong)ZFBaseTextField *pwTextField;

///验证码
@property (strong, nonatomic) ZFBaseTextField *codeTextField;
///获取验证码按钮
@property (strong, nonatomic) UIButton *getCodeBtn;

/** 指引视图 */
@property (nonatomic, weak) UIImageView *tipImageView;
/** 遮罩视图 */
@property (nonatomic, weak) UIView *darkView;

@property (nonatomic, strong)NSTimer *timer;
@property (nonatomic, assign)NSInteger downCount;

/** 必要参数 */
@property(nonatomic, strong) NSMutableDictionary *params;

@end

@implementation ZFSafeVerificationController

- (instancetype)initWithParams:(NSDictionary *)params {
    if (self = [super init]) {
        self.params = [NSMutableDictionary dictionaryWithDictionary:params];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myTitle = @"安全认证";
    if (!self.phoneNumber) {
        self.phoneNumber = [ZFGlobleManager getGlobleManager].userPhone;
    }
    
    [self createView];
}

#pragma mark 创建视图
- (void)createView{
    
    //顶部提示信息
//    _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 64+10, SCREEN_WIDTH - 40, 30)];
//    _tipLabel.font = [UIFont systemFontOfSize:12];
//    _tipLabel.textColor = [UIColor grayColor];
//    _tipLabel.numberOfLines = 0;
//    _tipLabel.text = [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"请输入收到的短信验证码", nil), [_phoneNum stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"]];
//    [self.view addSubview:_tipLabel];
    
    //有效期输入框
    _expiredTextField = [[ZFBaseTextField alloc] initWithFrame:CGRectMake(20, IPhoneXTopHeight+20, SCREEN_WIDTH-40, 40)];
    _expiredTextField.placeholder = @"MM/YY";
    _expiredTextField.font = [UIFont systemFontOfSize:14];
    _expiredTextField.keyboardType = UIKeyboardTypeNumberPad;
    _expiredTextField.secureTextEntry = YES;
    [_expiredTextField limitTextLength:4];
    
    UIView *rightViewBack1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 40)];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(0, 8, 24, 24);
    btn1.tag = 100;
    [btn1 addTarget:self action:@selector(showOrHidCVN:) forControlEvents:UIControlEventTouchUpInside];
    [btn1 setBackgroundImage:[UIImage imageNamed:@"showpassword_no"] forState:UIControlStateNormal];
    [btn1 setBackgroundImage:[UIImage imageNamed:@"showpassword_yes"] forState:UIControlStateSelected];
    [rightViewBack1 addSubview:btn1];
    
    UIButton *expiredBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    expiredBtn.frame = CGRectMake(30, 0, 40, 40);
    expiredBtn.tag = 2;
    [expiredBtn setImage:[UIImage imageNamed:@"icon_tips"] forState:UIControlStateNormal];
    [expiredBtn setImage:[UIImage imageNamed:@"icon_tips"] forState:UIControlStateHighlighted];
    [expiredBtn addTarget:self action:@selector(setupTipView:) forControlEvents:UIControlEventTouchUpInside];
    [rightViewBack1 addSubview:expiredBtn];
    
    _expiredTextField.rightViewMode = UITextFieldViewModeAlways;
    _expiredTextField.rightView = rightViewBack1;
    
    
    
    //cvn输入框
    _cvnTextField = [[ZFBaseTextField alloc] initWithFrame:CGRectMake(_expiredTextField.x, _expiredTextField.bottom+10, _expiredTextField.width, 40)];
    _cvnTextField.placeholder = NSLocalizedString(@"卡背后三位数字", nil);
    _cvnTextField.font = [UIFont systemFontOfSize:14];
    _cvnTextField.secureTextEntry = YES;
    [_cvnTextField limitTextLength:3];
    _cvnTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    UIView *rightViewBack = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 40)];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 8, 24, 24);
    btn.tag = 101;
    [btn addTarget:self action:@selector(showOrHidCVN:) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundImage:[UIImage imageNamed:@"showpassword_no"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"showpassword_yes"] forState:UIControlStateSelected];
    [rightViewBack addSubview:btn];
    
    UIButton *cvnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cvnBtn.frame = CGRectMake(30, 0, 40, 40);
    cvnBtn.tag = 1;
    [cvnBtn setImage:[UIImage imageNamed:@"icon_tips"] forState:UIControlStateNormal];
    [cvnBtn setImage:[UIImage imageNamed:@"icon_tips"] forState:UIControlStateHighlighted];
    [cvnBtn addTarget:self action:@selector(setupTipView:) forControlEvents:UIControlEventTouchUpInside];
    [rightViewBack addSubview:cvnBtn];
    
    _cvnTextField.rightViewMode = UITextFieldViewModeAlways;
    _cvnTextField.rightView = rightViewBack;
    
   
    
//    CGFloat codeY = 64+40;
//    if (_cardType == 1) {
        [self.view addSubview:_cvnTextField];
        [self.view addSubview:_expiredTextField];
//        codeY = _expiredTextField.bottom+10;
//        _tipLabel.y = codeY + 40;
//    }
//
//    //验证码输入框
//    _codeTextField = [[ZFBaseTextField alloc] initWithFrame:CGRectMake(20, codeY, SCREEN_WIDTH-215, 40)];
//    _codeTextField.keyboardType = UIKeyboardTypeNumberPad;
//    [_codeTextField limitTextLength:6];
//    _codeTextField.placeholder = NSLocalizedString(@"验证码", nil);
//    [self.view addSubview:_codeTextField];
//
//    //获取验证码按钮
//    _getCodeBtn = [[UIButton alloc] initWithFrame:CGRectMake(_codeTextField.right+15, _codeTextField.y, 160, 40)];
//    _getCodeBtn.backgroundColor = MainThemeColor;
//    _getCodeBtn.layer.cornerRadius = 5;
//    _getCodeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
//    [_getCodeBtn setTitle:NSLocalizedString(@"获取验证码", nil) forState:UIControlStateNormal];
//    [_getCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [_getCodeBtn addTarget:self action:@selector(getVeriCode) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_getCodeBtn];
    
    CGFloat heightY = _cvnTextField.bottom+45;
    
    // 需要输入支付密码
    if ([self.upModel.cvm containsObject:@"payPassword"]) {
        _pwTextField = [[ZFBaseTextField alloc] initWithFrame:CGRectMake(20, _cvnTextField.bottom+10, SCREEN_WIDTH-40, 40)];
        _pwTextField.placeholder = NSLocalizedString(@"银行卡预留手机支付密码", nil);
        _pwTextField.font = [UIFont systemFontOfSize:14];
        [_pwTextField limitTextLength:6];
        _pwTextField.keyboardType = UIKeyboardTypeNumberPad;
        [self.view addSubview:_pwTextField];
        heightY = _pwTextField.bottom+45;
    }
    
    //下一步按钮
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.frame = CGRectMake(20, heightY, SCREEN_WIDTH-40, 40);
    nextBtn.layer.cornerRadius = 5;
    nextBtn.backgroundColor = MainThemeColor;
    [nextBtn setTitle:NSLocalizedString(@"确认", nil) forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextBtn setTitleColor:ZFAlpColor(255, 255, 255, 0.7) forState:UIControlStateHighlighted];
    [nextBtn addTarget:self action:@selector(clickNextStepBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
}

- (void)showOrHidCVN:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (btn.tag == 100) {
        _expiredTextField.secureTextEntry = !btn.selected;
    }
    if (btn.tag == 101) {
        _cvnTextField.secureTextEntry = !btn.selected;
    }
}

//#pragma mark 获取验证码
//- (void)getVeriCode{
//
//}
//
//- (void)retextBtn{
//    _downCount--;
//    NSString *str = NSLocalizedString(@"后重新获取", nil);
//    if ([str hasPrefix:@"后"]) {
//        [_getCodeBtn setTitle:[NSString stringWithFormat:@"%zds后重新获取", _downCount] forState:UIControlStateNormal];
//    } else {
//        [_getCodeBtn setTitle:[NSString stringWithFormat:@"%@ %zds", str, _downCount] forState:UIControlStateNormal];
//    }
//    if (_downCount == 0) {
//        _getCodeBtn.enabled = YES;
//        [_getCodeBtn setTitle:NSLocalizedString(@"重新获取", nil) forState:UIControlStateNormal];
//        [_timer invalidate];
//        _timer = nil;
//    }
//}

#pragma mark -- 点击方法
- (void)clickNextStepBtn {
    
    [self.view endEditing:YES];
    NSString *cvnStr = _cvnTextField.text;
    NSString *expiredStr = _expiredTextField.text;
    
    //安全码
    if(!cvnStr || cvnStr.length < 3){
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"银行卡安全码输入有误", nil) inView:self.view];
        return ;
    }
    
    //有效期
    if(!expiredStr || expiredStr.length < 4){
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"银行卡有效期输入有误", nil) inView:self.view];
        return ;
    }
    
    [self bondBankCardAction];
}

#pragma mark -- 网络请求
- (void)bondBankCardAction {
    NSString *encryCvn = [TripleDESUtils getEncryptWithString:_cvnTextField.text keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    
    //后台有效期格式 年月
    NSString *exchange = [NSString stringWithFormat:@"%@%@", [_expiredTextField.text substringFromIndex:2], [_expiredTextField.text substringToIndex:2]];
    NSString *encryEx = [TripleDESUtils getEncryptWithString:exchange keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    [[MBUtils sharedInstance] showMBInView:self.view];
    
    [self.params setObject:encryCvn forKey:@"cvn2"];
    [self.params setObject:encryEx forKey:@"expired"];
    
    if (self.upModel.enrolID) { // 如果有enrolID肯定是银联国际卡
        [self.params setObject:self.upModel.enrolID forKey:@"enrolID"];
        [self.params setObject:self.upModel.tncID forKey:@"tncID"];
        
        NSString *cvm = @"";
        for (NSString *str in self.upModel.cvm) {
            cvm = [[cvm stringByAppendingString:str] stringByAppendingString:@"&"];
        }
        [self.params setObject:cvm forKey:@"cvm"];
        [self.params setObject:@"53" forKey:@"txnType"];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [NetworkEngine singlePostWithParmas:self.params success:^(id requestResult) {
            [[MBUtils sharedInstance] dismissMB];
            
            if ([[requestResult objectForKey:@"status"] isEqualToString:@"79"] && !self.upModel.enrolID) {//79时不需要验证码 直接调绑卡
                // 验证码界面
                ZFGetMSCodeController *vc = [[ZFGetMSCodeController alloc] initWithParams:self.params];
                vc.phoneNumber = self.phoneNumber;
                vc.orderId = [requestResult objectForKey:@"orderId"];
                vc.status = [requestResult objectForKey:@"status"];
                [self pushViewController:vc];
                return ;
            }
            
            if (![[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
                [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
                return ;
            }
            
            if (self.upModel.enrolID) {
                // 判断otp是否为空
                if ([[requestResult objectForKey:@"otpMethod"] isKindOfClass:[NSNull class]]) {
                    // 验证码也不需要，直接查绑定结果
                    [self addUNCard];
                } else {
                    // 获取验证码
                    [self getUNMessageCode:[[requestResult objectForKey:@"otpMethod"] firstObject]];
                }
            } else {
                // 验证码界面
                ZFGetMSCodeController *vc = [[ZFGetMSCodeController alloc] initWithParams:self.params];
                vc.phoneNumber = self.phoneNumber;
                vc.orderId = [requestResult objectForKey:@"orderId"];
                [self pushViewController:vc];
            }
        } failure:^(NSError *error) {
            
        }];
    });
}


// 银联国际：不需要验证码,直接绑定  55
- (void)addUNCard {
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"userKey":[ZFGlobleManager getGlobleManager].userKey,
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"enrolID":self.upModel.enrolID,
                                 @"cardNum": self.bcModel.encryCardNo,
                                 @"tncID":self.upModel.tncID,
                                 @"otpValue":@"",
                                 @"txnType": @"55"};
    
    [[MBUtils sharedInstance] showMBInView:self.view];
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self bondSuccess];
            });
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
            return ;
        }
    } failure:^(id error) {
        
    }];
}

// 银联国际：获取验证码 54
- (void)getUNMessageCode:(NSString *)otpMethod {
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"userKey":[ZFGlobleManager getGlobleManager].userKey,
                                 @"enrolID":self.upModel.enrolID,
                                 @"otpMethod":otpMethod,
                                 @"txnType": @"54"};
    
    [[MBUtils sharedInstance] showMBInView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if (![[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
            return ;
        }
        
        ZFGetMSCodeController *vc = [[ZFGetMSCodeController alloc] initWithBankCardModel:self.bcModel UPBankCardModel:self.upModel];
        vc.phoneNumber = self.bcModel.phoneNumber;
        vc.otpMethod = otpMethod;
        [self pushViewController:vc];
    } failure:^(NSError *error) {
        
    }];
}



#pragma mark - 其他方法
- (void)setupTipView:(UIButton *)sender {
    [self.view endEditing:YES];
    // 遮罩
    UIView *darkView = [[UIView alloc] init];
    darkView.alpha = 0.5;
    darkView.hidden = NO;
    darkView.backgroundColor = ZFColor(46, 49, 50);
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    darkView.frame = keyWindow.bounds;
    [keyWindow addSubview:darkView];
    self.darkView = darkView;
    
    UIImageView *tipImageView = [[UIImageView alloc] init];
    tipImageView.image = sender.tag == 1 ? [UIImage imageNamed:@"pic_tips_anquanma_no_word"] : [UIImage imageNamed:@"pic_tips_youxiaoriqi_no_word"];
    tipImageView.width = SCREEN_WIDTH-110;
    tipImageView.height = tipImageView.width*0.6;
    tipImageView.x = 55;
    tipImageView.y = (SCREEN_HEIGHT-tipImageView.height)/2-30;
    tipImageView.hidden = NO;
    [keyWindow addSubview:tipImageView];
    self.tipImageView = tipImageView;
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, tipImageView.width*0.6-50, tipImageView.width, 50)];
    tipLabel.text = sender.tag == 1 ? NSLocalizedString(@"卡背面三位数字", nil) : @"MM/YY";
    tipLabel.textColor = MainFontColor;
    tipLabel.font = [UIFont systemFontOfSize:14.0];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [tipImageView addSubview:tipLabel];
    
    // 添加点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [tap addTarget:self action:@selector(darkViewClicked)];
    [darkView addGestureRecognizer:tap];
}

- (void)darkViewClicked {
    [UIView animateWithDuration:1.0 animations:^{
        self.darkView.hidden = YES;
        self.tipImageView.hidden = YES;
    }];
}


// 绑定成功，返回
- (void)bondSuccess {
    if (![ZFGlobleManager getGlobleManager].notNeedShowSuccess) {
        [ZFGlobleManager getGlobleManager].notNeedShowSuccess = NO;
        [[MBUtils sharedInstance] showMBSuccessdWithText:NSLocalizedString(@"认证成功", nil) inView:self.view];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(AUTOTIPDISMISSTIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 返回银行卡列表页面
        [ZFGlobleManager getGlobleManager].isChanged = YES;
        [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
    });
}

@end
