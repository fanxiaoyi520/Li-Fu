//
//  ZFVCodeLoginViewController.m
//  newupop
//
//  Created by FANS on 2020/11/26.
//  Copyright © 2020 中付支付. All rights reserved.
//

#import "ZFVCodeLoginViewController.h"
#import "ZFFingerprintLoginViewController.h"
#import "ZFNavigationController.h"
#import "ZFLoginViewController.h"
#import "HBRSAHandler.h"
#import "UniversallyUniqueIdentifier.h"
#import "ZFTabBarController.h"

@interface ZFVCodeLoginViewController ()

@property (nonatomic ,strong)ZFBaseTextField *VcodeTextField;
@property (nonatomic ,strong)UIButton *countDownBtn;
@property (strong, nonatomic)CountDown *countDownForBtn;
@property (strong, nonatomic)UIButton *loginBtn;
@property (strong, nonatomic)UILabel *numLab;

@property (nonatomic, strong) NSString *securityKey;
@property (nonatomic, strong) NSString *tempSessionID;
@end

@implementation ZFVCodeLoginViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _VcodeTextField.text = @"";
    [_countDownForBtn destoryTimer];
    CGRect countDownRect = [[ZFGlobleManager getGlobleManager] getStringWidthAndHeightWithStr:NSLocalizedString(@"发送验证码", nil) withFont:[UIFont fontWithName:@"PingFangSC-Regular" size:14]];
    _VcodeTextField.frame = CGRectMake(20, _numLab.bottom+65, SCREEN_WIDTH-40-countDownRect.size.width-30, 40);
    _countDownBtn.frame = CGRectMake(_VcodeTextField.right + 10, _numLab.bottom+65, countDownRect.size.width+20, 40);
    self.countDownBtn.enabled = YES;
    self.countDownBtn.backgroundColor = [UIColor colorWithRed:74/255.0 green:144/255.0 blue:226/255.0 alpha:1/1.0];
    [self.countDownBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.countDownBtn setTitle:NSLocalizedString(@"发送验证码",nil) forState:UIControlStateNormal];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isHiddenBack = YES;
    self.myTitle = NSLocalizedString(@" 登录 ", nil);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeText) name:CHANGE_LANGUAGE object:nil];
    if ([_isPushStr isEqualToString:@"0"] || [_isPushStr isEqualToString:@"1"]) {
        [self getCountryCode:2];
    } else {
        [self getCountryCode:1];
    }
    [self creatView];
}

- (void)changeText {
    [self getCountryCode:2];
}

- (void)creatView {
    UIImageView *headerImageView = [UIImageView new];
    [self.view addSubview:headerImageView];
    headerImageView.frame = CGRectMake((SCREEN_WIDTH-64)/2, IPhoneXTopHeight+54, 64, 64);
    headerImageView.image = [ZFGlobleManager getGlobleManager].headImage;
    
    NSString *_userTextField = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhoneNum"];
    NSString *iphoneStr = nil;
    if (_userTextField.length == 11) {
        iphoneStr = [_userTextField stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    } else if (_userTextField.length == 8) {
        iphoneStr = [_userTextField stringByReplacingCharactersInRange:NSMakeRange(2, 4) withString:@"****"];
    } else {
        iphoneStr = _userTextField;
    }
    UILabel *numLab = [[UILabel alloc] init];
    numLab.frame = CGRectMake(0, headerImageView.bottom+12, SCREEN_WIDTH, 16);
    numLab.text = iphoneStr;
    numLab.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    numLab.textColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1/1.0];
    numLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:numLab];
    self.numLab = numLab;
    
    CGRect countDownRect = [[ZFGlobleManager getGlobleManager] getStringWidthAndHeightWithStr:NSLocalizedString(@"发送验证码", nil) withFont:[UIFont fontWithName:@"PingFangSC-Regular" size:14]];
    _VcodeTextField = [[ZFBaseTextField alloc] initWithFrame:CGRectMake(20, numLab.bottom+65, SCREEN_WIDTH-40-countDownRect.size.width-30, 40)];
    _VcodeTextField.placeholder = NSLocalizedString(@"验证码", nil);
    _VcodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _VcodeTextField.returnKeyType = UIReturnKeyDone;
    _VcodeTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [self.view addSubview:_VcodeTextField];
    _VcodeTextField.keyboardType = UIKeyboardTypeNumberPad;
