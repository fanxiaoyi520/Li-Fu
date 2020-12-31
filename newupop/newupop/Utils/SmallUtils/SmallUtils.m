//
//  SmallUtils.m
//  newupop
//
//  Created by 中付支付 on 2017/7/28.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "SmallUtils.h"

// ip address
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
//#define IOS_VPN       @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

// 系统类
#import <CoreLocation/CoreLocation.h>

@implementation SmallUtils

+ (NSString *)generateOrderAppendiOSTag {
    NSString *iOSTag = @"77";
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *date = [formatter stringFromDate:[NSDate date]];
    NSString *order = [NSString stringWithFormat:@"%@%04d%@", date, arc4random()%10000, iOSTag];
    return order;
}

+ (NSString *)generate24RandomKey{
    // A - Z , a - z , 0 - 9 共计62个字符
    NSArray *ar = [NSArray arrayWithObjects: @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"0", nil];
    NSString *result = [NSString string];
    
    // 产生24个数
    for (int i = 0; i < 24;  i++) {
        // 产生[0,ar.count - 1] 的随机数
        int value = arc4random() % ar.count;
        result = [result stringByAppendingString: ar[value]];
    }
    return result;
}

/*
 156 人民币    CNY
 702 新币     SGD
 344 港币     HKD
 840 美元     USD
 458 马币     MYR
 */
+ (NSString *)transformCurrencyNum2SymbolString:(NSString *) currencyNum{
    
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrencyInfo"];
    
    NSDictionary *localDict = @{@"156":@"CNY",
                                @"702":@"SGD",
                                @"344":@"HKD",
                                @"840":@"USD",
                                @"458":@"MYR",
                                @"096":@"BND",
                                
                                @"036":@"AUD",
                                @"124":@"CAD",
                                @"208":@"DKK",
                                @"392":@"JPY",
                                @"446":@"MOP",
                                @"554":@"NZD",
                                @"608":@"PHP",
                                @"752":@"SEK",
                                @"764":@"THB",
                                @"826":@"GBP",
                                @"410":@"KRW",
                                @"901":@"TWD",
                                @"978":@"EUR"
                                };
    if (!dict) {
        dict = localDict;
    }
    
    NSString *result = [dict objectForKey:currencyNum];
    if (!result) {
        result = [localDict objectForKey:currencyNum];
        if (!result) {
            result = @"";
        }
    }
    return result;
}

+ (NSString *)transformCountryString2SymbolString:(NSString *) countryNum{

    NSString *symbolString = @"";
    if([countryNum isEqualToString:@"中国香港/中国澳门 - 港币"])
    {
        symbolString = @"HK";
    }
    else if([countryNum isEqualToString:@"新加坡 - 新币"])
    {
        symbolString = @"SG";
    }
    else if([countryNum isEqualToString:@"马来西亚 - 马币"])
    {
        symbolString = @"MY";
    }
    else if([countryNum isEqualToString:@"其它地区 - 美元"])
    {
        symbolString = @"US";
    }
    return symbolString;
}

+ (NSString *)getCountryIdWith:(NSString *)countryName{
    NSString *symbolString = @"";
    if([countryName isEqualToString:NSLocalizedString(@"新加坡", nil)]){
        symbolString = @"SG";
    } else if([countryName isEqualToString:NSLocalizedString(@"马来西亚", nil)]){
        symbolString = @"MY";
    } else if ([countryName isEqualToString:NSLocalizedString(@"中国香港/中国澳门", nil)]){
        symbolString = @"HK";
    } else if ([countryName isEqualToString:NSLocalizedString(@"其它地区", nil)]){
        symbolString = @"US";
    }
    
    return symbolString;
}

