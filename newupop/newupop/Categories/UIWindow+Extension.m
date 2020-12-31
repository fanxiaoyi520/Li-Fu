//
//  UIWindow+Extension.m
//  StatePay
//
//  Created by Jellyfish on 17/3/19.
//  Copyright © 2017年 Jellyfish. All rights reserved.
//

#import "UIWindow+Extension.h"
#import "ZFMainViewController.h"
#import "ZFNavigationController.h"
#import "ZFLoginViewController.h"
#import "NewFeatureViewController.h"
#import "NSObject+LBLaunchImage.h"
#import "ZFFingerprintLoginViewController.h"
#import "ZFVCodeLoginViewController.h"

@implementation UIWindow (Extension)

- (void)switchRootViewController {
    
//    BOOL isFirstLaunch = [[[NSUserDefaults standardUserDefaults] valueForKey:@"FirstLaunch"] boolValue];
//    if (!isFirstLaunch) {
//        self.rootViewController = [[NewFeatureViewController alloc] init];
//    } else {
//        DLog(@"------非第一次进入APP,直接进入主界面------");
    
    NSString *isFirstLogin = [[NSUserDefaults standardUserDefaults] objectForKey:@"isFirstLogin"];
    if (!isFirstLogin) {
        ZFLoginViewController *loginVC = [[ZFLoginViewController alloc] init];
        loginVC.isFirstIntoStr = @"first";
        ZFNavigationController *navi = [[ZFNavigationController alloc] initWithRootViewController:loginVC];
        self.rootViewController = navi;
        //保存登录页 退出时不用重新创建
        [ZFGlobleManager getGlobleManager].loginVC = loginVC;
        [self setupLaunchAd];
    } else {
        NSArray *personArr = [[[ZFGlobleManager getGlobleManager] getdb] jq_lookupTable:@"user" dicOrModel:[ZFLogin class] whereFormat:[NSString stringWithFormat:@"where name = '%@'",[[NSUserDefaults standardUserDefaults] objectForKey:@"userPhoneNum"]]];
        if (personArr.count == 0) {
            ZFLogin *login = [ZFLogin new];
            login.isOpen = @"0";
            login.name = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhoneNum"];
            [[[ZFGlobleManager getGlobleManager] getdb] jq_insertTable:@"user" dicOrModel:login];
            
            ZFLoginViewController *loginVC = [[ZFLoginViewController alloc] init];
            loginVC.isFirstIntoStr = @"first";
            ZFNavigationController *navi = [[ZFNavigationController alloc] initWithRootViewController:loginVC];
            self.rootViewController = navi;
            //保存登录页 退出时不用重新创建
            [ZFGlobleManager getGlobleManager].loginVC = loginVC;
            [self setupLaunchAd];
        } else {
            ZFLogin *login = personArr[0];
            if ([login.isOpen isEqualToString:@"0"]) {
                ZFVCodeLoginViewController *loginVC = [[ZFVCodeLoginViewController alloc] init];
                ZFNavigationController *navi = [[ZFNavigationController alloc] initWithRootViewController:loginVC];
                self.rootViewController = navi;
                [ZFGlobleManager getGlobleManager].loginVC = loginVC;
            } else {
                ZFFingerprintLoginViewController *loginVC = [[ZFFingerprintLoginViewController alloc] init];
                ZFNavigationController *navi = [[ZFNavigationController alloc] initWithRootViewController:loginVC];
                self.rootViewController = navi;
                [ZFGlobleManager getGlobleManager].loginVC = loginVC;
                
                [self setupLaunchAd];
            }
        }
    }
//    ZFLoginViewController *loginVC = [[ZFLoginViewController alloc] init];
//    ZFNavigationController *navi = [[ZFNavigationController alloc] initWithRootViewController:loginVC];
//    self.rootViewController = navi;
//    //保存登录页 退出时不用重新创建
//    [ZFGlobleManager getGlobleManager].loginVC = loginVC;
//
//    [self setupLaunchAd];

//    }
}

- (void)setupLaunchAd
{
    [NSObject makeLBLaunchImageAdView:^(LBLaunchImageAdView *imgAdView) {
        //设置广告的类型
        imgAdView.getLBlaunchImageAdViewType(LogoAdType);
        imgAdView.adTime = 1.5;
        //自定义跳过按钮
        imgAdView.skipBtn.hidden = YES;
        
        //设置本地启动图片
        if ([[NetworkEngine getCurrentLanguage] isEqualToString:@"2"]) {
            imgAdView.localAdImgName = @"launch_ch_ad";
        } else {
            imgAdView.localAdImgName = @"launch_en_ad";
        }
        // 广告地址
        // imgAdView.imgUrl = @"http://img.zcool.cn/community/01316b5854df84a8012060c8033d89.gif";
        //各种点击事件的回调
        imgAdView.clickBlock = ^(clickType type){
            switch (type) {
                case clickAdType:
                    DLog(@"点击广告回调");
                    break;
                    
                case skipAdType:
                case overtimeAdType:
                    DLog(@"默认进入登录页面");
                    break;
                    
                default:
                    break;
            }
        };
    }];
}


@end

