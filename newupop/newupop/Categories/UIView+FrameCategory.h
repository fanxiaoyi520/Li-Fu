//
//  UIView+FrameCategory.h
//  newupop
//
//  Created by 中付支付 on 2017/7/21.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (FrameCategory)
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat bottom;

@end
