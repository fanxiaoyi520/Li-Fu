//
//  ZFRegisterViewController.m
//  newupop
//
//  Created by 中付支付 on 2017/7/21.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFRegisterViewController.h"
#import "ZFSetLoginPwdController.h"
#import "HBRSAHandler.h"
#import "SmallUtils.h"
#import "LocationUtils.h"
#import "UniversallyUniqueIdentifier.h"
#import "TripleDESUtils.h"
#import "ZFNavigationController.h"
#import "ZFMainViewController.h"
#import "ZFServiceAgreementController.h"
#import "ZFReadProtocolController.h"

@interface ZFRegisterViewController ()<UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
//@property (weak, nonatomic) IBOutlet ZFBaseTextField *backTextField;

@property (weak, nonatomic) IBOutlet ZFBaseTextField *areaTextField;
@property (weak, nonatomic) IBOutlet ZFBaseTextField *phoneNum;
@property (weak, nonatomic) IBOutlet ZFBaseTextField *verCode;
@property (weak, nonatomic) IBOutlet UIButton *getCodeBtn;
///下一步 或 登录
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UILabel *agreementLabel;
@property (weak, nonatomic) IBOutlet UIButton *agreementBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *agreementLeft;
@property (nonatomic, strong)NSTimer *timer;
@property (nonatomic, assign)NSInteger downCount;

/// 支持的手机号码国家/地区代码
@property(nonatomic,strong) NSMutableArray *areaArray;
///区域选择
@property(nonatomic,strong) UIPickerView *pickerView;
///区域工具栏
@property(nonatomic,strong) UIToolbar *toolbar;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

@end

@implementation ZFRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _phoneNum.placeholder = NSLocalizedString(@"请输入手机号", nil);
    _verCode.placeholder = NSLocalizedString(@"验证码", nil);
    [_getCodeBtn setTitle:NSLocalizedString(@"获取验证码", nil) forState:UIControlStateNormal];
    
    self.view.backgroundColor = [UIColor whiteColor];
    _topConstraint.constant = IPhoneXTopHeight+20;

    self.myTitle = @"注册";
    [_confirmBtn setTitle:NSLocalizedString(@"下一步", nil) forState:UIControlStateNormal];
    [self setAgreement];
    
    [self setViewStyle];
    
    //上次保存的数据
    NSString *phoneNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhoneNum"];
    NSString *areaNum = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"area_Num%@", phoneNum]];
//    _phoneNum.text = phoneNum;
    if (areaNum) {
        _areaTextField.text = areaNum;
    }
    
    //之前请求过就不再请求
    if ([ZFGlobleManager getGlobleManager].areaNumArray && [ZFGlobleManager getGlobleManager].areaNumArray.count > 0) {
        _areaArray = [ZFGlobleManager getGlobleManager].areaNumArray;
    } else {
        [self getCountryCode];
    }
    [self createPickView];
    [self createAgreeTipView];
}

#pragma mark 协议提示视图
- (void)createAgreeTipView{
    UIView *agreeBV = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-50, SCREEN_WIDTH, 50)];
    [self.view addSubview:agreeBV];
    
    UILabel *tipL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, agreeBV.width, 15)];
    tipL.font = [UIFont systemFontOfSize:13];
    tipL.textAlignment = NSTextAlignmentCenter;
    tipL.text = NSLocalizedString(@"点击\"下一步\"即表示您已阅读并同意:", nil);
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

- (void)setAgreement{
    _agreementLabel.text = NSLocalizedString(@"注册即代表您同意", nil);
    [_agreementLabel sizeToFit];
    NSString *str = [NSString stringWithFormat:@"%@", NSLocalizedString(@"服务协议", nil)];
    [_agreementBtn setTitle:str forState:UIControlStateNormal];
    [_agreementBtn sizeToFit];
    
    CGFloat width = _agreementLabel.width + _agreementBtn.width;
    
    _agreementLeft.constant = (SCREEN_WIDTH - width)/2;
    _agreementBtn.x = _agreementLabel.right;
}

#pragma mark 设置视图样式
- (void)setViewStyle{
//    _backTextField.layer.cornerRadius = 5;
//    _backTextField.backgroundColor = UIColorFromRGB(0xeeeeee);
    
    UIButton *telBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    telBtn.frame = CGRectMake(0, 0, 35, 40);
    [telBtn setImage:[UIImage imageNamed:@"tel_icon"] forState:UIControlStateNormal];
    [telBtn setImage:[UIImage imageNamed:@"tel_icon"] forState:UIControlStateHighlighted];
    [telBtn addTarget:self action:@selector(showPickKeyBoard) forControlEvents:UIControlEventTouchUpInside];
    _areaTextField.rightViewMode = UITextFieldViewModeAlways;
    _areaTextField.rightView = telBtn;
    
    [_areaTextField setStyle];
    [_phoneNum setStyle];
    [_verCode setStyle];
    
    _getCodeBtn.layer.cornerRadius = 5;
    _confirmBtn.layer.cornerRadius = 5;
}

