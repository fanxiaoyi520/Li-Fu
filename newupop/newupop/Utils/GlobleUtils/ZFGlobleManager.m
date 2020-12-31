//
//  ZFGlobleManager.m
//  newupop
//
//  Created by 中付支付 on 2017/7/28.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFGlobleManager.h"
#import "ZFBankCardModel.h"
#import "ZFExpandModel.h"
#import "pinyin.h"

@implementation ZFGlobleManager

+ (instancetype)getGlobleManager{
    static dispatch_once_t onceToken;
    static ZFGlobleManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[ZFGlobleManager alloc] init];
    });
    return manager;
}

- (UIImage *)headImage{
    NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"headImage%@", _userPhone]];
    _headImage = [UIImage imageWithData:imageData];
    
    if (!_headImage) {
        _headImage = [UIImage imageNamed:@"avatar_default"];
    }
    return _headImage;
}

- (void)saveHeadImageWithUrl:(NSString *)urlStr{
    NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"headImage%@", _userPhone]];
    UIImage *savedImage = [UIImage imageWithData:imageData];
    
    if (savedImage) {//已经存在 不需要重新下载
        return;
    }
    NSData *data = [NSData dataWithContentsOfURL:[NSURL  URLWithString:urlStr]];
    //UIImage *image = [UIImage imageWithData:data];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:[NSString stringWithFormat:@"headImage%@", _userPhone]];
}

- (void)saveHeadImageWithImage:(UIImage *)image{
    NSData *imageData = UIImagePNGRepresentation(image);
    [[NSUserDefaults standardUserDefaults] setObject:imageData forKey:[NSString stringWithFormat:@"headImage%@", _userPhone]];
}

#pragma mark 清除信息
- (void)clearInfo{
    _bankCardArray = nil;
    _totalCredit = nil;
    _recentTradeTime = nil;
    _cardNum = nil;
    _expired = nil;
    _cvn2 = nil;
    _sysareaid = nil;
    _idCard = nil;
    _name = nil;
    _isCreditCard = nil;
    
    _enrolID = nil;
    _otpMethod = nil;
    _tncURL = nil;
    _tncID = nil;
}

#pragma mark 获取银行卡图标名称
- (NSString *)getBankIconByBankName:(NSString *)bankName{
    bankName = [bankName stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"cardName" ofType:@"plist"];
    NSDictionary *bankInfoDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSDictionary *bankList = [bankInfoDictionary objectForKey:@"bank"];
    NSDictionary *currentBank = [bankList objectForKey:bankName];
    NSString *bankIcon = [currentBank objectForKey:@"icon"];
    return bankIcon ? bankIcon : @"img_bank_card";
}

#pragma mark - 保存和获取登录密码
- (void)saveLoginPwd:(NSString *)loginPwd{
    [self.myKeychainWrapper mySetObject:loginPwd forKey:(__bridge id)(kSecValueData)];
}

- (NSString *)getLoginPwd{
    return [self.myKeychainWrapper myObjectForKey:(__bridge id)(kSecValueData)];
}

- (KeychainWrapper *) myKeychainWrapper
{
    if (!_myKeychainWrapper) {
        _myKeychainWrapper = [[KeychainWrapper alloc]init];
    }
    return _myKeychainWrapper;
}

#pragma mark - 保存和获取区号数组
- (void)saveAreaNumArray:(NSMutableArray *)areaNumArr{
    _areaNumArray = areaNumArr;
    [[NSUserDefaults standardUserDefaults] setObject:areaNumArr forKey:@"areaNumArray"];
}

- (NSMutableArray *)getAreaNumArray{
    NSMutableArray *areaArr = [[NSUserDefaults standardUserDefaults] objectForKey:@"areaNumArray"];
    _areaNumArray = areaArr;
    return areaArr;
}

#pragma mark - 保存和获取支持国家
- (void)saveSupportCountry:(NSMutableArray *)supportCountry{
    [[NSUserDefaults standardUserDefaults] setObject:supportCountry forKey:@"supportCountry"];
}

- (NSMutableArray *)getSupportCountry{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"supportCountry"];
}

#pragma mark - 银行卡分组排序
- (NSMutableArray *)sortGroupBankCardWith:(NSMutableArray *)listArray{
    NSMutableArray *headArray = [[NSMutableArray alloc] init];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    
    for (ZFBankCardModel *cardModel in listArray) {
        
        if ([headArray containsObject:cardModel.channelType]) {
            NSInteger index = [headArray indexOfObject:cardModel.channelType];
            ZFExpandModel *exmodel = dataArray[index];
            [exmodel.dataArray addObject:cardModel];
        } else {
            [headArray addObject:cardModel.channelType];
            ZFExpandModel *model = [[ZFExpandModel alloc] init];
            if ([cardModel.channelType isEqualToString:@"000001"]) {
                model.name = NSLocalizedString(@"扫码枪 银行卡", nil);
            } else {
                model.name = NSLocalizedString(@"银联国际 银行卡", nil);
            }
            model.channelType = cardModel.channelType;
            model.dataArray = [[NSMutableArray alloc] init];
            [dataArray addObject:model];
            [model.dataArray addObject:cardModel];
        }
    }
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    if (dataArray.count == 2) {
        ZFExpandModel *exmodel = dataArray[0];
        if ([exmodel.channelType isEqualToString:@"000001"]) {
            [resultArr addObject:dataArray[1]];
            [resultArr addObject:dataArray[0]];
        } else {
            resultArr = dataArray;
        }
    } else {
        resultArr = dataArray;
    }
    
    return resultArr;
}

