//
//  ZFAddBankCardController.m
//  newupop
//
//  Created by 中付支付 on 2017/8/1.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFAddBankCardController.h"
#import "ZFGetMSCodeController.h"
#import "ZFAddCreditCardController.h"
#import "ZFAddUnionCardController.h"
#import "LocationUtils.h"

@interface ZFAddBankCardController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSArray *dataArray;
///添加类型
@property (nonatomic, strong)UITextField *addTypeTextField;
///国家
@property (nonatomic, strong)UITextField *countryTextField;
///卡号
@property (nonatomic, strong)UITextField *cardNumTextField;
///姓名
@property (nonatomic, strong)UITextField *userNameTextField;
///证件号
@property (nonatomic, strong)UITextField *idNumTextField;
///手机号
@property (nonatomic, strong)UITextField *phoneTextField;
// 下标箭头
@property (nonatomic, strong)UIView *rightView1;
// 详情箭头
@property (nonatomic, strong)UIView *rightView2;
///支持的国家
@property (nonatomic, strong)NSMutableArray *supportCountry;
@property(nonatomic,strong) UIPickerView *cityPickerView;

///添加类型
@property (nonatomic, strong)NSArray *addTypeArray;
@property (nonatomic, strong)UIPickerView *typePickerView;

@property (nonatomic, assign)NSInteger selectAddType;

@end

@implementation ZFAddBankCardController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.myTitle = @"添加银行卡";
    if (_addType == 1) {// 1 扫码枪银行卡
        self.myTitle = @"添加扫码枪银行卡";
    } else {
        self.myTitle = @"添加银行卡";
    }
    _selectAddType = _addType;
    _addTypeArray = [NSArray arrayWithObjects:NSLocalizedString(@"扫码枪银行卡", nil), NSLocalizedString(@"银联国际银行卡", nil), nil];
    [self createView];
    
    if (_addType == 1) {//中付卡才有
        [self getUserInfo];
        _supportCountry = [self sortArrayWith:[[ZFGlobleManager getGlobleManager] getSupportCountry]];
        if (_supportCountry.count > 0) {
            _countryTextField.text = _supportCountry[0];
        }
        [self getSupportCountry];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (_addType == 2) {
        [_cardNumTextField becomeFirstResponder];
    }
}

- (NSMutableArray *)sortArrayWith:(NSMutableArray *)array{
    NSMutableArray *resultArr = [NSMutableArray arrayWithArray:array];
    if (resultArr.count == 0) {
        return resultArr;
    }
    // 默认显示当前定位城市
    NSInteger index = 0;
    for (NSInteger i = 0; i < resultArr.count; i++) {
        NSString *countryName = [SmallUtils transformSymbolString2CountryString:[LocationUtils sharedInstance].ISOCountryCode];
        if ([resultArr[i] containsString:countryName]) {
            index = i;
            break;
        }
    }
    //把当前的城市放到首位
    [resultArr exchangeObjectAtIndex:0 withObjectAtIndex:index];
    
    return resultArr;
}

- (void)getArrayData{
    _dataArray = nil;
    if (_addType == 1) {
        _dataArray = [NSArray arrayWithObjects:NSLocalizedString(@"国家", nil), NSLocalizedString(@"卡号", nil), NSLocalizedString(@"姓名", nil), NSLocalizedString(@"证件号码", nil), NSLocalizedString(@"手机号码", nil), nil];
    } else {
        _dataArray = [NSArray arrayWithObjects:NSLocalizedString(@"卡号", nil), nil];
    }
}

- (void)createView{
    [self getArrayData];
    [self createTextField];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = GrayBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    [self.view addSubview:_tableView];
}

