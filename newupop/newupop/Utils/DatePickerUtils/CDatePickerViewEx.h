//
//  CDatePickerViewEx.h
//  MonthYearDatePicker
//
//  Created by 张振飞 on 2017/2/1.
//  Copyright © 2017年 zzf. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface CDatePickerViewEx : UIPickerView <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UIColor *monthSelectedTextColor;
@property (nonatomic, strong) UIColor *monthTextColor;

@property (nonatomic, strong) UIColor *yearSelectedTextColor;
@property (nonatomic, strong) UIColor *yearTextColor;

@property (nonatomic, strong) UIFont *monthSelectedFont;
@property (nonatomic, strong) UIFont *monthFont;

@property (nonatomic, strong) UIFont *yearSelectedFont;
@property (nonatomic, strong) UIFont *yearFont;

@property (nonatomic, assign) NSInteger rowHeight;

@property (nonatomic, strong, readonly) NSDate *date;

-(void)setupMinYear:(NSInteger)minYear maxYear:(NSInteger)maxYear;
-(void)selectToday;
- (void)addTarget:(id)target ValueChangeAction:(SEL)action;
///设置默认时间  yearRow 表示要默认的年份在第几行 monthRow..
- (void)setDefaultTime:(NSInteger)yearRow And:(NSInteger)monthRow;
@end
