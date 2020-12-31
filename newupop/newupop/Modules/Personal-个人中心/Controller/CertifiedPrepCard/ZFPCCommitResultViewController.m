//
//  ZFPCCommitResultViewController.m
//  newupop
//
//  Created by Jellyfish on 2020/1/7.
//  Copyright © 2020 中付支付. All rights reserved.
//

#import "ZFPCCommitResultViewController.h"

@interface ZFPCCommitResultViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMargin;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@end

@implementation ZFPCCommitResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenBack = YES;
    self.myTitle = NSLocalizedString(@"提交", nil);
    
    _backButton.backgroundColor = MainThemeColor;
    [_backButton setTitle:NSLocalizedString(@"返回", nil) forState:UIControlStateNormal];
    _bottomMargin.constant = IPhoneXTabBarHeight - 30;
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (IBAction)backVC:(id)sender {
    [ZFGlobleManager getGlobleManager].pcCommitSuccess = YES;
    [ZFGlobleManager getGlobleManager].isChanged = YES;
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:(self.navigationController.viewControllers.count-3)] animated:YES];
}


@end
