//
//  ZFLoginViewController.m
//  newupop
//
//  Created by 中付支付 on 2017/7/21.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFLoginViewController.h"
#import "ZFRegisterViewController.h"
#import "ZFMainViewController.h"
#import "ZFNavigationController.h"
#import "ZFForgetLoginPwdController.h"
#import "HBRSAHandler.h"
#import "LocationUtils.h"
#import "TripleDESUtils.h"
#import "SmallUtils.h"
#import "UniversallyUniqueIdentifier.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "ZFTabBarController.h"
#import <CommonCrypto/CommonDigest.h>
#import "IQUIView+Hierarchy.h"
#import "ZFReadProtocolController.h"
#import "NUCountryInfo.h"
#import "YYModel.h"
#import "ZFVCodeLoginViewController.h"
#import "ZFFingerprintLoginViewController.h"

@interface ZFLoginViewController () <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

///用户名
@property (nonatomic, strong)ZFBaseTextField *userTextField;

///区号
@property (nonatomic, strong)ZFBaseTextField *areaTextField;
///真实姓名
@property (nonatomic, strong)ZFBaseTextField *realNameTextField;
/// 支持的手机号码国家/地区代码
@property(nonatomic,strong) NSMutableArray *areaArray;
///区域选择
@property(nonatomic,strong) UIPickerView *pickerView;
///区域工具栏
@property(nonatomic,strong) UIToolbar *toolbar;

@property (nonatomic, strong) NSString *securityKey;
@property (nonatomic, strong) NSString *tempSessionID;

///
@property (nonatomic, strong)UIButton *registerBtn;
@property (nonatomic, strong)UIButton *loginBtn;
//@property (nonatomic, strong)UIButton *codeLoginBtn;
@property (nonatomic, strong)UIButton *forgetBtn;
@property (nonatomic, strong)UIImageView *topImageView;

@property (nonatomic, strong)UIBarButtonItem *doneBBI;
@property (nonatomic, strong)UIBarButtonItem *textBBI;
@property (nonatomic ,strong)UIButton *countDownBtn;
@property (strong, nonatomic)CountDown *countDownForBtn;
@property (nonatomic ,strong)UIButton *cancelBtn;
@property (nonatomic ,strong)NSString *isFirstLogin;

@end

@implementation ZFLoginViewController
- (void)dealloc {
    [self.countDownForBtn destoryTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self createView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeText) name:CHANGE_LANGUAGE object:nil];
    [self createAgreeTipView];
}