#pragma mark 创建输入框
- (void)createTextField{
    //国家
    _countryTextField = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-230, 0, 190, 40)];
    _countryTextField.font = [UIFont systemFontOfSize:14];
    _countryTextField.delegate = self;
    _countryTextField.textAlignment = NSTextAlignmentRight;
    _countryTextField.rightViewMode = UITextFieldViewModeAlways;
    // 下标箭头
    _rightView1 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_countryTextField.frame)-2, 0, 40, 40)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 10, 24, 24)];
    imageView.image = [UIImage imageNamed:@"list_unfold"];
    [_rightView1 addSubview:imageView];
    [_countryTextField addSubview:_rightView1];
    // 添加点击手势
    UITapGestureRecognizer *rightViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(test)];
    _rightView1.userInteractionEnabled = YES;
    [_rightView1 addGestureRecognizer:rightViewTap];
    
    //卡号
    _cardNumTextField = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-240, 0, 215-5, 40)];
    _cardNumTextField.font = [UIFont systemFontOfSize:14];
    _cardNumTextField.delegate = self;
    _cardNumTextField.keyboardType = UIKeyboardTypeNumberPad;
    _cardNumTextField.textAlignment = NSTextAlignmentRight;
    _cardNumTextField.placeholder = NSLocalizedString(@"请输入本人银行卡号", nil);
    _cardNumTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    //姓名
    _userNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-230, 0, 190, 40)];
    _userNameTextField.font = [UIFont systemFontOfSize:14];
    _userNameTextField.placeholder = NSLocalizedString(@"请输入本人真实姓名", nil);
    _userNameTextField.textAlignment = NSTextAlignmentRight;
    _userNameTextField.rightViewMode = UITextFieldViewModeAlways;
    // 详情箭头
    _rightView2 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_userNameTextField.frame), 0, 30, 40)];
    UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(2, 8, 24, 24)];
    imageView2.image = [UIImage imageNamed:@"icon_tips"];
    [_rightView2 addSubview:imageView2];
    [_countryTextField addSubview:_rightView2];
    // 添加点击手势
    UITapGestureRecognizer *rightViewTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickNameDetail)];
    _rightView2.userInteractionEnabled = YES;
    [_rightView2 addGestureRecognizer:rightViewTap2];
    
    //证件号
    _idNumTextField = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-230, 0, 230-30, 40)];
    _idNumTextField.font = [UIFont systemFontOfSize:14];
    _idNumTextField.placeholder = NSLocalizedString(@"请输入本人有效证件号码", nil);
    _idNumTextField.delegate = self;
    _idNumTextField.textAlignment = NSTextAlignmentRight;
    _idNumTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _idNumTextField.keyboardType = UIKeyboardTypeNamePhonePad;
    
    //手机号
    _phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-220, 0, 220-45, 40)];
    _phoneTextField.placeholder = NSLocalizedString(@"银行预留手机号", nil);
    _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    [_phoneTextField limitTextLength:11];
    _phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _phoneTextField.text = [ZFGlobleManager getGlobleManager].userPhone;
    _phoneTextField.textAlignment = NSTextAlignmentRight;
    _phoneTextField.font = [UIFont systemFontOfSize:14];
    
    [self addTextInfo];
    
    [self createPickView];
    [self createTypePickView];
}

- (void)test
{
    DLog(@"++++++");
    [_countryTextField becomeFirstResponder];
}

#pragma mark 给输入框赋值
- (void)addTextInfo{
    _userNameTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:UserName];
    if (_userNameTextField.text.length > 0) {
        _userNameTextField.enabled = NO;
    }
    _idNumTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:UserIdCardNum];
    if (_idNumTextField.text.length > 0) {
        _idNumTextField.enabled = NO;
    }
}

#pragma mark 点击姓名详情
- (void)clickNameDetail{
    NSString *title = NSLocalizedString(@"持卡人说明", nil);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:NSLocalizedString(@"为保证资金安全，暂只能绑定持卡人本人名下的银行卡，若需更改持卡人信息，请解绑全部银行卡", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    // 确定
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:confirmAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark 创建支持国家pickView
- (void)createPickView{
    // 创建pickerView
    self.cityPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 220)];
    self.cityPickerView.backgroundColor = [UIColor whiteColor];
    // 代理
    self.cityPickerView.delegate = self;
    self.cityPickerView.dataSource = self;
    
    self.countryTextField.inputView = self.cityPickerView;
    self.countryTextField.inputAccessoryView = [self getToolbar:1];
    self.countryTextField.tintColor = [UIColor clearColor];
}

#pragma mark 创建添加类型
- (void)createTypePickView{
    _typePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 220)];
    _typePickerView.backgroundColor = [UIColor whiteColor];
    _typePickerView.delegate = self;
    _typePickerView.dataSource = self;
    [_typePickerView selectRow:_addType-1 inComponent:0 animated:NO];
    
    _addTypeTextField.inputView = _typePickerView;
    _addTypeTextField.inputAccessoryView = [self getToolbar:2];
    _addTypeTextField.tintColor = [UIColor clearColor];
}

