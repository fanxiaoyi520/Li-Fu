//
//  ZFDatePickerView.m
//  Agent
//
//  Created by 中付支付 on 2018/9/13.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "ZFDatePickerView.h"
#import "DateUtils.h"

@implementation ZFDatePickerView
{
    UIView *_darkView;
    UIView *_contentView;
    UILabel *_tipLabel;
    UIDatePicker *_pickerView;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden = YES;
        [self createView];
    }
    return self;
}

- (void)createView{
    // 遮罩
    _darkView = [[UIView alloc] init];
    _darkView.alpha = 0.6;
    _darkView.backgroundColor = ZFColor(46, 49, 50);
    _darkView.frame = self.frame;
    _darkView.hidden = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelBtnClicked)];
    [_darkView addGestureRecognizer:tap];
    [self addSubview:_darkView];
    
    // 容器视图
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height, SCREEN_WIDTH, 225)];
    _contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_contentView];
    
    // 取消按钮
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];;
    cancelBtn.backgroundColor = [UIColor clearColor];
    [cancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [cancelBtn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [cancelBtn addTarget:self action:@selector(cancelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:cancelBtn];
    
    // 提示文字
    _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/4, 0, SCREEN_WIDTH/2, 44)];
    _tipLabel.text = _title;
    _tipLabel.textColor = UIColorFromRGB(0x313131);
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    _tipLabel.font = [UIFont boldSystemFontOfSize:17.0];
    _tipLabel.adjustsFontSizeToFitWidth = YES;
    [_contentView addSubview:_tipLabel];

    // 确定按钮
    UIButton *ctBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-80, 0, 80, 44)];;
    ctBtn.backgroundColor = [UIColor clearColor];
    [ctBtn setTitleColor:MainThemeColor forState:UIControlStateNormal];
    [ctBtn setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
    ctBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [ctBtn addTarget:self action:@selector(ctBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:ctBtn];
    
    // 分割线
    UIView *spliteView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, 1)];
    spliteView.backgroundColor = UIColorFromRGB(0xf6f6f6);
    [_contentView addSubview:spliteView];
    
    // 选择器
    _pickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 45, SCREEN_WIDTH, 200)];
    _pickerView.backgroundColor = [UIColor whiteColor];
    _pickerView.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
    _pickerView.datePickerMode = UIDatePickerModeDate;
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    NSDate *minDate = [fmt dateFromString:@"2010-01-01"];
    
//    _pickerView.maximumDate = [NSDate date];
//    _pickerView.minimumDate = minDate;
    
    [_contentView addSubview:_pickerView];
}


- (void)setTitle:(NSString *)title{
    _tipLabel.text = title;
}

- (void)cancelBtnClicked{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         self->_contentView.y = self.height;
                     }
                     completion:^(BOOL finished){
                         self->_darkView.hidden = YES;
                         self.hidden = YES;
                     }];
}

- (void)ctBtnClicked{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         self->_contentView.y = self.height;
                     }
                     completion:^(BOOL finished){
                         self->_darkView.hidden = YES;
                         self.hidden = YES;
                     }];
    NSString *dateStr = [DateUtils dateToStringWithFormatter:@"yyyy-MM-dd" date:_pickerView.date];
    [_delegate datePickerViewTag:self.tag time:dateStr];
}

- (void)show{
    self.hidden = NO;
    _darkView.hidden = NO;
    [UIView animateWithDuration:0.5f animations:^{
        self->_contentView.y = self.height-225;
    }];
}

- (void)dismiss{
    [self cancelBtnClicked];
}

@end
