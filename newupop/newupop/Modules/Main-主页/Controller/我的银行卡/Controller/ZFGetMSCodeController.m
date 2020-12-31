//
//  ZFGetMSCodeController.m
//  newupop
//
//  Created by 中付支付 on 2017/9/8.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFGetMSCodeController.h"
#import "NSString+Extension.h"


@interface ZFGetMSCodeController () <UITextFieldDelegate>

@property (nonatomic, strong)ZFBaseTextField *codeTextField;
@property (nonatomic, strong)UIButton *getCodeBtn;

@property (nonatomic, strong)NSTimer *timer;
@property (nonatomic, assign)NSInteger downCount;

/** 必要参数 */
@property(nonatomic, strong) NSDictionary *params;

/** 传过来的银行卡模型 */
@property(nonatomic, strong) ZFBankCardModel *bcModel;
/** 银联国际返回的cvm模型 */
@property(nonatomic, strong) ZFUPBankCardModel *upModel;
@end

@implementation ZFGetMSCodeController

- (instancetype)initWithParams:(NSDictionary *)params {
    if (self = [super init]) {
        self.params = params;
    }
    return self;
}

- (instancetype)initWithBankCardModel:(ZFBankCardModel *)bcModel UPBankCardModel:(ZFUPBankCardModel *)upModel {
    if (self = [super init]) {
        self.bcModel = bcModel;
        self.upModel = upModel;
        self.phoneNumber = self.bcModel.phoneNumber;
    }
    return self;
}

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myTitle = @"安全认证";
    
    
    if ([self.status isEqualToString:@"79"]) {
        [self notNeedCode];
        return;
    }
    
    [self createView];
    [self startTimer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![self.status isEqualToString:@"79"]) {
        [_codeTextField becomeFirstResponder];
    }
}

- (void)dealloc {
    [_timer invalidate];
    _timer = nil;
}

- (void)notNeedCode{
    [self bondBankCardAction];
//    [XLAlertController acWithMessage:NSLocalizedString(@"此银行卡不需短信验证", nil) confirmBtnTitle:NSLocalizedString(@"确定", nil) confirmAction:^(UIAlertAction *action) {
//        [self bondBankCardAction];
//    }];
}

#pragma mark - 初始化视图
- (void)createView{
    NSString *phoneNum = self.phoneNumber;
    
    UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, IPhoneXTopHeight+10, SCREEN_WIDTH - 40, 30)];
    phoneLabel.font = [UIFont systemFontOfSize:12];
    phoneLabel.textColor = [UIColor grayColor];
    phoneLabel.numberOfLines = 0;
    phoneLabel.text = [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"请输入收到的短信验证码", nil), [phoneNum stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"]];
    [self.view addSubview:phoneLabel];
    
    _codeTextField = [[ZFBaseTextField alloc] initWithFrame:CGRectMake(20, phoneLabel.bottom+10, SCREEN_WIDTH-215, 40)];
    _codeTextField.keyboardType = UIKeyboardTypeNumberPad;
    _codeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_codeTextField limitTextLength:6];
    _codeTextField.placeholder = NSLocalizedString(@"验证码", nil);
    _codeTextField.delegate = self;
    _codeTextField.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:_codeTextField];
    
    _getCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _getCodeBtn.frame = CGRectMake(_codeTextField.right+15, _codeTextField.y, 160, 40);
    _getCodeBtn.layer.cornerRadius = 5;
    _getCodeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_getCodeBtn setTitle:NSLocalizedString(@"获取验证码", nil) forState:UIControlStateNormal];
    [_getCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_getCodeBtn setBackgroundColor:MainThemeColor];
    [_getCodeBtn addTarget:self action:@selector(clickGetCodeBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_getCodeBtn];
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.frame = CGRectMake(20, _getCodeBtn.bottom+45, SCREEN_WIDTH-40, 40);
    nextBtn.layer.cornerRadius = 5;
    nextBtn.backgroundColor = MainThemeColor;
    [nextBtn setTitle:NSLocalizedString(@"下一步", nil) forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextBtn setTitleColor:ZFAlpColor(255, 255, 255, 0.7) forState:UIControlStateHighlighted];
    [nextBtn addTarget:self action:@selector(clickNextStepBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
}

#pragma mark -- 点击方法
// 获取验证码
- (void)clickGetCodeBtn {
    if (self.upModel.enrolID) { // 说明是银联国际卡
        [self getUNMessageCode:self.otpMethod];
    } else { // 其他地区获取验证码
        [[MBUtils sharedInstance] showMBInView:self.view];
        [NetworkEngine singlePostWithParmas:self.params success:^(id requestResult) {
            [[MBUtils sharedInstance] dismissMB];
            
            if ([[requestResult objectForKey:@"status"] isEqualToString:@"79"]) {
                // 设置获取验证码按钮状态
                _orderId = [requestResult objectForKey:@"orderId"];
                [self notNeedCode];
                return ;
            }
            
            if (![[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
                [XLAlertController acWithMessage:[requestResult objectForKey:@"msg"] confirmBtnTitle:NSLocalizedString(@"确定", nil) confirmAction:^(UIAlertAction *action) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                return ;
            }
            
            // 设置获取验证码按钮状态
            [self setupBtnStatusOfSendMsg:[requestResult objectForKey:@"orderId"]];
            
        } failure:^(NSError *error) {
            
        }];
    }
}

- (void)clickNextStepBtn {
    [self.view endEditing:YES];
    
    if ([self.status isEqualToString:@"79"]) {
        [self bondBankCardAction];
        return;
    }
    
    if (_codeTextField.text.length != 6) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"验证码输入错误", nil) inView:self.view];
        return;
    }
    if (self.upModel.enrolID) { // 说明是银联国际卡
        [self addUNCard];
    } else {
        [self bondBankCardAction];
    }
}

#pragma mark -- 网络请求
- (void)bondBankCardAction {
    NSString *smsCode = _codeTextField.text;
    if ([self.status isEqualToString:@"79"]) {
        smsCode = @"";
    }
    if (!_orderId) {
        _orderId = @"";
    }
    
    NSMutableDictionary *mParams = [NSMutableDictionary dictionaryWithDictionary:self.params];
    [mParams setObject:_orderId forKey:@"orderId"];
    [mParams setObject:smsCode forKey:@"smsCode"];
    [mParams setObject:@"10" forKey:@"txnType"];
    
    [[MBUtils sharedInstance] showMBInView:self.view];
    dispatch_async(dispatch_get_main_queue(), ^{
        [NetworkEngine singlePostWithParmas:mParams success:^(id requestResult) {
            [[MBUtils sharedInstance] dismissMB];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
                    [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
                    return ;
                }
                [self bondSuccess];
            });
        } failure:^(NSError *error) {
            
        }];
    });
}

