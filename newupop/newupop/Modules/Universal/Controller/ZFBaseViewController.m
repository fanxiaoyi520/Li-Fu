//
//  ZFBaseViewController.m
//  StatePay
//
//  Created by Jellyfish on 17/3/13.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"


@interface ZFBaseViewController () <UIGestureRecognizerDelegate>
/** 顶部背景视图 **/
@property(nonatomic, weak) UIView *naviBgView;
/** 导航栏title **/
@property(nonatomic, weak) UILabel *naviTitle;
/** 返回按钮 **/
@property(nonatomic, weak) UIButton *backBtn;

/** 返回箭头按钮 */
@property(nonatomic, weak) UIImageView *backImage;

@end

@implementation ZFBaseViewController

#pragma mark -- 生命周期


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 子类没设置的话默认导航栏背景颜色:白色
    //    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setHidden:YES];
    
    // 设置:基础页面统一隐藏导航栏下面的横线
    self.navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    // 默认隐藏导航栏下面的横线
    self.navBarHairlineImageView.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.navigationController.viewControllers.count > 1) {
        // 添加向右滑动返回上一级页面手势
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    } else {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    [self setExclusiveTouchForButtons:self.view];
}

/// 当前界面已经消失,取消网络请求
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [NetworkEngine cancelAllNetworkAciton];
}

#pragma mark -- 初始化方法
- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

// 有设置标题才添加,只要子类重写了此方法,就添加返回按钮和标题
- (void)setMyTitle:(NSString *)myTitle {
    if (_naviTitle) {//只创建一次
        self.naviTitle.text = NSLocalizedString(myTitle, myTitle);
        return;
    }
    if (myTitle.length > 0) {
        
        // 顶部背景视图
        UIView *naviBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, IPhoneXTopHeight)];;
        naviBgView.backgroundColor = MainThemeColor;
        [self.view addSubview:naviBgView];
        self.naviBgView = naviBgView;
        
        // title
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, IPhoneXStatusBarHeight, SCREEN_WIDTH, 44)];
        title.text = myTitle;
        title.text = NSLocalizedString(myTitle, myTitle);
        title.backgroundColor = [UIColor clearColor];
        title.textAlignment = NSTextAlignmentCenter;
        title.textColor = [UIColor whiteColor];
        title.font = [UIFont boldSystemFontOfSize:18.0];
        [naviBgView addSubview:title];
        self.naviTitle = title;

        //默认导航栏颜色
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        
        if (_isHiddenBack) {
            return;
        }
        
        // 返回按钮
        UIImageView *backImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 33+IPhoneXStatusBarHeightInterval, 12, 20)];
        backImage.image = [UIImage imageNamed:@"nave_back"];
        [naviBgView addSubview:backImage];
        self.backImage = backImage;
        
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0, IPhoneXStatusBarHeight, 80, 44);
        [backBtn setTitle:@"" forState:UIControlStateNormal];
        [backBtn setTitleColor:MainFontColor forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
        [naviBgView addSubview:backBtn];
        self.backBtn = backBtn;
    }
}

// 注意:只有添加了title,重写此方法才有效
- (void)setupRightBarButtonItemWithTitle:(NSString *)title action:(SEL)action {
    if (title.length > 0) {
        //注册按钮
        UIButton *registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        registerBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        registerBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        registerBtn.frame = CGRectMake(SCREEN_WIDTH-130, IPhoneXStatusBarHeight, 110, 44);
        [registerBtn setTitle:title forState:UIControlStateNormal];
        registerBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [registerBtn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
        [self.naviBgView addSubview:registerBtn];
    }
}

- (void)setNaviBgColor:(UIColor *)naviBgColor {
    self.naviBgView.backgroundColor = naviBgColor;
    //改变状态栏颜色
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
}

- (void)setTitleColor:(UIColor *)titleColor {
    self.naviTitle.textColor = titleColor;
}

- (void)setBackArrowImageName:(NSString *)backArrowImageName
{
    self.backImage.image = [UIImage imageNamed:backArrowImageName];
}

- (void)setBackBtnFontColor:(UIColor *)BackBtnFontColor {
    [self.backBtn setTitleColor:BackBtnFontColor forState:UIControlStateNormal];
}

-(void)setExclusiveTouchForButtons:(UIView *)myView
{
    for (UIView * v in [myView subviews]) {
        if([v isKindOfClass:[UIButton class]])
            [((UIButton *)v) setExclusiveTouch:YES];
        else if ([v isKindOfClass:[UIView class]]){
            [self setExclusiveTouchForButtons:v];
        }
    }
}


#pragma mark -- 给子类提供的方法
- (void)pushViewController:(UIViewController *)vc {
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)popViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
