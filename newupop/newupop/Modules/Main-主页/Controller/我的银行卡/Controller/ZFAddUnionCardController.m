//
//  ZFAddUnionCardController.m
//  newupop
//
//  Created by 中付支付 on 2017/11/5.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFAddUnionCardController.h"
#import "ZFCvmModel.h"
#import "ZFGetMSCodeController.h"
#import "ZFBankCardModel.h"
#import "ZFGetUnionMSCodeController.h"

@interface ZFAddUnionCardController ()<UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource>
///持卡人姓名
@property (nonatomic, strong)UITextField *nameTextField;
///有效期
@property (nonatomic, strong)UITextField *expiryDateTextField;
///卡安全码
@property (nonatomic, strong)UITextField *cvnTextField;
///证件类型
@property (nonatomic, strong)UITextField *idTypeTextField;
///证件号
@property (nonatomic, strong)UITextField *idNoTextField;
///银行预留手机号
@property (nonatomic, strong)UITextField *mobileNoTextField;
///银行卡预留手机支付密码
@property (nonatomic, strong)UITextField *pwdTextField;

///证件类型pickview
@property (nonatomic, strong)UIPickerView *idTypePickView;
///证件类型数组
@property (nonatomic, strong)NSDictionary *idTypeDict;

///要显示的cvm
@property (nonatomic, strong)NSMutableArray *cvmArray;
///
@property (nonatomic, strong)UITableView *tableView;

@end

@implementation ZFAddUnionCardController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myTitle = @"添加银行卡";
    [self createTextField];
}

- (ZFCvmModel *)createCVMModelWithID:(NSString *)cvmID title:(NSString *)title textField:(UITextField *)textField{
    ZFCvmModel *model = [[ZFCvmModel alloc] init];
    model.cvmID = cvmID;
    model.title = title;
    model.textField = textField;
    return model;
}

- (void)createTextField{
    //姓名
    _nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-220, 0, 204, 40)];
    _nameTextField.placeholder = NSLocalizedString(@"请输入本人真实姓名", nil);
    _nameTextField.textAlignment = NSTextAlignmentRight;
    _nameTextField.font = [UIFont systemFontOfSize:14];
    _nameTextField.rightViewMode = UITextFieldViewModeAlways;
    _nameTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:UserName];
    if (_nameTextField.text.length > 0) {
        _nameTextField.enabled = NO;
    }
    _nameTextField.rightView = [self createRightView:1];
    
    //cvn
    _cvnTextField = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-220, 0, 204, 40)];
    _cvnTextField.placeholder = NSLocalizedString(@"卡背后三位数字", nil);
    _cvnTextField.font = [UIFont systemFontOfSize:14];
    _cvnTextField.textAlignment = NSTextAlignmentRight;
    _cvnTextField.rightViewMode = UITextFieldViewModeAlways;
    _cvnTextField.keyboardType = UIKeyboardTypeNumberPad;
    [_cvnTextField limitTextLength:3];
    _cvnTextField.rightView = [self createRightView:2];
    
    //有效期
    _expiryDateTextField = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-220, 0, 204, 40)];
    _expiryDateTextField.placeholder = @"MM/YY";
    _expiryDateTextField.font = [UIFont systemFontOfSize:14];
    _expiryDateTextField.textAlignment = NSTextAlignmentRight;
    _expiryDateTextField.rightViewMode = UITextFieldViewModeAlways;
    _expiryDateTextField.keyboardType = UIKeyboardTypeNumberPad;
    [_expiryDateTextField limitTextLength:4];
    _expiryDateTextField.rightView = [self createRightView:3];
    
    //证件类型
    _idTypeDict = @{NSLocalizedString(@"身份证", nil):@"01",
                    NSLocalizedString(@"军官证", nil):@"02",
                    NSLocalizedString(@"护照", nil):@"03",
                    NSLocalizedString(@"回乡证", nil):@"04",
                    NSLocalizedString(@"台胞证", nil):@"05",
                    NSLocalizedString(@"警官证", nil):@"06",
                    NSLocalizedString(@"士兵证", nil):@"07",
                    NSLocalizedString(@"其他", nil):@"99"
                    };
    
    _idTypeTextField = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-220, 0, 220-45, 40)];
    _idTypeTextField = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-220, 0, 204, 40)];
    _idTypeTextField.font = [UIFont systemFontOfSize:14];
    _idTypeTextField.delegate = self;
    _idTypeTextField.textAlignment = NSTextAlignmentRight;
    _idTypeTextField.rightViewMode = UITextFieldViewModeAlways;
    UIView *typerightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 40)];
    UIImageView *typeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 8, 24, 24)];
    typeImageView.image = [UIImage imageNamed:@"list_unfold"];
    [typerightView addSubview:typeImageView];
    _idTypeTextField.rightView = typerightView;
    _idTypeTextField.text = [[_idTypeDict allKeys] firstObject];
    [self createPickView];
    
    //证件号
    _idNoTextField = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-205, 0, 205-45, 40)];
    _idNoTextField.font = [UIFont systemFontOfSize:14];
    _idNoTextField.textAlignment = NSTextAlignmentRight;
    _idNoTextField.placeholder = NSLocalizedString(@"证件号", nil);
    
    //银行预留手机号
    _mobileNoTextField = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-220, 0, 220-45, 40)];
    _mobileNoTextField.placeholder = NSLocalizedString(@"银行预留手机号", nil);
    _mobileNoTextField.textAlignment = NSTextAlignmentRight;
    _mobileNoTextField.keyboardType = UIKeyboardTypeNumberPad;
    [_mobileNoTextField limitTextLength:11];
    _mobileNoTextField.text = [ZFGlobleManager getGlobleManager].userPhone;
    _mobileNoTextField.font = [UIFont systemFontOfSize:14];
    
    //银行卡预留手机支付密码
    _pwdTextField = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-220, 0, 220-45, 40)];
    _pwdTextField.placeholder = NSLocalizedString(@"银行卡预留手机支付密码", nil);
    _pwdTextField.textAlignment = NSTextAlignmentRight;
    _pwdTextField.font = [UIFont systemFontOfSize:14];
    _pwdTextField.secureTextEntry = YES;
    
    [self chooseTextField];
    [self createTableView];
}

