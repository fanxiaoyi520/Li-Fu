//
//  ZFUserSetController.m
//  newupop
//
//  Created by 中付支付 on 2017/7/21.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFUserSetController.h"
#import "ZFNavigationController.h"
#import "ZFLoginViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "UIImage+Extension.h"
#import "UIImageView+WebCache.h"
#import "ZFLoginViewController.h"
#import "ZFVCodeLoginViewController.h"
#import "ZFFingerprintLoginViewController.h"

@interface ZFUserSetController ()<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSArray *dataArray;
/** 拍摄的照片 **/
@property(nonatomic, strong) UIImage *scaleImage;


@end

@implementation ZFUserSetController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myTitle = @"账号设置";
    [self createView];
    
    [self getUserInfo];
}

- (void)getUserInfo{
    NSDictionary *parameters = @{@"txnType": @"73",
                                 @"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID":[ZFGlobleManager getGlobleManager].sessionID
                                 };
    
    //[[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            
            NSData *decodedImageData  = [[NSData alloc] initWithBase64EncodedString:[requestResult objectForKey:@"image"] options:(NSDataBase64DecodingIgnoreUnknownCharacters)];
            UIImage *headImage = [UIImage imageWithData:decodedImageData];
            NSString *imageUrl = [requestResult objectForKey:@"image"];
            [[ZFGlobleManager getGlobleManager] saveHeadImageWithUrl:imageUrl];
            
            if (![[requestResult objectForKey:@"idNo"] isKindOfClass:[NSNull class]] && [requestResult objectForKey:@"idNo"]) {
                [[NSUserDefaults standardUserDefaults] setObject:[requestResult objectForKey:@"idNo"] forKey:UserIdCardNum];
            }
            if (![[requestResult objectForKey:@"userName"] isKindOfClass:[NSNull class]] && [requestResult objectForKey:@"userName"]) {
                [[NSUserDefaults standardUserDefaults] setObject:[requestResult objectForKey:@"userName"] forKey:UserName];
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ZFGlobleManager getGlobleManager].headImage = headImage;
                [_tableView reloadData];
            });
        } else {
            //[[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(NSError *error) {
        //[[MBUtils sharedInstance] dismissMB];
        
    }];
}

- (void)createView{
    _dataArray = [NSArray arrayWithObjects:NSLocalizedString(@"头像", @"头像"), NSLocalizedString(@"姓名", @"姓名"), NSLocalizedString(@"证件号码", @"证件号码"), NSLocalizedString(@"手机号码", @"手机号码"), NSLocalizedString(@"退出登录", @"退出登录"), nil];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = GrayBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    [self.view addSubview:_tableView];
}

#pragma mark - tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 70;
    }
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return 20;
    }
    else if (section == 3) {
        return 20;
    }
    else {
        return 10;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 20;
    }
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    if (indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-90, 11, 48, 48)];
        imageView.layer.cornerRadius = imageView.width/2.0;
        imageView.clipsToBounds = YES;
        imageView.image = [ZFGlobleManager getGlobleManager].headImage;
        [cell addSubview:imageView];
    }
    cell.textLabel.text = _dataArray[indexPath.section];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
    
    if (indexPath.section == 4) {
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = UIColorFromRGB(0xD73246);
    }
    
    if (indexPath.section == 1 || indexPath.section == 2 || indexPath.section == 3) {
        [cell addSubview:[self cellLabelWith:indexPath.section]];
    }
    
    return cell;
}

//右侧标签
- (UILabel *)cellLabelWith:(NSInteger)index{
    NSString *str = @"";
    if (index == 1) {
        str = [[NSUserDefaults standardUserDefaults] objectForKey:UserName];
    }
    if (index == 2) {
        NSString *idNo = [[NSUserDefaults standardUserDefaults] objectForKey:UserIdCardNum];
        if (idNo.length > 2) {
            NSString *preStr = [idNo substringToIndex:1]; // 前缀
            NSString *sufStr = [idNo substringFromIndex:idNo.length-1]; // 后缀
            
            NSString *xingStr = @"";
            for (int i = 0; i < idNo.length-2; i++) {
                xingStr = [xingStr stringByAppendingString:@"*"]; // 中间*号替换
            }
            
            str = [[preStr stringByAppendingString:xingStr] stringByAppendingString:sufStr];
            
        } else {
            str = idNo;
        }
    }
    if (index == 3) {
        str = [[ZFGlobleManager getGlobleManager].userPhone stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-230, 0, 200, 44)];
    label.textAlignment = NSTextAlignmentRight;
    label.textColor = [UIColor grayColor];
    label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
    label.text = str;
    return label;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DLog(@"%zd", indexPath.section);
    if (indexPath.section == 0) {
        [self changeHeadimage];
    }
    if (indexPath.section == 4) {
        [self exitLogin];
    }
}

