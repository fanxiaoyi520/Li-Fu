//
//  ZFPCAddPicViewController.m
//  newupop
//
//  Created by Jellyfish on 2020/1/7.
//  Copyright © 2020 中付支付. All rights reserved.
//

#import "ZFPCAddPicViewController.h"
#import "ZFPCCommitResultViewController.h"
#import "ZFImageUtils.h"
#import "TZImagePickerController.h"
#import "UIImage+Extension.h"
#import "NSString+Extension.h"

@interface ZFPCAddPicViewController () <TZImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *bgScrollView;
@property (weak, nonatomic) IBOutlet UIButton *nextStepBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgScrollviewTopMargin;

@property (weak, nonatomic) IBOutlet UIImageView *zmpic1;
@property (weak, nonatomic) IBOutlet UIImageView *zmpic2;
@property (weak, nonatomic) IBOutlet UIImageView *zmpic3;
@property (weak, nonatomic) IBOutlet UILabel *zmpic3Label;
@property (weak, nonatomic) IBOutlet UIImageView *gzzzpic1;
@property (weak, nonatomic) IBOutlet UIImageView *gzzzpic2;
@property (weak, nonatomic) IBOutlet UIImageView *gzzzpic3;
@property (weak, nonatomic) IBOutlet UIImageView *zdpic1;
@property (strong, nonatomic) UIImage *photoContext1;
@property (strong, nonatomic) UIImage *photoContext2;
@property (strong, nonatomic) UIImage *photoContext3;
@property (strong, nonatomic) UIImage *photoContext4;
@property (strong, nonatomic) UIImage *photoContext5;
@property (strong, nonatomic) UIImage *photoContext6;
@property (strong, nonatomic) UIImage *photoContext7;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *zmpic3_Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gzzzpic1TopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gzzzpic1_Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gzzzpic2_Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gzzzpic3_Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *zdpicTopMargin;
@property (nonatomic, assign) NSInteger clickTag;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMargin;
@property (nonatomic, strong) NSMutableDictionary *params;
/** 图片数组 */
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *imageArray;
@property (weak, nonatomic) IBOutlet UILabel *notoLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notoLabelHeight;

@end

@implementation ZFPCAddPicViewController

- (instancetype)initWithParams:(NSDictionary *)params {
    if (self = [super init]) {
        self.params = [NSMutableDictionary dictionaryWithDictionary:params];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myTitle = NSLocalizedString(@"上传证件资料", nil);
    
    _bgScrollviewTopMargin.constant = IPhoneXTopHeight;
    _bgScrollView.backgroundColor = GrayBgColor;
    _bgScrollView.bounces = NO;
    _bottomMargin.constant = 20;
    
    _nextStepBtn.backgroundColor = MainThemeColor;
    [_nextStepBtn setTitle:NSLocalizedString(@"完成", nil) forState:UIControlStateNormal];
    
    _gzzzpic1_Height.constant = 0;
    _gzzzpic2_Height.constant = 0;
    _gzzzpic3_Height.constant = 0;
    _zdpicTopMargin.constant = -60*2;
//    if ([_citizenshipCode isEqualToString:@"65"]) {
//        _zmpic3_Height.constant = 0;
//        _zmpic3Label.hidden = YES;
//        _zdpicTopMargin.constant = -60*3;
//    }
    
    NSInteger imageCount = [ZFGlobleManager getGlobleManager].pcSaveImageArray.count;
    if (imageCount > 0) {
        for (int i = 0; i < imageCount; i++) {
            UIImage *savaImage = [[ZFGlobleManager getGlobleManager].pcSaveImageArray[i] objectForKey:kPC_INFO_SHOWTEXT];
            NSInteger imageTag = [[[ZFGlobleManager getGlobleManager].pcSaveImageArray[i] objectForKey:kPC_INFO_UPSTRING] integerValue];
            [self setImageViewWithImage:savaImage viewOfTag:imageTag];
        }
    }
    
    CGRect contentRect = [_notoLabel.text boundingRectWithSize:CGSizeMake(_notoLabel.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0]} context:nil];
    _notoLabel.numberOfLines = 0;
    _notoLabelHeight.constant = contentRect.size.height;
    
}

- (IBAction)next:(id)sender {
    if (_photoContext1 == nil || _photoContext2 == nil) {
        [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"证件资料不完整", nil) inView:self.view];
        return;
    }
//    if (![_citizenshipCode isEqualToString:@"65"] && _photoContext3 == nil) {
//        [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"证件资料不完整", nil) inView:self.view];
//        return;
//    }
    if (_photoContext3 == nil) {
        [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"证件资料不完整", nil) inView:self.view];
        return;
    }
    
    self.imageArray = [NSMutableArray arrayWithObjects:@{kPC_INFO_SHOWTEXT:_photoContext1,kPC_INFO_UPSTRING:@"2"},
                       @{kPC_INFO_SHOWTEXT:_photoContext2, kPC_INFO_UPSTRING:@"0"},
                       nil];