//    if (@available(iOS 12.0, *)) _VcodeTextField.textContentType = @"one-time-code";

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
    countDownBtn.frame = CGRectMake(_VcodeTextField.right + 10, numLab.bottom+65, countDownRect.size.width+20, 40);
    [countDownBtn addTarget:self action:@selector(countDownBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //登录
    _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _loginBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH-40, 40);
    _loginBtn.center = CGPointMake(SCREEN_WIDTH/2, _VcodeTextField.bottom+45);
    _loginBtn.layer.cornerRadius = 5.0;
    [_loginBtn setTitle:NSLocalizedString(@" 登录 ", nil) forState:UIControlStateNormal];
    [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _loginBtn.backgroundColor = MainThemeColor;
    [_loginBtn addTarget:self action:@selector(clickLoginBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginBtn];
    
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:moreBtn];
    moreBtn.frame = CGRectMake((SCREEN_WIDTH-100)/2, _loginBtn.bottom+10, 100, 14);
    [moreBtn setTitle:NSLocalizedString(@"更多", nil) forState:UIControlStateNormal];
    [moreBtn setTitleColor:[UIColor colorWithRed:109/255.0 green:109/255.0 blue:109/255.0 alpha:1/1.0] forState:UIControlStateNormal];
    moreBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
    [moreBtn addTarget:self action:@selector(moreBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark - actions
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
    NSString *_userTextField = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhoneNum"];
    NSString *_areaTextField = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"area_Num%@", _userTextField]];
    NSString *countryCode = [[_areaTextField componentsSeparatedByString:@"+"] lastObject];

    NSDictionary *parameters = @{@"countryCode": countryCode,
                                 @"mobile": _userTextField,
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
            _VcodeTextField.frame = CGRectMake(20, _numLab.bottom+65, SCREEN_WIDTH-40-countDownRect.size.width-30, 40);
            _countDownBtn.frame = CGRectMake(_VcodeTextField.right + 10, _numLab.bottom+65, countDownRect.size.width+20, 40);
            self.countDownBtn.enabled = YES;
            self.countDownBtn.backgroundColor = [UIColor colorWithRed:74/255.0 green:144/255.0 blue:226/255.0 alpha:1/1.0];
            [self.countDownBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.countDownBtn setTitle:NSLocalizedString(@"发送验证码",nil) forState:UIControlStateNormal];

        }else{
            CGRect countDownRect = [[ZFGlobleManager getGlobleManager] getStringWidthAndHeightWithStr:NSLocalizedString(@"60s", nil) withFont:[UIFont fontWithName:@"PingFangSC-Regular" size:14]];
            _VcodeTextField.frame = CGRectMake(20, _numLab.bottom+65, SCREEN_WIDTH-40-countDownRect.size.width-30, 40);
            _countDownBtn.frame = CGRectMake(_VcodeTextField.right + 10, _numLab.bottom+65, countDownRect.size.width+20, 40);
            self.countDownBtn.enabled = NO;
            self.countDownBtn.backgroundColor = [UIColor clearColor];
            [self.countDownBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0] forState:UIControlStateNormal];
            [self.countDownBtn setTitle:[NSString stringWithFormat:@"%lis",totoalSecond] forState:UIControlStateNormal];
        }
    }];
}

- (void)clickLoginBtn {
    [self getSessionID:@"login"];
}

- (void)moreBtnAction:(UIButton *)sender {
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
          UIAlertAction *cancle = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消",nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action) {
              
          }];
    
          UIAlertAction *camera = [UIAlertAction actionWithTitle:NSLocalizedString(@"指纹登录", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
              ZFFingerprintLoginViewController *loginVC = [[ZFFingerprintLoginViewController alloc] init];
              ZFNavigationController *navi = [[ZFNavigationController alloc] initWithRootViewController:loginVC];
              [UIApplication sharedApplication].keyWindow.rootViewController = navi;
          }];
          
          UIAlertAction *picture = [UIAlertAction actionWithTitle:NSLocalizedString(@"切换/注册账号",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
              ZFLoginViewController *loginVC = [[ZFLoginViewController alloc] init];
              ZFNavigationController *navi = [[ZFNavigationController alloc] initWithRootViewController:loginVC];
              [UIApplication sharedApplication].keyWindow.rootViewController = navi;
              loginVC.isPushStr = @"2";
              [ZFGlobleManager getGlobleManager].loginVC = loginVC;
          }];
          [alertVc addAction:cancle];
          [alertVc addAction:camera];
          [alertVc addAction:picture];
          [self presentViewController:alertVc animated:YES completion:nil];
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

