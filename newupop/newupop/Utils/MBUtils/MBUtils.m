//
//  MBUtils.m
//  newupop
//
//  Created by Jellyfish on 2017/7/27.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "MBUtils.h"
#import "MBProgressHUD.h"


@interface MBUtils ()


/** 加载框 */
@property (nonatomic, strong) MBProgressHUD *progressHUD;

@end

@implementation MBUtils

+ (instancetype)sharedInstance
{
    static MBUtils *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MBUtils alloc] init];
    });
    return instance;
}


- (void)showMBInView:(UIView *)parentView
{
    self.progressHUD.mode = MBProgressHUDModeIndeterminate;
    self.progressHUD.labelText = nil;
    self.progressHUD.detailsLabelText = nil;
    [parentView addSubview:self.progressHUD];
    [self.progressHUD show:YES];
}


- (void)showMBMomentWithText:(NSString *)text inView:(UIView *)parentView
{
    self.progressHUD.labelText = nil;
    self.progressHUD.mode = MBProgressHUDModeText;
    self.progressHUD.detailsLabelText = text;
    [parentView addSubview:self.progressHUD];
    [self.progressHUD show:YES];
    [self.progressHUD hide:YES afterDelay:AUTODISMISSTIME];
    
    //显示完成之后去掉 防止再次显示的时候出现上次文字
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(AUTODISMISSTIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissMB];
    });
}


- (void)showMBWithText:(NSString *)text inView:(UIView *)parentView
{
    self.progressHUD.labelText = nil;
    //初始化MBProgressHUD
    self.progressHUD.mode = MBProgressHUDModeIndeterminate;
    self.progressHUD.detailsLabelText = text;
    //添加ProgressHUD到界面中
    [parentView addSubview:self.progressHUD];
    [self.progressHUD show:YES];
}

/** 自动消失, 带有成功打钩图片,自定义文字 */
- (void)showMBSuccessdWithText:(NSString *)text inView:(UIView *)parentView {
    self.progressHUD.mode = MBProgressHUDModeCustomView;
    self.progressHUD.labelText = text;
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mb_success"]];
    self.progressHUD.customView = iv;
    [parentView addSubview:self.progressHUD];
    [self.progressHUD show:YES];
    [self.progressHUD hide:YES afterDelay:AUTOTIPDISMISSTIME];
}

/** 自动消失, 带有提示图片, 自定义文字 */
- (void)showMBTipWithText:(NSString *)text inView:(UIView *)parentView {
    self.progressHUD.mode = MBProgressHUDModeCustomView;
    self.progressHUD.labelText = text;
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mb_tip"]];
    self.progressHUD.customView = iv;
    [parentView addSubview:self.progressHUD];
    [self.progressHUD show:YES];
    [self.progressHUD hide:YES afterDelay:AUTOTIPDISMISSTIME];
}


- (MBProgressHUD *)progressHUD {
    if (!_progressHUD) {
        _progressHUD = [[MBProgressHUD alloc] init];
        // 透明度
        _progressHUD.opacity = 0.7f;
        // 无遮罩
        _progressHUD.dimBackground = NO;
    }
    
    return _progressHUD;
}



/** 移除加载框 */
- (void)dismissMB
{
    [self.progressHUD hide:YES];
    [_progressHUD removeFromSuperview];
    _progressHUD = nil;
}


@end
