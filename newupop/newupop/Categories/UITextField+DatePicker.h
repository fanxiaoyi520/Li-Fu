//
//  UITextField+DatePicker.h
//  newupop
//
//  Created by 中付支付 on 2017/8/8.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (DatePicker)

@property (nonatomic, assign) BOOL datePickerInput;

+ (UIDatePicker *)sharedDatePicker;

@end