#pragma mark 创建tableview
- (void)createTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = GrayBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    [self.view addSubview:_tableView];
}

#pragma mark 选择要显示的cvm
- (void)chooseTextField{

    _cvmArray = [[NSMutableArray alloc] init];
    if ([_cvmIDArray containsObject:@"name"]) {
        ZFCvmModel *model = [self createCVMModelWithID:@"name" title:NSLocalizedString(@"姓名", nil) textField:_nameTextField];
        [_cvmArray addObject:model];
    }
    
    if ([_cvmIDArray containsObject:@"idType"]) {
        ZFCvmModel *model = [self createCVMModelWithID:@"idType" title:NSLocalizedString(@"证件类型", nil) textField:_idTypeTextField];
        [_cvmArray addObject:model];
    }
    if ([_cvmIDArray containsObject:@"idNo"]) {
        ZFCvmModel *model = [self createCVMModelWithID:@"idNo" title:NSLocalizedString(@"证件号", nil) textField:_idNoTextField];
        [_cvmArray addObject:model];
    }
    if ([_cvmIDArray containsObject:@"mobileNo"]) {
        ZFCvmModel *model = [self createCVMModelWithID:@"mobileNo" title:NSLocalizedString(@"银行预留手机号", nil) textField:_mobileNoTextField];
        [_cvmArray addObject:model];
    }
    if ([_cvmIDArray containsObject:@"cvn2"]) {
        ZFCvmModel *model = [self createCVMModelWithID:@"cvn2" title:NSLocalizedString(@"CVN", nil) textField:_cvnTextField];
        [_cvmArray addObject:model];
    }
    if ([_cvmIDArray containsObject:@"expiryDate"]) {
        ZFCvmModel *model = [self createCVMModelWithID:@"expiryDate" title:NSLocalizedString(@"有效期", nil) textField:_expiryDateTextField];
        [_cvmArray addObject:model];
    }
    if ([_cvmIDArray containsObject:@"payPassword"]) {
        ZFCvmModel *model = [self createCVMModelWithID:@"payPassword" title:NSLocalizedString(@"银行卡预留手机支付密码", nil) textField:_pwdTextField];
        [_cvmArray addObject:model];
    }
}

#pragma mark 创建pickview
- (void)createPickView{
    _idTypePickView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 220)];
    _idTypePickView.backgroundColor = [UIColor whiteColor];
    _idTypePickView.delegate = self;
    _idTypePickView.dataSource = self;
    
    _idTypeTextField.inputView = _idTypePickView;
    _idTypeTextField.inputAccessoryView = [self getToolbar:1];
    _idTypeTextField.tintColor = [UIColor clearColor];
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
    UIBarButtonItem *textBBI = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"证件类型", nil) style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [textBBI setEnabled:NO];
    UIBarButtonItem *flexibleBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *toolbarItems = [NSArray arrayWithObjects:flexibleBBILeft, textBBI, flexibleBBI, doneBBI, nil];
    
    UIToolbar *myToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    [myToolbar setBarStyle:UIBarStyleDefault];
    [myToolbar setItems:toolbarItems];
    return myToolbar;
}
- (void)clickDoneBtn:(UIBarButtonItem *)btn{
    [_idTypeTextField resignFirstResponder];
}