- (void)clickDoneBtn:(UIBarButtonItem *)btn{
    if (btn.tag == 2) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (_addType != _selectAddType) {
                _addType = _selectAddType;
                DLog(@"a = %zd-- s = %zd", _addType, _selectAddType);
                [self getArrayData];
                [_tableView reloadData];
            }
        });
    }
    [_countryTextField resignFirstResponder];
    [_addTypeTextField resignFirstResponder];
}

- (UIToolbar *)getToolbar:(NSInteger)flag{
    // --- tool bar ---
    UIBarButtonItem *doneBBI = [[UIBarButtonItem alloc]
                                initWithTitle:NSLocalizedString(@"确定", nil)
                                style:UIBarButtonItemStyleDone
                                target:self
                                action:@selector(clickDoneBtn:)];
    doneBBI.tag = flag;
    UIBarButtonItem *flexibleBBILeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *textBBI = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"请选择地区/国家", nil) style:UIBarButtonItemStylePlain target:nil action:nil];
    if (flag == 2) {
        [textBBI setTitle:NSLocalizedString(@"添加类型", nil)];
    }
    [textBBI setEnabled:NO];
    UIBarButtonItem *flexibleBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *toolbarItems = [NSArray arrayWithObjects:flexibleBBILeft, textBBI, flexibleBBI, doneBBI, nil];
    
    UIToolbar *myToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    [myToolbar setBarStyle:UIBarStyleDefault];
    [myToolbar setItems:toolbarItems];
    return myToolbar;
}

#pragma mark 获取用户信息
- (void)getUserInfo{
    NSDictionary *parameters = @{@"txnType": @"73",
                                 @"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID":[ZFGlobleManager getGlobleManager].sessionID
                                 };
    
//    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
           
            if (![[requestResult objectForKey:@"idNo"] isKindOfClass:[NSNull class]] && [requestResult objectForKey:@"idNo"]) {
                [[NSUserDefaults standardUserDefaults] setObject:[requestResult objectForKey:@"idNo"] forKey:UserIdCardNum];
            }
            if (![[requestResult objectForKey:@"userName"] isKindOfClass:[NSNull class]] && [requestResult objectForKey:@"userName"]) {
                [[NSUserDefaults standardUserDefaults] setObject:[requestResult objectForKey:@"userName"] forKey:UserName];
            }
            [self addTextInfo];
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(NSError *error) {
        //[[MBUtils sharedInstance] dismissMB];
        
    }];
}

#pragma mark 获取所支持的国家
- (void)getSupportCountry{
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    // 加载支持的国家地区
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile"      : [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID"   : [ZFGlobleManager getGlobleManager].sessionID,
                                 @"txnType"     : @"31"
                                 };
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if([[requestResult objectForKey:@"status"] isEqualToString:@"0"]){
            NSMutableArray *countryArr = [[NSMutableArray alloc] init];
            NSArray *resultCountryArray = [requestResult objectForKey:@"list"];
            for (NSDictionary *dict in resultCountryArray) {
                NSString *countryName = [SmallUtils transformSymbolString2CountryString:[dict objectForKey:@"countryCode"]];
                [countryArr addObject:countryName];
            }
            
            _supportCountry = [self sortArrayWith:countryArr];
            [[ZFGlobleManager getGlobleManager] saveSupportCountry:_supportCountry];
            [_cityPickerView reloadAllComponents];
            _countryTextField.text = _supportCountry[0];
            
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - textfield delegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == _idNumTextField) {//只能输入字符和数字
        if (range.location >= 20) {
            return NO;
        }
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:IDNumLimitString] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        return [string isEqualToString:filtered];
    }
    if (textField == _cardNumTextField) { // 格式化
        NSString *text = [textField text];
        
        NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789\b"];
        string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([string rangeOfCharacterFromSet:[characterSet invertedSet]].location != NSNotFound) {
            return NO;
        }
        
        text = [text stringByReplacingCharactersInRange:range withString:string];
        text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSString *newString = @"";
        while (text.length > 0) {
            NSString *subString = [text substringToIndex:MIN(text.length, 4)];
            newString = [newString stringByAppendingString:subString];
            if (subString.length == 4) {
                newString = [newString stringByAppendingString:@" "];
            }
            text = [text substringFromIndex:MIN(text.length, 4)];
        }
        
        newString = [newString stringByTrimmingCharactersInSet:[characterSet invertedSet]];
        
        if (newString.length >= 24) {
            return NO;
        }
        
        [textField setText:newString];
        
        return NO;
    }
    
    if (textField == _countryTextField) {
        return NO;
    }
    if (textField == _addTypeTextField) {
        return NO;
    }
    return YES;
}

