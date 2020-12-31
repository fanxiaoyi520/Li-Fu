//
//  NetworkEngine.h
//  newupop
//
//  Created by Jellyfish on 2017/7/27.
//  Copyright © 2017年 中付支付. All rights reserved.
//  网络工具类

#import <Foundation/Foundation.h>


typedef void (^RequestSuccessBlock) (id requestResult);
typedef void (^RequestFailureBlock) (id error);

@interface NetworkEngine : NSObject

/**
 *  获取单例对象
 */
+ (instancetype)sharedManager;


/**
 带url的post网络请求

 @param urlStr 请求地址
 @param params 请求参数
 @param success 请求成功回调
 @param failure 请求失败回调
 */
+ (void)postWtihURL:(NSString *)urlStr parmas:(NSDictionary *)params outTime:(CGFloat)outTime success:(RequestSuccessBlock)success failure:(RequestFailureBlock)failure;

/**
 * 固定请求地址,通过构建请求参数 发起post请求
 *
 * @params params  请求参数
 * @params success 请求成功回调
 * @params failure 请求失败回调
 */
+ (void)singlePostWithParmas:(NSDictionary *)params success:(RequestSuccessBlock)success failure:(RequestFailureBlock)failure;


/// 取消当前页面所有的网络请求动作
+ (void)cancelAllNetworkAciton;

//判断网络状态
+ (void)getNetStatus;

///获取系统语言  1 英语  2 汉语
+ (NSString *)getCurrentLanguage;


@end
