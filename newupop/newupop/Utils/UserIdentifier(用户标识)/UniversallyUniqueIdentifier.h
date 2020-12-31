//
//  UniversallyUniqueIdentifier.h
//  newupop
//
//  Created by 中付支付 on 2017/7/28.
//  Copyright © 2017年 中付支付. All rights reserved.
//

// UUID(Universally Unique Identifier)
#import <Foundation/Foundation.h>

@interface UniversallyUniqueIdentifier : NSObject

// 应用卸载后再安装，此uuid会改变
@property (nonatomic, copy, readonly) NSString *uuid;
@property (nonatomic, copy, readonly) NSString *userkey;      //用户表识

+ (instancetype)sharedInstance;

@end
