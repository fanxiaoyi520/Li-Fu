//
//  ZFUplanWebViewController.m
//  newupop
//
//  Created by Jellyfish on 2017/11/3.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFUplanWebViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "ZFHeadScrollviewViewController.h"
#import "ZFValidatePwdController.h"
#import "ZFInputPwdController.h"

typedef void(^MyBlock)(BOOL isOK);

@interface ZFUplanWebViewController () <UIWebViewDelegate>

@property(nonatomic, weak) UIWebView *webView;

/** JS交互上下文 */
@property (nonatomic, assign) JSContext *context;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
/** 优计划模型 */
//@property(nonatomic, strong) ZFUplanModel *uplanModel;

@property(nonatomic, copy) NSString *activityUrl;
@property(nonatomic, copy) NSString *activityID;

@end

@implementation ZFUplanWebViewController

- (instancetype)initWithActivityUrl:(NSString *)activityUrl activityID:(NSString *)activityID myTitle:(NSString *)title
{
    if (self = [super init]) {
        self.activityUrl = activityUrl;
        self.activityID = activityID;
        DLog(@"%@", self.activityUrl);
        self.myTitle = title;
    }
    
    return self;
}

#pragma mark -- 生命周期

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.titleColor = [UIColor blackColor];
    self.naviBgColor = [UIColor whiteColor];
    self.backArrowImageName = @"nav_return_black";
    [UIApplication sharedApplication].statusBarStyle = UIBarStyleDefault;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIBarStyleBlack;
    [self.indicatorView stopAnimating];
    [self.indicatorView removeFromSuperview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = GrayBgColor;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initWebView];
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, 20, SCREEN_HEIGHT-IPhoneXTopHeight)];
        leftView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:leftView];
    });
    // 添加系统菊花
    [UIApplication.sharedApplication.keyWindow addSubview:self.indicatorView];
}

- (void)initWebView
{
    // 添加webView
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight+1, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight-1)];
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    webView.dataDetectorTypes = UIDataDetectorTypeLink;
    webView.opaque= NO;
    NSURL *url = [NSURL URLWithString:self.activityUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    
    //取消右侧，下侧滚动条，去处上下滚动边界的黑色背景
    webView.backgroundColor = [UIColor clearColor];
    for (UIView *_aView in [webView subviews])
    {
        if ([_aView isKindOfClass:[UIScrollView class]])
        {
            [(UIScrollView *)_aView setShowsVerticalScrollIndicator:YES];
            //右侧的滚动条
            [(UIScrollView *)_aView setShowsHorizontalScrollIndicator:NO];
            //下侧的滚动条
            for (UIView *_inScrollview in _aView.subviews)
            {
                if ([_inScrollview isKindOfClass:[UIImageView class]])
                {
                    _inScrollview.hidden = YES;  //上下滚动出边界时的黑色的图片
                }
            }
        }
    }
    [self.view addSubview:webView];
    self.webView = webView;
}


#pragma mark -- UIWebViewDelegate

/**
 *  判断网页是否加载完成
 */
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (!webView.isLoading) {
        [self.indicatorView stopAnimating];
    }
    
    // 禁用 页面元素选择
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    // 禁用 长按弹出ActionSheet
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
    
    self.context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    // 优惠详情
    self.context[@"coupon"] = ^() {
        [self useCoupon];
    };
    
    // 我的优惠券
    self.context[@"payment"] = ^() {
        dispatch_async(dispatch_get_main_queue(), ^{
            //先验证支付密码
            [self checkPayPwdAlreadySet:^(BOOL isOK) {
                if (isOK) {
                    ZFValidatePwdController *generateVC = [[ZFValidatePwdController alloc] init];
                    generateVC.couponID = self.activityID;
                    generateVC.fromType = 1;
                    [self.navigationController pushViewController:generateVC animated:YES];
                    
                    NSMutableArray *tempMArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                    // 移除中间的控制器,下个页面可以直接回到首页
                    [tempMArray removeObjectsInRange:NSMakeRange(1, tempMArray.count-2)];
                    [self.navigationController setViewControllers:tempMArray animated:NO];
                }
            }];
        });
    };
    
}

