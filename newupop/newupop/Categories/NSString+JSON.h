//
//  NSString+JSON.h
//  newupop
//
//  Created by Jellyfish on 2017/7/27.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (JSON)

+ (NSDictionary *)parseJSONStringToNSDictionary:(NSString *)JSONString;

@end
