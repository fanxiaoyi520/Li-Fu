//
//  XLAlertController.m
//  newupop
//
//  Created by Jellyfish on 2017/7/27.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "XLAlertController.h"


@interface XLAlertController ()

/** 弹窗 **/
@property(nonatomic, strong) UIAlertController *alertController;

@end

@implementation XLAlertController

+ (void)acWithMessage:(NSString *)msg confirmBtnTitle:(NSString *)confirmTitle
{
    [self acWithTitle:@""
                               message:msg
                       confirmBtnTitle:confirmTitle
                        cancleBtnTitle:nil
                         confirmAction:nil
                          cancleAction:nil];
}


+ (void)acWithMessage:(NSString *)msg confirmBtnTitle:(NSString *)confirmTitle confirmAction:(void (^)(UIAlertAction *action))confirmAction
{
    // 弹窗
    UIAlertController *alertvc = [UIAlertController alertControllerWithTitle:@"" message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    // 改变msg字体大小
    NSMutableAttributedString *messageAtt = [[NSMutableAttributedString alloc] initWithString:msg];
    [messageAtt addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15.0] range:NSMakeRange(0, msg.length)];
    [alertvc setValue:messageAtt forKey:@"attributedMessage"];
    
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:confirmTitle style:0 handler:^(UIAlertAction * _Nonnull action) {
        confirmAction(action);
    }];
    [alertvc addAction:confirm];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertvc animated:YES completion:nil];
}


+ (void)acWithTitle:(NSString *)title msg:(NSString *)msg confirmBtnTitle:(NSString *)confirmTitle cancleBtnTitle:(NSString *)cancleTitle confirmAction:(void (^)(UIAlertAction *action))confirmAction
{
    [self acWithTitle:title
              message:msg
       confirmBtnTitle:confirmTitle
        cancleBtnTitle:cancleTitle
         confirmAction:^(UIAlertAction *action) {
             confirmAction(action);}
          cancleAction:^(UIAlertAction *action) {
              
          }];
}

// 基础的
+ (void)acWithTitle:(NSString *)title message:(NSString *)message confirmBtnTitle:(NSString *)confirmTitle cancleBtnTitle:(NSString *)cancleTitle confirmAction:(void (^)(UIAlertAction *action))confirmAction cancleAction:(void (^)(UIAlertAction *action))cancleAction {
    
    dispatch_async(dispatch_get_main_queue(), ^{
      
        // 弹窗
        UIAlertController *alertvc = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        if (message) {
            // 改变msg字体大小
            NSMutableAttributedString *messageAtt = [[NSMutableAttributedString alloc] initWithString:message];
            [messageAtt addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15.0] range:NSMakeRange(0, message.length)];
            [alertvc setValue:messageAtt forKey:@"attributedMessage"];
        }
        
        if (cancleTitle.length != 0) // 有确定按钮
        {
            // 取消按钮,有动作
            UIAlertAction *cancle = [UIAlertAction actionWithTitle:cancleTitle style:0 handler:^(UIAlertAction * _Nonnull action) {
                cancleAction(action);
            }];
            [alertvc addAction:cancle];
            
            // 确定按钮,有动作
            UIAlertAction *confirm = [UIAlertAction actionWithTitle:confirmTitle style:0 handler:^(UIAlertAction * _Nonnull action) {
                confirmAction(action);
            }];
            [alertvc addAction:confirm];
        } else  // 没有确定按钮
        {
            // 确定按钮,没动作
            UIAlertAction *confirm = [UIAlertAction actionWithTitle:confirmTitle style:0 handler:nil];
            [alertvc addAction:confirm];
        }
        
        // 弹出
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertvc animated:YES completion:nil];
    });
}



@end
