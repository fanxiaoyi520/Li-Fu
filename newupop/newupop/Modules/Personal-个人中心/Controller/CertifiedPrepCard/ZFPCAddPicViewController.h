//
//  ZFPCAddPicViewController.h
//  newupop
//
//  Created by Jellyfish on 2020/1/7.
//  Copyright © 2020 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFPCAddPicViewController : ZFBaseViewController

- (instancetype)initWithParams:(NSDictionary *)params;
/** 国籍 */
@property (nonatomic, strong) NSString *citizenshipCode;

@end

NS_ASSUME_NONNULL_END
