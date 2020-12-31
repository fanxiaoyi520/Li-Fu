//
//  ZDPayPopView.h
//  ReadingEarn
//
//  Created by FANS on 2020/4/15.
//  Copyright © 2020 FANS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

typedef enum _ZDPayPopViewEnum {
    SetUpFingerprintPayment  = 0, //设置支指纹支付

} ZDPayPopViewEnum;

typedef void (^ZDFingerprintOpenBlock)(UIButton *sender);
@interface ZDPayPopView : UIView
@property (nonatomic ,copy)ZDFingerprintOpenBlock fingerprintOpenBlock;

+ (ZDPayPopView *)readingEarnPopupViewWithType:(ZDPayPopViewEnum)type;
/**
// 设置支指纹支付
// */
- (void)showPopupViewWithData:(__nullable id)model
                       isOpen:(void (^) (UIButton *sender))isOpen;
- (void)closeThePopupView;

@end

NS_ASSUME_NONNULL_END
