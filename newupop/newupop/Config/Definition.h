//
//  Definition.h
//  SinopayStore
//
//  Created by Jellyfish on 2017/12/4.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#ifndef Definition_h
#define Definition_h


//获取屏幕 宽度、高度
#define ZFSCREEN [UIScreen mainScreen].bounds
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define IsIPhoneXSeries (SCREEN_HEIGHT == 812.0 || SCREEN_HEIGHT == 896.0)
// 屏幕适配
#define IPhoneXStatusBarHeight (IsIPhoneXSeries ? 44 : 20) // 状态栏高度
#define IPhoneXTopHeight (IsIPhoneXSeries ? 88 : 64)    // 顶部高度
#define IPhoneXTabBarHeight (IsIPhoneXSeries ? (49.0 + 34.0): (49.0))    // TabBar高度
#define IPhoneXStatusBarHeightInterval (IsIPhoneXSeries ? 24 : 0) // iPhone间的状态栏间隔



// RGB颜色
#define ZFColor(R, G, B) [UIColor colorWithRed:(R)/255.0 green:(G)/255.0 blue:(B)/255.0 alpha:1.0]
// RGB颜色
#define ZFAlpColor(R, G, B, A) [UIColor colorWithRed:(R)/255.0 green:(G)/255.0 blue:(B)/255.0 alpha:A]

/// rgb颜色转换（16进制->10进制）
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


// APP主题颜色(蓝)
#define MainThemeColor UIColorFromRGB(0x4990E2)

// 灰色背景颜色
#define GrayBgColor ZFColor(239, 239, 244)

#define MainFontColor MainThemeColor

#define AUTODISMISSTIME 1.5 // 菊花文字提示消失时间
#define AUTOTIPDISMISSTIME 1.0 // 图片文字提示消失时间


///网络请求时菊花
#define NetRequestText NSLocalizedString(@"加载中", @"加载中")
///网络请求失败
#define NetRequestError NSLocalizedString(@"网络请求失败", nil)

/// 3DES的iv
#define TRIPLEDES_IV @"01234567"

///网络是否可用key
#define NETWORK_ISOK @"networkStatus"

///改变语言通知
#define CHANGE_LANGUAGE @"change_langeage"

#define Alias_DeviceID [[[[UIDevice currentDevice] identifierForVendor] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""]

#define Alias_DeviceID [[[[UIDevice currentDevice] identifierForVendor] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""]

// 极光推送  开发者账号
#define JPUSH_APP_KEY @"67c5ca2dee8fcb4cdadf5251"
// 极光推送 通知
#define ReadRemoteNotificationContent @"ReadRemoteNotificationContent"

///bugly appid
#define Bugly_appid @"e4a18b7335"

#ifdef DEBUG // 处于开发阶段
#define DLog(...) NSLog(__VA_ARGS__)
#else // 处于发布阶段
#define DLog(...)
#endif

/**
 *  强弱引用转换，用于解决代码块（block）与强引用对象之间的循环引用问题
 *  调用方式: `@weakify(object)`实现弱引用转换，`@strongify(object)`实现强引用转换
 *
 *  示例：
 *  @weakify(object)
 *  [obj block:^{
 *      @strongify(object)
 *      strong_object = something;
 *  }];
 */
#ifndef    weakify
#if __has_feature(objc_arc)
#define weakify(object)    autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object)    autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#endif
#ifndef    strongify
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) strong##_##object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) strong##_##object = block##_##object;
#endif
#endif

#define kPC_INFO_SHOWTEXT @"showText"
#define kPC_INFO_UPSTRING @"uploadString"
#define Alert(v,s, d) [[ZFGlobleManager getGlobleManager] Alert:v title:s message:d]


#endif /* Definition_h */
