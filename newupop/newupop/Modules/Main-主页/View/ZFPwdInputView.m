//
//  ZFPwdInputView.m
//  newupop
//
//  Created by 中付支付 on 2017/8/9.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFPwdInputView.h"


@implementation ZFPwdInputView
{
    NSMutableArray *pointArray;
    //NOCutTextField *textField;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self createView];
    }
    return self;
}

#pragma mark 创建视图
- (void)createView{
    pointArray = [[NSMutableArray alloc] init];
    CGFloat width = self.width/6;
    CGFloat height = self.height;
    
    for (NSInteger i = 0; i < 6; i++) {
        UIImageView *backImage = [[UIImageView alloc] initWithFrame:CGRectMake(i*width, 0, width, height)];
        backImage.image = [UIImage imageNamed:@"password_back"];
        backImage.layer.cornerRadius = 5;
        backImage.clipsToBounds = YES;
        [self addSubview:backImage];
        
        UIImageView *pointImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        pointImage.center = CGPointMake(width/2, height/2);
        pointImage.image = [UIImage imageNamed:@"password_point"];
        pointImage.hidden = YES;
        [backImage addSubview:pointImage];
        
        [pointArray addObject:pointImage];
    }
    
    _textField = [[NOCutTextField alloc] initWithFrame:CGRectMake(0, 0, self.width, height)];
    _textField.tintColor = [UIColor clearColor];
    _textField.textColor = [UIColor clearColor];
    //_textField.placeholder = @"请输入密码";
    _textField.keyboardType = UIKeyboardTypeNumberPad;
    _textField.font = [UIFont systemFontOfSize:1];
    [_textField addTarget:self action:@selector(inputPwd) forControlEvents:UIControlEventEditingChanged];
    [self addSubview:_textField];
}

#pragma mark 输入监听并回掉
- (void)inputPwd{
    NSString *inputStr = _textField.text;
    if (inputStr.length == 6) {
        [_textField resignFirstResponder];
    }
    if (inputStr.length > 6) {
        _textField.text = [inputStr substringToIndex:6];
        inputStr = _textField.text;
        [_textField resignFirstResponder];
    }
    
    [self drowPointWith:inputStr.length];
    
    if (!self.tag) {
        
        [self.delegate inputString:inputStr];
    }
    
    //多个密码输入框时
    if (self.tag) {
        
        [self.delegate inputString:inputStr tag:self.tag];
    }
}

#pragma mark 显示隐藏黑点
- (void)drowPointWith:(NSInteger)length{
    for (NSInteger i = 0; i < 6; i++) {
        if (i < length) {
            [pointArray[i] setHidden:NO];
        } else {
            [pointArray[i] setHidden:YES];
        }
    }
}

@end
