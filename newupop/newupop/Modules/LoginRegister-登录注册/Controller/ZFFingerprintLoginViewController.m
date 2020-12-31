//
//  ZFFingerprintLoginViewController.m
//  newupop
//
//  Created by FANS on 2020/11/26.
//  Copyright © 2020 中付支付. All rights reserved.
//

#import "ZFFingerprintLoginViewController.h"
#import "ZFVCodeLoginViewController.h"
#import "ZFNavigationController.h"
#import "ZFLoginViewController.h"
#import "ZFTabBarController.h"
#import "HBRSAHandler.h"
#import "UniversallyUniqueIdentifier.h"

@interface ZFFingerprintLoginViewController ()

@property (nonatomic, strong) NSString *securityKey;
@property (nonatomic, strong) NSString *tempSessionID;

@end

@implementation ZFFingerprintLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isHiddenBack = YES;
    self.myTitle = NSLocalizedString(@"登录", nil);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeText) name:CHANGE_LANGUAGE object:nil];
    [self getCountryCode];
    [self creatView];
}

- (void)changeText {
    [self getCountryCode];
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
    
    CGRect FPRect = [[ZFGlobleManager getGlobleManager] getStringWidthAndHeightWithStr:NSLocalizedString(@"点击进行指纹登录", nil) withFont:[UIFont fontWithName:@"PingFangSC-Medium" size:14]];
    UIView *FPBackView = [UIView new];
    [self.view addSubview:FPBackView];
    FPBackView.userInteractionEnabled = YES;
    FPBackView.frame = CGRectMake((SCREEN_WIDTH-FPRect.size.width)/2, numLab.bottom+88, FPRect.size.width, 110);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickFPBtnAction:)];
    [FPBackView addGestureRecognizer:tap];
    
    UIImageView *FPImageView = [UIImageView new];
    [FPBackView addSubview:FPImageView];
    FPImageView.frame = CGRectMake((FPBackView.width-128)/2, 0, 128, 80);
    FPImageView.image = [UIImage imageNamed:@"icon_zhiwen2"];
    FPBackView.userInteractionEnabled = YES;
    
    UIButton *clickFPBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [FPBackView addSubview:clickFPBtn];
    clickFPBtn.frame = CGRectMake(0, FPImageView.bottom+16, FPRect.size.width, 14);
    [clickFPBtn setTitle:NSLocalizedString(@"点击进行指纹登录", nil) forState:UIControlStateNormal];
    [clickFPBtn setTitleColor:[UIColor colorWithRed:73/255.0 green:144/255.0 blue:226/255.0 alpha:1/1.0] forState:UIControlStateNormal];
    clickFPBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
    
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:moreBtn];
    moreBtn.frame = CGRectMake((SCREEN_WIDTH-100)/2, FPBackView.bottom+62, 100, 14);
    [moreBtn setTitle:NSLocalizedString(@"更多", nil) forState:UIControlStateNormal];
    [moreBtn setTitleColor:[UIColor colorWithRed:109/255.0 green:109/255.0 blue:109/255.0 alpha:1/1.0] forState:UIControlStateNormal];
    moreBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
    [moreBtn addTarget:self action:@selector(moreBtnAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    sleep(1);
    [self clickFPBtnAction:nil];
}

#pragma mark - actions
- (void)clickFPBtnAction:(UIGestureRecognizer *)tap {
    LAContext* context = [[LAContext alloc] init];
    NSError* error = nil;
    context.localizedFallbackTitle = @"";
    
    NSString *userPhoneNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhoneNum"];
    NSArray *personArr = [[[ZFGlobleManager getGlobleManager] getdb] jq_lookupTable:@"user" dicOrModel:[ZFLogin class] whereFormat:[NSString stringWithFormat:@"where name = '%@'",userPhoneNum]];
    if (personArr.count == 0) {
        ZFLogin *login = [ZFLogin new];
        login.isOpen = @"0";
        login.name = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhoneNum"];
        [[[ZFGlobleManager getGlobleManager] getdb] jq_insertTable:@"user" dicOrModel:login];
    } else {
        ZFLogin *login = personArr[0];
        if ([login.isOpen isEqualToString:@"1"]) {
            [self authenticateUser];
        } else {
            if (![context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
                [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"该设备尚未录入指纹", nil) inView:self.view];
                return;
            }
            
            if ([SmallUtils supportTouchsDevicesAndSystem] == NO) {
                [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"该设备不支持指纹登录", nil) inView:self.view];
            } else {
                [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"请开启指纹登录权限后再验证", nil) inView:self.view];
            }
        }
    }
}

