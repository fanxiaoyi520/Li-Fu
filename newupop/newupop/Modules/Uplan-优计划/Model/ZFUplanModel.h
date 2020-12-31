//
//  ZFUplanModel.h
//  newupop
//
//  Created by Jellyfish on 2017/11/4.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFUplanModel : NSObject

/** 图片名称 */
@property(nonatomic, copy) NSString *iconUrl;
/** 商家名称 */
@property(nonatomic, copy) NSString *merchantName;
/** 活动ID */
@property(nonatomic, copy) NSString *activityId;
/** 活动截止日期 */
@property(nonatomic, copy) NSString *endTime;
/** 活动详情 */
@property(nonatomic, copy) NSString *activityIntroduction;
/** 活动网页 */
@property(nonatomic, copy) NSString *activityUrl;
/** 国家区域 */
@property(nonatomic, copy) NSString *sysareaID;
/** 用户优惠券编码 */
@property(nonatomic, copy) NSString *codeId;

@end
