//
//  ZFSetFingerprintViewController.m
//  newupop
//
//  Created by FANS on 2020/11/26.
//  Copyright © 2020 中付支付. All rights reserved.
//

#import "ZFSetFingerprintViewController.h"

@interface ZFSetFingerprintViewController ()

@property (nonatomic ,strong)UISwitch *mySwitch;
@end

@implementation ZFSetFingerprintViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"0" forKey:@"isFirstLogin"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = NSLocalizedString(@"指纹设置", nil);
    self.view.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1/1.0];
    [self creatView];
}

- (void)creatView {
    UIView *backView = [UIView new];
    [self.view addSubview:backView];
    backView.backgroundColor = [UIColor whiteColor];
    backView.frame = CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, 44);
    backView.userInteractionEnabled = YES;
    
    CGRect titleRect = [[ZFGlobleManager getGlobleManager] getStringWidthAndHeightWithStr:NSLocalizedString(@"指纹登录",nil) withFont:[UIFont fontWithName:@"PingFangSC-Regular" size:16]];
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.frame = CGRectMake(20, 14, titleRect.size.width, titleRect.size.height);
    titleLab.text = NSLocalizedString(@"指纹登录",nil);
    titleLab.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    titleLab.textColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1/1.0];
    [backView addSubview:titleLab];
    
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSString *isOPen = [userDefaults objectForKey:@"isOPen"];
    UISwitch *mySwitch = [[UISwitch alloc] init];
    [backView addSubview:mySwitch];
    mySwitch.frame = CGRectMake(SCREEN_WIDTH-44-20, 9, 44, 26);
    mySwitch.onTintColor = [UIColor colorWithRed:78/255.0 green:145/255.0 blue:223/255.0 alpha:1/1.0];
    [mySwitch addTarget:self action:@selector(switchedAction:) forControlEvents:UIControlEventValueChanged];
    self.mySwitch = mySwitch;
    //if ([isOPen isEqualToString:@"1"]) self.mySwitch.on = YES;
    NSArray *personArr = [[[ZFGlobleManager getGlobleManager] getdb] jq_lookupTable:@"user" dicOrModel:[ZFLogin class] whereFormat:[NSString stringWithFormat:@"where name = '%@'",[[NSUserDefaults standardUserDefaults] objectForKey:@"userPhoneNum"]]];
    if (personArr.count == 0) {
        ZFLogin *login = [ZFLogin new];
        login.isOpen = @"0";
        login.name = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhoneNum"];
        [[[ZFGlobleManager getGlobleManager] getdb] jq_insertTable:@"user" dicOrModel:login];
    } else {
        ZFLogin *login = personArr[0];
        if ([login.isOpen isEqualToString:@"1"]) {
            self.mySwitch.on = YES;
        } else {
            self.mySwitch.on = NO;
            [self checkFingerprint];
        }
    }
    
    UILabel *tipsLab = [[UILabel alloc] init];
    tipsLab.text = NSLocalizedString(@"温馨提示",nil);
    tipsLab.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    tipsLab.textColor = [UIColor colorWithRed:140/255.0 green:140/255.0 blue:140/255.0 alpha:1/1.0];
    [self.view addSubview:tipsLab];
    tipsLab.frame = CGRectMake(20, backView.bottom+12, 100, 20);
    
    UITextView *tipsTextView = [[UITextView alloc] init];
    [self.view addSubview:tipsTextView];
    tipsTextView.frame = CGRectMake(20, tipsLab.bottom+6, SCREEN_WIDTH-40, 300);
    tipsTextView.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    tipsTextView.backgroundColor = [UIColor clearColor];
    tipsTextView.contentInset = UIEdgeInsetsMake(0, -5, 0, -5);
    tipsTextView.textColor = [UIColor colorWithRed:140/255.0 green:140/255.0 blue:140/255.0 alpha:1/1.0];
    tipsTextView.text =NSLocalizedString( @"1.您手机系统里所有解锁指纹均可登录此APP，请注意留存您本人的指纹。\n2.若手机解锁指纹发生变化，需要重新开通指纹登录功能。\n3.该设置只对本机有效，在其他手机上登录时需重新开通。",nil);
    tipsTextView.userInteractionEnabled = NO;
}

