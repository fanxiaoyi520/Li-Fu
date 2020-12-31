//
//  ZFForgetLoginPwdController.m
//  newupop
//
//  Created by 中付支付 on 2017/7/25.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFForgetLoginPwdController.h"
#import "ZFGetVerCodeController.h"
#import "HBRSAHandler.h"

@interface ZFForgetLoginPwdController ()<UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong)ZFBaseTextField *phoneTextField;
///区号
@property (nonatomic, strong)ZFBaseTextField *areaTextField;
/// 支持的手机号码国家/地区代码
@property(nonatomic,strong) NSMutableArray *areaArray;
///区域选择
@property(nonatomic,strong) UIPickerView *pickerView;
///区域工具栏
@property(nonatomic,strong) UIToolbar *toolbar;

@end

@implementation ZFForgetLoginPwdController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myTitle = @"找回登录密码";
    self.view.backgroundColor = [UIColor whiteColor];
    [self createView];
}

- (void)createView{
    //区号
    _areaTextField = [[ZFBaseTextField alloc] initWithFrame:CGRectMake(20, IPhoneXTopHeight+20, SCREEN_WIDTH-40, 40)];
    _areaTextField.text = @"中国+86";
    _areaTextField.delegate = self;
    [self.view addSubview:_areaTextField];
    UIButton *telBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    telBtn.frame = CGRectMake(0, 0, 35, 40);
    [telBtn setImage:[UIImage imageNamed:@"tel_icon"] forState:UIControlStateNormal];
    [telBtn setImage:[UIImage imageNamed:@"tel_icon"] forState:UIControlStateHighlighted];
    [telBtn addTarget:self action:@selector(showPickKeyBoard) forControlEvents:UIControlEventTouchUpInside];
    _areaTextField.rightViewMode = UITextFieldViewModeAlways;
    _areaTextField.rightView = telBtn;
    _areaTextField.placeholder = NSLocalizedString(@"国家／地区", nil);
    
    _phoneTextField = [[ZFBaseTextField alloc] initWithFrame:CGRectMake(_areaTextField.x, _areaTextField.bottom+10, _areaTextField.width, 40)];
    _phoneTextField.delegate = self;
    _phoneTextField.placeholder = NSLocalizedString(@"请输入手机号", nil);
    _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    _phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:_phoneTextField];
    
    //下一步
    UIButton *nextStepBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextStepBtn.frame = CGRectMake(20, _phoneTextField.bottom+45, SCREEN_WIDTH-40, 40);
    nextStepBtn.layer.cornerRadius = 5.0;
    [nextStepBtn setTitle:NSLocalizedString(@"下一步", nil) forState:UIControlStateNormal];
    [nextStepBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextStepBtn.backgroundColor = MainThemeColor;
    [nextStepBtn addTarget:self action:@selector(nextStep) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextStepBtn];
   
    [self getCountryCode];
    [self createPickView];
}

- (void)showPickKeyBoard{
    [_areaTextField becomeFirstResponder];
}

#pragma mark 获取手机区号
- (void)getCountryCode{
    //之前请求过就不再请求
    if ([ZFGlobleManager getGlobleManager].areaNumArray && [ZFGlobleManager getGlobleManager].areaNumArray.count > 0) {
        _areaArray = [ZFGlobleManager getGlobleManager].areaNumArray;
        return;
    }
    _areaArray = [[NSMutableArray alloc] init];
    NSDictionary *parameters = @{@"txnType": @"35"};
    
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            NSArray *countryArr = [requestResult objectForKey:@"list"];
//            NSString *languageDesc = [[NetworkEngine getCurrentLanguage] isEqualToString:@"1"]?@"engDesc":@"chnDesc";
            NSString *languageDesc = @"";
            NSString *language = [NetworkEngine getCurrentLanguage];
            if ([language isEqualToString:@"1"]) {
                languageDesc = @"engDesc";
            } else if ([language isEqualToString:@"2"]) {
                languageDesc = @"chnDesc";
            } else if ([language isEqualToString:@"3"]) {
                languageDesc = @"fonDesc";
            }
            for (NSDictionary *dict in countryArr) {
                NSString *str = [NSString stringWithFormat:@"%@+%@", [dict objectForKey:languageDesc], [dict objectForKey:@"countryCode"]];
                [_areaArray addObject:str];
            }
            //把区号保存到本地 防止下次无网络列表空白
            [[ZFGlobleManager getGlobleManager] saveAreaNumArray:_areaArray];
            [_pickerView reloadAllComponents];
            NSString *countryStr = _areaArray[0];//[NSString stringWithFormat:@"+%@", [[_areaArray[0] componentsSeparatedByString:@"+"] lastObject]];
            _areaTextField.text = countryStr;
        } else {
            
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
        
    } failure:^(NSError *error) {
        //[[MBUtils sharedInstance] dismissMB];
        
    }];
}

