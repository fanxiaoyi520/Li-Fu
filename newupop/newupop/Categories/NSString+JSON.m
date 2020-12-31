//
//  NSString+JSON.m
//  newupop
//
//  Created by Jellyfish on 2017/7/27.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "NSString+JSON.h"

@implementation NSString (JSON)


+ (NSDictionary *)parseJSONStringToNSDictionary:(NSString *)JSONString {
    NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableLeaves error:nil];
    return responseJSON;
}


@end