- (void)showPickKeyBoard{
    [_areaTextField becomeFirstResponder];
}

- (IBAction)clickAgreementBtn:(id)sender {
    ZFServiceAgreementController *serVC = [[ZFServiceAgreementController alloc] init];
    [self.navigationController pushViewController:serVC animated:YES];
}

#pragma mark 获取手机区号
- (void)getCountryCode{
    
    _areaArray = [[NSMutableArray alloc] init];
    NSDictionary *parameters = @{@"txnType": @"35"};
    
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            NSArray *countryArr = [requestResult objectForKey:@"list"];
//            NSString *languageDesc = [[NetworkEngine getCurrentLanguage] isEqualToString:@"1"]?@"engDesc":@"chnDesc";
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
                [_areaArray addObject:str];
            }
            //把区号保存到本地 防止下次无网络列表空白
            [[ZFGlobleManager getGlobleManager] saveAreaNumArray:_areaArray];
            
            [_pickerView reloadAllComponents];
            NSString *countryStr = _areaArray[0];//[NSString stringWithFormat:@"+%@", [[_areaArray[0] componentsSeparatedByString:@"+"] lastObject]];
            NSString *phoneNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhoneNum"];
            NSString *areaNum = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"area_Num%@", phoneNum]];
            if (areaNum) {
                countryStr = areaNum;
            }
            _areaTextField.text = countryStr;
        } else {
            
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
        
    } failure:^(NSError *error) {
        //[[MBUtils sharedInstance] dismissMB];
        
    }];
}

- (void)createPickView{
    
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 220)];
    self.pickerView.backgroundColor = [UIColor whiteColor];
    
    // 代理
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    
    UIView *toolView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    toolView.backgroundColor = GrayBgColor;
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];
    [cancelBtn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(hidePickView) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitleColor:MainThemeColor forState:UIControlStateNormal];
    [toolView addSubview:cancelBtn];
    
    UIButton *confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-80, 0, 80, 44)];
    [confirmBtn setTitle:NSLocalizedString(@"完成", nil) forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(hidePickView) forControlEvents:UIControlEventTouchUpInside];
    [confirmBtn setTitleColor:MainThemeColor forState:UIControlStateNormal];
    [toolView addSubview:confirmBtn];
    
    self.areaTextField.delegate = self;
    self.areaTextField.inputView = _pickerView;
    self.areaTextField.inputAccessoryView = toolView;
    self.areaTextField.tintColor = [UIColor clearColor];
}

- (void)hidePickView{
    [_areaTextField resignFirstResponder];
}

#pragma mark 验证手机号
- (BOOL)checkPhoneNum{
    NSString *moblie = self.phoneNum.text;
    
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
    return YES;
}

#pragma mark 获取验证码
- (IBAction)getCodeBtn:(id)sender {
    if (![self checkPhoneNum]) {
        return;
    }
    
    [self getSessionID];
}

#pragma mark 获取临时sessionID
- (void)getSessionID{
    
    NSString *countryCode = [[_areaTextField.text componentsSeparatedByString:@"+"] lastObject];
    
    NSDictionary *parameters = @{@"countryCode": countryCode,
                                 @"mobile": _phoneNum.text,
                                 @"txnType": @"01"};
    
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            // 解密secretKey得到3DES的key
            NSString *securityKey = [[HBRSAHandler sharedInstance] decryptWithPrivateKey:[requestResult objectForKey:@"securityKey"]];
            // 保存secreykey
            [ZFGlobleManager getGlobleManager].tempSecurityKey = securityKey;
            [ZFGlobleManager getGlobleManager].tempSessionID = [requestResult objectForKey:@"sessionID"];
            [ZFGlobleManager getGlobleManager].userPhone = _phoneNum.text;
            [ZFGlobleManager getGlobleManager].areaNum = countryCode;
            
            [self getVerCode];
        } else {
            [[MBUtils sharedInstance] dismissMB];
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
        
    } failure:^(NSError *error) {
        //[[MBUtils sharedInstance] dismissMB];
    }];
}

#pragma mark 获取短信验证码
- (void)getVerCode{
    NSString *txnType = @"30";
//    if (_type == 1) {//验证码登录
//        txnType = @"41";
//    }
    
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": _phoneNum.text,
                                 @"txnType": txnType,
                                 @"tempSessionID":[ZFGlobleManager getGlobleManager].tempSessionID};
    
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            _getCodeBtn.enabled = NO;
            _downCount = 60;
            [self retextBtn];
            _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(retextBtn) userInfo:nil repeats:YES];
            [_verCode becomeFirstResponder];
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
    }
}

