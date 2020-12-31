//
//  UITextField+LimitLength.m
//  TextLengthLimitDemo
//
//  Created by Su XinDe on 13-4-8.
//  Copyright (c) 2013年 Su XinDe. All rights reserved.
//

#import "UITextField+LimitLength.h"
#import <objc/objc.h>
#import <objc/runtime.h>

static NSString *kLimitTextLengthKey = @"kLimitTextLengthKey";

@implementation UITextField (LimitLength)

/**
 限制英文或数字长度
 
 @param length 长度
 */
- (void)limitTextLength:(int)length
{
    objc_setAssociatedObject(self, (__bridge const void *)(kLimitTextLengthKey), [NSNumber numberWithInt:length], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self addTarget:self action:@selector(textFieldTextLengthLimit:) forControlEvents:UIControlEventEditingChanged];
}

/**
 限制中文文本长度
 
 @param length 长度
 */
- (void)limitCNTextLength:(int)length
{
    objc_setAssociatedObject(self, (__bridge const void *)(kLimitTextLengthKey), [NSNumber numberWithInt:length], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self addTarget:self action:@selector(textFieldTextLengthLimit:) forControlEvents:UIControlEventEditingDidEnd];
}

- (void)textFieldTextLengthLimit:(id)sender
{
    NSNumber *lengthNumber = objc_getAssociatedObject(self, (__bridge const void *)(kLimitTextLengthKey));
    int length = [lengthNumber intValue];
    if(self.text.length > length){
        self.text = [self.text substringToIndex:length];
    }
}

@end
