- (void)createPickView{
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 220)];
    self.pickerView.backgroundColor = [UIColor whiteColor];
    
    // 代理
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    
    // --- tool bar ---
    UIBarButtonItem *doneBBI = [[UIBarButtonItem alloc]
                                initWithTitle:NSLocalizedString(@"确定", nil)
                                style:UIBarButtonItemStyleDone
                                target:self
                                action:@selector(hidePickView)];
    UIBarButtonItem *flexibleBBILeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *textBBI = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"请选择手机区号", nil) style:UIBarButtonItemStylePlain target:nil action:nil];
    [textBBI setEnabled:NO];
    UIBarButtonItem *flexibleBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *toolbarItems = [NSArray arrayWithObjects:flexibleBBILeft, textBBI, flexibleBBI, doneBBI, nil];
    
    // 工具栏
    self.toolbar = [[UIToolbar alloc]initWithFrame:
                    CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    [self.toolbar setBarStyle:UIBarStyleDefault];
    [self.toolbar setItems:toolbarItems];
    
    self.areaTextField.delegate = self;
    self.areaTextField.inputView = _pickerView;
    self.areaTextField.inputAccessoryView = self.toolbar;
    self.areaTextField.tintColor = [UIColor clearColor];
}

- (void)hidePickView{
    [_areaTextField resignFirstResponder];
}

- (void)nextStep{
    [self.view endEditing:YES];
    NSString *moblie = self.phoneTextField.text;
    
    NSString *errorMessage = @"";
    
    if (!moblie || moblie.length == 0) {
        errorMessage = NSLocalizedString(@"请输入手机号", nil);
        [[MBUtils sharedInstance] showMBMomentWithText:errorMessage inView:self.view];
        return;
    }
    
    if (moblie.length > 11 || moblie.length < 7) {
        errorMessage = NSLocalizedString(@"手机号码应为7~11位", nil);
        [[MBUtils sharedInstance] showMBMomentWithText:errorMessage inView:self.view];
        return;
    }
    
    [self getSessionID];
}

#pragma mark 获取临时sessionID
- (void)getSessionID{
    NSString *countryCode = [[_areaTextField.text componentsSeparatedByString:@"+"] lastObject];
    
    NSDictionary *parameters = @{@"countryCode": countryCode,
                                 @"mobile": _phoneTextField.text,
                                 @"txnType": @"01"};
    
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            // 解密secretKey得到3DES的key
            NSString *securityKey = [[HBRSAHandler sharedInstance] decryptWithPrivateKey:[requestResult objectForKey:@"securityKey"]];
            // 保存secreykey
            [ZFGlobleManager getGlobleManager].tempSecurityKey = securityKey;
            [ZFGlobleManager getGlobleManager].tempSessionID = [requestResult objectForKey:@"sessionID"];
            [ZFGlobleManager getGlobleManager].areaNum = countryCode;
            [ZFGlobleManager getGlobleManager].userPhone = _phoneTextField.text;
            
            [self getVeriCode];
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
        
    } failure:^(NSError *error) {
        //[[MBUtils sharedInstance] dismissMB];
        
    }];
}

- (void)getVeriCode{
    
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                       @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                       @"txnType": @"03",
                       @"tempSessionID":[ZFGlobleManager getGlobleManager].tempSessionID};
    
    [[MBUtils sharedInstance] showMBInView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            //跳转
            ZFGetVerCodeController *gcVC = [[ZFGetVerCodeController alloc] init];
            gcVC.getCodeType = 0;
            [self.navigationController pushViewController:gcVC animated:YES];
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
        }
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - UITextField Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _areaTextField) {
        return NO;
    }
    if (textField == _phoneTextField) {
        if (range.location >= 11) {
            textField.text = [textField.text substringToIndex:range.location];
            return NO;
        }
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == _areaTextField) {
        if (![ZFGlobleManager getGlobleManager].areaNumArray || [ZFGlobleManager getGlobleManager].areaNumArray.count == 0) {
            [self getCountryCode];
            return NO;
        }
    }
    return YES;
}

#pragma mark - pickview delegate
// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _areaArray.count;
}

- (NSInteger) numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return _areaArray.count;
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
    textlabel.text = _areaArray[row];
    textlabel.font = [UIFont systemFontOfSize:19];
    [view addSubview:textlabel];
    return view;
}

// didSelectRow
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
//    self.areaTextField.text = [NSString stringWithFormat:@"+%@", [[_areaArray[row] componentsSeparatedByString:@"+"] lastObject]];
    self.areaTextField.text = _areaArray[row];
}

@end