// 页面加载失败时调用
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nonnull NSError *)error {
    [XLAlertController acWithMessage:NSLocalizedString(@"网络异常，请稍后重试", nil) confirmBtnTitle:NSLocalizedString(@"确定", nil) confirmAction:^(UIAlertAction *action) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } ];
}

- (void)useCoupon{
    NSDictionary *parameters = @{
                                 @"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"activityId": self.activityID,
                                 @"txnType": @"67"};
    
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([requestResult[@"status"] isEqualToString:@"0"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [XLAlertController acWithTitle:NSLocalizedString(@"领取成功", nil) message:NSLocalizedString(@"券已放至\"我的优惠券\"中,限62开头的银行卡使用", nil) confirmBtnTitle:NSLocalizedString(@"立即使用", nil) cancleBtnTitle:NSLocalizedString(@"查看优惠券", nil) confirmAction:^(UIAlertAction *action) {
                    DLog(@"立即使用");
                    // 传返回的url给优惠券生成二维码
                    self.activityUrl = requestResult[@"activityUrl"];
                    ZFUplanWebViewController *web = [[ZFUplanWebViewController alloc] initWithActivityUrl:self.activityUrl activityID:self.activityID myTitle:NSLocalizedString(@"优惠详情", nil)];
                    [self pushViewController:web];
                } cancleAction:^(UIAlertAction *action) {
                    DLog(@"查看优惠券");
                    ZFHeadScrollviewViewController *hsvc = [[ZFHeadScrollviewViewController alloc] initWithHeadType:ZFHeadScrollviewTypeMyCoupon];
                    [self pushViewController:hsvc];
                }];
                
                // 重新加载
                [self.webView reload];
            });
        } else if ([requestResult[@"status"] isEqualToString:@"2"]) {
            // 传返回的url给优惠券生成二维码
            self.activityUrl = requestResult[@"activityUrl"];
            ZFUplanWebViewController *web = [[ZFUplanWebViewController alloc] initWithActivityUrl:self.activityUrl activityID:self.activityID myTitle:NSLocalizedString(@"优惠详情", nil)];
            [self pushViewController:web];
//            ZFValidatePwdController *generateVC = [[ZFValidatePwdController alloc] init];
//            generateVC.couponID = self.uplanModel.activityId;
//            generateVC.fromType = 1;
//            [self.navigationController pushViewController:generateVC animated:YES];
//
//            NSMutableArray *tempMArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
//            // 移除中间的控制器,下个页面可以直接回到首页
//            [tempMArray removeObjectsInRange:NSMakeRange(1, tempMArray.count-2)];
//            [self.navigationController setViewControllers:tempMArray animated:NO];
        } else {
            [XLAlertController acWithMessage:requestResult[@"msg"] confirmBtnTitle:NSLocalizedString(@"好的", nil) confirmAction:^(UIAlertAction *action) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
        
    } failure:^(id error) {
        [[MBUtils sharedInstance] dismissMB];
    }];
}

#pragma mark 是否设置支付密码
- (void)checkPayPwdAlreadySet:(MyBlock)block{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:PayPwdAlreadySet]) {
        block(YES);
        return;
    }
    
    NSDictionary * paramSign = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"userKey": [ZFGlobleManager getGlobleManager].userKey,
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"txnType": @"27"};
    
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    [NetworkEngine singlePostWithParmas:paramSign success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {//已设置
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PayPwdAlreadySet];
            block(YES);
        } else {//未设置
            [XLAlertController acWithTitle:NSLocalizedString(@"提示", nil) msg:NSLocalizedString(@"未设置支付密码", nil) confirmBtnTitle:NSLocalizedString(@"去设置", nil) cancleBtnTitle:NSLocalizedString(@"取消", nil) confirmAction:^(UIAlertAction *action) {
                ZFInputPwdController *inputVC = [[ZFInputPwdController alloc] init];
                inputVC.inputType = 5;
                [self.navigationController pushViewController:inputVC animated:YES];
            }];
        }
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark -- 懒加载
- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.center = CGPointMake(self.view.center.x, SCREEN_HEIGHT * 0.4);
        [_indicatorView startAnimating];
        _indicatorView.hidesWhenStopped = YES;
    }
    return _indicatorView;
}

@end

