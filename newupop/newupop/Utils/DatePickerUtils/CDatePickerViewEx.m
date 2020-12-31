//
//  CDatePickerViewEx.m
//  MonthYearDatePicker
//
//  Created by 张振飞 on 2017/2/1.
//  Copyright © 2017年 zzf. All rights reserved.
//

#import "CDatePickerViewEx.h"

// Identifiers of components
#define MONTH ( 1 )
#define YEAR ( 0 )


// Identifies for component views
#define LABEL_TAG 43


@interface CDatePickerViewEx()

@property (nonatomic, strong) NSIndexPath *todayIndexPath;
@property (nonatomic, strong) NSArray *months;
@property (nonatomic, strong) NSArray *years;

@property (nonatomic, assign) NSInteger minYear;
@property (nonatomic, assign) NSInteger maxYear;

@property (nonatomic) SEL action;
@property (nonatomic, weak) id target;
@end

@implementation CDatePickerViewEx

const NSInteger bigRowCount = 1;
const NSInteger numberOfComponents = 2;

#pragma mark - Properties

-(void)setMonthFont:(UIFont *)monthFont
{
    if (monthFont)
    {
        _monthFont = monthFont;
    }
}

-(void)setMonthSelectedFont:(UIFont *)monthSelectedFont
{
    if (monthSelectedFont)
    {
        _monthSelectedFont = monthSelectedFont;
    }
}

-(void)setYearFont:(UIFont *)yearFont
{
    if (yearFont)
    {
        _yearFont = yearFont;
    }
}

-(void)setYearSelectedFont:(UIFont *)yearSelectedFont
{
    if (yearSelectedFont)
    {
        _yearSelectedFont = yearSelectedFont;
    }
}

#pragma mark - Init

-(instancetype)init
{
    if (self = [super init])
    {
        [self loadDefaultsParameters];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self loadDefaultsParameters];
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self loadDefaultsParameters];
}

#pragma mark - Open methods

-(NSDate *)date
{
    //NSInteger length = [NSLocalizedString(@"月", nil) length];
    
    NSInteger monthCount = self.months.count;
    NSString *month = [self.months objectAtIndex:([self selectedRowInComponent:MONTH] % monthCount)];
    //month = [month substringWithRange:NSMakeRange(0, month.length-length)];
    
    NSInteger yearCount = self.years.count;
    NSString *year = [self.years objectAtIndex:([self selectedRowInComponent:YEAR] % yearCount)];
    //year = [year substringWithRange:NSMakeRange(0, year.length-length)];
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy:MM"];
    NSDate *date = [formatter dateFromString:[NSString stringWithFormat:@"%@:%@", year, month]];
    return date;
}

- (void)setupMinYear:(NSInteger)minYear maxYear:(NSInteger)maxYear
{
    self.minYear = minYear;
    
    if (maxYear > minYear)
    {
        self.maxYear = maxYear;
    }
    else
    {
        self.maxYear = minYear + 10;
    }

    self.years = [self nameOfYears];
    self.todayIndexPath = [self todayPath];
}

- (void)setDefaultTime:(NSInteger)yearRow And:(NSInteger)monthRow{
    [self selectRow:yearRow inComponent:0 animated:NO];
    [self selectRow:monthRow inComponent:1 animated:NO];
}

-(void)selectToday
{
    [self selectRow: self.todayIndexPath.row
        inComponent: MONTH
           animated: NO];
    
    [self selectRow: self.todayIndexPath.section
        inComponent: YEAR
           animated: NO];
}

- (void)addTarget:(id)target ValueChangeAction:(SEL)action
{
    if (!target || !action) {
        return;
    }
    if ([target canPerformAction:action withSender:self]) {
        self.target = target;
        self.action = action;
    }
}

#pragma mark - UIPickerViewDelegate

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return [self componentWidth];
}

-(UIView *)pickerView: (UIPickerView *)pickerView viewForRow: (NSInteger)row forComponent: (NSInteger)component reusingView: (UIView *)view
{
    BOOL selected = NO;
    if(component == MONTH)
    {
        NSInteger monthCount = self.months.count;
        NSString *monthName = [self.months objectAtIndex:(row % monthCount)];
        NSString *currentMonthName = [self currentMonthName];
        if([monthName isEqualToString:currentMonthName] == YES)
        {
            selected = YES;
        }
    }
    else
    {
        NSInteger yearCount = self.years.count;
        NSString *yearName = [self.years objectAtIndex:(row % yearCount)];
        NSString *currenrYearName  = [self currentYearName];
        if([yearName isEqualToString:currenrYearName] == YES)
        {
            selected = YES;
        }
    }
    
    UILabel *returnView = nil;
    if(view.tag == LABEL_TAG)
    {
        returnView = (UILabel *)view;
    }
    else
    {
        returnView = [self labelForComponent:component];
    }
    
    returnView.font = selected ? [self selectedFontForComponent:component] : [self fontForComponent:component];
    returnView.textColor = selected ? [self selectedColorForComponent:component] : [self colorForComponent:component];
    
    returnView.text = [self titleForRow:row forComponent:component];
    return returnView;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return self.rowHeight;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //[self.target performSelector:_action withObject:self];
}
#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return numberOfComponents;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component == MONTH)
    {
        return [self bigRowMonthCount];
    }
    return [self bigRowYearCount];
}

