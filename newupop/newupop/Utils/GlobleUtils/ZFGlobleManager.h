//
//  ZFGlobleManager.h
//  newupop
//
//  Created by 中付支付 on 2017/7/28.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFLoginViewController.h"
#import "KeychainWrapper.h"
#import "ZFBankCardModel.h"
#import "NUCountryInfo.h"
#import "JQFMDB.h"

@interface ZFGlobleManager : NSObject
///
@property (nonatomic, strong)ZFBaseViewController *loginVC;
///手机号
@property (nonatomic, strong)NSString *userPhone;
///手机区号
@property (nonatomic, strong)NSString *areaNum;
///手机唯一值
@property (nonatomic, strong)NSString *userKey;
///sessionid
@property (nonatomic, strong)NSString *sessionID;
///密钥
@property (nonatomic, strong)NSString *securityKey;

///临时session
@property (nonatomic, strong)NSString *tempSessionID;
///临时密钥
@property (nonatomic, strong)NSString *tempSecurityKey;
///时间差 (离线二维码用)
@property (nonatomic, assign)NSInteger timeDiff;
///随机数 (离线二维码用)
@property (nonatomic, strong)NSString *ramdom;

///头像
@property (nonatomic, strong)UIImage *headImage;

///最近交易时间
@property (nonatomic, strong)NSString *recentTradeTime;
///拥有的积分
@property (nonatomic, strong)NSString *totalCredit;

///区号数组
@property (nonatomic, strong)NSMutableArray *areaNumArray;

///银行卡数组
@property (nonatomic, strong)NSMutableArray *bankCardArray;

///中付卡数组
@property (nonatomic, strong)NSMutableArray *sinoCardArray;
///银联卡数组
@property (nonatomic, strong)NSMutableArray *unionCardArray;

/** 添加银行卡 */
///银行卡号
@property (nonatomic, strong)NSString *cardNum;
///有效期
@property (nonatomic, strong)NSString *expired;
///卡安全码
@property (nonatomic, strong)NSString *cvn2;
///国家区域
@property (nonatomic, strong)NSString *sysareaid;
///身份证号码
@property (nonatomic, strong)NSString *idCard;
///持卡人姓名
@property (nonatomic, strong)NSString *name;
///是否是信用卡 1 是   0 不是
@property (nonatomic, strong)NSString *isCreditCard;

// 判断是否需要刷新银行卡列表
@property (nonatomic, assign)BOOL isChanged;
///认证成功后是否提示 交易时认证不提示
@property (nonatomic, assign)BOOL notNeedShowSuccess;

///预留手机号
@property (nonatomic, strong)NSString *reservedPhone;

/**  银联卡 */
///关联码 登记ID
@property (nonatomic, strong)NSString *enrolID;
///OTP方式
@property (nonatomic, strong)NSString *otpMethod;
///条款链接
@property (nonatomic, strong)NSString *tncURL;
///条款编号
@property (nonatomic, strong)NSString *tncID;

///0 银行卡列表绑卡 1 首页绑卡 2 扫码绑卡  3 被扫绑卡  4 主扫可变金额输入金额后下页绑卡
@property (nonatomic, assign)NSInteger addCardFromType;

///清除信息
- (void)clearInfo;


+ (instancetype)getGlobleManager;

///获取银行卡图标名称
- (NSString *)getBankIconByBankName:(NSString *)bankName;

@property (nonatomic, strong) KeychainWrapper *myKeychainWrapper;
///保存登录密码
- (void)saveLoginPwd:(NSString *)loginPwd;

///获取登录密码
//- (NSString *)getLoginPwd;

///保存区号数组
- (void)saveAreaNumArray:(NSMutableArray *)areaNumArr;
///获取区号数组
- (NSMutableArray *)getAreaNumArray;

///保存支持的国家数组
- (void)saveSupportCountry:(NSMutableArray *)supportCountry;
///获取支持的国家数组
- (NSMutableArray *)getSupportCountry;

///银行卡分组排序
- (NSMutableArray *)sortGroupBankCardWith:(NSMutableArray *)listArray;
/// 1得到中付卡  2 得到银联卡
- (NSMutableArray *)getCardListWithType:(NSInteger)cardType;
///判断是否支持此城市
- (BOOL)isSupportTheCity:(NSString *)sysareaId cardModel:(ZFBankCardModel *)cardModel;

///银行卡首字母排序
- (NSMutableArray *)sortBankArrayWith:(NSArray *)bankArray;

///保存交易银行卡
- (void)saveTradeCardWith:(ZFBankCardModel *)cardModel;

///数组转字符串
- (NSString *)convertToJsonData:(NSArray *)array;
///获取当前版本号
- (NSString *)getCurrentVersion;

///通过URL保存用户头像
- (void)saveHeadImageWithUrl:(NSString *)urlStr;
///通过图片保存用户头像
- (void)saveHeadImageWithImage:(UIImage *)image;



/** 推送的消息内容 */
@property(nonatomic, strong) NSDictionary *notificationInfo;


/** 登录返回国家区号、名称等信息 */
@property (nonatomic, strong) NSArray<NUCountryInfo *> *countryInfo;
/** 国家代码 */
@property (nonatomic, strong) NSMutableArray *countryCodeArray;
@property (nonatomic, assign) BOOL pcCommitSuccess;//提交成功之后刷新列表
@property (nonatomic, strong) NSArray<NSDictionary *> *pcSaveImageArray;//添加图片页面保存图片
#pragma 获取字符串的宽高
- (CGRect)getStringWidthAndHeightWithStr:(NSString *)str withFont:(UIFont *)font;
//提示弹窗
- (void)Alert:(ZFBaseViewController *)vc title:(NSString *)title message:(NSString *)message;


/**
    更新
 */
@property (nonatomic, strong)NSString *applyType;
- (JQFMDB *)getdb;

- (CGRect)getStringWidthAndHeightWithStr:(NSString *)str withFont:(UIFont *)font withWidth:(CGFloat)width;
@end
