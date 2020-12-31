//
//  NSString+Extension.m
//  newupop
//
//  Created by Jellyfish on 2017/11/15.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

- (NSString *)hideCharactersWithRange:(NSRange)range replace:(NSString *)str
{
    
    return nil;
}

- (NSString *)dictArrayToJsonString:(NSMutableArray *)array{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *locationInfo = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    locationInfo = [locationInfo stringByReplacingOccurrencesOfString:@" " withString:@""];
    locationInfo = [locationInfo stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    locationInfo = [locationInfo stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    locationInfo = [locationInfo stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    
    return locationInfo;
}

- (NSString *)convertDictToJsonData:(NSDictionary *)dict{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        NSLog(@"%@",error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    return [self replacingOccurrencesOfString:jsonString];
}

- (NSString *)replacingOccurrencesOfString:(NSString *)string {
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    
    return string;
}

@end
