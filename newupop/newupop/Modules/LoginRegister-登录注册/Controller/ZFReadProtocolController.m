//
//  ZFReadProtocolController.m
//  newupop
//
//  Created by 中付支付 on 2019/9/30.
//  Copyright © 2019 中付支付. All rights reserved.
//

#import "ZFReadProtocolController.h"
#import <WebKit/WebKit.h>

@interface ZFReadProtocolController ()<WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) WKUserContentController *userContentController;

@end

@implementation ZFReadProtocolController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *title = NSLocalizedString(@"力付用户协议", nil);
    if (_protocolType == 1) {
        title = NSLocalizedString(@"隐私条款", nil);
    }
    self.myTitle = title;
    [self createView];
}

- (void)createView{
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, 1)];
    lineView.backgroundColor = GrayBgColor;
    [self.view addSubview:lineView];
    
    WKWebViewConfiguration * Configuration = [[WKWebViewConfiguration alloc]init];
    ///添加js和wkwebview的调用
    _userContentController =[[WKUserContentController alloc]init];
    //    [_userContentController addScriptMessageHandler:self  name:@"testShow"];//注册一个name为testShow的js方法
    Configuration.userContentController = _userContentController;
    
    // 添加webView
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, lineView.bottom, SCREEN_WIDTH, SCREEN_HEIGHT-1-IPhoneXTopHeight) configuration:Configuration];
    _webView.backgroundColor = [UIColor whiteColor];
    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;
    _webView.scrollView.showsVerticalScrollIndicator = NO;
    [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    
    NSString *urlStr = @"https://u.sinopayonline.com/UGateWay/tiaokuan/terms.jsp?language=";
    if (_protocolType == 1) {
        urlStr = @"https://u.sinopayonline.com/UGateWay/tiaokuan/Policy.jsp?language=";
    }
    
    NSString *state = @"0";
    NSString *language = [NetworkEngine getCurrentLanguage];
    if ([language isEqualToString:@"1"]) {
        state = @"1";
    } else if ([language isEqualToString:@"2"]) {
        state = @"0";
    } else if ([language isEqualToString:@"3"]) {
        state = @"3";
    }
    urlStr = [urlStr stringByAppendingString:state];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    
    [_webView loadRequest:request];
    [_webView loadRequest:request];
    [self.view addSubview:_webView];
}

#pragma mark - WKNavigationDelegate
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    [XLAlertController acWithMessage:NetRequestError confirmBtnTitle:NSLocalizedString(@"确定", nil) confirmAction:^(UIAlertAction *action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.webView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newprogress == 1) {
            self.progressView.hidden = YES;
            [self.progressView setProgress:0 animated:NO];
        } else {
            self.progressView.hidden = NO;
            [self.progressView setProgress:newprogress animated:YES];
        }
    }
}

#pragma mark WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
}

#pragma mark other
- (void)dealloc {
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

#pragma mark 懒加载
- (UIProgressView *)progressView
{
    if(!_progressView)
    {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, 0)];
        _progressView.tintColor = MainThemeColor;
        _progressView.trackTintColor = [UIColor whiteColor];
        [self.view addSubview:_progressView];
    }
    return _progressView;
}


@end