//push过来返回的按钮
- (void)cancelBtnAction:(UIButton *)sender {
    if ([_isPushStr isEqualToString:@"1"]) {
        ZFFingerprintLoginViewController *loginVC = [[ZFFingerprintLoginViewController alloc] init];
        ZFNavigationController *navi = [[ZFNavigationController alloc] initWithRootViewController:loginVC];
        [UIApplication sharedApplication].keyWindow.rootViewController = navi;
    } else {
        ZFVCodeLoginViewController *loginVC = [[ZFVCodeLoginViewController alloc] init];
        loginVC.isPushStr = @"0";
        ZFNavigationController *navi = [[ZFNavigationController alloc] initWithRootViewController:loginVC];
        [UIApplication sharedApplication].keyWindow.rootViewController = navi;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([_isPushStr isEqualToString:@"1"] || [_isPushStr isEqualToString:@"2"]) {
        self.cancelBtn.hidden = NO;
    } else {
        self.cancelBtn.hidden = YES;
    }
    _pwdTextField.text = @"";
    [_countDownForBtn destoryTimer];
    CGRect countDownRect = [[ZFGlobleManager getGlobleManager] getStringWidthAndHeightWithStr:NSLocalizedString(@"发送验证码", nil) withFont:[UIFont fontWithName:@"PingFangSC-Regular" size:14]];
    _pwdTextField.frame = CGRectMake(_areaTextField.x, _userTextField.bottom+10, SCREEN_WIDTH-40-countDownRect.size.width-30, _userTextField.height);
    _countDownBtn.frame = CGRectMake(_pwdTextField.right + 10, _userTextField.bottom+10, countDownRect.size.width+20, _userTextField.height);
    self.countDownBtn.enabled = YES;
    self.countDownBtn.backgroundColor = [UIColor colorWithRed:74/255.0 green:144/255.0 blue:226/255.0 alpha:1/1.0];
    [self.countDownBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.countDownBtn setTitle:NSLocalizedString(@"发送验证码",nil) forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
}

#pragma mark 切换语言时重新赋值
- (void)changeText{
    //self.myTitle = @"登录";
    [_registerBtn setTitle:NSLocalizedString(@"注册", nil) forState:UIControlStateNormal];
    _userTextField.placeholder = NSLocalizedString(@"手机号", nil);
    _pwdTextField.placeholder = NSLocalizedString(@"验证码", nil);
    [_loginBtn setTitle:NSLocalizedString(@"登录", nil) forState:UIControlStateNormal];
    [_forgetBtn setTitle:NSLocalizedString(@"忘记密码", nil) forState:UIControlStateNormal];
    _topImageView.image = [UIImage imageNamed:NSLocalizedString(@"pic_sign_in_background_chinese", @"登录顶部图片")];
    [_textBBI setTitle:NSLocalizedString(@"请选择手机区号", nil)];
    [_doneBBI setTitle:NSLocalizedString(@"确定", nil)];
    [_countDownBtn setTitle:NSLocalizedString(@"发送验证码",nil) forState:UIControlStateNormal];
    _realNameTextField.placeholder = NSLocalizedString(@"真实姓名", nil);
    [self getCountryCode:2];
    [self createAgreeTipView];
    
    CGRect countDownRect = [[ZFGlobleManager getGlobleManager] getStringWidthAndHeightWithStr:NSLocalizedString(@"发送验证码", nil) withFont:[UIFont fontWithName:@"PingFangSC-Regular" size:14]];
    _pwdTextField.frame = CGRectMake(_areaTextField.x, _userTextField.bottom+10, SCREEN_WIDTH-40-countDownRect.size.width-30, _userTextField.height);
    self.countDownBtn.frame = CGRectMake(_pwdTextField.right + 10, _userTextField.bottom+10, countDownRect.size.width+20, _userTextField.height);

}

#pragma mark 协议提示视图
- (void)createAgreeTipView{
    UIView *agreeBV = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-50, SCREEN_WIDTH, 50)];
    agreeBV.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:agreeBV];
    
    UILabel *tipL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, agreeBV.width, 15)];
    tipL.font = [UIFont systemFontOfSize:13];
    tipL.textAlignment = NSTextAlignmentCenter;
    tipL.text = NSLocalizedString(@"登录表示您已阅读并同意:", nil);
    [agreeBV addSubview:tipL];
    
    UIButton *proBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [proBtn setTitle:NSLocalizedString(@"《力付用户协议》", nil) forState:UIControlStateNormal];
    proBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [proBtn sizeToFit];
    [agreeBV addSubview:proBtn];
    proBtn.tag = 0;
    [proBtn addTarget:self action:@selector(toProtocol:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *andL = [[UILabel alloc] init];
    andL.text = NSLocalizedString(@"及", nil);
    andL.font = [UIFont systemFontOfSize:12];
    [andL sizeToFit];
    [agreeBV addSubview:andL];
    
    UIButton *itemBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [itemBtn setTitle:NSLocalizedString(@"《隐私条款》", nil) forState:UIControlStateNormal];
    itemBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [itemBtn sizeToFit];
    [agreeBV addSubview:itemBtn];
    itemBtn.tag = 1;
    [itemBtn addTarget:self action:@selector(toProtocol:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat totalWith = proBtn.width+andL.width+itemBtn.width;
    CGFloat x = (SCREEN_WIDTH-totalWith)/2;
    proBtn.frame = CGRectMake(x, tipL.bottom+2, proBtn.width, 16);
    andL.frame = CGRectMake(proBtn.right, proBtn.y, andL.width, proBtn.height);
    itemBtn.frame = CGRectMake(andL.right, proBtn.y, itemBtn.width, proBtn.height);    
}

- (void)toProtocol:(UIButton *)btn{
    DLog(@"%zd", btn.tag);
    ZFReadProtocolController *rpVC = [[ZFReadProtocolController alloc] init];
    rpVC.protocolType = btn.tag;
    [self pushViewController:rpVC];
}

- (void)createView{
    NSString *phoneNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhoneNum"];
    //NSString *pwdStr = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"passWord%@", phoneNum]];
    NSString *areaNum = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"area_Num%@", phoneNum]];
    
    _topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 250*SCREEN_HEIGHT/667)];
    _topImageView.image = [UIImage imageNamed:NSLocalizedString(@"pic_sign_in_background_chinese", @"登录顶部图片")];
    [self.view addSubview:_topImageView];
    
    //区号
    _areaTextField = [[ZFBaseTextField alloc] initWithFrame:CGRectMake(20, _topImageView.bottom+10, SCREEN_WIDTH-40, 40)];
    _areaTextField.text = NSLocalizedString(@"中国+86", nil);
    if (areaNum) {
        _areaTextField.text = NSLocalizedString(areaNum,nil);
    }
    _areaTextField.textAlignment = NSTextAlignmentLeft;
    _areaTextField.placeholder = NSLocalizedString(@"国家／地区", nil);
    _areaTextField.delegate = self;
    [self.view addSubview:_areaTextField];
    
    UIButton *telBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    telBtn.frame = CGRectMake(0, 0, 35, 40);
    [telBtn setImage:[UIImage imageNamed:@"tel_icon"] forState:UIControlStateNormal];
    [telBtn setImage:[UIImage imageNamed:@"tel_icon"] forState:UIControlStateHighlighted];
    [telBtn addTarget:self action:@selector(showPickKeyBoard) forControlEvents:UIControlEventTouchUpInside];
    _areaTextField.rightViewMode = UITextFieldViewModeAlways;
    _areaTextField.rightView = telBtn;
    
    
    //手机号
    _userTextField = [[ZFBaseTextField alloc] initWithFrame:CGRectMake(_areaTextField.x, _areaTextField.bottom+10, _areaTextField.width, 40)];
    _userTextField.placeholder = NSLocalizedString(@"手机号", nil);
    _userTextField.text = phoneNum;
    _userTextField.delegate = self;
    _userTextField.keyboardType = UIKeyboardTypeNumberPad;
    _userTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:_userTextField];
    
    CGRect countDownRect = [[ZFGlobleManager getGlobleManager] getStringWidthAndHeightWithStr:NSLocalizedString(@"发送验证码", nil) withFont:[UIFont fontWithName:@"PingFangSC-Regular" size:14]];
    _pwdTextField = [[ZFBaseTextField alloc] initWithFrame:CGRectMake(_areaTextField.x, _userTextField.bottom+10, SCREEN_WIDTH-40-countDownRect.size.width-30, _userTextField.height)];
    _pwdTextField.placeholder = NSLocalizedString(@"验证码", nil);
    _pwdTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _pwdTextField.delegate = self;
    _pwdTextField.returnKeyType = UIReturnKeyDone;
    _pwdTextField.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:_pwdTextField];
    //if (@available(iOS 12.0, *)) _pwdTextField.textContentType = @"one-time-code";
    
    _countDownForBtn = [[CountDown alloc] init];
    UIButton *countDownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.countDownBtn = countDownBtn;
    self.countDownBtn.backgroundColor =  [UIColor colorWithRed:74/255.0 green:144/255.0 blue:226/255.0 alpha:1/1.0];
    [self.countDownBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.countDownBtn setTitle:NSLocalizedString(@"发送验证码",nil) forState:UIControlStateNormal];
    [self.view addSubview:countDownBtn];
    countDownBtn.titleLabel.font =  [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    countDownBtn.layer.cornerRadius = 5;
    countDownBtn.layer.masksToBounds = YES;
    countDownBtn.frame = CGRectMake(_pwdTextField.right + 10, _userTextField.bottom+10, countDownRect.size.width+20, _userTextField.height);
    [countDownBtn addTarget:self action:@selector(countDownBtnAction:) forControlEvents:UIControlEventTouchUpInside];

    //登录
    _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _loginBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH-40, 40);
    _loginBtn.center = CGPointMake(SCREEN_WIDTH/2, _pwdTextField.bottom+50);
    _loginBtn.layer.cornerRadius = 5.0;
    [_loginBtn setTitle:NSLocalizedString(@"登录/注册", nil) forState:UIControlStateNormal];
    [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _loginBtn.backgroundColor = MainThemeColor;
    [_loginBtn addTarget:self action:@selector(clickLoginBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginBtn];
    
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:cancelBtn];
    [cancelBtn addTarget:self action:@selector(cancelBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.frame = CGRectMake(20, 33+IPhoneXStatusBarHeightInterval, 25, 25);
    [cancelBtn setImage:[UIImage imageNamed:@"icon_top_back"] forState:UIControlStateNormal];
    self.cancelBtn = cancelBtn;
    
    //注册按钮
    _registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _registerBtn.frame = CGRectMake(30, _loginBtn.bottom+20, 80, 30);
    [_registerBtn setTitle:NSLocalizedString(@"注册", nil) forState:UIControlStateNormal];
    _registerBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_registerBtn setTitleColor:MainThemeColor forState:UIControlStateNormal];
    _registerBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_registerBtn addTarget:self action:@selector(clickRegisterBtn) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:_registerBtn];
    
    //忘记密码
    _forgetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _forgetBtn.frame =  CGRectMake(SCREEN_WIDTH-150, _loginBtn.bottom+20, 120, 30);
    [_forgetBtn setTitle:NSLocalizedString(@"忘记密码", nil) forState:UIControlStateNormal];
    _forgetBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _forgetBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_forgetBtn setTitleColor:UIColorFromRGB(0x313131) forState:UIControlStateNormal];
    [_forgetBtn addTarget:self action:@selector(forgetPwdBtn) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:_forgetBtn];
    
    [self createPickView];
    if ([_isPushStr isEqualToString:@"1"] || [_isPushStr isEqualToString:@"2"]) {
        [self getCountryCode:2];
    } else {
        [self getCountryCode:1];
    }
}

