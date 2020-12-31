//
//  ZFPCBankCard.m
//  newupop
//
//  Created by Jellyfish on 2020/1/8.
//  Copyright © 2020 中付支付. All rights reserved.
//

#import "ZFPCBankCard.h"

@implementation ZFPCBankCard

- (NSString *)cardNum {
    return [_cardNum stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}


@end
