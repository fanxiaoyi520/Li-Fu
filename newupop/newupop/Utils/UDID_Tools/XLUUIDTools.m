//
//  XLUUIDTools.m
//  newupop
//
//  Created by Jellyfish on 2020/3/9.
//  Copyright © 2020 中付支付. All rights reserved.
//

#import "XLUUIDTools.h"
#import "KeyChainStore.h"

#define KEY_POWERPAYSCAN_UUID @"cn.qtopay.unionpay.uuid"

@implementation XLUUIDTools


+(NSString*)getUUID {
    NSString *strUUID = (NSString *)[KeyChainStore load:KEY_POWERPAYSCAN_UUID];
    if([strUUID isEqualToString:@""] || !strUUID) {
            //生成一个uuid的方法
            CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
            strUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidRef));
            //将该uuid保存到keychain
            [KeyChainStore save:KEY_POWERPAYSCAN_UUID data:strUUID];
    }
    
    DLog(@"strUUID: %@", strUUID);//B3E3E9BF-E57C-41BA-9F9A-DE3FB47D4064
    
    return strUUID;
}

@end
