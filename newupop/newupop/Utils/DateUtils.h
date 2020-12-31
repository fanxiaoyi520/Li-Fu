//
//  DateUtils.h
//  newupop
//
//  Created by Jellyfish on 2017/8/1.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateUtils : NSObject

/// 按当前时间段返回问候语
+ (NSString *)getCurrentTimePeriodGreetings;


/**
 根据格式获取当前日期 @"yyyy-MM-dd"
 
 @param dateFormat 日期格式
 @return 日期字符串
 */
+ (NSString *)getCurrentDateWithFormat:(NSString *)dateFormat;

/**
 获取当前时间戳
 
 @return 当前时间戳
 */
+ (NSString *)getCurrentTimeStamp;


/**
 获取标准格式的时间
 
 @param timeStamp 时间戳 yyyyMMddHHmmss
 @return 标准格式的时间 yyyy-MM-dd HH:mm:ss
 */
+ (NSString *)getCurrentTimeWithTimeStamp:(NSString *)timeStamp;


/**
 根据传进来的时间返回与当前时间的秒差
 
 @param dTime 传进来进行比较的时间
 @return 秒差
 */
+ (long)getTimeIntervalWithDTime:(NSString *)dTime;

/**
 根据传入的日期在年月日中间添加符号

 @param date 日期
 @param symbol 需要添加的符号
 @return 格式化日期
 */
+(NSString *)formatDate:(NSString *)date symbol:(NSString *)symbol;

///根据传进来的时间格式与时间返回字符串
+(NSString *)dateToStringWithFormatter:(NSString *)formatter date:(NSDate *)date;

///获取一个月前时间
+ (NSString *)getMonthAgoTime:(NSString *)formatter;

///比较两个时间差值(天)
+ (NSInteger)compareBeginTime:(NSString *)beginTime endTime:(NSString *)endTime;

@end
