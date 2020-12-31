//
//  ZFTabBarController.m
//  newupop
//
//  Created by 中付支付 on 2017/11/1.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFTabBarController.h"
#import "ZFNavigationController.h"
#import "ZFMainViewController.h"
#import "ZFPersonalController.h"
#import "ZFHeadScrollviewViewController.h"

@interface ZFTabBarController ()

@end

@implementation ZFTabBarController

#pragma mark - 生命周期
/**
 *  自定义UITabBarController
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    ZFMainViewController *home = [[ZFMainViewController alloc] init];
    [self addChildVc:home Title:NSLocalizedString(@"首页", nil) Image:@"tabBar1_normal" selectedImage:@"tabBar1_select"];

    ZFHeadScrollviewViewController *MyCenter = [[ZFHeadScrollviewViewController alloc] initWithHeadType:ZFHeadScrollviewTypeUpan];
    [self addChildVc:MyCenter Title:NSLocalizedString(@"优计划", nil) Image:@"tabBar2_normal" selectedImage:@"tabBar2_select"];

    ZFPersonalController *shareCenter = [[ZFPersonalController alloc] init];
    [self addChildVc:shareCenter Title:NSLocalizedString(@"我的", nil) Image:@"tabBar3_normal" selectedImage:@"tabBar3_select"];
}

#pragma mark - 方法
/**
 *  添加一个子控制器
 *
 *  @param childVc       子控制器
 *  @param title         名字
 *  @param image         图片
 *  @param selectedImage 选中时的图片
 */
- (void)addChildVc:(UIViewController *)childVc Title:(NSString *)title Image:(NSString *)image selectedImage:(NSString *)selectedImage {
    //设置子控制器的标题和图片
    // 同时设置tabbar和navigationBar的文字
    childVc.tabBarItem.title = title;
    childVc.tabBarItem.image = [UIImage imageNamed:image];
    childVc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // 默认文字样式
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSFontAttributeName] = [UIFont fontWithName:@"Helvetica" size:12.0];
    textAttrs[NSForegroundColorAttributeName] = [UIColor grayColor];
    [childVc.tabBarItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    
    // 选中文字样式
    NSMutableDictionary *selectTextAttrs = [NSMutableDictionary dictionary];
    selectTextAttrs[NSFontAttributeName] = [UIFont fontWithName:@"Helvetica" size:12.0];
    selectTextAttrs[NSForegroundColorAttributeName] = MainThemeColor;
    [childVc.tabBarItem setTitleTextAttributes:selectTextAttrs forState:UIControlStateSelected];
    //    [childVc.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -3)];
    
    // 用自定义的导航控制器包装tabBarController每一个子控制器
    ZFNavigationController *navi = [[ZFNavigationController alloc] initWithRootViewController:childVc];
    
    // 添加为子控制器
    [self addChildViewController:navi];
}



#pragma mark - 旋转
- (BOOL)shouldAutorotate {
    return NO;
}


@end
