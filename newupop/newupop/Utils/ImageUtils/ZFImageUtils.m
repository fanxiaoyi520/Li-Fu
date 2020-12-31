//
//  ZFImageUtils.m
//  Agent
//
//  Created by 中付支付 on 2019/1/25.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "ZFImageUtils.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "UIImage+Extension.h"
#import "TZImagePickerController.h"

@interface ZFImageUtils ()<UIActionSheetDelegate, TZImagePickerControllerDelegate>

@property (nonatomic, strong)UIViewController *contorller;
@property (nonatomic, assign)NSInteger count;

@end

@implementation ZFImageUtils

- (void)presentWithMaxCount:(NSInteger)count controller:(UIViewController *)controller{
    _count = count;
    _contorller = controller;
    [self presentActionSheet];
}

#pragma mark - actionsheet
- (void)presentActionSheet {
    // 准备初始化配置参数
    NSString *photo = NSLocalizedString(@"拍照", nil);
    NSString *album = NSLocalizedString(@"从手机相册选择", nil);
    NSString *cancel = NSLocalizedString(@"取消", nil);
    
    // 初始化
    UIAlertController *alertDialog = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:photo style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // 相机拍照
        [self photograph];
    }];
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:album style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // 相册
        [self openPhotoLibrary];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // 取消按键
        DLog(@"cancelAction");
    }];
    
    // 添加操作（顺序就是呈现的上下顺序）
    [alertDialog addAction:photoAction];
    [alertDialog addAction:albumAction];
    [alertDialog addAction:cancelAction];
    
    // 呈现警告视图
    [_contorller presentViewController:alertDialog animated:YES completion:nil];
}

#pragma mark - 相机拍照
- (void)photograph {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // 检查打开相机的权限是否打开
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
        {
            NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
            NSString *title = [appName stringByAppendingString:NSLocalizedString(@"不能访问您的相机", nil)];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:NSLocalizedString(@"请前往“设置”打开相机访问权限", nil) preferredStyle:UIAlertControllerStyleAlert];
            // 取消
            UIAlertAction *cancle = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:0 handler:nil];
            [alert addAction:cancle];
            
            // 确定
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"打开", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
            }];
            [alert addAction:confirmAction];
            
            [_contorller presentViewController:alert animated:YES completion:nil];
        } else { // 调用照相机
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = _contorller;//有UINavigationControllerDelegate代理 必须在vc里实现
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                // 不允许编辑
                picker.allowsEditing = NO;
                // 弹出系统拍照
                [_contorller presentViewController:picker animated:YES completion:nil];
            }
        }
    } else {
        [XLAlertController acWithMessage:NSLocalizedString(@"该设备不支持相机", nil) confirmBtnTitle:NSLocalizedString(@"确定", nil)];
    }
}

#pragma mark - 相册
- (void)openPhotoLibrary{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:_count delegate:self];
    imagePickerVc.showSelectedIndex = YES;
    imagePickerVc.allowTakeVideo = NO;
    imagePickerVc.allowPickingVideo = NO;
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        if (_block) {
            _block(photos);
        }
    }];
    [_contorller presentViewController:imagePickerVc animated:YES completion:nil];
}

@end