#pragma mark 1得到中付卡  2 得到银联卡
- (NSMutableArray *)getCardListWithType:(NSInteger)cardType{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if (cardType == 1) {
        for (ZFBankCardModel *cardModel in _bankCardArray) {
            if ([cardModel.openCountry.HK isEqualToString:@"0"] || [cardModel.openCountry.SG isEqualToString:@"0"] || [cardModel.openCountry.MY isEqualToString:@"0"]) {
                [array addObject:cardModel];
            }
        }
    }
    
    if (cardType == 2) {
        for (ZFBankCardModel *cardModel in _bankCardArray) {
            if ([cardModel.openCountry.UP isEqualToString:@"0"]) {
                [array addObject:cardModel];
            }
        }
    }
    
    return array;
}

#pragma mark 判断是否支持此城市
- (BOOL)isSupportTheCity:(NSString *)sysareaId cardModel:(ZFBankCardModel *)cardModel{
    if ([sysareaId isEqualToString:@"HK"]) {//港澳
        if ([cardModel.openCountry.HK isEqualToString:@"0"]) {
            return YES;
        }
    }
    
    if ([sysareaId isEqualToString:@"SG"]) {//新加坡
        if ([cardModel.openCountry.SG isEqualToString:@"0"]) {
            return YES;
        }
    }
    
    if ([sysareaId isEqualToString:@"MY"]) {//马来
        if ([cardModel.openCountry.MY isEqualToString:@"0"]) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark 银行卡首字母排序
- (NSMutableArray *)sortBankArrayWith:(NSArray *)bankArray{
    //卡类型 信用卡在前 借记卡在后
    NSMutableArray *xArray = [[NSMutableArray alloc] init];//信用卡
    NSMutableArray *jArray = [[NSMutableArray alloc] init];//借记卡
    for (ZFBankCardModel *model in bankArray) {
        if ([model.cardType isEqualToString:@"2"]) {
            [xArray addObject:model];
        } else {
            [jArray addObject:model];
        }
    }
    
    NSArray *sort1 = [self sortArray:xArray];
    NSArray *sort2 = [self sortArray:jArray];
    
    
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    for (ZFBankCardModel *model in sort1) {
        [resultArr addObject:model];
    }
    
    for (ZFBankCardModel *model in sort2) {
        [resultArr addObject:model];
    }
    
    NSString *cardNum = [[NSUserDefaults standardUserDefaults] objectForKey:LastTradeCardKey];
    if (cardNum) {
        for (NSInteger i = 0; i < resultArr.count; i++) {
            ZFBankCardModel *model = resultArr[i];
            if ([model.cardNo isEqualToString:cardNum]) {
                [resultArr removeObject:model];
                [resultArr insertObject:model atIndex:0];
                break;
            }
        }
    }
    
    return resultArr;
}

- (NSMutableArray *)sortArray:(NSMutableArray *)bankArray{
    NSMutableArray *marr = [[NSMutableArray alloc] init];
    for (ZFBankCardModel *model in bankArray) {
        NSString *pinYin;
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        if(model.bankName && ![model.bankName isEqualToString:@""]){
            pinYin = [[NSString stringWithFormat:@"%c",pinyinFirstLetter([model.bankName characterAtIndex:0])] uppercaseString];
        }else{  //nil或@""排最后，ASCII表 @"{" 在 小写字母 后
            pinYin = @"{";
        }
        [dict setObject:model forKey:@"model"];
        [dict setObject:pinYin forKey:@"pinYin"];
        [marr addObject:dict];
    }
    
    NSArray *sortArr = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"pinYin" ascending:YES]];
    [marr sortUsingDescriptors:sortArr];
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in marr) {
        [resultArr addObject:dict[@"model"]];
    }
    return resultArr;
}

- (void)saveTradeCardWith:(ZFBankCardModel *)cardModel{
    [[NSUserDefaults standardUserDefaults] setObject:cardModel.cardNo forKey:LastTradeCardKey];
    _bankCardArray = [self sortBankArrayWith:_bankCardArray];
}

- (NSMutableArray *)countryCodeArray {
    if (!_countryCodeArray) {
        _countryCodeArray = [NSMutableArray arrayWithCapacity:0];
        for (NUCountryInfo *info in _countryInfo) {
            [_countryCodeArray addObject:[@"+" stringByAppendingString:info.countryCode]];
        }
    }
    return _countryCodeArray;
}




#pragma mark - 数组转字符串
- (NSString *)convertToJsonData:(NSArray *)array{
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        DLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
}
#pragma mark - 获取当前版本号
- (NSString *)getCurrentVersion{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    CFShow((__bridge CFTypeRef)(infoDict));
    NSString *currVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
    
    return currVersion;
}

#pragma 获取字符串的宽高
- (CGRect)getStringWidthAndHeightWithStr:(NSString *)str withFont:(UIFont *)font {
    if (![str isKindOfClass:[NSString class]]) {
        return CGRectZero;
    }
    CGRect contentRect = [str boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 40, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    return contentRect;
}

- (void)Alert:(UIViewController *)vc title:(NSString *)title message:(NSString *)message {
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
          UIAlertAction *cancle = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定",nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action) {
              
          }];
          [alertVc addAction:cancle];
          [vc presentViewController:alertVc animated:YES completion:nil];
}

- (JQFMDB *)getdb {
    JQFMDB *db = [JQFMDB shareDatabase:@"lifu.sqlite"];
    [db jq_createTable:@"user" dicOrModel:[ZFLogin class]];
    return db;
}

- (CGRect)getStringWidthAndHeightWithStr:(NSString *)str withFont:(UIFont *)font withWidth:(CGFloat)width {
    if (![str isKindOfClass:[NSString class]]) {
        return CGRectZero;
    }
    CGRect contentRect = [str boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    return contentRect;
}
@end
