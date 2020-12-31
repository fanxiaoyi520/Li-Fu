//
//  SGQRCodeScanningView.m
//  SGQRCodeExample
//
//  Created by apple on 17/3/20.
//  Copyright © 2017年 Sorgle. All rights reserved.
//

#import "SGQRCodeScanningView.h"
#import <AVFoundation/AVFoundation.h>
#import "SGQRCodeConst.h"

/** 扫描内容的Y值 */
#define scanContent_Y self.frame.size.height * 0.1
/** 扫描内容的Y值 */
#define scanContent_X self.frame.size.width * 0.15

@interface SGQRCodeScanningView ()
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) CALayer *tempLayer;
//@property (nonatomic, strong) UIImageView *scanningline;
//@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong)UILabel *tipLable;
@property (nonatomic, strong)UIButton *light_button;

@end

@implementation SGQRCodeScanningView

/** 扫描动画线(冲击波) 的高度 */
//static CGFloat const scanninglineHeight = 12;
/** 扫描内容外部View的alpha值 */
//static CGFloat const scanBorderOutsideViewAlpha = 0.4;

- (CALayer *)tempLayer {
    if (!_tempLayer) {
        _tempLayer = [[CALayer alloc] init];
    }
    return _tempLayer;
}

- (instancetype)initWithFrame:(CGRect)frame layer:(CALayer *)layer {
    if (self = [super initWithFrame:frame]) {
        layer.frame = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT);
        self.tempLayer = layer;
        
        // 布局扫描界面
        [self setupSubviews];

    }
    return self;
}

+ (instancetype)scanningViewWithFrame:(CGRect )frame layer:(CALayer *)layer {
    return [[self alloc] initWithFrame:frame layer:layer];
}

- (void)setupSubviews {
    CALayer *imageLayer = [[CALayer alloc] init];
    imageLayer.frame = CGRectMake(50, 50, SCREEN_WIDTH-100, SCREEN_WIDTH-100);
    imageLayer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"home_scanQr"].CGImage);
    [self.layer addSublayer:imageLayer];
    
    // 添加闪光灯按钮
    _light_button = [[UIButton alloc] init];
    _light_button.size = CGSizeMake(40, 40);
    _light_button.center = CGPointMake(SCREEN_WIDTH/2, CGRectGetMaxY(imageLayer.frame)+_light_button.width);
    [_light_button setImage:[UIImage imageNamed:@"light_close"] forState:UIControlStateNormal];
    [_light_button setImage:[UIImage imageNamed:@"light_open"] forState:UIControlStateSelected];
//    [_light_button addTarget:self action:@selector(light_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_light_button];
    
    _tipLable = [[UILabel alloc] init];
    _tipLable.size = CGSizeMake(180, 15);
    _tipLable.center = CGPointMake(SCREEN_WIDTH/2, _light_button.bottom+15);
    _tipLable.font = [UIFont systemFontOfSize:13];
    _tipLable.textAlignment = NSTextAlignmentCenter;
    _tipLable.textColor = [UIColor whiteColor];
    _tipLable.text = NSLocalizedString(@"轻触照亮", nil);
    [self addSubview:_tipLable];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    btn.center = CGPointMake(SCREEN_WIDTH/2, CGRectGetMaxY(imageLayer.frame)+_light_button.width+10);
    [btn addTarget:self action:@selector(light_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor clearColor];
    [self addSubview:btn];
    
    //[self createBottomView];
}

#pragma mark 创建底部支付方式视图
- (void)createBottomView{
    UIView *bottomBackView = [UIView new];
    bottomBackView.backgroundColor = [UIColor clearColor];
    bottomBackView.frame = CGRectMake(0, SCREEN_HEIGHT-120-64, SCREEN_WIDTH, 120);
    [self addSubview:bottomBackView];
    
    for (int i = 0; i < 2; i++) {
        NSString *btnTitle = @"";
        NSString *btnImage = @"";
        UIButton *mainToolBtn = [[UIButton alloc] init];
        mainToolBtn.size = CGSizeMake(bottomBackView.width/2, bottomBackView.height);
        mainToolBtn.y = 10;
        mainToolBtn.x = i*SCREEN_WIDTH/2;
        mainToolBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
        [mainToolBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        switch (i) {
            case 0:
            {
                mainToolBtn.tag = 100;
                btnTitle = NSLocalizedString(@"扫一扫", nil);
                btnImage = @"home_scan";
            }
                break;
                
            case 1:
            {
                mainToolBtn.tag = 101;
                btnTitle = NSLocalizedString(@"付款码", nil);
                btnImage = @"home_qrcode_normal";
            }
                break;
        }
        // 设置图片,title
        [mainToolBtn setImage:[UIImage imageNamed:btnImage] forState:UIControlStateNormal];
        [mainToolBtn setTitle:btnTitle forState:UIControlStateNormal];
        [mainToolBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        // 设置偏移量
        CGFloat totalHeight = mainToolBtn.imageView.height + mainToolBtn.titleLabel.height;
        mainToolBtn.imageEdgeInsets = UIEdgeInsetsMake(-(totalHeight-mainToolBtn.imageView.height)-20, 0, 0, -mainToolBtn.titleLabel.width);
        mainToolBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -mainToolBtn.imageView.width, -(totalHeight-mainToolBtn.titleLabel.height)-10, 0);
        [bottomBackView addSubview:mainToolBtn];
    }
}

- (void)clickBtn:(UIButton *)button{
    if (button.tag == 101) {
        DLog(@"qrcode");
        [self.delegate jumpToGenerateVC];
    }
}

#pragma mark - - - 照明灯的点击事件
- (void)light_buttonAction:(UIButton *)button {
    if (_light_button.selected == NO) { // 点击打开照明灯
        [self turnOnLight:YES];
        _light_button.selected = YES;
        _tipLable.text = NSLocalizedString(@"轻触关闭", nil);
    } else { // 点击关闭照明灯
        [self turnOnLight:NO];
        _light_button.selected = NO;
        _tipLable.text = NSLocalizedString(@"轻触照亮", nil);
    }
}
- (void)turnOnLight:(BOOL)on {
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([_device hasTorch]) {
        [_device lockForConfiguration:nil];
        if (on) {
            [_device setTorchMode:AVCaptureTorchModeOn];
        } else {
            [_device setTorchMode: AVCaptureTorchModeOff];
        }
        [_device unlockForConfiguration];
    }
}


@end