#pragma mark - actions
- (void)switchedAction:(UISwitch *)sender {
    NSLog(@"Switch current state %@", sender.on ? @"On" : @"Off");
    if (sender.on == YES) {
        [self checkFingerprint];
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"温馨提示",nil)
                                                                       message:NSLocalizedString(@"确认关闭指纹登录？",nil)
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消",nil) style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                              self.mySwitch.on = YES;
                                                              [userDefaults setObject:@"1" forKey:@"isOPen"];
                                                              }];
        UIAlertAction* sureAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确认",nil) style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                              self.mySwitch.on = NO;
                                                              [userDefaults setObject:@"0" forKey:@"isOPen"];
                                                              ZFLogin *login = [ZFLogin new];
                                                              login.isOpen = @"0";
                                                              [[[ZFGlobleManager getGlobleManager] getdb] jq_updateTable:@"user" dicOrModel:login whereFormat:[NSString stringWithFormat:@"where name = '%@'",[[NSUserDefaults standardUserDefaults] objectForKey:@"userPhoneNum"]]];
                                                              }];
        [defaultAction setValue:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0] forKey:@"_titleTextColor"];
        [alert addAction:defaultAction];
        [alert addAction:sureAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)checkFingerprint {
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0) {
        Alert(self,NSLocalizedString(@"提示",nil), NSLocalizedString(@"系统版本不支持TouchID",nil));
        return;
    }
    
    LAContext *context = [[LAContext alloc] init];
    context.localizedFallbackTitle = @"";
    NSError *error = nil;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error] && [SmallUtils supportTouchsDevicesAndSystem] == YES) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:NSLocalizedString(@"请验证已有指纹，用于开启登录",nil) reply:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.mySwitch.on = YES;
                    [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"开启成功", nil) inView:self.view];
                    [userDefaults setObject:@"1" forKey:@"isOPen"];
                    
                    ZFLogin *login = [ZFLogin new];
                    login.isOpen = @"1";
                    [[[ZFGlobleManager getGlobleManager] getdb] jq_updateTable:@"user" dicOrModel:login whereFormat:[NSString stringWithFormat:@"where name = '%@'",[[NSUserDefaults standardUserDefaults] objectForKey:@"userPhoneNum"]]];
                });
            } else if(error){
                switch (error.code) {
                    case LAErrorAuthenticationFailed:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            Alert(self,NSLocalizedString(@"提示",nil), NSLocalizedString(@"TouchID 验证失败",nil));
                            self.mySwitch.on = NO;
                            [userDefaults setObject:@"0" forKey:@"isOPen"];
                        });
                        break;
                    }
                    case LAErrorUserCancel:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            Alert(self,NSLocalizedString(@"提示",nil), NSLocalizedString(@"TouchID 被用户手动取消",nil));
                            self.mySwitch.on = NO;
                            [userDefaults setObject:@"0" forKey:@"isOPen"];
                        });
                    }
                        break;
                    case LAErrorUserFallback:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            Alert(self,NSLocalizedString(@"提示",nil), NSLocalizedString(@"用户不使用TouchID,选择手动输入密码",nil));
                            self.mySwitch.on = NO;
                            [userDefaults setObject:@"0" forKey:@"isOPen"];
                        });
                    }
                        break;
                    case LAErrorSystemCancel:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            Alert(self,NSLocalizedString(@"提示",nil), NSLocalizedString(@"TouchID 被系统取消 (如遇到来电,锁屏,按了Home键等)",nil));
                            self.mySwitch.on = NO;
                            [userDefaults setObject:@"0" forKey:@"isOPen"];
                        });
                    }
                        break;
                    case LAErrorPasscodeNotSet:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            Alert(self,NSLocalizedString(@"提示",nil), NSLocalizedString(@"TouchID 无法启动,因为用户没有设置密码",nil));
                            self.mySwitch.on = NO;
                            [userDefaults setObject:@"0" forKey:@"isOPen"];
                        });
                    }
                        break;
                    case LAErrorTouchIDNotEnrolled:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            Alert(self,NSLocalizedString(@"提示",nil), NSLocalizedString(@"TouchID 无法启动,因为用户没有设置TouchID",nil));
                            self.mySwitch.on = NO;
                            [userDefaults setObject:@"0" forKey:@"isOPen"];
                        });
                    }
                        break;
                    case LAErrorTouchIDNotAvailable:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            Alert(self,NSLocalizedString(@"提示",nil), NSLocalizedString(@"TouchID 无效",nil));
                            self.mySwitch.on = NO;
                            [userDefaults setObject:@"0" forKey:@"isOPen"];
                        });
                    }
                        break;
                    case LAErrorTouchIDLockout:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"TouchID 被锁定(连续多次验证TouchID失败,系统需要用户手动输入密码)");
                            UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"温馨提示",nil)
                                                                                           message:NSLocalizedString(@"指纹验证失败次数过多\n请稍后再试",nil)
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction* sureAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确认",nil) style:UIAlertActionStyleDefault
                                                                                  handler:^(UIAlertAction * action) {
                                                                                  self.mySwitch.on = NO;
                                [userDefaults setObject:@"0" forKey:@"isOPen"];
                                                                                  }];
                            [alert addAction:sureAction];
                            [self presentViewController:alert animated:YES completion:nil];
                        });
                    }
                        break;
                    case LAErrorAppCancel:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            Alert(self,NSLocalizedString(@"提示",nil), NSLocalizedString(@"当前软件被挂起并取消了授权 (如App进入了后台等)",nil));
                            self.mySwitch.on = NO;
                            [userDefaults setObject:@"0" forKey:@"isOPen"];
                        });
                    }
                        break;
                    case LAErrorInvalidContext:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                Alert(self,NSLocalizedString(@"提示",nil), NSLocalizedString(@"当前软件被挂起并取消了授权 (LAContext对象无效)",nil));
                            });
                            self.mySwitch.on = NO;
                            [userDefaults setObject:@"0" forKey:@"isOPen"];
                        });
                    }
                        break;
                    default:
                        break;
                }
            }
        }];
        
    }else{
        NSLog(@"当前设备不支持TouchID");
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
        self.mySwitch.on = NO;
        [userDefaults setObject:@"0" forKey:@"isOPen"];
    }
    [userDefaults synchronize];
}
@end
