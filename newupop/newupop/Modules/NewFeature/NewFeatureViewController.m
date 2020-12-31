//
//  NewFeatureViewController.m
//  StatePay
//
//  Created by Jellyfish on 17/3/13.
//  Copyright © 2017年 Jellyfish. All rights reserved.
//

#import "NewFeatureViewController.h"
#import "ZFLoginViewController.h"
#import "ZFNavigationController.h"


// 新特性图片数量
#define NEWFEATUREPICTURECOUNT 3

@interface NewFeatureViewController ()<UIScrollViewDelegate, CAAnimationDelegate>
/** 跟随页面滚动的点 */
//@property (nonatomic, weak) UIPageControl *pageController;

@end

@implementation NewFeatureViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIBarStyleDefault;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIBarStyleBlack;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 添加scrollView
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:ZFSCREEN];
    scrollView.contentSize = CGSizeMake(NEWFEATUREPICTURECOUNT * SCREEN_WIDTH, 0);
    scrollView.pagingEnabled = YES;
    scrollView.bounces = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    
    // 判断系统语言
    NSString *languageStr = [NetworkEngine getCurrentLanguage];
    
    // 给scrollView添加imageView
    for (int i = 0; i < NEWFEATUREPICTURECOUNT; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:ZFSCREEN];
        NSString *imageName = @"";
        if ([languageStr isEqualToString:@"2"]) {
            imageName = [NSString stringWithFormat:@"newfeature_ch%d", i + 1];
        } else {
            imageName = [NSString stringWithFormat:@"newfeature%d", i + 1];
        }
        
        imageView.image = [UIImage imageNamed:imageName];
        imageView.x = SCREEN_WIDTH * i;
        imageView.y = 0;
        
        [scrollView addSubview:imageView];
        
        if (i == NEWFEATUREPICTURECOUNT - 1) {
            [self setupLastImageView:imageView];
        }
    }
    
    // 保存状态
    [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:@"FirstLaunch"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

/** 给最后一张image添加按钮 */
- (void)setupLastImageView:(UIImageView *)imageView {
    //开启imageView上的交互功能
    imageView.userInteractionEnabled = YES;
    
    UIButton *enterButton = [[UIButton alloc] init];
    enterButton.clipsToBounds = YES;
    if ([[NetworkEngine getCurrentLanguage] isEqualToString:@"2"]) {
        [enterButton setBackgroundImage:[UIImage imageNamed:@"newfeature_chbtn"] forState:UIControlStateNormal];
        [enterButton setBackgroundImage:[UIImage imageNamed:@"newfeature_chbtn"] forState:UIControlStateHighlighted];
    } else {
        [enterButton setBackgroundImage:[UIImage imageNamed:@"newfeaturebtn"] forState:UIControlStateNormal];
        [enterButton setBackgroundImage:[UIImage imageNamed:@"newfeaturebtn"] forState:UIControlStateHighlighted];
    }
//    [enterButton setTitle:@"立即体验" forState:UIControlStateNormal];
    enterButton.titleLabel.font = [UIFont italicSystemFontOfSize:18];
    enterButton.size = CGSizeMake(SCREEN_WIDTH*0.6, SCREEN_HEIGHT*0.07);
    enterButton.centerX = imageView.size.width * 0.5;
    enterButton.centerY = imageView.size.height * 0.85;
    [enterButton addTarget:self action:@selector(clickEnterButton) forControlEvents:UIControlEventTouchUpInside];
    [imageView addSubview:enterButton];
}

/** 进入主界面 */
- (void)clickEnterButton {
    // 动画
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    ZFLoginViewController *loginVC = [[ZFLoginViewController alloc] init];
    ZFNavigationController *navi = [[ZFNavigationController alloc] initWithRootViewController:loginVC];
    //保存登录页 退出时不用重新创建
    [ZFGlobleManager getGlobleManager].loginVC = loginVC;
    window.rootViewController = navi;
    
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

@end
