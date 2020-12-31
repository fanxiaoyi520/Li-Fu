//
//  ZFLoginViewController.h
//  newupop
//
//  Created by 中付支付 on 2017/7/21.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "ZFBaseTextField.h"

@interface ZFLoginViewController : ZFBaseViewController

///密码
@property (nonatomic, strong)ZFBaseTextField *pwdTextField;
@property (nonatomic, strong)NSString *isPushStr; //1：指纹 2：验证码
@property (nonatomic, strong)NSString *isFirstIntoStr; //1：指纹 2：验证码
@end
