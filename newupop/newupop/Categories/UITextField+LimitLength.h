//
//  UITextField+LimitLength.h
//  TextLengthLimitDemo
//
//  Created by Su XinDe on 13-4-8.
//  Copyright (c) 2013年 Su XinDe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UITextField (LimitLength)

/**
 限制英文或数字长度

 @param length 长度
 */
- (void)limitTextLength:(int)length;

/**
 限制中文文本长度

 @param length 长度
 */
- (void)limitCNTextLength:(int)length;

@end
