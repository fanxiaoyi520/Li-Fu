//
//  TripleDESUtils.m
//  newupop
//
//  Created by 中付支付 on 2017/7/28.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "TripleDESUtils.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCrypto.h>

@implementation TripleDESUtils

#pragma mark- 3des加密
+ (NSString*)getEncryptWithString:(NSString *)encryptString keyString:(NSString *)keyString ivString:(NSString *)ivString{
    
    return [self doCipher:encryptString keyString:keyString ivString:ivString operation:kCCEncrypt];
}

+ (NSString*)getHexEncryptWithString:(NSString*)encryptString keyString:(NSString*)keyString ivString:(NSString*)ivString
{
    return [self doCipherHexString:encryptString keyString:keyString ivString:ivString operation:kCCEncrypt];
}

#pragma mark- 3des解密
+ (NSString*)getDecryptWithString:(NSString *)decryptString keyString:(NSString *)keyString ivString:(NSString *)ivString{
    
    return [self doCipher:decryptString keyString:keyString ivString:ivString operation:kCCDecrypt];
}

+ (NSString*)getDecryptWithHexString:(NSString*)decryptString keyString:(NSString*)keyString ivString:(NSString*)ivString
{
    return [self doCipherHexString:decryptString keyString:keyString ivString:ivString operation:kCCDecrypt];
}