- (void)moreBtnAction:(UIButton *)sender {
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
          UIAlertAction *cancle = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消",nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action) {
              
          }];
    
          UIAlertAction *camera = [UIAlertAction actionWithTitle:NSLocalizedString(@"验证码登录", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
              ZFVCodeLoginViewController *loginVC = [[ZFVCodeLoginViewController alloc] init];
              loginVC.isPushStr = @"1";
              ZFNavigationController *navi = [[ZFNavigationController alloc] initWithRootViewController:loginVC];
              [UIApplication sharedApplication].keyWindow.rootViewController = navi;
          }];
          
          UIAlertAction *picture = [UIAlertAction actionWithTitle:NSLocalizedString(@"切换/注册账号",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
              ZFLoginViewController *loginVC = [[ZFLoginViewController alloc] init];
              ZFNavigationController *navi = [[ZFNavigationController alloc] initWithRootViewController:loginVC];
              [UIApplication sharedApplication].keyWindow.rootViewController = navi;
              loginVC.isPushStr = @"1";
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

#pragma mark - 开启指纹识别
- (void)authenticateUser {
    LAContext* context = [[LAContext alloc] init];
    NSError* error = nil;
    NSString* result = NSLocalizedString(@"登录APP 需要验证你的指纹",nil);
    context.localizedFallbackTitle = @"";
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error] && [SmallUtils supportTouchsDevicesAndSystem] == YES) {
        
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:result reply:^(BOOL success, NSError *error) {
            if (success) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self getSessionID];
                }];
            } else {
                NSLog(@"%@",error.localizedDescription);
                switch (error.code) {
                    case LAErrorSystemCancel:
                    {
                        NSLog(@"系统取消了验证touch id");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //Alert(self,NSLocalizedString(@"提示",nil), NSLocalizedString(@"指纹登录失败，请选择验证码登录!",nil));
                        });

                        break;
                    }
                    case LAErrorUserCancel:
                    {
                        NSLog(@"用户取消了验证");
                        break;
                    }
                    case LAErrorUserFallback:
                    {
                        NSLog(@"用户选择手动输入密码");
                        dispatch_async(dispatch_get_main_queue(), ^{
                        });
                        break;
                    }
                    default:
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            Alert(self,NSLocalizedString(@"提示",nil), NSLocalizedString(@"指纹登录失败，请选择验证码登录!",nil));
                        });
//                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                            //Alert(self,NSLocalizedString(@"提示",nil), NSLocalizedString(@"指纹登录失败，请选择验证码登录!",nil));
//                        }];
                        break;
                    }
                }
            }
        }];
    } else {
        //不支持指纹识别，LOG出错误详情
        switch (error.code) {
            case LAErrorTouchIDNotEnrolled:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    Alert(self,NSLocalizedString(@"提示",nil), NSLocalizedString(@"设备Touch ID不可用或者用户未录入！",nil));
                });

                break;
            }
            case LAErrorPasscodeNotSet:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    Alert(self,NSLocalizedString(@"提示",nil), NSLocalizedString(@"系统未设置密码",nil));
                });

                break;
            }
            default:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    Alert(self,NSLocalizedString(@"提示",nil), NSLocalizedString(@"TouchID 不可用",nil));
                });
                break;
            }
        }
    }
}

#pragma mark 获取临时sessionID
- (void)getSessionID {
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

            //登录
            [self requestLogin];
            //获取币种信息
            [self getCurrencyInfo];
        } else {
            [[MBUtils sharedInstance] dismissMB];
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark 登录请求
- (void)requestLogin{
    NSString *random24Key = [SmallUtils generate24RandomKey];
    // 检查此处的RSA算法是否存在（公钥长度引起的）内存问题
    NSString *MD5Data = [[HBRSAHandler sharedInstance] encryptWithPublicKey: random24Key];
    MD5Data = [MD5Data stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    MD5Data = [MD5Data stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    LocationUtils *loc = [LocationUtils sharedInstance];
    NSString *baseStation = [NSString stringWithFormat:@"%@-%@", loc.country, loc.city];
    UniversallyUniqueIdentifier *uuid = [UniversallyUniqueIdentifier sharedInstance];
    
    
    // 3DES加密
    NSString *_userTextField = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhoneNum"];
    NSString *_areaTextField = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"area_Num%@", _userTextField]];
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
                                 @"smsCode":@"",
                                 @"loginType":@"fingerprint_login"};
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        //请求成功
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
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
- (void)getCountryCode {
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
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(NSError *error) {
        //[[MBUtils sharedInstance] dismissMB];
    }];
}
@end