#pragma mark 创建右视图
- (UIView *)createRightView:(NSInteger)flag{
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 40)];
    rightView.tag = flag;
    rightView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickNameDetail:)];
    [rightView addGestureRecognizer:tap];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 8, 24, 24)];
    imageView.image = [UIImage imageNamed:@"icon_tips"];
    [rightView addSubview:imageView];
    
    return rightView;
}

#pragma mark 点击姓名详情
- (void)clickNameDetail:(UITapGestureRecognizer *)tap{
    NSInteger tag = [tap.view tag];
    NSString *title = NSLocalizedString(@"持卡人说明", nil);
    NSString *message = NSLocalizedString(@"为保证资金安全，暂只能绑定持卡人本人名下的银行卡，若需更改持卡人信息，请解绑全部银行卡", nil);
    if (tag == 2) {//cvn
        title = NSLocalizedString(@"CVN说明", nil);
        message = NSLocalizedString(@"卡背面三位数字", nil);
    }
    if (tag == 3) {//有效期
        title = NSLocalizedString(@"有效期说明", nil);
        message = NSLocalizedString(@"卡正面有效期", nil);
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    // 确定
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:confirmAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark tableView 代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_cvmArray.count > 0) {//加一行 下一步
        return _cvmArray.count + 1;
    }
    return _cvmArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == _cvmArray.count) {
        return 85;
    }
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 20;
    }
    if (section == _cvmArray.count) {
        return 0.1;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZFCvmModel *model;
    if (indexPath.section < _cvmArray.count) {
        model = _cvmArray[indexPath.section];
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cvmCell"];
    if (indexPath.section < _cvmArray.count) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 40)];
        label.font = [UIFont systemFontOfSize:14];
        label.numberOfLines = 0;
        label.text = model.title;
        [cell addSubview:label];
        
        [cell addSubview:model.textField];
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark 检查信息
- (BOOL)checkInfo{
    //姓名
    if ([_cvmIDArray containsObject:@"name"]) {
        if (_nameTextField.text.length < 1) {
            [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"持卡人姓名不能为空", nil) inView:self.view];
            return NO;
        }
    }
    //证件号
    if ([_cvmIDArray containsObject:@"idNo"]) {
        if (_idNoTextField.text.length < 5){
            [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"证件号码输入有误", nil) inView:self.view];
            return NO;
        }
    }
    //预留手机号
    if ([_cvmIDArray containsObject:@"mobileNo"]) {
        if (_mobileNoTextField.text.length > 11 || _mobileNoTextField.text.length < 7) {
            [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"手机号码应为7~11位", nil) inView:self.view];
            return NO;
        }
    }
    //cvn
    if ([_cvmIDArray containsObject:@"cvn2"]) {
        if(_cvnTextField.text.length < 3){
            [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"银行卡安全码输入有误", nil) inView:self.view];
            return NO;
        }
    }
    //有效期
    if ([_cvmIDArray containsObject:@"expiryDate"]) {
        if(_expiryDateTextField.text.length < 4){
            [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"银行卡有效期输入有误", nil) inView:self.view];
            return NO;
        }
    }
    //支付密码
    if ([_cvmIDArray containsObject:@"payPassword"]) {
        if (_pwdTextField.text.length != 6) {
            [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"密码输入有误", nil) inView:self.view];
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
    
    //姓名
    NSString *name = @"";
    if ([_cvmIDArray containsObject:@"name"]) {
        name = _nameTextField.text;
    }
    
    //证件号
    NSString *idNo = @"";
    if ([_cvmIDArray containsObject:@"idNo"]) {
        idNo = [TripleDESUtils getEncryptWithString:_idNoTextField.text keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    }
    //预留手机号
    [ZFGlobleManager getGlobleManager].reservedPhone = [ZFGlobleManager getGlobleManager].userPhone;
    NSString *mobileNo = @"";
    if ([_cvmIDArray containsObject:@"mobileNo"]) {
        mobileNo = [TripleDESUtils getEncryptWithString:_mobileNoTextField.text keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
        [ZFGlobleManager getGlobleManager].reservedPhone = _mobileNoTextField.text;
    }
    //cvn
    NSString *cvn2 = @"";
    if ([_cvmIDArray containsObject:@"cvn2"]) {
        cvn2 = [TripleDESUtils getEncryptWithString:_cvnTextField.text keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    }
    //有效期
    NSString *expired = @"";
    if ([_cvmIDArray containsObject:@"expiryDate"]) {
        //后台有效期格式 年月
        NSString *exchange = [NSString stringWithFormat:@"%@%@", [_expiryDateTextField.text substringFromIndex:2], [_expiryDateTextField.text substringToIndex:2]];
        expired = [TripleDESUtils getEncryptWithString:exchange keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    }
    //支付密码
    NSString *payPassword = @"";
    if ([_cvmIDArray containsObject:@"payPassword"]) {
        payPassword = [TripleDESUtils getEncryptWithString:_pwdTextField.text keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    }
    //证件类型
    NSString *idType = @"";
    if ([_cvmIDArray containsObject:@"idType"]) {
        idType = [_idTypeDict objectForKey:_idTypeTextField.text];
    }
    
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"userKey": [ZFGlobleManager getGlobleManager].userKey,
                                 @"enrolID":[ZFGlobleManager getGlobleManager].enrolID,
                                 @"expired":expired,
                                 @"cvn2":cvn2,
                                 @"idType":idType,
                                 @"idCard":idNo,
                                 @"name":name,
                                 @"phoneNo":mobileNo,
                                 @"payPassword":payPassword,
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"txnType": @"53"};
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            //[ZFGlobleManager getGlobleManager].enrolID = [requestResult objectForKey:@"enrolID"];
            //判断otp是否为空 为空不需要验证码
            if ([[requestResult objectForKey:@"otpMethod"] isKindOfClass:[NSNull class]]) {
                [self addUNCard];
            } else {
                [ZFGlobleManager getGlobleManager].otpMethod = [[requestResult objectForKey:@"otpMethod"] firstObject];
                [self getUNMessageCode:[ZFGlobleManager getGlobleManager].otpMethod];
            }
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
        
    } failure:^(id error) {
        
    }];
}

// 银联国际：获取验证码 54
- (void)getUNMessageCode:(NSString *)otpMethod {
    
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"userKey":[ZFGlobleManager getGlobleManager].userKey,
                                 @"enrolID":[ZFGlobleManager getGlobleManager].enrolID,
                                 @"otpMethod":otpMethod,
                                 @"txnType": @"54"};
    
    [[MBUtils sharedInstance] showMBInView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if (![[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
            return ;
        }
        ZFGetUnionMSCodeController *getVC = [[ZFGetUnionMSCodeController alloc] init];
        [self.navigationController pushViewController:getVC animated:YES];
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark 不需要验证码 直接绑定
- (void)addUNCard {
    NSString *cardNum = [TripleDESUtils getEncryptWithString:[ZFGlobleManager getGlobleManager].cardNum keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"userKey":[ZFGlobleManager getGlobleManager].userKey,
                                 @"enrolID":[ZFGlobleManager getGlobleManager].enrolID,
                                 @"cardNum":cardNum,
                                 @"tncID":[ZFGlobleManager getGlobleManager].tncID,
                                 @"otpValue":@"",
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"txnType": @"55"};
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
           
            //通知重新查询银行卡
            [[NSNotificationCenter defaultCenter] postNotificationName:BINDING_CARD_ALREADY object:@"checkAgain"];
            [self popBack];
            
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(id error) {
        
    }];
}

- (void)popBack{
    if ([ZFGlobleManager getGlobleManager].addCardFromType == 1) {//首页
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else if ([ZFGlobleManager getGlobleManager].addCardFromType == 4) {//主扫可输入金额下一页绑卡
        [self.navigationController popToViewController:self.navigationController.viewControllers[2] animated:YES];
    } else {//列表页 扫码 被扫
        [ZFGlobleManager getGlobleManager].isChanged = YES;
        [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
    }
}

#pragma mark textfield 代理
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == _idTypeTextField) {
        return NO;
    }
    return YES;
}

#pragma mark pickview 代理
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [[_idTypeDict allKeys] count];
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
    textlabel.text = [[_idTypeDict allKeys] objectAtIndex:row];
    
    return view;
}

// didSelectRow
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    _idTypeTextField.text = [[_idTypeDict allKeys] objectAtIndex:row];
}

@end
