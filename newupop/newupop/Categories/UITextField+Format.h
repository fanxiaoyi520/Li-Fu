//
//  UITextField+Format.h
//  SinopayStore
//
//  Created by Jellyfish on 2017/12/7.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (Format)

/// 格式化手机号码
- (BOOL)formatMobileWithString:(NSString *)string range:(NSRange)range;

/// 格式化银行卡号
- (BOOL)formatBankCardNoWithString:(NSString *)string range:(NSRange)range;

@end
