//
//  ZFPCBankCard.h
//  newupop
//
//  Created by Jellyfish on 2020/1/8.
//  Copyright © 2020 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFPCBankCard : NSObject

@property (nonatomic, strong) NSString *cardNum;
@property (nonatomic, strong) NSString *failReasons;
@property (nonatomic, strong) NSString *origStatus;

@end

NS_ASSUME_NONNULL_END
