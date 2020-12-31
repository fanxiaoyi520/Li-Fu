//
//  TradeModel.m
//  newupop
//
//  Created by 中付支付 on 2017/8/4.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "TradeModel.h"

@implementation TradeModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    DLog(@"Undefined ---> %@==%@", key, value);
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"merId" : @"merCode",
             };
}


- (NSString *)tradeMonth {
    return [_orderTime substringToIndex:6];
}

@end
