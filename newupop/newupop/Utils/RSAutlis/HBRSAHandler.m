//
//  HBRSAHandler.m
//  iOSRSAHandlerDemo
//
//  Created by wangfeng on 15/10/19.
//  Copyright (c) 2015年 HustBroventure. All rights reserved.
//
#import "HBRSAHandler.h"
#include <openssl/rsa.h>
#include <openssl/pem.h>
#include <openssl/err.h>
#include <openssl/md5.h>

typedef enum {
    RSA_PADDING_TYPE_NONE       = RSA_NO_PADDING,
    RSA_PADDING_TYPE_PKCS1      = RSA_PKCS1_PADDING,
    RSA_PADDING_TYPE_SSLV23     = RSA_SSLV23_PADDING
}RSA_PADDING_TYPE;

#define  PADDING   RSA_PADDING_TYPE_PKCS1

@implementation HBRSAHandler
{

    RSA* _rsa_pub;
    RSA* _rsa_pri;
}

+ (instancetype)sharedInstance
{
    static HBRSAHandler *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HBRSAHandler alloc] init];
        [sharedInstance initRSASign];
    });
    return sharedInstance;
}

//-(instancetype) init
//{
//    self = [super init];
//
//    if(self)
//    {
//        [self initRSASign];
//    }
//    return self;
//}

-(void) initRSASign
{
    NSString* private_key_string = @"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";
    
    NSString* public_key_string = @"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwUje6Zui/mX7Uns+uTb8VGQEK4Qoq4veeobUljfsiNuTg8FQECw6dMUje6pic/gwW2SGqzQJjfP1YqFc2FCHOsoCGPNazU74kYmRzpL1m1jTwatS8Km7dE9oENyhpItXMYemuEV9RTR/z8OsQbPVo/mp7axYYJtkmcR3P9eeAFkOTNO51N775JXTRbchceTDiyxNAg4Nq/fHjBOzPx5VmgYBY2qF1YNZqGZ0/kIU31Ei9z7aLjM5aPuGYTDEe5nz0E3zXizfpAPoNBlIX9rgI7rhhye1jTRwzoOVIsx7JGF9QeWoir0krzLzF6Yt7Jfn9GKO5PzC3KsnUjJDWQfC7QIDAQAB";
    
    //    _rsaHandler = [HBRSAHandler new];
    
    // 使用公私钥字符串
    [self importKeyWithType:KeyTypePrivate andkeyString:private_key_string];
    [self importKeyWithType:KeyTypePublic andkeyString:public_key_string];
    
}

