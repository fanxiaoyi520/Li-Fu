//
//  MBUtils.h
//  newupop
//
//  Created by Jellyfish on 2017/7/27.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBUtils : UIView

/**
 *  获取单例对象
 */
+ (instancetype)sharedInstance;


/** 只有菊花 用于普通加载网络 */
- (void)showMBInView:(UIView *)parentView;

/**
 *  自动消失, 只显示文字, 提示用户操作不当
 */
- (void)showMBMomentWithText:(NSString *)text inView:(UIView *)parentView;

/**
 *  非自动消失的菊花 可自行添加文字, 用于特殊提示用户加载网络
 */
- (void)showMBWithText:(NSString *)text inView:(UIView *)parentView;

/**
 *  自动消失, 带有成功打钩图片,自定义文字
 */
- (void)showMBSuccessdWithText:(NSString *)text inView:(UIView *)parentView;

/**
 *  自动消失, 带有失败提示图片, 自定义文字
 */
- (void)showMBTipWithText:(NSString *)text inView:(UIView *)parentView;

/**
 *  移除加载框
 */
- (void)dismissMB;


@end
