//
//  ZFAboutDetailController.m
//  newupop
//
//  Created by 中付支付 on 2017/11/14.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFAboutDetailController.h"

@interface ZFAboutDetailController ()<UIWebViewDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation ZFAboutDetailController

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
    self.myTitle = @"关于我们";
    [self initWebView];
    // 添加系统菊花
    [UIApplication.sharedApplication.keyWindow addSubview:self.indicatorView];
}

- (void)initWebView
{
    NSString *urlStr = @"https://u.sinopayonline.com/UGateWay/about.jsp?Language=ENG";
    NSString *language = [NetworkEngine getCurrentLanguage];
    if ([language isEqualToString:@"2"]) {
        urlStr = @"https://u.sinopayonline.com/UGateWay/about.jsp?Language=CHN";
    }
    // 添加webView
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight+1, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight-1)];
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    webView.dataDetectorTypes = UIDataDetectorTypeLink;
    webView.opaque= NO;
    NSURL *url = [NSURL URLWithString:urlStr];
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
}

#pragma mark -- UIWebViewDelegate

/**
 *  判断网页是否加载完成
 */
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.indicatorView stopAnimating];
}

// 页面加载失败时调用
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nonnull NSError *)error {
    [XLAlertController acWithMessage:NSLocalizedString(@"网络异常，请稍后重试", nil) confirmBtnTitle:NSLocalizedString(@"确定", nil) confirmAction:^(UIAlertAction *action) {
        [self.navigationController popViewControllerAnimated:YES];
    } ];
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
