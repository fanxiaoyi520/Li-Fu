//
//  SmallUtils.h
//  newupop
//
//  Created by 中付支付 on 2017/7/28.
//  Copyright © 2017年 中付支付. All rights reserved.
//

// 小工具类合集
#import <Foundation/Foundation.h>
#import <sys/utsname.h>


@interface SmallUtils : NSObject

// 生成订单号
+ (NSString *)generateOrderAppendiOSTag;

// 生成24位随机的字符串，做为3DES加密的key使用
+ (NSString *)generate24RandomKey;

/*
 * Zzz 2017年 5月 8日 星期一 11时36分38秒 CST
 * 将币种序号转换成符号字符串
 * param: 币种序号
 * retrun:符号字符串
 */
+ (NSString *)transformCurrencyNum2SymbolString:(NSString *) currencyNum;

/*
 * Zzz 2017年 5月 11日 星期一 11时36分38秒 CST
 * 将国家名称字符串转换成国家编号
 * param: 币种序号
 * retrun:符号字符串
 */
+ (NSString *)transformCountryString2SymbolString:(NSString *) countryNum;

/*
 * Zzz 2017年 5月12日 星期五 10时00分57秒 CST
 * 将国家编号转换成国家名称字符串
 * param: 国家编号
 * retrun:国家名称字符串
 */
+ (NSString *)transformSymbolString2CountryString:(NSString *) countryNum;

/*
 *2017 9 11
 *根据国家名返回国家id
 */
+ (NSString *)getCountryIdWith:(NSString *)countryName;

/*
 * Zzz 2017年 6月 7日 星期三 10时43分49秒 CST
 * 将国家代码转换成国家名称字符串
 * param: 国家编号
 * retrun:国家名称字符串
 */
+ (NSString *)transformCodeString2CountryString:(NSString *) countryCode;

/**
 根据编号返回图片名字
 */
+ (NSString *)getImageWitCode:(NSString *)code;

+ (BOOL)supportTouchsDevicesAndSystem;
@end

// 系统类
@interface SmallUtils (SystemInfo)

// 此方法可获取移动网络下的ip地址
+ (NSString *)getIPAddress:(BOOL)preferIPv4;

@end
