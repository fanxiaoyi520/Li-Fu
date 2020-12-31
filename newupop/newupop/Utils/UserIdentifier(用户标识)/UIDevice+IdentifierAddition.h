//
//  UIDevice(Identifier).h
//  newupop
//
//  Created by 中付支付 on 2017/7/28.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIDevice (IdentifierAddition)

/*
 * @method uuid
 * @description apple identifier support iOS6 and iOS5 below
 */

- (NSString *) AIF_uuid;
//- (NSString *) AIF_udid;
- (NSString *) AIF_macaddress;
//- (NSString *) AIF_macaddressMD5;
- (NSString *) AIF_machineType;
- (NSString *) AIF_ostype;//显示“ios6，ios5”，只显示大版本号
- (NSString *) AIF_createUUID;

//兼容旧版本
- (NSString *) uuid;
//- (NSString *) udid;
- (NSString *) macaddress;
//- (NSString *) macaddressMD5;
- (NSString *) machineType;
- (NSString *) ostype;//显示“ios6，ios5”，只显示大版本号
- (NSString *) createUUID;
@end