- (void)countDownBtnAction:(UIButton *)sender {
    [self getSessionID:@"smscode"];
}

- (void)senderSmscode {
    NSString *random24Key = [SmallUtils generate24RandomKey];
    // 检查此处的RSA算法是否存在（公钥长度引起的）内存问题
    NSString *MD5Data = [[HBRSAHandler sharedInstance] encryptWithPublicKey: random24Key];
    MD5Data = [MD5Data stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    MD5Data = [MD5Data stringByReplacingOccurrencesOfString:@"\n" withString:@""];

    UniversallyUniqueIdentifier *uuid = [UniversallyUniqueIdentifier sharedInstance];
    NSString *countryCode = [[_areaTextField.text componentsSeparatedByString:@"+"] lastObject];

    NSDictionary *parameters = @{@"countryCode": countryCode,
                                 @"mobile": _userTextField.text,
                                 @"txnType":@"41",
                                 @"tempSessionID":_tempSessionID,
                                 @"userKey":uuid.uuid};
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        //请求成功
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [self startcountDown];
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(NSError *error) {
    }];
}

#pragma mark - 倒计时
- (void)startcountDown {
    NSTimeInterval aMinutes = 60;
    [_countDownForBtn countDownWithStratDate:[NSDate date] finishDate:[NSDate dateWithTimeIntervalSinceNow:aMinutes] completeBlock:^(NSInteger day, NSInteger hour, NSInteger minute, NSInteger second) {
        NSInteger totoalSecond =day*24*60*60+hour*60*60 + minute*60+second;
        if (totoalSecond==0) {
            CGRect countDownRect = [[ZFGlobleManager getGlobleManager] getStringWidthAndHeightWithStr:NSLocalizedString(@"发送验证码", nil) withFont:[UIFont fontWithName:@"PingFangSC-Regular" size:14]];
            _pwdTextField.frame = CGRectMake(_areaTextField.x, _userTextField.bottom+10, SCREEN_WIDTH-40-countDownRect.size.width-30, _userTextField.height);
            _countDownBtn.frame = CGRectMake(_pwdTextField.right + 10, _userTextField.bottom+10, countDownRect.size.width+20, _userTextField.height);
            self.countDownBtn.enabled = YES;
            self.countDownBtn.backgroundColor = [UIColor colorWithRed:74/255.0 green:144/255.0 blue:226/255.0 alpha:1/1.0];
            [self.countDownBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.countDownBtn setTitle:NSLocalizedString(@"发送验证码",nil) forState:UIControlStateNormal];

        }else{
            CGRect countDownRect = [[ZFGlobleManager getGlobleManager] getStringWidthAndHeightWithStr:NSLocalizedString(@"60s", nil) withFont:[UIFont fontWithName:@"PingFangSC-Regular" size:14]];
            _pwdTextField.frame = CGRectMake(_areaTextField.x, _userTextField.bottom+10, SCREEN_WIDTH-40-countDownRect.size.width-30, _userTextField.height);
            _countDownBtn.frame = CGRectMake(_pwdTextField.right + 10, _userTextField.bottom+10, countDownRect.size.width+20, _userTextField.height);
            self.countDownBtn.enabled = NO;
            self.countDownBtn.backgroundColor = [UIColor clearColor];
            [self.countDownBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0] forState:UIControlStateNormal];
            [self.countDownBtn setTitle:[NSString stringWithFormat:@"%lis",totoalSecond] forState:UIControlStateNormal];
        }
    }];
}

