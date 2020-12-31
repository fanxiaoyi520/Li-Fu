//
//  ZFPwdInputView.h
//  newupop
//
//  Created by 中付支付 on 2017/8/9.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NOCutTextField.h"

@protocol InputPwdDelegate <NSObject>


@optional
- (void)inputString:(NSString *)password;
- (void)inputString:(NSString *)passWord tag:(NSInteger)tag;

@end

@interface ZFPwdInputView : UIView
@property (nonatomic, strong)NOCutTextField *textField;
@property (nonatomic, weak)id<InputPwdDelegate>delegate;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)inputPwd;

@end
