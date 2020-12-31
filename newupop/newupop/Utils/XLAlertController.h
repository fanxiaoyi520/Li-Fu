//
//  XLAlertController.h
//  newupop
//
//  Created by Jellyfish on 2017/7/27.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XLAlertController : UIAlertController

/**
 *  自定义"确定"按钮名称, "确定"按钮没有动作的UIAlertController
 */
+ (void)acWithMessage:(NSString *)msg confirmBtnTitle:(NSString *)confirmTitle;


/**
 *  自定义"确定"按钮名称, "确定"按钮有动作的UIAlertController
 */
+ (void)acWithMessage:(NSString *)msg confirmBtnTitle:(NSString *)confirmTitle confirmAction:(void (^)(UIAlertAction *action))confirmAction;


/**
 *  自定义title, "确定"按钮,"取消"按钮, "确定"按钮有动作的UIAlertController
 */
+ (void)acWithTitle:(NSString *)title msg:(NSString *)msg confirmBtnTitle:(NSString *)confirmTitle cancleBtnTitle:(NSString *)cancleTitle confirmAction:(void (^)(UIAlertAction *action))confirmAction;


/**
 *  自定义title,"确定"按钮,"取消"按钮, 点击按钮都有动作的的UIAlertController
 */
+ (void)acWithTitle:(NSString *)title message:(NSString *)message confirmBtnTitle:(NSString *)confirmTitle cancleBtnTitle:(NSString *)cancleTitle confirmAction:(void (^)(UIAlertAction *action))confirmAction cancleAction:(void (^)(UIAlertAction *action))cancleAction;


@end