- (void)showPickKeyBoard{
    [_areaTextField becomeFirstResponder];
}

- (void)createPickView{
    
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 220)];
    self.pickerView.backgroundColor = [UIColor whiteColor];
    
    // 代理
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    
    // --- tool bar ---
    _doneBBI = [[UIBarButtonItem alloc]
                                initWithTitle:NSLocalizedString(@"确定", nil)
                                style:UIBarButtonItemStyleDone
                                target:self
                                action:@selector(hidePickView)];
    UIBarButtonItem *flexibleBBILeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    _textBBI = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"请选择手机区号", nil) style:UIBarButtonItemStylePlain target:nil action:nil];
    [_textBBI setEnabled:NO];
    UIBarButtonItem *flexibleBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *toolbarItems = [NSArray arrayWithObjects:flexibleBBILeft, _textBBI, flexibleBBI, _doneBBI, nil];

    // 工具栏
    self.toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    [self.toolbar setBarStyle:UIBarStyleDefault];
    [self.toolbar setItems:toolbarItems];
    
    self.areaTextField.delegate = self;
    self.areaTextField.inputView = _pickerView;
    self.areaTextField.inputAccessoryView = _toolbar;
    self.areaTextField.tintColor = [UIColor clearColor];
}

- (void)hidePickView{
    [_areaTextField resignFirstResponder];
}

