//
//  ZFSuccessController.m
//  newupop
//
//  Created by 中付支付 on 2017/7/26.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFSuccessController.h"

@interface ZFSuccessController ()

@end

@implementation ZFSuccessController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[MBUtils sharedInstance] dismissMB];
    self.myTitle = NSLocalizedString(@"设置成功", nil);
    [self createView];
}

- (void)createView{
    //图标
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    imageView.center = CGPointMake(SCREEN_WIDTH/2, 180);
    imageView.image = [UIImage imageNamed:@"paySuccess_icon"];
    [self.view addSubview:imageView];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(30, imageView.bottom+20, SCREEN_WIDTH-60, 30)];
    label1.text = NSLocalizedString(@"密码设置成功", nil);
    label1.textColor = MainThemeColor;
    label1.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(10, label1.bottom+20, SCREEN_WIDTH-20, 30)];
    label2.text = NSLocalizedString(@"您可以使用新密码进行相关操作", nil);
    label2.textColor = UIColorFromRGB(0x313131);
    label2.textAlignment = NSTextAlignmentCenter;
    label2.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:label2];
    
    //按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(40, label2.bottom+120, SCREEN_WIDTH-80, 50);
    button.layer.borderWidth = 1;
    button.layer.cornerRadius = 5;
    button.layer.borderColor = MainFontColor.CGColor;
    [button setTitle:NSLocalizedString(@"完成", nil) forState:UIControlStateNormal];
    [button setTitleColor:MainFontColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)clickBtn{
    if (_successType == 3) {//忘记登录密码
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    
    NSMutableArray *vcArr = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];
    
    [self.navigationController popToViewController:vcArr[1] animated:YES];
}



@end
