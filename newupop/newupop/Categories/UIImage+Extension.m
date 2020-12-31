//
//  UIImage+Extension.m
//  StatePay
//
//  Created by Jellyfish on 2017/5/5.
//  Copyright © 2017年 Jellyfish. All rights reserved.
//

#import "UIImage+Extension.h"

@implementation UIImage (Extension)

- (UIImage *)scaleImageWithWidth:(CGFloat)width
{
    CGFloat newWidth = width;
    CGFloat newHeight = newWidth * self.size.height / self.size.width;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(newWidth, newHeight), NO, 0);
    [self drawInRect:CGRectMake(0, 0, ceil(newWidth), ceil(newHeight))];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)scaleImage200
{
    return [self scaleImageWithWidth:200];
}

- (UIImage *)scaleImage250
{
    return [self scaleImageWithWidth:250];
}

- (UIImage *)scaleImage400
{
    return [self scaleImageWithWidth:400];
}

- (UIImage *)fixOrientation
{
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0);
    [self drawInRect:(CGRect){0, 0, self.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return normalizedImage;
}

@end