#pragma mark 上传头像
- (void)uploadImageWith:(NSString *)imageStr{
    NSDictionary *parameters = @{@"txnType": @"72",
                                 @"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                                 @"image":imageStr};
    
    [[MBUtils sharedInstance] showMBWithText:NSLocalizedString(@"头像上传中", nil) inView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[ZFGlobleManager getGlobleManager] saveHeadImageWithImage:_scaleImage];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(NSError *error) {
        //[[MBUtils sharedInstance] dismissMB];
        
    }];
}


#pragma mark - 拍照相关
//更换头像
- (void)changeHeadimage{
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
    [self presentViewController:alertDialog animated:YES completion:nil];
}

- (void)photograph { // 相机
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // 检查打开相机的权限是否打开 ·
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
            
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            [self showCamera];
        }
    } else {
        [XLAlertController acWithMessage:NSLocalizedString(@"该设备不支持相机", nil) confirmBtnTitle:NSLocalizedString(@"确定", nil)];
    }
}

- (void)openPhotoLibrary  {
    // 判断是否有权限
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            dispatch_async(dispatch_get_main_queue(), ^{            
                UIImagePickerController *alubmPicker = [[UIImagePickerController alloc] init];
                alubmPicker.delegate = self;
                alubmPicker.allowsEditing = YES;
                alubmPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                [self presentViewController:alubmPicker animated:YES completion:nil];
            });
        } else {
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"请去设置中打开访问相册开关", nil) preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *alertA = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy&path=PHOTOS"]];
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil];
            [alertC addAction:cancel];
            [alertC addAction:alertA];
            [self presentViewController:alertC animated:YES completion:nil];
        }
    }];
}

#pragma mark -- 调用照相机
- (void)showCamera{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.allowsEditing = YES;
        // 弹出系统拍照
        [self presentViewController:picker animated:YES completion:nil];
    }
}

#pragma mark -- 拍照代理方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    // 退出拍照页面,对拍摄的照片编辑
    [picker dismissViewControllerAnimated:YES completion:^{
        self.scaleImage = [[info objectForKey:UIImagePickerControllerEditedImage] scaleImage200];
        NSString *imageStr = [UIImageJPEGRepresentation(self.scaleImage, 0.5)  base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        imageStr = [self encodeToPercentEscapeString:imageStr];
        [self uploadImageWith:imageStr];
    }];
}

- (NSString *)encodeToPercentEscapeString: (NSString *) input{
    // (<http://www.ietf.org/rfc/rfc3986.txt>)
    NSString *outputStr = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,                   (CFStringRef)input, NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8));
    return outputStr;
}

//退出登录
- (void)exitLogin{
    DLog(@"退出登录");
    [XLAlertController acWithTitle:NSLocalizedString(@"退出登录", nil) msg:@"" confirmBtnTitle:NSLocalizedString(@"确定", nil) cancleBtnTitle:NSLocalizedString(@"取消", nil) confirmAction:^(UIAlertAction *action) {
        NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                     @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                     @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                                     @"txnType": @"26"};
        
        [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
        
        [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
            [[MBUtils sharedInstance] dismissMB];
            if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
                //清空信息
                [[ZFGlobleManager getGlobleManager] clearInfo];
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:@"1" forKey:@"autoLogin"];
                [userDefaults synchronize];
                
                NSArray *personArr = [[[ZFGlobleManager getGlobleManager] getdb] jq_lookupTable:@"user" dicOrModel:[ZFLogin class] whereFormat:[NSString stringWithFormat:@"where name = '%@'",[[NSUserDefaults standardUserDefaults] objectForKey:@"userPhoneNum"]]];
                if (personArr.count == 0) {
                    ZFLogin *login = [ZFLogin new];
                    login.isOpen = @"0";
                    login.name = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhoneNum"];
                    [[[ZFGlobleManager getGlobleManager] getdb] jq_insertTable:@"user" dicOrModel:login];
                } else {
                    ZFLogin *login = personArr[0];
                    if ([login.isOpen isEqualToString:@"1"]) {
                        UIWindow *window = [UIApplication sharedApplication].keyWindow;
                        ZFFingerprintLoginViewController *vc = [ZFFingerprintLoginViewController new];
                        window.rootViewController = [[ZFNavigationController alloc] initWithRootViewController:vc];
                    } else {
                        ZFVCodeLoginViewController *vc = [ZFVCodeLoginViewController new];
                        UIWindow *window = [UIApplication sharedApplication].keyWindow;
                        window.rootViewController = [[ZFNavigationController alloc] initWithRootViewController:vc];
                    }
                }
            } else {
                [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
            }
        } failure:^(NSError *error) {
            //[[MBUtils sharedInstance] dismissMB];
            
        }];
    }];
}

@end