- (void)showOrHidPwd:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (btn.selected) {
        [btn setBackgroundImage:[UIImage imageNamed:@"showpassword_yes"] forState:UIControlStateNormal];
        _pwdTextField.secureTextEntry = NO;
    } else {
        [btn setBackgroundImage:[UIImage imageNamed:@"showpassword_no"] forState:UIControlStateNormal];
        _pwdTextField.secureTextEntry = YES;
    }
}

#pragma mark 获取手机区号
- (void)getCountryCode:(NSInteger)flag{
    
    _areaArray = [[NSMutableArray alloc] init];
    _areaArray = [[ZFGlobleManager getGlobleManager] getAreaNumArray];
    
    NSDictionary *parameters = @{@"txnType": @"35"};
    
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            NSArray *countryArr = [requestResult objectForKey:@"list"];
            NSMutableArray *areaArray = [[NSMutableArray alloc] init];
            
            [ZFGlobleManager getGlobleManager].countryInfo = [NSArray yy_modelArrayWithClass:[NUCountryInfo class] json:[requestResult objectForKey:@"list"]];
            NSString *languageDesc = @"";
            NSString *language = [NetworkEngine getCurrentLanguage];
            if ([language isEqualToString:@"1"]) {
                languageDesc = @"engDesc";
            } else if ([language isEqualToString:@"2"]) {
                languageDesc = @"chnDesc";
            } else if ([language isEqualToString:@"3"]) {
                languageDesc = @"fonDesc";
            }
            for (NSDictionary *dict in countryArr) {
                NSString *str = [NSString stringWithFormat:@"%@+%@", [dict objectForKey:languageDesc], [dict objectForKey:@"countryCode"]];
                [areaArray addObject:str];
            }
            _areaArray = areaArray;
            
            //把区号保存到本地 防止下次无网络列表空白
            [[ZFGlobleManager getGlobleManager] saveAreaNumArray:_areaArray];
            
            [_pickerView reloadAllComponents];
            NSString *countryStr = _areaArray[0];
            NSString *phoneNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhoneNum"];
            NSString *areaNum = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"area_Num%@", phoneNum]];
            if (areaNum) {
                NSString *code = [[areaNum componentsSeparatedByString:@"+"] lastObject];
                for (NSString *str in _areaArray) {//避免改变语言后退出显示没改变
                    if ([str hasSuffix:code]) {
                        countryStr = str;
                        break;
                    }
                }
            }
            
            _areaTextField.text = countryStr;
            
            if (flag == 1) {
                [self checkAutoLogin];
            }
        } else {
            
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
        
    } failure:^(NSError *error) {
        //[[MBUtils sharedInstance] dismissMB];
        
    }];
}

#pragma mark 获取币种信息
- (void)getCurrencyInfo{
    NSDictionary *parameters = @{@"txnType": @"82"};
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
            if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
                NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
                NSArray *listArr = [requestResult objectForKey:@"list"];
                for (NSDictionary *dict in listArr) {
                    [resultDict setObject:[dict objectForKey:@"currSign"] forKey:[dict objectForKey:@"currCode"]];
                }
                
                [[NSUserDefaults standardUserDefaults] setObject:resultDict forKey:@"CurrencyInfo"];
            }
        } failure:^(id error) {
            
        }];
    });
}

#pragma mark 注册
- (void)clickRegisterBtn{
    DLog(@"click register");
    ZFRegisterViewController *regVC = [[ZFRegisterViewController alloc] init];
//    regVC.type = 0;
    [self.navigationController pushViewController:regVC animated:YES];
}

