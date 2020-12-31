//
//  ZFNavigationController.m
//  StatePay
//
//  Created by Jellyfish on 17/3/13.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFNavigationController.h"
//#import "UIBarButtonItem+Extension.h"

@implementation ZFNavigationController

// 禁止旋转
- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark - 方法
+ (void)initialize
{
    // 设置所有的NavigationBar的title字体属性
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:19.0], NSForegroundColorAttributeName : [UIColor blackColor]}];
    // 顶部状态栏黑色
    [[UINavigationBar appearance] setBarStyle:UIBarStyleDefault];
}

// 设置顶部白色状态栏
//- (UIStatusBarStyle)preferredStatusBarStyle {
//    return UIStatusBarStyleLightContent;
//}

/**
 拦截push操作

 @param viewController 将要push入栈的控制器
 @param animated 是否动画入栈
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
//        viewController.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(backBeforeVC) image:@"back_white" highlightedImage:@"back_white"];
    } else {
        // 设置透明颜色才一致
        self.navigationBar.translucent = NO;
    }
    [super pushViewController:viewController animated:YES];
}


#pragma mark -- 点击方法
- (void)backBeforeVC
{
    [self popViewControllerAnimated:YES];
    DLog(@"返回上一个VC");
}

@end