// 银联国际：不需要验证码,直接绑定  55
- (void)addUNCard {
    
    // TODO卡号暂时写死
//    NSString *encryCardNo = [TripleDESUtils getEncryptWithString:@"6234154000000018" keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"userKey":[ZFGlobleManager getGlobleManager].userKey,
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"enrolID":self.upModel.enrolID,
                                 @"cardNum": self.bcModel.encryCardNo,
                                 @"tncID":self.upModel.tncID,
                                 @"otpValue":_codeTextField.text,
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
        
        // 设置获取验证码按钮状态
        [self setupBtnStatusOfSendMsg:@""];
    } failure:^(NSError *error) {
        
    }];
}


#pragma mark - 其他方法
- (void)startTimer {
    _getCodeBtn.enabled = NO;
    _downCount = 60;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(retextBtn) userInfo:nil repeats:YES];
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
    }
}

// 发送成功之后的按钮状态
- (void)setupBtnStatusOfSendMsg:(NSString *)orderId
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _orderId = orderId;
        _getCodeBtn.enabled = NO;
        _downCount = 60;
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(retextBtn) userInfo:nil repeats:YES];
        [_codeTextField becomeFirstResponder];
    });
}

- (void)bondSuccess {
    if (![ZFGlobleManager getGlobleManager].notNeedShowSuccess) {
        [ZFGlobleManager getGlobleManager].notNeedShowSuccess = NO;
        
        if (self.upModel.enrolID || [self.params[@"isAgain"] isEqualToString:@"yes"]) {
            [[MBUtils sharedInstance] showMBSuccessdWithText:NSLocalizedString(@"认证成功", nil) inView:self.view];
        } else {
            [[MBUtils sharedInstance] showMBSuccessdWithText:NSLocalizedString(@"银行卡绑定成功", nil) inView:self.view];
        }
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(AUTOTIPDISMISSTIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 返回银行卡列表页面
        [ZFGlobleManager getGlobleManager].isChanged = YES;
        if ([ZFGlobleManager getGlobleManager].addCardFromType == 1) {//从首页绑卡
            [ZFGlobleManager getGlobleManager].addCardFromType = 0;
            [self.navigationController popToRootViewControllerAnimated:YES];
            return ;
        }
        [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
    });
}

// return按钮
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self clickNextStepBtn];
    
    return YES;
}


//#pragma mark 银联卡获取验证码
//- (void)getUNMessageCode{
//
//    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
//                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
//                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
//                                 @"userKey":[ZFGlobleManager getGlobleManager].userKey,
//                                 @"enrolID":[ZFGlobleManager getGlobleManager].enrolID,
//                                 @"otpMethod":[ZFGlobleManager getGlobleManager].otpMethod,
//                                 @"txnType": @"54"};
//
//    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
//
//    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
//        [[MBUtils sharedInstance] dismissMB];
//        if (![[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
//            [XLAlertController acWithMessage:[requestResult objectForKey:@"msg"] confirmBtnTitle:@"" confirmAction:^(UIAlertAction *action) {
//                [self.navigationController popViewControllerAnimated:YES];
//            }];
//            return ;
//        }
//        _getCodeBtn.enabled = NO;
//        _downCount = 60;
//        [self retextBtn];
//        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(retextBtn) userInfo:nil repeats:YES];
//        [_codeTextField becomeFirstResponder];
//
//    } failure:^(NSError *error) {
//
//    }];
//}
//
//#pragma mark 绑定银联卡
//- (void)addUNCard{
//    //加密
//    NSString *cardNumEncry = [TripleDESUtils getEncryptWithString:[ZFGlobleManager getGlobleManager].cardNum keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
//
//    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
//                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
//                                 @"userKey": [ZFGlobleManager getGlobleManager].userKey,
//                                 @"enrolID":[ZFGlobleManager getGlobleManager].enrolID,
//                                 @"cardNum":cardNumEncry,
//                                 @"tncID":[ZFGlobleManager getGlobleManager].tncID,
//                                 @"otpValue":_codeTextField.text,
//                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
//                                 @"txnType": @"55"};
//    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
//    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
//        [[MBUtils sharedInstance] dismissMB];
//        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
//            [self addCardSuccess];
//        } else {
//            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
//        }
//
//    } failure:^(id error) {
//
//    }];
//}

@end