#pragma mark 获取临时sessionID
- (void)getSessionID:(NSString *)isWhat {
    if (![self userInputIsRight:isWhat]) {
        return;
    }
    NSString *_userTextField = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhoneNum"];
    NSString *_areaTextField = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"area_Num%@", _userTextField]];
    NSString *countryCode = [[_areaTextField componentsSeparatedByString:@"+"] lastObject];
    NSDictionary *parameters = @{@"countryCode": countryCode,
                                  @"mobile": _userTextField,
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
    
    NSString *_userTextField = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhoneNum"];
    NSString *_areaTextField = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"area_Num%@", _userTextField]];
    NSString *password = [NSString stringWithFormat:@"%@",_VcodeTextField.text];
    if ([isWhat isEqualToString:@"auto"]) password = @"";

    NSString *countryCode = [[_areaTextField componentsSeparatedByString:@"+"] lastObject];
    NSDictionary *parameters = @{@"countryCode": countryCode,
                                 @"mobile": _userTextField,
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
            
            [ZFGlobleManager getGlobleManager].loginVC = self;
            // 解密secretKey得到3DES的key
            // 此处的处理与获取临时securityKey时不同，此处使用3DES解密，解密的key为app生成的24位随机数）
            NSString *securityKey = [TripleDESUtils getDecryptWithString:[requestResult objectForKey:@"securityKey"] keyString: random24Key ivString: @"01234567"];
            // 保存secreykey
            [ZFGlobleManager getGlobleManager].securityKey = securityKey;
            [ZFGlobleManager getGlobleManager].sessionID = [requestResult objectForKey:@"sessionID"];
            [ZFGlobleManager getGlobleManager].userPhone = _userTextField;
            [ZFGlobleManager getGlobleManager].areaNum = countryCode;
            [ZFGlobleManager getGlobleManager].userKey = uuid.uuid;
            
            //随机数和时间差 （时间差是手机端时间和服务端时间差值）
            [ZFGlobleManager getGlobleManager].ramdom = [requestResult objectForKey:@"randomNo"];
            [ZFGlobleManager getGlobleManager].timeDiff = [self timeDiffWith:[requestResult objectForKey:@"upopTime"]];
            
            [self jumpToMain];
        } else {

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

#pragma mark 检测是否可以自动登录
- (void)checkAutoLogin{
    NSString *phoneNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhoneNum"];
    [ZFGlobleManager getGlobleManager].userPhone = phoneNum;
    NSString *areaNum = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"area_Num%@", phoneNum]];
    if (phoneNum && areaNum) {
        [self getSessionID:@"auto"];
    }
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

#pragma mark 获取手机区号
- (void)getCountryCode:(NSInteger)flag {
    NSDictionary *parameters = @{@"txnType": @"35"};
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
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
            //把区号保存到本地 防止下次无网络列表空白
            [[ZFGlobleManager getGlobleManager] saveAreaNumArray:areaArray];
            NSString *countryStr = areaArray[0];
            NSString *phoneNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhoneNum"];
            NSString *areaNum = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"area_Num%@", phoneNum]];
            if (areaNum) {
                NSString *code = [[areaNum componentsSeparatedByString:@"+"] lastObject];
                for (NSString *str in areaArray) {//避免改变语言后退出显示没改变
                    if ([str hasSuffix:code]) {
                        countryStr = str;
                        break;
                    }
                }
            }
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

#pragma mark 校验信息
-(BOOL) userInputIsRight:(NSString *)isWhat {
    NSString *password = self.VcodeTextField.text;
    NSString *errorMessage = @"";
    if ([isWhat isEqualToString:@"login"] && (!password || password.length == 0)) {
        errorMessage = NSLocalizedString(@"请输入验证码", nil);
        [[MBUtils sharedInstance] showMBMomentWithText:errorMessage inView:self.view];
        return NO;
    }
    
    if ([isWhat isEqualToString:@"smscode"]) {
        return YES;
    }

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *autoLogin = [userDefaults objectForKey:@"autoLogin"];
    if ([autoLogin isEqualToString:@"1"] && (!password || password.length == 0) ) {
        return NO;
    }
    return YES;
}
@end