#pragma mark - public methord
-(BOOL)importKeyWithType:(KeyType)type andPath:(NSString *)path
{
    BOOL status = NO;
    const char* cPath = [path cStringUsingEncoding:NSUTF8StringEncoding];
    FILE* file = fopen(cPath, "rb");
    if (!file) {
        return status;
    }
    if (type == KeyTypePublic) {
        _rsa_pub = NULL;
        if((_rsa_pub = PEM_read_RSA_PUBKEY(file, NULL, NULL, NULL))){
            status = YES;
        }
        
        
    }else if(type == KeyTypePrivate){
        _rsa_pri = NULL;
        if ((_rsa_pri = PEM_read_RSAPrivateKey(file, NULL, NULL, NULL))) {
            status = YES;
        }

    }
    fclose(file);
    return status;

}
- (BOOL)importKeyWithType:(KeyType)type andkeyString:(NSString *)keyString
{
    if (!keyString) {
        return NO;
    }
    BOOL status = NO;
    BIO *bio = NULL;
    RSA *rsa = NULL;
    bio = BIO_new(BIO_s_file());
    NSString* temPath = NSTemporaryDirectory();
    NSString* rsaFilePath = [temPath stringByAppendingPathComponent:@"RSAKEY"];
    NSString* formatRSAKeyString = [self formatRSAKeyWithKeyString:keyString andKeytype:type];
    BOOL writeSuccess = [formatRSAKeyString writeToFile:rsaFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    if (!writeSuccess) {
        return NO;
    }
    const char* cPath = [rsaFilePath cStringUsingEncoding:NSUTF8StringEncoding];
    BIO_read_filename(bio, cPath);
    if (type == KeyTypePrivate) {
        rsa = PEM_read_bio_RSAPrivateKey(bio, NULL, NULL, "");
        _rsa_pri = rsa;
        if (rsa != NULL && 1 == RSA_check_key(rsa)) {
            status = YES;
        } else {
            status = NO;
        }


    }
    else{
        rsa = PEM_read_bio_RSA_PUBKEY(bio, NULL, NULL, NULL);
        _rsa_pub = rsa;
        if (rsa != NULL) {
            status = YES;
        } else {
            status = NO;
        }
    }
    
           BIO_free_all(bio);
    [[NSFileManager defaultManager] removeItemAtPath:rsaFilePath error:nil];
    return status;
}


#pragma mark RSA sha1验证签名
    //signString为base64字符串
- (BOOL)verifyString:(NSString *)string withSign:(NSString *)signString
{
    if (!_rsa_pub) {
        //NSLog(@"please import public key first");
        return NO;
    }

    const char *message = [string cStringUsingEncoding:NSUTF8StringEncoding];
    int messageLength = (int)[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSData *signatureData = [[NSData alloc]initWithBase64EncodedString:signString options:0];
    unsigned char *sig = (unsigned char *)[signatureData bytes];
    unsigned int sig_len = (int)[signatureData length];
    

    
   
    unsigned char sha1[20];
    SHA1((unsigned char *)message, messageLength, sha1);
       int verify_ok = RSA_verify(NID_sha1
                                      , sha1, 20
                                      , sig, sig_len
                                      , _rsa_pub);

    if (1 == verify_ok){
        return   YES;
    }
    return NO;
    
    
}
#pragma mark RSA MD5 验证签名
- (BOOL)verifyMD5String:(NSString *)string withSign:(NSString *)signString
{
    if (!_rsa_pub) {
        //NSLog(@"please import public key first");
        return NO;
    }

    const char *message = [string cStringUsingEncoding:NSUTF8StringEncoding];
        // int messageLength = (int)[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSData *signatureData = [[NSData alloc]initWithBase64EncodedString:signString options:0];
    unsigned char *sig = (unsigned char *)[signatureData bytes];
    unsigned int sig_len = (int)[signatureData length];
    
    unsigned char digest[MD5_DIGEST_LENGTH];
    MD5_CTX ctx;
    MD5_Init(&ctx);
    MD5_Update(&ctx, message, strlen(message));
    MD5_Final(digest, &ctx);
    int verify_ok = RSA_verify(NID_md5
                                      , digest, MD5_DIGEST_LENGTH
                                      , sig, sig_len
                                      , _rsa_pub);
    if (1 == verify_ok){
        return   YES;
    }
    return NO;
    
}

- (NSString *)signString:(NSString *)string
{
    if (!_rsa_pri) {
        //NSLog(@"please import private key first");
        return nil;
    }
    const char *message = [string cStringUsingEncoding:NSUTF8StringEncoding];
    int messageLength = (int)strlen(message);
    unsigned char *sig = (unsigned char *)malloc(256);
    unsigned int sig_len;
    
    unsigned char sha1[20];
    SHA1((unsigned char *)message, messageLength, sha1);
    
    int rsa_sign_valid = RSA_sign(NID_sha1
                                          , sha1, 20
                                          , sig, &sig_len
                                          , _rsa_pri);
    if (rsa_sign_valid == 1) {
        NSData* data = [NSData dataWithBytes:sig length:sig_len];
        
        NSString * base64String = [data base64EncodedStringWithOptions:0];
        free(sig);
        return base64String;
    }
    
    free(sig);
    return nil;
}
- (NSString *)signMD5String:(NSString *)string
{
    if (!_rsa_pri) {
        //NSLog(@"please import private key first");
        return nil;
    }
    const char *message = [string cStringUsingEncoding:NSUTF8StringEncoding];
        //int messageLength = (int)strlen(message);
//    unsigned char *sig = (unsigned char *)malloc(256);
    unsigned char *sig = (unsigned char *)malloc(1024);
    unsigned int sig_len;
    
    unsigned char digest[MD5_DIGEST_LENGTH];
    MD5_CTX ctx;
    MD5_Init(&ctx);
    MD5_Update(&ctx, message, strlen(message));
    MD5_Final(digest, &ctx);
    
    int rsa_sign_valid = RSA_sign(NID_md5
                                  , digest, MD5_DIGEST_LENGTH
                                  , sig, &sig_len
                                  , _rsa_pri);
   
    if (rsa_sign_valid == 1) {
        NSData* data = [NSData dataWithBytes:sig length:sig_len];
        
        NSString * base64String = [data base64EncodedStringWithOptions:0];
        free(sig);
        return base64String;
    }
    
    free(sig);
    return nil;
}

- (NSString *) encryptWithPublicKey:(NSString*)content
{
    if (!_rsa_pub) {
        //NSLog(@"please import public key first");
        return nil;
    }
    int status;
    int length  = (int)[content length];
    unsigned char input[length + 1];
    bzero(input, length + 1);
    int i = 0;
    for (; i < length; i++)
        {
        input[i] = [content characterAtIndex:i];
        }
    
    NSInteger  flen = [self getBlockSizeWithRSA_PADDING_TYPE:PADDING andRSA:_rsa_pub];
    
    char *encData = (char*)malloc(flen);
    bzero(encData, flen);
    status = RSA_public_encrypt(length, (unsigned char*)input, (unsigned char*)encData, _rsa_pub, PADDING);
    
    if (status){
        NSData *returnData = [NSData dataWithBytes:encData length:status];
        free(encData);
        encData = NULL;
        
            //NSString *ret = [returnData base64EncodedString];
        NSString *ret = [returnData base64EncodedStringWithOptions: NSDataBase64Encoding64CharacterLineLength];
        return ret;
        }
    
    free(encData);
    encData = NULL;
    
    return nil;
}

// RSA加密——私钥 Zzz新加
- (NSString *) encryptWithPrivateKey:(NSString*)content
{
    if (!_rsa_pri) {
        //NSLog(@"please import private key first");
        return nil;
    }
    int status;
    int length  = (int)[content length];
    unsigned char input[length + 1];
    bzero(input, length + 1);
    int i = 0;
    for (; i < length; i++)
    {
        input[i] = [content characterAtIndex:i];
    }
    
    NSInteger  flen = [self getBlockSizeWithRSA_PADDING_TYPE:PADDING andRSA:_rsa_pri];
    
    char *encData = (char*)malloc(flen);
    bzero(encData, flen);
    status = RSA_private_encrypt(length, (unsigned char*)input, (unsigned char*)encData, _rsa_pri, PADDING);
    
    if (status){
        NSData *returnData = [NSData dataWithBytes:encData length:status];
        free(encData);
        encData = NULL;
        
        //NSString *ret = [returnData base64EncodedString];
        NSString *ret = [returnData base64EncodedStringWithOptions: NSDataBase64Encoding64CharacterLineLength];
        return ret;
    }
    
    free(encData);
    encData = NULL;
    
    return nil;
}

- (NSString *) decryptWithPrivateKey:(NSString*)content
{
    if (!_rsa_pri) {
        //NSLog(@"please import private key first");
        return nil;
    }
    int status;
        //NSData *data = [content base64DecodedData];
    NSData *data = [[NSData alloc]initWithBase64EncodedString:content options:NSDataBase64DecodingIgnoreUnknownCharacters];
    int length = (int)[data length];
    
    NSInteger flen = [self getBlockSizeWithRSA_PADDING_TYPE:PADDING andRSA:_rsa_pri];
    char *decData = (char*)malloc(flen);
    bzero(decData, flen);
    
    status = RSA_private_decrypt(length, (unsigned char*)[data bytes], (unsigned char*)decData, _rsa_pri, PADDING);
   
    if (status)
        {
        NSMutableString *decryptString = [[NSMutableString alloc] initWithBytes:decData length:strlen(decData) encoding:NSASCIIStringEncoding];
        free(decData);
        decData = NULL;
        
        return decryptString;
        }
    
    free(decData);
    decData = NULL;
    
    return nil;
}

// RSA解密——公钥 Zzz新加
- (NSString *) decryptWithPublicKey:(NSString*)content
{
    if (!_rsa_pub) {
        //NSLog(@"please import public key first");
        return nil;
    }
    int status;
    //NSData *data = [content base64DecodedData];
    NSData *data = [[NSData alloc]initWithBase64EncodedString:content options:NSDataBase64DecodingIgnoreUnknownCharacters];
    int length = (int)[data length];
    
    NSInteger flen = [self getBlockSizeWithRSA_PADDING_TYPE:PADDING andRSA:_rsa_pub];
    char *decData = (char*)malloc(flen);
    bzero(decData, flen);
    
    status = RSA_public_decrypt(length, (unsigned char*)[data bytes], (unsigned char*)decData, _rsa_pub, PADDING);
    
    if (status)
    {
        NSMutableString *decryptString = [[NSMutableString alloc] initWithBytes:decData length:strlen(decData) encoding:NSASCIIStringEncoding];
        free(decData);
        decData = NULL;
        
        return decryptString;
    }
    
    free(decData);
    decData = NULL;
    
    return nil;
}

- (int)getBlockSizeWithRSA_PADDING_TYPE:(RSA_PADDING_TYPE)padding_type andRSA:(RSA*)rsa
{
    int len = RSA_size(rsa);
    
    if (padding_type == RSA_PADDING_TYPE_PKCS1 || padding_type == RSA_PADDING_TYPE_SSLV23) {
        len -= 11;
    }
    
    return len;
}

-(NSString*)formatRSAKeyWithKeyString:(NSString*)keyString andKeytype:(KeyType)type
{
    NSInteger lineNum = -1;
    NSMutableString *result = [NSMutableString string];
    
    if (type == KeyTypePrivate) {
        [result appendString:@"-----BEGIN PRIVATE KEY-----\n"];
        lineNum = 79;
    }else if(type == KeyTypePublic){
    [result appendString:@"-----BEGIN PUBLIC KEY-----\n"];
         lineNum = 76;
    }
   
    int count = 0;
    for (int i = 0; i < [keyString length]; ++i) {
        unichar c = [keyString characterAtIndex:i];
        if (c == '\n' || c == '\r') {
            continue;
        }
        [result appendFormat:@"%c", c];
        if (++count == lineNum) {
            [result appendString:@"\n"];
            count = 0;
        }
    }
    if (type == KeyTypePrivate) {
        [result appendString:@"\n-----END PRIVATE KEY-----"];
       
    }else if(type == KeyTypePublic){
        [result appendString:@"\n-----END PUBLIC KEY-----"];
    }
    return result;
 
}
@end
