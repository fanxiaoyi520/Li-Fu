//
//  UIImage+Extension.h
//  StatePay
//
//  Created by Jellyfish on 2017/5/5.
//  Copyright © 2017年 Jellyfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)

- (UIImage *)scaleImage200;

- (UIImage *)scaleImage250;

/**
 *  图片比例,固定宽度,高度自适应
 */
- (UIImage *)scaleImage400;

/**
 *  矫正方向,横屏强制竖屏
 */
- (UIImage *)fixOrientation;


@end