// 加解密实现方法
+(NSString *) doCipher:(NSString*)plainText keyString:(NSString*)keyString ivString:(NSString*)ivString operation:(CCOperation)encryptOrDecrypt
{
    const void * vplainText;
    size_t plainTextBufferSize;
    
    if (encryptOrDecrypt== kCCDecrypt)
    {
        //        NSData * EncryptData = [GTMBase64 decodeData:[plainText
        //                                                      dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSData *EncryptData = [[NSData alloc] initWithBase64EncodedString:plainText options:0];
        plainTextBufferSize = [EncryptData length];
        vplainText = [EncryptData bytes];
        
        plainTextBufferSize= [EncryptData length];
        vplainText = [EncryptData bytes];
    }
    else
    {
        NSData * tempData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
        plainTextBufferSize= [tempData length];
        vplainText = [tempData bytes];
    }
    
    CCCryptorStatus ccStatus;
    uint8_t * bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    // uint8_t ivkCCBlockSize3DES;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES)
    &~(kCCBlockSize3DES- 1);
    
    bufferPtr = malloc(bufferPtrSize* sizeof(uint8_t));
    memset((void*)bufferPtr,0x0, bufferPtrSize);
    
    NSString * key = keyString;
    NSString * initVec = ivString;
    
    const void * vkey= (const void *)[key UTF8String];
    const void * vinitVec= (const void *)[initVec UTF8String];
    
    uint8_t iv[kCCBlockSize3DES];
    memset((void*) iv,0x0, (size_t)sizeof(iv));
    
    ccStatus = CCCrypt(encryptOrDecrypt,
                       kCCAlgorithm3DES,
                       kCCOptionPKCS7Padding,
                       vkey,//"123456789012345678901234", //key
                       kCCKeySize3DES,
                       vinitVec,//"init Vec", //iv,
                       vplainText,//plainText,
                       plainTextBufferSize,
                       (void*)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    
    //if (ccStatus == kCCSuccess) NSLog(@"SUCCESS");
    if (ccStatus== kCCParamError) return @"PARAM ERROR";
    else if (ccStatus == kCCBufferTooSmall) return @"BUFFER TOO SMALL";
    else if (ccStatus == kCCMemoryFailure) return @"MEMORY FAILURE";
    else if (ccStatus == kCCAlignmentError) return @"ALIGNMENT";
    else if (ccStatus == kCCDecodeError) return @"DECODE ERROR";
    else if (ccStatus == kCCUnimplemented) return @"UNIMPLEMENTED";
    
    NSString * result;
    
    if (encryptOrDecrypt== kCCDecrypt)
    {
        result = [[NSString alloc] initWithData:[NSData
                                                 dataWithBytes:(const void *)bufferPtr
                                                 length:(NSUInteger)movedBytes]
                                       encoding:NSUTF8StringEncoding];
        ;
    }
    else
    {
        NSData * myData =[NSData dataWithBytes:(const void *)bufferPtr
                                        length:(NSUInteger)movedBytes];
        
        //        result = [GTMBase64 stringByEncodingData:myData];
        result = [myData base64EncodedStringWithOptions:0];
    }
    
    return result;
}

// 16进行要求的3DES加解密
// 用于二维码信息加密
+(NSString *) doCipherHexString:(NSString*)plainText keyString:(NSString*)keyString ivString:(NSString*)ivString operation:(CCOperation)encryptOrDecrypt
{
    const void * vplainText;
    size_t plainTextBufferSize;
    
    if (encryptOrDecrypt== kCCDecrypt)
    {
        // 16进制转换成10进制
        // ------------ new hex string handle fast
        const char *chars = [plainText UTF8String];
        int i = 0;
        unsigned long len = plainText.length;
        
        NSMutableData *EncryptData = [NSMutableData dataWithCapacity:len / 2];
        char byteChars[3] = {'\0','\0','\0'};
        unsigned long wholeByte;
        
        while (i < len) {
            byteChars[0] = chars[i++];
            byteChars[1] = chars[i++];
            wholeByte = strtoul(byteChars, NULL, 16);
            [EncryptData appendBytes:&wholeByte length:1];
        }
        
        plainTextBufferSize = [EncryptData length];
        vplainText = [EncryptData bytes];
        
        plainTextBufferSize= [EncryptData length];
        vplainText = [EncryptData bytes];
    }
    else
    {
        NSData * tempData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
        plainTextBufferSize= [tempData length];
        vplainText = [tempData bytes];
    }
    
    CCCryptorStatus ccStatus;
    uint8_t * bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    // uint8_t ivkCCBlockSize3DES;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES)
    &~(kCCBlockSize3DES- 1);
    
    bufferPtr = malloc(bufferPtrSize* sizeof(uint8_t));
    memset((void*)bufferPtr,0x0, bufferPtrSize);
    
    NSString * key = keyString;
    NSString * initVec = ivString;
    
    const void * vkey= (const void *)[key UTF8String];
    const void * vinitVec= (const void *)[initVec UTF8String];
    
    uint8_t iv[kCCBlockSize3DES];
    memset((void*) iv,0x0, (size_t)sizeof(iv));
    
    ccStatus = CCCrypt(encryptOrDecrypt,
                       kCCAlgorithm3DES,
                       kCCOptionPKCS7Padding,
                       vkey,//"123456789012345678901234", //key
                       kCCKeySize3DES,
                       vinitVec,//"init Vec", //iv,
                       vplainText,//plainText,
                       plainTextBufferSize,
                       (void*)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    
    //if (ccStatus == kCCSuccess) NSLog(@"SUCCESS");
    if (ccStatus== kCCParamError) return @"PARAM ERROR";
    else if (ccStatus == kCCBufferTooSmall) return @"BUFFER TOO SMALL";
    else if (ccStatus == kCCMemoryFailure) return @"MEMORY FAILURE";
    else if (ccStatus == kCCAlignmentError) return @"ALIGNMENT";
    else if (ccStatus == kCCDecodeError) return @"DECODE ERROR";
    else if (ccStatus == kCCUnimplemented) return @"UNIMPLEMENTED";
    
    NSString * result;
    
    if (encryptOrDecrypt== kCCDecrypt)
    {
        result = [[NSString alloc] initWithData:[NSData
                                                 dataWithBytes:(const void *)bufferPtr
                                                 length:(NSUInteger)movedBytes]
                                       encoding:NSUTF8StringEncoding];
        
    }
    else
    {
        NSData * myData =[NSData dataWithBytes:(const void *)bufferPtr
                                        length:(NSUInteger)movedBytes];
        
        Byte *bytes = (Byte *)[myData bytes];
        // 下面是Byte转换为16进制
        NSString *hexStr=@"";
        for(int i=0;i<[myData length];i++)
        {
            NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
            
            if([newHexStr length]==1)
                hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
            else
                hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
        }
        result = [hexStr uppercaseString];
    }
    
    return result;
}


@end
