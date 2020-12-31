//
//  UniversallyUniqueIdentifier.m
//  newupop
//
//  Created by 中付支付 on 2017/7/28.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "UniversallyUniqueIdentifier.h"
#import "UIDevice+IdentifierAddition.h"
#import "XLUUIDTools.h"

@interface UniversallyUniqueIdentifier()

@property (nonatomic, strong) UIDevice *device;
@property (nonatomic, copy, readwrite) NSString *uuid;

@end

@implementation UniversallyUniqueIdentifier

- (UIDevice *)device
{
    if (_device == nil) {
        _device = [UIDevice currentDevice];
    }
    return _device;
}

- (NSString *)userkey
{
    return self.uuid;
}

- (NSString *)uuid
{
    return [XLUUIDTools getUUID];
}

+ (instancetype)sharedInstance
{
    static UniversallyUniqueIdentifier *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[UniversallyUniqueIdentifier alloc] init];
    });
    return sharedInstance;
}


@end
