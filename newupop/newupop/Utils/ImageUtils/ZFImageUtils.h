//
//  ZFImageUtils.h
//  Agent
//
//  Created by 中付支付 on 2019/1/25.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ImageBlock)(NSArray<UIImage *> *photos);

NS_ASSUME_NONNULL_BEGIN

@interface ZFImageUtils : NSObject

- (void)presentWithMaxCount:(NSInteger)count controller:(UIViewController *)controller;

@property (nonatomic, copy)ImageBlock block;

@end

NS_ASSUME_NONNULL_END
