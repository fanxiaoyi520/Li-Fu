//
//  ZFPCApprovalStatusViewController.h
//  newupop
//
//  Created by Jellyfish on 2020/1/7.
//  Copyright © 2020 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "ZFPCBankCard.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFPCApprovalStatusViewController : ZFBaseViewController

- (instancetype)initWithCardInfo:(ZFPCBankCard *)cardInfo;
@property (nonatomic, assign) BOOL isVirtualCard;
@property (nonatomic, strong) NSString *cardType;
@end

NS_ASSUME_NONNULL_END