#pragma mark - tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _dataArray.count+1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == _dataArray.count) {
        return 85;
    }
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_addType == 1) {
        if (section == 0 || section == 2 || section == 4) {
            return 20;
        }
        return 1;
    } else {
        if (section == 1) {
            return 1;
        }
        return 20;
    }
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    if (section == 0) {
//        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 45)];
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 200, 15)];
//        label.font = [UIFont systemFontOfSize:15];
//        label.text = NSLocalizedString(@"银联国际银行卡", nil);
//        if (_addType == 1) {
//            label.text = NSLocalizedString(@"扫码枪银行卡", nil);
//        }
//        [headView addSubview:label];
//
//        return headView;
//    } else {
//        return nil;
//    }
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSInteger section = indexPath.section;
    if (_addType == 1) {//中付卡
        if (section == 0) {
            [cell addSubview:_countryTextField];
            [cell addSubview:_rightView1];
        } else if (section == 1) {
            [cell addSubview:_cardNumTextField];
        } else if (section == 2) {
            [cell addSubview:_userNameTextField];
            [cell addSubview:_rightView2];
        } else if (section == 3) {
            [cell addSubview:_idNumTextField];
        } else if (section == 4) {
            [cell addSubview:_phoneTextField];
        }
        
    } else {//银联卡
        if (section == 0){
            [cell addSubview:_cardNumTextField];
        }
    }
    if (section < _dataArray.count) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 40)];
        label.font = [UIFont systemFontOfSize:15];
        label.numberOfLines = 0;
        label.text = _dataArray[section];
        [cell addSubview:label];
    } else {//下一步
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 85)];
        backView.backgroundColor = GrayBgColor;
        [cell addSubview:backView];
        
        UIButton *nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 45, SCREEN_WIDTH-40, 40)];
        nextBtn.layer.cornerRadius = 5;
        nextBtn.backgroundColor = MainThemeColor;
        [nextBtn setTitle:NSLocalizedString(@"下一步", nil) forState:UIControlStateNormal];
        nextBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [nextBtn addTarget:self action:@selector(nextStepBtn) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:nextBtn];
    }
    
    return cell;
}

#pragma mark 检测信息
- (BOOL)checkInfo{
    NSString *cardNum = _cardNumTextField.text;
    NSString *name = _userNameTextField.text;
    NSString *idNum = _idNumTextField.text;
    NSString *phoneNum = _phoneTextField.text;
    // 银行卡号
    if(!cardNum || cardNum.length ==0){
        [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"请输入银行卡号", nil) inView:self.view];
        return NO;
    }
    
    if(cardNum.length < 15){
        [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"银行卡号输入有误", nil) inView:self.view];
        return NO;
    }
    
    if (_addType == 1) {
        // 持卡人姓名
        if(!name || name.length == 0){
            [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"持卡人姓名不能为空", nil) inView:self.view];
            return NO;
        }
        
        // 证件号码
        if (idNum.length < 5){
            [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"证件号码输入有误", nil) inView:self.view];
            return NO;
        }
        
        //预留手机号
        if (phoneNum.length < 7 || phoneNum.length > 11) {
            [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"手机号码应为7~11位", nil) inView:self.view];
            return NO;
        }
    } 
    
    return YES;
}

