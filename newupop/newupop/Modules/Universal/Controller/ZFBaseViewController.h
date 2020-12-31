//
//  ZFBaseViewController.h
//  StatePay
//
//  Created by Jellyfish on 17/3/13.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ZFBaseViewController : UIViewController

/** 导航栏下面的横线,子类可自定义是否影藏 */
@property (nonatomic, weak) UIImageView *navBarHairlineImageView;

// 推出下一个控制器
- (void)pushViewController:(UIViewController *)vc;

///隐藏返回按钮
@property (nonatomic, assign)BOOL isHiddenBack;

// 自定义导航栏标题
@property(nonatomic, copy) NSString *myTitle;
// 返回箭头按钮图片名称
@property(nonatomic, copy) NSString *backArrowImageName;

/** 顶部背景颜色 **/
@property(nonatomic, strong) UIColor *naviBgColor;

/** 返回按钮字体颜色 **/
@property(nonatomic, strong) UIColor *backBtnFontColor;

/** 字体颜色 **/
@property(nonatomic, strong) UIColor *titleColor;

// 注意:只有添加了title,重写此方法才有效
- (void)setupRightBarButtonItemWithTitle:(NSString *)title action:(SEL)action;


@end