+ (NSString *)transformSymbolString2CountryString:(NSString *) countryNum{

    NSString *CountryString = @"";
    if([countryNum isEqualToString:@"SG"]){
        CountryString = NSLocalizedString(@"新加坡", nil);
    } else if([countryNum isEqualToString:@"MY"]){
        CountryString = NSLocalizedString(@"马来西亚", nil);
    } else if([countryNum isEqualToString:@"HK"]){
        CountryString = NSLocalizedString(@"中国香港/中国澳门", nil);
    } else if([countryNum isEqualToString:@"US"]){
        CountryString = NSLocalizedString(@"其它地区", nil);
    }
    return CountryString;
}

+ (NSString *)transformCodeString2CountryString:(NSString *) countryCode{
    NSString *CountryString = @"";
    if([countryCode isEqualToString:@"702"]){
        CountryString = NSLocalizedString(@"新币", nil);
    } else if([countryCode isEqualToString:@"344"]){
        CountryString = NSLocalizedString(@"港币", nil);
    } else if([countryCode isEqualToString:@"840"]){
        CountryString = NSLocalizedString(@"美元", nil);
    } else if([countryCode isEqualToString:@"458"]){
        CountryString = NSLocalizedString(@"马币", nil);
    }
    return CountryString;
}

+ (NSString *)getImageWitCode:(NSString *)code{
    
    NSArray *arr1 = @[@"4511", @"4722", @"5200", @"5962", @"8220", @"9399", @"7922"];
    if ([arr1 containsObject:code]) {
        return @"record_icon_ticket";
    }
    
    NSArray *arr2 = @[@"5944", @"5309", @"7221", @"7273", @"7929", @"8099"];
    if ([arr2 containsObject:code]) {
        return @"record_icon_jewel";
    }
    
    NSArray *arr3 = @[@"5947", @"5969", @"5946", @"5045"];
    if ([arr3 containsObject:code]) {
        return @"record_icon_gift";
    }
    
    NSArray *arr4 = @[@"4733", @"5311", @"5331", @"5398", @"5411", @"5441", @"5442", @"5451", @"5462", @"5732", @"5921", @"5977", @"7011", @"8299", @"5499", @"5571", @"5712", @"5993", @"5995", @"7996", @"5948", @"7512"];
    if ([arr4 containsObject:code]) {
        return @"record_icon_market";
    }
    
    NSArray *arr5 = @[@"4215", @"4812", @"4814", @"5399", @"7994", @"4816", @"4899", @"5734"];
    if ([arr5 containsObject:code]) {
        return @"record_icon_virtual_item";
    }
    
    //0743、0744、1520、1740、1750、1761、1771、1799、2741、2791、2842、4011、4214、4225、4468、4582、5013、5021、5039、5044、5046、5047、5051、5065、5072、5074、5085、5094、5099、5111、5122、5131、5137、5139、5169、5172、5192、5193、5198、5199、5211、5551、5715、5960、6300、7299、7311、7321、7322、7333、7361、7372、7375、7379、7392、7399、7829、7993、7997、8111、8398、8641、8651、8661、8911、8912、8931、8999
    
    return @"record_icon_forex";
}

+ (BOOL)supportTouchsDevicesAndSystem {
    struct utsname systemInfo;
    uname(&systemInfo);

    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if ([platform isEqualToString:@"i386"])       return NO;
    if ([platform isEqualToString:@"x86_64"])     return NO;
    if ([platform isEqualToString:@"iPhone10,3"]) return NO;
    if ([platform isEqualToString:@"iPhone10,6"]) return NO;
    if ([platform isEqualToString:@"iPhone11,2"]) return NO;
    if ([platform isEqualToString:@"iPhone11,6"]) return NO;
    if ([platform isEqualToString:@"iPhone11,8"]) return NO;
    if ([platform isEqualToString:@"iPhone12,1"]) return NO;
    if ([platform isEqualToString:@"iPhone12,3"]) return NO;
    if ([platform isEqualToString:@"iPhone12,5"]) return NO;
    return YES;
}
@end

@implementation SmallUtils (SystemInfo)

+ (NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[ /*IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6,*/ IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ /*IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4,*/ IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
//    NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         if(address) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

+ (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

@end
