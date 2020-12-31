//
//  ZFServiceAgreementController.m
//  newupop
//
//  Created by 中付支付 on 2017/11/3.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFServiceAgreementController.h"

@interface ZFServiceAgreementController ()

@end

@implementation ZFServiceAgreementController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myTitle = @"服务协议";
    [self createView];
}

- (void)createView{
    UITextView *contentTextView  = [[UITextView alloc]initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight)];
    contentTextView.layer.cornerRadius = 6.0f;
    
    contentTextView.editable = NO;
    contentTextView.textColor = [UIColor grayColor];
    [contentTextView setFont:[UIFont systemFontOfSize:17.0f]];
    
    [self.view addSubview:contentTextView];
    
    contentTextView.text = [self configureDisplay];
}

- (NSString *) configureDisplay {
    
    NSString *fileName = @"service_agreement.txt";
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
    NSError *error;
    NSString *text = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
   
    NSMutableString *mtext = [NSMutableString stringWithString:text];
    NSDictionary *bundleDic = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [bundleDic objectForKey:@"CFBundleDisplayName"];
    
    NSString *company = @"中付支付有限公司";
    NSString *companyShort = @"中付支付";
    
    [mtext replaceOccurrencesOfString: @"{0}" withString:appName options:NSCaseInsensitiveSearch range:NSMakeRange(0, mtext.length)];
    [mtext replaceOccurrencesOfString: @"{1}" withString:company options:NSCaseInsensitiveSearch range:NSMakeRange(0, mtext.length)];
    [mtext replaceOccurrencesOfString: @"{2}" withString:companyShort options:NSCaseInsensitiveSearch range:NSMakeRange(0, mtext.length)];
    text = mtext;
    
    return text;
}

@end