#pragma mark 忘记密码
- (void)forgetPwdBtn{
    DLog(@"click forget");
    ZFForgetLoginPwdController *forgetVC = [[ZFForgetLoginPwdController alloc] init];
    [self.navigationController pushViewController:forgetVC animated:YES];
}

//#pragma mark 验证码登录
//- (void)verCodeLoginBtn{
//    ZFRegisterViewController *regVC = [[ZFRegisterViewController alloc] init];
//    regVC.type = 1;
//    [self.navigationController pushViewController:regVC animated:YES];
//}

#pragma mark 校验信息
-(BOOL) userInputIsRight:(NSString *)isWhat {
    NSString *moblie = self.userTextField.text;
    NSString *password = self.pwdTextField.text;
    //防止复制通讯录里面的号码出现bug
    moblie = [moblie stringByReplacingOccurrencesOfString:@"\\p{Cf}" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, moblie.length)];
    moblie = [moblie stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.userTextField.text = moblie;
    
    NSString *errorMessage = @"";
    
    if (!moblie || moblie.length == 0) {
        errorMessage = NSLocalizedString(@"请输入手机号", nil);
        [[MBUtils sharedInstance] showMBMomentWithText:errorMessage inView:self.view];
        return NO;
    }
    
    if (moblie.length > 11 || moblie.length < 7) {
        errorMessage = NSLocalizedString(@"手机号码应为7~11位", nil);
        [[MBUtils sharedInstance] showMBMomentWithText:errorMessage inView:self.view];
        return NO;
    }
    
    if ([isWhat isEqualToString:@"login"] && (!password || password.length == 0)) {
        errorMessage = NSLocalizedString(@"请输入验证码", nil);
        [[MBUtils sharedInstance] showMBMomentWithText:errorMessage inView:self.view];
        return NO;
    }

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *autoLogin = [userDefaults objectForKey:@"autoLogin"];
    if ([autoLogin isEqualToString:@"0"] && (!password || password.length == 0) ) {
        errorMessage = NSLocalizedString(@"请输入验证码", nil);
        [[MBUtils sharedInstance] showMBMomentWithText:errorMessage inView:self.view];
        //return NO;
    }
//    if(!password || password.length == 0){
//        errorMessage = NSLocalizedString(@"请输入登录密码", nil);
//        [[MBUtils sharedInstance] showMBMomentWithText:errorMessage inView:self.view];
//        return NO;
//    }
//
//    if(password.length  < 6){
//        errorMessage = NSLocalizedString(@"登录密码长度不能小于6位", nil);
//        [[MBUtils sharedInstance] showMBMomentWithText:errorMessage inView:self.view];
//        return NO;
//    }
//
//    if(password.length > 20){
//        errorMessage = NSLocalizedString(@"登录密码长度不能大于20位", nil);
//        [[MBUtils sharedInstance] showMBMomentWithText:errorMessage inView:self.view];
//        return NO;
//    }
    return YES;
}

#pragma mark 登录
- (void)clickLoginBtn{
    //测试
//    [self jumpToMain];
//    return;
    [self.view endEditing:YES];
    [self getSessionID:@"login"];
}

#pragma mark 检测是否可以自动登录
- (void)checkAutoLogin{
    NSString *phoneNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhoneNum"];
//    NSString *pwdStr = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"passWord%@", phoneNum]];
    [ZFGlobleManager getGlobleManager].userPhone = phoneNum;
    //NSString *pwdStr = [[ZFGlobleManager getGlobleManager] getLoginPwd];
    NSString *areaNum = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"area_Num%@", phoneNum]];
    if (phoneNum && areaNum) {//&& pwdStr && pwdStr.length > 5
        _areaTextField.text = areaNum;
        _userTextField.text = phoneNum;
        //_pwdTextField.text = pwdStr;

        [self getSessionID:@"auto"];
//        [self loadAuthentication];
    }
}

