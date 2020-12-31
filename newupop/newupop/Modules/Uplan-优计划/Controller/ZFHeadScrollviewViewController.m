//
//  ZFHeadScrollviewViewController.m
//  newupop
//
//  Created by Jellyfish on 2017/11/6.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFHeadScrollviewViewController.h"
#import "ZFMyCouponViewController.h"
#import "ZFUplanController.h"

@interface ZFHeadScrollviewViewController ()
/** 头部类型 */
@property(nonatomic, assign) ZFHeadScrollviewType headType;
@end

@implementation ZFHeadScrollviewViewController

- (instancetype)initWithHeadType:(ZFHeadScrollviewType)headType
{
    if (self = [super init]) {
        self.headType = headType;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = GrayBgColor;
    
    // 向右滑动
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, SCREEN_HEIGHT)];
    leftView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:leftView];
    
    if (self.headType == ZFHeadScrollviewTypeUpan) {
        self.isHiddenBack = YES;
        self.myTitle = NSLocalizedString(@"优计划", nil);
        [self setupUplanVC];
    } else {
        self.myTitle = NSLocalizedString(@"我的优惠券", nil);
        [self setupMyCouponVC];
    }
    
    // 配置
    [self setUpTitleEffect:^(UIColor *__autoreleasing *titleScrollViewColor, UIColor *__autoreleasing *norColor, UIColor *__autoreleasing *selColor, UIFont *__autoreleasing *titleFont, CGFloat *titleHeight, CGFloat *titleWidth) {
        *norColor = [UIColor blackColor];
        *selColor = MainThemeColor;
        *titleFont = [UIFont systemFontOfSize:15.0];
        *titleHeight = 50.f;
        if (self.headType == ZFHeadScrollviewTypeUpan) {
            *titleWidth = [UIScreen mainScreen].bounds.size.width / 4;
        } else {
            *titleWidth = [UIScreen mainScreen].bounds.size.width / 3;
        }
    }];
    
    // 标题渐变
    // *推荐方式(设置标题渐变)
    [self setUpTitleGradient:^(YZTitleColorGradientStyle *titleColorGradientStyle, UIColor *__autoreleasing *norColor, UIColor *__autoreleasing *selColor) {
        
    }];
    
    [self setUpUnderLineEffect:^(BOOL *isUnderLineDelayScroll, CGFloat *underLineH, UIColor *__autoreleasing *underLineColor,BOOL *isUnderLineEqualTitleWidth) {
        *isUnderLineEqualTitleWidth = YES;
        *underLineColor = MainThemeColor;
    }];
}

// 优计划
- (void)setupUplanVC
{
    NSArray<NSString *> *titleArray = @[NSLocalizedString(@"新加坡", nil), NSLocalizedString(@"马来西亚", nil), NSLocalizedString(@"香港", nil), NSLocalizedString(@"澳门", nil)];
    NSMutableArray *mTitleArray = [NSMutableArray arrayWithArray:titleArray];
    
    // 默认选中定位的国家
    NSInteger index = 0;
    NSString *country = [LocationUtils sharedInstance].ISOCountryCode;
    NSLog(@"当前国家--- %@", country);
    if ([country isEqualToString:@"SG"]) {
        index = 0;
    } else if ([country isEqualToString:@"MY"]) {
        index = 1;
    } else if ([country isEqualToString:@"HK"]) {
        index = 2;
    } else if ([country isEqualToString:@"US"]) {
        index = 3;
    } else {
        index = 0;
    }
    
    [mTitleArray removeObjectAtIndex:index];
    [mTitleArray insertObject:titleArray[index] atIndex:0];
    
    for (int i = 0; i < mTitleArray.count; i++) {
        ZFUplanController *wordVc = [[ZFUplanController alloc] init];
        wordVc.title = mTitleArray[i];
        [self addChildViewController:wordVc];
    }
}

// 我的优惠券
- (void)setupMyCouponVC
{
    NSArray<NSString *> *titleArray = @[NSLocalizedString(@"未使用", nil), NSLocalizedString(@"已使用", nil), NSLocalizedString(@"已过期", nil)];
    for (int i = 0; i < titleArray.count; i++) {
        ZFMyCouponViewController *wordVc = [[ZFMyCouponViewController alloc] init];
        wordVc.title = titleArray[i];
        [self addChildViewController:wordVc];
    }
}

@end