#pragma mark - Util

-(NSInteger)bigRowMonthCount
{
    return self.months.count  * bigRowCount;
}

-(NSInteger)bigRowYearCount
{
    return self.years.count  * bigRowCount;
}

-(CGFloat)componentWidth
{
    return self.bounds.size.width / numberOfComponents - 20;
}

-(NSString *)titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(component == MONTH)
    {
        NSInteger monthCount = self.months.count;
        return [self.months objectAtIndex:(row % monthCount)];
    }
    NSInteger yearCount = self.years.count;
    return [self.years objectAtIndex:(row % yearCount)];
}

-(UILabel *)labelForComponent:(NSInteger)component
{
    CGRect frame = CGRectMake(0, 0, [self componentWidth], self.rowHeight);
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.userInteractionEnabled = NO;
    
    label.tag = LABEL_TAG;
    
    return label;
}

-(NSArray *)nameOfMonths
{
    NSMutableArray *months = [NSMutableArray array];
    for (int i = 0; i < 12; i++) {
//        NSString *monthStr = [NSString stringWithFormat:@"%d%@",i+1, NSLocalizedString(@"月", nil)];
        NSString *monthStr = [NSString stringWithFormat:@"%d",i+1];
        [months addObject:monthStr];
    }
    return months;
}

-(NSArray *)nameOfYears
{
    NSMutableArray *years = [NSMutableArray array];
    
    for(NSInteger year = self.minYear; year <= self.maxYear; year++)
    {
//        NSString *yearStr = [NSString stringWithFormat:@"%li%@", (long)year, NSLocalizedString(@"年", nil)];
        NSString *yearStr = [NSString stringWithFormat:@"%li", (long)year];
        [years addObject:yearStr];
    }
    return years;
}

-(NSIndexPath *)todayPath // row - month ; section - year
{
    CGFloat row = 0.f;
    CGFloat section = 0.f;
    
    NSString *month = [self currentMonthName];
    NSString *year  = [self currentYearName];
    
    //set table on the middle
    for(NSString *cellMonth in self.months)
    {
        if([cellMonth isEqualToString:month])
        {
            row = [self.months indexOfObject:cellMonth];
            row = row + [self bigRowMonthCount] / 2;
            break;
        }
    }
    
    for(NSString *cellYear in self.years)
    {
        if([cellYear isEqualToString:year])
        {
            section = [self.years indexOfObject:cellYear];
            section = section + [self bigRowYearCount] / 2;
            break;
        }
    }
    
    return [NSIndexPath indexPathForRow:row inSection:section];
}

-(NSString *)currentMonthName
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    [formatter setLocale:usLocale];
    [formatter setDateFormat:@"MMMM"];
    return [formatter stringFromDate:[NSDate date]];
}

-(NSString *)currentYearName
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy"];
    return [formatter stringFromDate:[NSDate date]];
}

- (UIColor *)selectedColorForComponent:(NSInteger)component
{
    if (component == 0)
    {
        return self.monthSelectedTextColor;
    }
    return self.yearSelectedTextColor;
}

- (UIColor *)colorForComponent:(NSInteger)component
{
    if (component == 0)
    {
        return self.monthTextColor;
    }
    return self.yearTextColor;
}

- (UIFont *)selectedFontForComponent:(NSInteger)component
{
    if (component == 0)
    {
        return self.monthSelectedFont;
    }
    return self.yearSelectedFont;
}

- (UIFont *)fontForComponent:(NSInteger)component
{
    if (component == 0)
    {
        return self.monthFont;
    }
    return self.yearFont;
}

-(void)loadDefaultsParameters
{
    self.minYear = 2008;
    self.maxYear = 2030;
    self.rowHeight = 44;
    
    self.months = [self nameOfMonths];
    self.years = [self nameOfYears];
    self.todayIndexPath = [self todayPath];
    self.backgroundColor = [UIColor whiteColor];
    self.delegate = self;
    self.dataSource = self;
    
    self.monthSelectedTextColor = [UIColor blackColor];
    self.monthTextColor = [UIColor blackColor];
    
    self.yearSelectedTextColor = [UIColor blackColor];
    self.yearTextColor = [UIColor blackColor];
    
    self.monthSelectedFont = [UIFont systemFontOfSize:23];
    self.monthFont = [UIFont systemFontOfSize:23];
    
    self.yearSelectedFont = [UIFont systemFontOfSize:23];
    self.yearFont = [UIFont systemFontOfSize:23];
}

@end
