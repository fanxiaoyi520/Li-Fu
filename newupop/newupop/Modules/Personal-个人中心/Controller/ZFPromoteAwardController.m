//
//  ZFPromoteAwardController.m
//  newupop
//
//  Created by 中付支付 on 2018/7/10.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "ZFPromoteAwardController.h"
#import "SGQRCodeTool.h"

#define PromoteCodeStr [NSString stringWithFormat:@"qrcodeStr%@", [ZFGlobleManager getGlobleManager].userPhone]
#define CIColorFromRGB(rgbValue) [CIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ZFPromoteAwardController ()

@property (nonatomic, strong)UIImageView *codeImageView;
@property (nonatomic, strong)NSString *qrcodeStr;

@end

@implementation ZFPromoteAwardController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myTitle = NSLocalizedString(@"推广有奖", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    
    _qrcodeStr = [[NSUserDefaults standardUserDefaults] objectForKey:PromoteCodeStr];
    
    [self createView];
    
    [self getQRCodeString];
}

- (void)getQRCodeString{
    NSDictionary *dict = @{@"countryCode":[ZFGlobleManager getGlobleManager].areaNum,
                           @"mobile":[ZFGlobleManager getGlobleManager].userPhone,
                           @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                           @"txnType":@"83"
                           };
    if (!_qrcodeStr) {
        [[MBUtils sharedInstance] showMBInView:self.view];
    }
    [NetworkEngine singlePostWithParmas:dict success:^(id requestResult) {
        
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[MBUtils sharedInstance] dismissMB];
            _qrcodeStr = [requestResult objectForKey:@"qrCode"];
            _codeImageView.image = [self getImageWithString:_qrcodeStr];
            
            [[NSUserDefaults standardUserDefaults] setObject:_qrcodeStr forKey:PromoteCodeStr];
            
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

- (void)createView{
    
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_WIDTH*1.28)];
    backImageView.image = [UIImage imageNamed:@"pic_background_promote"];
    [self.view addSubview:backImageView];
    
    CGFloat heightRate = backImageView.height/480;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40*heightRate, SCREEN_WIDTH, 30)];
    titleLabel.text = NSLocalizedString(@"分享得好礼", nil);
    titleLabel.font = [UIFont boldSystemFontOfSize:25];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [backImageView addSubview:titleLabel];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 180*heightRate, 180*heightRate)];
    backView.backgroundColor = UIColorFromRGB(0xFDB926);
    backView.layer.cornerRadius = 10;
    backView.alpha = 0.1;
    backView.center = CGPointMake(SCREEN_WIDTH/2, IPhoneXTopHeight+165*heightRate+backView.height/2);
    [self.view addSubview:backView];
    
    _codeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, backView.width-30, backView.width-30)];
    _codeImageView.image = [self getImageWithString:_qrcodeStr];
    _codeImageView.center = backView.center;
    [self.view addSubview:_codeImageView];
    
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.frame = CGRectMake(50, backView.bottom+20*heightRate, SCREEN_WIDTH-100, 45);
    tipLabel.font = [UIFont systemFontOfSize:14];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.numberOfLines = 2;
    tipLabel.adjustsFontSizeToFitWidth = YES;
    tipLabel.text = NSLocalizedString(@"扫码注册成为“力付”用户\n推荐人获取奖励", nil);
    [self.view addSubview:tipLabel];
}

- (UIImage *)getImageWithString:(NSString *)str{
    if ([str isKindOfClass:[NSNull class]] || !str) {
        return nil;
    }

    CIColor *backColor = CIColorFromRGB(0xffffff);
    CIColor *color = CIColorFromRGB(0xFDB926);
    
    UIImage *image = [SGQRCodeTool SG_generateWithColorQRCodeData:str backgroundColor:color mainColor:backColor];
    return image;
}


@end