#pragma mark 下一步
- (void)nextStepBtn{
    [self.view endEditing:YES];
    
    if (![self checkInfo]) {
        return;
    }
    if (_addType == 2) {
        [self unCardNextStep];
        return;
    }
    //去掉前后空格和换行符
    [ZFGlobleManager getGlobleManager].cardNum = [[_cardNumTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [ZFGlobleManager getGlobleManager].idCard = [[_idNumTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [ZFGlobleManager getGlobleManager].name = [[_userNameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [ZFGlobleManager getGlobleManager].sysareaid = [SmallUtils getCountryIdWith:_countryTextField.text];
    
    [ZFGlobleManager getGlobleManager].reservedPhone = _phoneTextField.text;
    
    //判断银行卡信息 暂无接口
    NSString *cardNum = [TripleDESUtils getEncryptWithString:[_cardNumTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"cardNum":cardNum,
                                 @"txnType": @"51"};
    
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            //1 储蓄卡  2 信用卡
            NSString *type = [requestResult objectForKey:@"cardType"];
            if ([type isEqualToString:@"1"]) {
                ZFGetMSCodeController *getVC = [[ZFGetMSCodeController alloc] init];
                getVC.cardType = 0;
                [self.navigationController pushViewController:getVC animated:YES];
            } else {
                ZFAddCreditCardController *creditVC = [[ZFAddCreditCardController alloc] init];
                [self.navigationController pushViewController:creditVC animated:YES];
            }
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
            
        }
        
    } failure:^(NSError *error) {
        
    }];
//
//    return;
    
    
    //信用卡
//    ZFAddCreditCardController *creditVC = [[ZFAddCreditCardController alloc] init];
//    [self.navigationController pushViewController:creditVC animated:YES];
//    return;
    
    //借记卡
//    ZFGetMSCodeController *getVC = [[ZFGetMSCodeController alloc] init];
//    getVC.cardType = 0;
//    [self.navigationController pushViewController:getVC animated:YES];
}

#pragma mark 添加银联卡下一步
- (void)unCardNextStep{
//    NSMutableArray *cvmIdArr = [[NSMutableArray alloc] init];
//    [cvmIdArr addObject:@"expiryDate"];
//    [cvmIdArr addObject:@"cvn2"];
//    [cvmIdArr addObject:@"name"];
//    [cvmIdArr addObject:@"idType"];
//    [cvmIdArr addObject:@"idNo"];
//    [cvmIdArr addObject:@"mobileNo"];
//    [cvmIdArr addObject:@"payPassword"];
//
//    ZFAddUnionCardController *addUVC = [[ZFAddUnionCardController alloc] init];
//    addUVC.cvmIDArray = cvmIdArr;
//    [self.navigationController pushViewController:addUVC animated:YES];
//    return;
    
    
    //去掉前后空格和换行符
    [ZFGlobleManager getGlobleManager].cardNum = [[_cardNumTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *cardNum = [TripleDESUtils getEncryptWithString:[ZFGlobleManager getGlobleManager].cardNum keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    //加密
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"cardNum":cardNum,
                                 @"userKey": [ZFGlobleManager getGlobleManager].userKey,
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"txnType": @"52"};
    
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            NSArray *cvmArr = [requestResult objectForKey:@"cvm"];
            NSMutableArray *cvmIdArr = [NSMutableArray arrayWithArray:cvmArr];
            
            ZFAddUnionCardController *addUVC = [[ZFAddUnionCardController alloc] init];
            addUVC.cvmIDArray = cvmIdArr;
            [ZFGlobleManager getGlobleManager].enrolID = [requestResult objectForKey:@"enrolID"];
            [ZFGlobleManager getGlobleManager].tncURL = [requestResult objectForKey:@"tncURL"];
            [ZFGlobleManager getGlobleManager].tncID = [requestResult objectForKey:@"tncID"];
            [self.navigationController pushViewController:addUVC animated:YES];
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

#pragma mark - pickvView Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == _typePickerView) {
        return 2;
    }
    return _supportCountry.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 30;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return self.view.bounds.size.width;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    if (!view) {
        view = [[UIView alloc] init];
    }
    UILabel *textlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
    textlabel.textAlignment = NSTextAlignmentCenter;
    textlabel.font = [UIFont systemFontOfSize:19];
    [view addSubview:textlabel];
    
    if (pickerView == _typePickerView) {
        textlabel.text = _addTypeArray[row];
    } else {
        textlabel.text = _supportCountry[row];
    }
    
    return view;
}

// didSelectRow
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (pickerView == _typePickerView) {
        _selectAddType = row+1;
        _addTypeTextField.text = _addTypeArray[row];
    } else {
        self.countryTextField.text = self.supportCountry[row];
    }
}

@end
