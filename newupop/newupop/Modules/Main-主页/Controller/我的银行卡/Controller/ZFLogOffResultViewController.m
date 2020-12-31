//
//  ZFLogOffResultViewController.m
//  newupop
//
//  Created by Jellyfish on 2017/12/21.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFLogOffResultViewController.h"

@interface ZFLogOffResultViewController ()

@end

@implementation ZFLogOffResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myTitle = NSLocalizedString(@"注销实名信息", nil);
    
    [self creatView];
    [ZFGlobleManager getGlobleManager].isChanged = YES;
}

- (void)creatView {
    UIImageView *resultView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"paySuccess_icon"]];
    resultView.frame = CGRectMake((SCREEN_WIDTH-100)/2, SCREEN_HEIGHT*0.16+IPhoneXTopHeight, 100, 100);
    [self.view addSubview:resultView];
    
    UILabel *resultL = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(resultView.frame)+20, SCREEN_WIDTH, 20)];
    resultL.font = [UIFont systemFontOfSize:17.0];
    resultL.textColor = MainFontColor;
    resultL.textAlignment = NSTextAlignmentCenter;
    resultL.text = NSLocalizedString(@"原身份信息已注销", nil);
    [self.view addSubview:resultL];
    
    UIButton *resultBtn = [[UIButton alloc] initWithFrame:CGRectMake(40, SCREEN_HEIGHT*0.8-44, SCREEN_WIDTH-80, 44)];
    [resultBtn setTitle:NSLocalizedString(@"确认", nil) forState:UIControlStateNormal];
    [resultBtn setTitleColor:MainThemeColor forState:UIControlStateNormal];
    resultBtn.titleLabel.font = [UIFont systemFontOfSize:17.0];
    resultBtn.backgroundColor = [UIColor whiteColor];
    resultBtn.layer.cornerRadius = 5.0f;
    resultBtn.layer.borderColor = MainThemeColor.CGColor;
    resultBtn.layer.borderWidth = 1.0f;
    [resultBtn addTarget:self action:@selector(resultBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resultBtn];
}


- (void)resultBtnClicked {
    // 返回银行卡列表页面
    [self.navigationController popViewControllerAnimated:YES];
}

@end