#pragma mark 获取临时sessionID
- (void)getSessionID:(NSString *)isWhat {
    if (![self userInputIsRight:isWhat]) {
        return;
    }
    
    NSString *countryCode = [[_areaTextField.text componentsSeparatedByString:@"+"] lastObject];
        
    NSDictionary *parameters = @{@"countryCode": countryCode,
                                  @"mobile": _userTextField.text,
                                  @"txnType": @"01"};
    
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            // 解密secretKey得到3DES的key
            NSString *securityKey = [[HBRSAHandler sharedInstance] decryptWithPrivateKey:[requestResult objectForKey:@"securityKey"]];
            // 保存secreykey
            _securityKey = securityKey;
            _tempSessionID = [requestResult objectForKey:@"sessionID"];
            
            if ([isWhat isEqualToString:@"smscode"]) {
                [self senderSmscode];
            } else {
                //登录
                [self requestLogin:isWhat];
                //获取币种信息
                [self getCurrencyInfo];
            }
        } else {
            [[MBUtils sharedInstance] dismissMB];
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark 登录请求
- (void)requestLogin:(NSString *)isWhat {
    NSString *random24Key = [SmallUtils generate24RandomKey];
    // 检查此处的RSA算法是否存在（公钥长度引起的）内存问题
    NSString *MD5Data = [[HBRSAHandler sharedInstance] encryptWithPublicKey: random24Key];
    MD5Data = [MD5Data stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    MD5Data = [MD5Data stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    LocationUtils *loc = [LocationUtils sharedInstance];
    NSString *baseStation = [NSString stringWithFormat:@"%@-%@", loc.country, loc.city];
    UniversallyUniqueIdentifier *uuid = [UniversallyUniqueIdentifier sharedInstance];
    
    // 3DES加密
    NSString *password = self.pwdTextField.text;
    if ([isWhat isEqualToString:@"auto"]) password = @"";
//    NSString *encrypptpasswordString = [TripleDESUtils getEncryptWithString:password keyString: random24Key ivString: @"01234567"];
    NSString *countryCode = [[_areaTextField.text componentsSeparatedByString:@"+"] lastObject];
    
    NSDictionary *parameters = @{@"countryCode": countryCode,
                                 @"mobile": _userTextField.text,
                                 //@"password": encrypptpasswordString,
                                 @"userKey":uuid.uuid,
                                 @"MD5Data":MD5Data,
                                 @"longitude":[loc getLongitude],
                                 @"latitude":[loc getLatitude],
                                 @"baseStation":baseStation.length ? baseStation : @"",
                                 @"IP":[SmallUtils getIPAddress : YES],
                                 @"tempSessionID":_tempSessionID,
                                 @"txnType":@"93",
                                 @"smsCode":password,
                                 @"loginType":@"sms_login"};
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        //请求成功
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:@"0" forKey:@"autoLogin"];
            [userDefaults synchronize];
            // 解密secretKey得到3DES的key
            // 此处的处理与获取临时securityKey时不同，此处使用3DES解密，解密的key为app生成的24位随机数）
            NSString *securityKey = [TripleDESUtils getDecryptWithString:[requestResult objectForKey:@"securityKey"] keyString: random24Key ivString: @"01234567"];
            // 保存secreykey
            [ZFGlobleManager getGlobleManager].securityKey = securityKey;
            [ZFGlobleManager getGlobleManager].sessionID = [requestResult objectForKey:@"sessionID"];
            [ZFGlobleManager getGlobleManager].userPhone = _userTextField.text;
            [ZFGlobleManager getGlobleManager].areaNum = countryCode;
            [ZFGlobleManager getGlobleManager].userKey = uuid.uuid;
            
            //随机数和时间差 （时间差是手机端时间和服务端时间差值）
            [ZFGlobleManager getGlobleManager].ramdom = [requestResult objectForKey:@"randomNo"];
            [ZFGlobleManager getGlobleManager].timeDiff = [self timeDiffWith:[requestResult objectForKey:@"upopTime"]];
            
            //保存用户信息到本地 下次自动登录
            [self saveUserInfo];
            
            [self jumpToMain];
        } else {
            //登录错误清除密码
            //[[ZFGlobleManager getGlobleManager] saveLoginPwd:@""];
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
        
    } failure:^(NSError *error) {
    }];
}

- (NSInteger)timeDiffWith:(NSString *)upopTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *clientDate = [NSDate date];
    long clientInt = [clientDate timeIntervalSince1970];
    NSDate *serviceDate = [formatter dateFromString:upopTime];
    NSInteger timeDiff = [serviceDate timeIntervalSince1970] - clientInt;

    return timeDiff;
}

