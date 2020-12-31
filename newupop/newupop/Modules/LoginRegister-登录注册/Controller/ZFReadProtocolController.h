//
//  ZFReadProtocolController.h
//  newupop
//
//  Created by 中付支付 on 2019/9/30.
//  Copyright © 2019 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFReadProtocolController : ZFBaseViewController

/// 0用户协议  1隐私条款
@property (nonatomic, assign)NSInteger protocolType;

@end

NS_ASSUME_NONNULL_END
