//
//  ZFBankCardModel.m
//  newupop
//
//  Created by Jellyfish on 2017/7/25.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFBankCardModel.h"

@implementation ZFBankCardModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"encryCardNo" : @"cardNum"};
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"openCountry" : [ZFBCOpenedModel class]};
}

- (NSString *)logoStr
{
    return [[ZFGlobleManager getGlobleManager] getBankIconByBankName:_bankName];
}

- (NSString *)cardNo
{
    //3des 解密
    NSString *cardNum = [TripleDESUtils getDecryptWithString:[_encryCardNo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                                                   keyString:[ZFGlobleManager getGlobleManager].securityKey
                                                    ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    return cardNum;
}

- (void)setBankName:(NSString *)bankName{
    _bankName = [bankName stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}

- (void)setBankNameLog:(NSString *)bankNameLog{
    _bankNameLog = [bankNameLog stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}

- (NSString *)phoneNumber {
    if ([_phoneNumber containsString:@"-"]) {
        return [[_phoneNumber componentsSeparatedByString:@"-"] lastObject];
    } else {
        return _phoneNumber;
    }
}


@end
