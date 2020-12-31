//
//  NSString+Extension.h
//  newupop
//
//  Created by Jellyfish on 2017/11/15.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)

- (NSString *)hideCharactersWithRange:(NSRange)range replace:(NSString *)str;


///数组转json串
- (NSString *)dictArrayToJsonString:(NSMutableArray *)array;

///字典转json串
- (NSString *)convertDictToJsonData:(NSDictionary *)dict;

@end