#pragma mark 信息保存到本地
- (void)saveUserInfo{
    NSArray *personArr = [[[ZFGlobleManager getGlobleManager] getdb] jq_lookupTable:@"user" dicOrModel:[ZFLogin class] whereFormat:[NSString stringWithFormat:@"where name = '%@'",_userTextField.text]];
    if (personArr.count == 0) {
        ZFLogin *login = [ZFLogin new];
        login.isOpen = @"0";
        login.name = _userTextField.text;
        [[[ZFGlobleManager getGlobleManager] getdb] jq_insertTable:@"user" dicOrModel:login];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:@"1" forKey:@"isFirstLogin"];
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:@"0" forKey:@"isFirstLogin"];
    }
    
    //手机号
    [[NSUserDefaults standardUserDefaults] setObject:_userTextField.text forKey:@"userPhoneNum"];
    [[ZFGlobleManager getGlobleManager] saveLoginPwd:_pwdTextField.text];
    //区号
    [[NSUserDefaults standardUserDefaults] setObject:_areaTextField.text forKey:[NSString stringWithFormat:@"area_Num%@", _userTextField.text]];
}

#pragma mark 跳转到主页
- (void)jumpToMain{
    ZFTabBarController *tabVC = [[ZFTabBarController alloc] init];
    tabVC.tabBarController.tabBar.translucent = NO;
    // 动画
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    //window.rootViewController = [[ZFNavigationController alloc] initWithRootViewController:[[ZFMainViewController alloc] init]];
    window.rootViewController = tabVC;
    UIView *toView;
    UIView *fromView;
    UIViewAnimationOptions option = UIViewAnimationOptionTransitionCrossDissolve;
    [UIView transitionWithView:window
                      duration:1.0f
                       options:option
                    animations:^ {
                        [fromView removeFromSuperview];
                        [window addSubview:toView];
                    }
                    completion:nil];
}

#pragma mark - UITextField Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger maxCount = 0;
    
    if (textField == self.userTextField ) {
        maxCount = 11;
    } else if (textField == self.pwdTextField){
        maxCount = 20;
    }else if(textField == self.areaTextField)
    {
        return NO;
    }
    else {
        return YES;
    }
    
    if (range.location >= maxCount) {
        textField.text = [textField.text substringToIndex:range.location];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == _areaTextField && !_areaTextField.isAskingCanBecomeFirstResponder) {
        if (![ZFGlobleManager getGlobleManager].areaNumArray || [ZFGlobleManager getGlobleManager].areaNumArray.count==0) {
            [self getCountryCode:2];
            return NO;
        }
    }
    return YES;
}

#pragma mark - pickview delegate
// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _areaArray.count;
}

- (NSInteger) numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return _areaArray.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 30;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return self.view.bounds.size.width;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    if (!view) {
        view = [[UIView alloc] init];
    }
    UILabel *textlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
    textlabel.textAlignment = NSTextAlignmentCenter;
    textlabel.text = _areaArray[row];
    textlabel.font = [UIFont systemFontOfSize:19];
    [view addSubview:textlabel];
    return view;
}

// didSelectRow
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
//    self.areaTextField.text = [NSString stringWithFormat:@"+%@", [[_areaArray[row] componentsSeparatedByString:@"+"] lastObject]];
    self.areaTextField.text = _areaArray[row];
}


// return按钮
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self clickLoginBtn];
    return YES;
}


@end

//NSString *random24Key = [SmallUtils generate24RandomKey];
//// 检查此处的RSA算法是否存在（公钥长度引起的）内存问题
//NSString *MD5Data = [[HBRSAHandler sharedInstance] encryptWithPublicKey: random24Key];
//MD5Data = [MD5Data stringByReplacingOccurrencesOfString:@"\r" withString:@""];
//MD5Data = [MD5Data stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//
//LocationUtils *loc = [LocationUtils sharedInstance];
//NSString *baseStation = [NSString stringWithFormat:@"%@-%@", loc.country, loc.city];
//UniversallyUniqueIdentifier *uuid = [UniversallyUniqueIdentifier sharedInstance];
//NSString *countryCode = [[_areaTextField.text componentsSeparatedByString:@"+"] lastObject];
//
//NSDictionary *parameters = @{@"countryCode": countryCode,
//                             @"mobile": _userTextField.text,
//                             @"txnType":@"06",
//                             @"language":@"",
//                             @"IP":[SmallUtils getIPAddress : YES],
//                             @"MD5Data":MD5Data,
//                             @"baseStation":baseStation.length ? baseStation : @"",
//                             @"longitude":[loc getLongitude],
//                             @"latitude":[loc getLatitude],
//                             @"loginType":@"",
//                             @"smsCode":@"",
//                             @"tempSessionID":_tempSessionID,
//                             @"userKey":uuid.uuid,
//                             @"signature": @"",};
//    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
//    [[MBUtils sharedInstance] dismissMB];
//    //请求成功
//    if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
//
//    } else {
//
//        [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
//    }
//    
//} failure:^(NSError *error) {
//}];
