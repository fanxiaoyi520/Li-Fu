//
//  UITextField+DatePicker.m
//  newupop
//
//  Created by 中付支付 on 2017/8/8.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "UITextField+DatePicker.h"

@implementation UITextField (DatePicker)
// 1
+ (UIDatePicker *)sharedDatePicker;
{
    UIDatePicker *daterPicker = [[UIDatePicker alloc] init];
    daterPicker.datePickerMode = UIDatePickerModeDate;
    [daterPicker setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"zh_Hans_CN"]];
    NSDate *now = [NSDate date];
    daterPicker.maximumDate = now;
    [daterPicker setDate:now animated:NO];
    
    return daterPicker;
}

// 2
- (void)datePickerValueChanged:(UIDatePicker *)sender
{
    if (self.isFirstResponder)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM"];
        self.text = [formatter stringFromDate:sender.date];
    }
}

// 3
- (void)setDatePickerInput:(BOOL)datePickerInput
{
    if (datePickerInput)
    {
        self.inputView = [UITextField sharedDatePicker];
        UIButton *doneBBI = [UIButton buttonWithType:UIButtonTypeCustom];
        doneBBI.frame = CGRectMake(SCREEN_WIDTH-60, 0, 40, 40);
        [doneBBI setTitle:@"确定" forState:UIControlStateNormal];
        [doneBBI setTitleColor:ZFColor(38,158,223) forState:UIControlStateNormal];
        [doneBBI addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventTouchUpInside];
        
        // 工具栏
        UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:
                        CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        [toolbar setBarStyle:UIBarStyleDefault];
        [toolbar addSubview:doneBBI];
        self.inputAccessoryView = toolbar;
        [[UITextField sharedDatePicker] addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    else
    {
        self.inputView = nil;
        [[UITextField sharedDatePicker] removeTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
}

- (void)hideKeyboard{
    [self resignFirstResponder];
}

// 4
- (BOOL)datePickerInput
{
    return [self.inputView isKindOfClass:[UIDatePicker class]];
}
@end
