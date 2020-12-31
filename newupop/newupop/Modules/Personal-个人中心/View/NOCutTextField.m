//
//  NOCutTextField.m
//  newupop
//
//  Created by 中付支付 on 2017/8/9.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "NOCutTextField.h"

@implementation NOCutTextField

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    // 禁用粘贴功能
    if (action == @selector(paste:))
        return NO;
    
    // 禁用选择功能
    if (action == @selector(select:))
        return NO;
    
    // 禁用全选功能
    if (action == @selector(selectAll:))
        return NO;
    
    return [super canPerformAction:action withSender:sender];
}

@end
