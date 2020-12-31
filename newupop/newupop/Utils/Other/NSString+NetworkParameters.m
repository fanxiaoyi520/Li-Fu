//
//  NSString+NetworkParameters.m
//  SanWingQuickPayAbroad
//
//  Created by zhouzezhou on 2017/4/28.
//  Copyright © 2017年 Zzz. All rights reserved.
//

#import "NSString+NetworkParameters.h"

@implementation NSString (NetworkParameters)

// 对需要进行签名的字段进行拼接（并进行ASCII排序）
+(NSString *) getSanwingNetworkParam:(NSDictionary *) paramDic connector:(NSString *) connector
{
    NSString *result = [NSString string];
    BOOL first = YES;
    
    // 字符串数组排序
    NSArray *paramKey = [paramDic allKeys];
    
//    NSStringCompareOptions comparisonOptions =NSCaseInsensitiveSearch|NSNumericSearch|
//    NSWidthInsensitiveSearch|NSForcedOrderingSearch;
    NSStringCompareOptions comparisonOptions = NSNumericSearch|
    NSWidthInsensitiveSearch|NSForcedOrderingSearch;
    NSComparator sort = ^(NSString *obj1, NSString *obj2){
        NSRange range = NSMakeRange(0, obj1.length);
        return [obj1 compare:obj2 options:comparisonOptions range:range];
    };
    
    NSArray *paramKeySorted = [paramKey sortedArrayUsingComparator:sort];
//    NSLog(@"字符串数组排序结果%@",paramKeySorted);

    for(int i = 0; i < paramKeySorted.count; i++)
    {
        if(!first)
        {
            result = [result stringByAppendingString:@"&"];
        }
        first = NO;
        
        result = [result stringByAppendingString: paramKeySorted[i]];
        result = [result stringByAppendingString: @"="];
        NSString *value = [paramDic objectForKey: paramKeySorted[i]];
        if(value != nil && [value isKindOfClass:[NSString class]]  && ![value isEqualToString:@""])
        {
            result = [result stringByAppendingString:value];
        }
    }
    
    return result;
}



@end
