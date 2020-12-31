//
//  AppDelegate.m
//  newupop
//
//  Created by Jellyfish on 2017/7/20.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "AppDelegate.h"
#import "IQKeyboardManager.h"
#import "LocationUtils.h"
#import "UIWindow+Extension.h"
#import <Bugly/Bugly.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

// cn.qtopay.unionpay
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
        }
    } failure:^(NSError *error) {
        //[[MBUtils sharedInstance] dismissMB];
    }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //启动页时间
    [NSThread sleepForTimeInterval:0.5];
    
    dispatch_async(dispatch_get_global_queue(0,0),^{
        [self getCountryCode];
    });
    [[UIButton appearance] setExclusiveTouch:YES];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window switchRootViewController];
    [self.window makeKeyAndVisible];
    
    // 位置获取
    [[LocationUtils sharedInstance] startLocation];
    
    //监控网络状态
    [NetworkEngine getNetStatus];
    
    //初始化bugly
    [self setupBugly];
    
    [self setupIQKeyBoard];
    return YES;
}

#pragma mark bugly
- (void)setupBugly{
    BuglyConfig *config = [[BuglyConfig alloc]init];
#if DEBUG
    config.reportLogLevel = BuglyLogLevelDebug;
#else
    config.reportLogLevel = BuglyLogLevelWarn;
#endif
    config.symbolicateInProcessEnable = YES;
    //自定义版本号
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    config.version = app_Version;
    [Bugly startWithAppId:Bugly_appid config:config];
}

/**
 设置键盘管理器
 */
- (void)setupIQKeyBoard{
    IQKeyboardManager *keyboardManager = [IQKeyboardManager sharedManager];
    // 控制整个功能是否启用
    keyboardManager.enable = YES;
    // 控制点击背景是否收起键盘
    keyboardManager.shouldResignOnTouchOutside = YES;
    // 输入框距离键盘的距离
    keyboardManager.keyboardDistanceFromTextField = 10.0f;
    
    // 控制键盘上的工具条文字颜色是否用户自定义
    keyboardManager.shouldToolbarUsesTextFieldTintColor = YES;
    // 有多个输入框时，可以通过点击Toolbar 上的“前一个”“后一个”按钮来实现移动到不同的输入框
    keyboardManager.toolbarManageBehaviour = IQAutoToolbarBySubviews;
    // 控制是否显示键盘上的工具条
    keyboardManager.enableAutoToolbar = YES;
    // 是否显示占位文字
    keyboardManager.shouldShowTextFieldPlaceholder = YES;
    // 设置占位文字的字体
    keyboardManager.placeholderFont = [UIFont boldSystemFontOfSize:17];
}

@end