//    if (![_citizenshipCode isEqualToString:@"65"] && _photoContext3 != nil) {
//        [self.imageArray addObject:@{kPC_INFO_SHOWTEXT:_photoContext3,kPC_INFO_UPSTRING:@"2"}];
//    }
    if (_photoContext3 != nil) {
        [self.imageArray addObject:@{kPC_INFO_SHOWTEXT:_photoContext3,kPC_INFO_UPSTRING:@"1"}];
    }
    if (_photoContext7 != nil) {
        [self.imageArray addObject:@{kPC_INFO_SHOWTEXT:_photoContext7,kPC_INFO_UPSTRING:@"6"}];
    }
    
    [self uploadData];
}


- (IBAction)zdpicTap:(UITapGestureRecognizer *)sender {
    _clickTag = sender.view.tag;
    NSLog(@"%zd", _clickTag);
    ZFImageUtils *imageU = [[ZFImageUtils alloc] init];
    imageU.block = ^(NSArray<UIImage *> *photos) {
        [self setImageViewWithImage:[photos firstObject] viewOfTag:_clickTag];
    };
    [imageU presentWithMaxCount:1 controller:self];
}


#pragma mark 拍照代理方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // 退出拍照页面,对拍摄的照片编辑
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *image = [[info objectForKey:UIImagePickerControllerOriginalImage] scaleImage200];
        [self setImageViewWithImage:image viewOfTag:_clickTag];
    }];
}

#pragma mark -- 网络请求
- (void)uploadData {
    NSMutableArray *uploadImageArray = [NSMutableArray array];
    for (int i = 0; i < self.imageArray.count; i++) {
        //        NSLog(@"1大小：%lu", [UIImageJPEGRepresentation(self.imageArray[i], 1) length]/1024);
        UIImage *uploadPic = [self.imageArray[i] objectForKey:kPC_INFO_SHOWTEXT];
        NSString *type = [self.imageArray[i] objectForKey:kPC_INFO_UPSTRING];
        if ([type isEqualToString:@"6"]) {
            type = @"04";
        } else {
            type = [NSString stringWithFormat:@"0%d", [type intValue]+1];
        }
        
        NSString *imageString = [UIImageJPEGRepresentation(uploadPic, 0.4) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        NSMutableDictionary *imageDic = [NSMutableDictionary dictionaryWithCapacity:2];
        [imageDic setObject:imageString forKey:@"image"];
        [imageDic setObject:type forKey:@"type"];
        [uploadImageArray addObject:imageDic];
    }

    NSMutableDictionary *uploadParams = [NSMutableDictionary dictionaryWithDictionary:self.params];
    [uploadParams setValue:[ZFGlobleManager getGlobleManager].areaNum forKey:@"countryCode"];
    [uploadParams setValue:[ZFGlobleManager getGlobleManager].userPhone forKey:@"mobile"];
    [uploadParams setValue:[ZFGlobleManager getGlobleManager].sessionID forKey:@"sessionID"];
    [uploadParams setValue:[ZFGlobleManager getGlobleManager].applyType forKey:@"applyType"];
    [uploadParams setValue:[ZFGlobleManager getGlobleManager].userKey forKey:@"userKey"];
    [uploadParams setValue:uploadImageArray forKey:@"imageList"];
    [uploadParams setValue:@"85" forKey:@"txnType"];
    
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    [NetworkEngine singlePostWithParmas:uploadParams success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        @try {
            if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
                [ZFGlobleManager getGlobleManager].pcSaveImageArray = nil;
                ZFPCCommitResultViewController *commitResult = [ZFPCCommitResultViewController new];
                [self pushViewController:commitResult];
                NSMutableArray<ZFBaseViewController *> *tempMArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                // 移除中间的控制器,下个页面可以直接回到银行卡列表页
                [tempMArray removeObjectsInRange:NSMakeRange(2, tempMArray.count-3)];
                [self.navigationController setViewControllers:tempMArray animated:NO];
            } else {
                [ZFGlobleManager getGlobleManager].pcSaveImageArray = [NSArray arrayWithArray:self.imageArray];
                [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
            }
        } @catch (NSException *exception) {
            [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"参数错误", nil) inView:self.view];
            return ;
        }
        
    } failure:^(id error) {
        [ZFGlobleManager getGlobleManager].pcSaveImageArray = [NSArray arrayWithArray:self.imageArray];
    }];
}


- (void)setImageViewWithImage:(UIImage *)image viewOfTag:(NSInteger)tag {
    switch (tag) {
        case 0:
        {
            _zmpic1.image = image;
            _photoContext1 = image;
        }
            break;
        case 1:
        {
            _zmpic2.image = image;
            _photoContext2 = image;
        }
            break;
        case 2:
        {
            _zmpic3.image = image;
            _photoContext3 = image;
        }
            break;
        case 3:
        {
            _gzzzpic1.image = image;
            _photoContext4 = image;
        }
            break;
        case 4:
        {
            _gzzzpic2.image = image;
            _photoContext5 = image;
        }
            break;
        case 5:
        {
            _gzzzpic3.image = image;
            _photoContext6 = image;
        }
            break;
        case 6:
        {
            _zdpic1.image = image;
            _photoContext7 = image;
        }
            break;
        default:
            break;
    }
}


@end