#pragma mark 下一步
- (IBAction)nextStepBtn:(id)sender {
    [self.view endEditing:YES];
    //验证信息
    if (![self checkPhoneNum]) {
        return;
    }
    if (_verCode.text.length != 6) {
        [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"验证码输入错误", nil) inView:self.view];
        return;
    }
    
//    if (_type == 1) {//login
//        [self loginWithMessage];
//        return;
//    }
    
    [self verificationCode];
}

#pragma mark 短信登录
- (void)loginWithMessage{
    NSString *random24Key = [SmallUtils generate24RandomKey];
    // 检查此处的RSA算法是否存在（公钥长度引起的）内存问题
    NSString *MD5Data = [[HBRSAHandler sharedInstance] encryptWithPublicKey: random24Key];
    MD5Data = [MD5Data stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    MD5Data = [MD5Data stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    LocationUtils *loc = [LocationUtils sharedInstance];
    
    UniversallyUniqueIdentifier *uuid = [UniversallyUniqueIdentifier sharedInstance];
    
    NSString *countryCode = [[_areaTextField.text componentsSeparatedByString:@"+"] lastObject];
    
    NSDictionary *parameters = @{@"countryCode": countryCode,
                                 @"mobile": _phoneNum.text,
                                 @"password":@"",
                                 @"userKey":uuid.uuid,
                                 @"MD5Data":MD5Data,
                                 @"longitude":[loc getLongitude],
                                 @"latitude":[loc getLatitude],
                                 @"baseStation":@"ww",
                                 @"IP":[SmallUtils getIPAddress : YES],
                                 @"tempSessionID":[ZFGlobleManager getGlobleManager].tempSessionID,
                                 @"loginType":@"1",
                                 @"loginCode":_verCode.text,
                                 @"txnType":@"06"};
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        
        //请求成功
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            // 解密secretKey得到3DES的key
            // 此处的处理与获取临时sessionID时不同，此处使用3DES解密，解密的key为app生成的24位随机数）
            NSString *securityKey = [TripleDESUtils getDecryptWithString:[requestResult objectForKey:@"securityKey"] keyString: random24Key ivString: @"01234567"];
            // 保存secreykey
            [ZFGlobleManager getGlobleManager].securityKey = securityKey;
            [ZFGlobleManager getGlobleManager].sessionID = [requestResult objectForKey:@"sessionID"];
            [ZFGlobleManager getGlobleManager].userPhone = _phoneNum.text;
            [ZFGlobleManager getGlobleManager].areaNum = countryCode;
            [ZFGlobleManager getGlobleManager].userKey = uuid.uuid;
            
            //保存用户信息到本地 下次自动登录
            [self saveUserInfo];
            [self jumpToMain];
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
        
    } failure:^(NSError *error) {
        //        [[MBUtils sharedInstance] dismissMB];
    }];
}

#pragma mark 信息保存到本地
- (void)saveUserInfo{
    //手机号
    [[NSUserDefaults standardUserDefaults] setObject:_phoneNum.text forKey:@"userPhoneNum"];
    //区号
    [[NSUserDefaults standardUserDefaults] setObject:_areaTextField.text forKey:[NSString stringWithFormat:@"area_Num%@", _phoneNum.text]];
}

#pragma mark 跳转到主页
- (void)jumpToMain{
    // 动画
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.rootViewController = [[ZFNavigationController alloc] initWithRootViewController:[[ZFMainViewController alloc] init]];
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

#pragma mark 验证 验证码
- (void)verificationCode{
    
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"txnType": @"44",
                                 @"tempSessionID":[ZFGlobleManager getGlobleManager].tempSessionID,
                                 @"mailVerifyCode":_verCode.text};
    
    [[MBUtils sharedInstance] showMBInView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            ZFSetLoginPwdController *setPwdVC = [[ZFSetLoginPwdController alloc] init];
            setPwdVC.type = 0;
            [self.navigationController pushViewController:setPwdVC animated:YES];
            
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
        
    } failure:^(NSError *error) {
        //[[MBUtils sharedInstance] dismissMB];
        
    }];
}

#pragma mark - UITextField Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSUInteger maxCount = 0;
    
    if (textField == self.phoneNum ) {
        maxCount = 11;
    } else if(textField == self.areaTextField) {
        return NO;
    } else if (textField == _verCode){
        maxCount = 6;
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
    if (textField == _areaTextField) {
        if (![ZFGlobleManager getGlobleManager].areaNumArray || [ZFGlobleManager getGlobleManager].areaNumArray.count == 0) {
            [self getCountryCode];
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
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
//    self.areaTextField.text = [NSString stringWithFormat:@"+%@", [[_areaArray[row] componentsSeparatedByString:@"+"] lastObject]];
    self.areaTextField.text = _areaArray[row];
}



@end
