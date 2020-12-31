//
//  ZFPickerView.m
//  Agent
//
//  Created by 中付支付 on 2018/9/11.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "ZFPickerView.h"

@implementation ZFPickerView
{
    UIView *_darkView;
    UIView *_contentView;
    UILabel *_tipLabel;
    UIPickerView *_pickerView;
    NSInteger _selectIndex;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:ZFSCREEN];
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
    _darkView.frame = ZFSCREEN;
    _darkView.hidden = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelBtnClicked)];
    [_darkView addGestureRecognizer:tap];
    [self addSubview:_darkView];
    
    // 容器视图
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 225)];
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
    _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, SCREEN_WIDTH-160, 44)];
    _tipLabel.text = _title;
    _tipLabel.textColor = UIColorFromRGB(0x313131);
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    _tipLabel.font = [UIFont boldSystemFontOfSize:17.0];
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
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 45, SCREEN_WIDTH, 200)];
    _pickerView.backgroundColor = [UIColor whiteColor];
    _pickerView.showsSelectionIndicator = YES;
    _pickerView.dataSource = self;
    _pickerView.delegate = self;
    [_contentView addSubview:_pickerView];
}

- (void)setTitle:(NSString *)title{
    _tipLabel.text = title;
}

- (void)setDataArray:(NSArray *)dataArray{
    _dataArray = dataArray;
    [_pickerView reloadAllComponents];
}

- (void)setNotNeedSeparated:(BOOL)notNeedSeparated{
    _notNeedSeparated = notNeedSeparated;
}

#pragma mark -- UIPickerViewDataSource 选择器数据源
// 指定pickerview有几个表盘
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// 指定每个表盘上有几行数据
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return _dataArray.count;
}

#pragma mark UIPickerViewDelegate 选择器代理方法
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return SCREEN_WIDTH;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}

// 选中的方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _selectIndex = row;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    //设置分割线的颜色
    for(UIView *singleLine in pickerView.subviews)
    {
        if (singleLine.frame.size.height < 1)
        {
            singleLine.backgroundColor = ZFAlpColor(0, 0, 0, 0.3);
        }
    }
    //设置文字的属性
    UILabel *genderLabel = [UILabel new];
    genderLabel.textAlignment = NSTextAlignmentCenter;
    NSString *str = @"";
    if (_notNeedSeparated) {
        str = _dataArray[row];
    } else {
        str = [_dataArray[row] componentsSeparatedByString:@"-"].firstObject;
    }
    genderLabel.text = str;
    genderLabel.font = [UIFont systemFontOfSize:22.0];
    genderLabel.adjustsFontSizeToFitWidth = YES;
    
    return genderLabel;
}

- (void)cancelBtnClicked{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         self->_contentView.y = SCREEN_HEIGHT;
                     }
                     completion:^(BOOL finished){
                         self->_darkView.hidden = YES;
                         self.hidden = YES;
                     }];
}

- (void)ctBtnClicked{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         self->_contentView.y = SCREEN_HEIGHT;
                     }
                     completion:^(BOOL finished){
                         self->_darkView.hidden = YES;
                         self.hidden = YES;
                     }];
    [_delegate selectZFPickerViewTag:self.tag index:_selectIndex];
}

- (void)show{
    self.hidden = NO;
    _darkView.hidden = NO;
    [UIView animateWithDuration:0.5f animations:^{
        self->_contentView.y = SCREEN_HEIGHT-225;
    }];
}

@end
