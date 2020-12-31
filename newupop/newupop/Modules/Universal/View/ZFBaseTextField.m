//
//  ZFBaseTextField.m
//  newupop
//
//  Created by 中付支付 on 2017/8/31.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFBaseTextField.h"

@implementation ZFBaseTextField

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 5;
        self.backgroundColor = UIColorFromRGB(0xeeeeee);
        self.font = [UIFont systemFontOfSize:14];
        //paddingTop  paddingLeft  paddingBottom  paddingRight
        //[self setValue:[NSNumber numberWithInt:10] forKey:@"paddingLeft"];
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        self.leftViewMode = UITextFieldViewModeAlways;
        self.leftView = leftView;
    }
    return self;
}

- (void)setStyle{
    self.layer.cornerRadius = 5;
    self.backgroundColor = UIColorFromRGB(0xeeeeee);
    self.font = [UIFont systemFontOfSize:14];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.leftViewMode = UITextFieldViewModeAlways;
    self.leftView = leftView;
}

@end
