//
//  KeyChainStore.h
//  newupop
//
//  Created by Jellyfish on 2020/3/9.
//  Copyright © 2020 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KeyChainStore : NSObject


+ (void)save:(NSString*)service data:(id)data;
+ (id)load:(NSString*)service;
+ (void)deleteKeyData:(NSString*)service;

@end

NS_ASSUME_NONNULL_END
