//
//  ZFPCPersonInfoViewController.m
//  newupop
//
//  Created by Jellyfish on 2020/1/6.
//  Copyright © 2020 中付支付. All rights reserved.
//

#import "ZFPCPersonInfoViewController.h"
#import "ZFPCAddPicViewController.h"
#import "ZFPickerView.h"
#import "ZFDatePickerView.h"
#import "DateUtils.h"
#import "WLCardNoFormatter.h"
#import "ZFGlobleManager.h"
static H = 19.093750;
@interface ZFPCPersonInfoViewController () <ZFPickerViewDelegate, ZFDatePickerViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topMargin;
@property (weak, nonatomic) IBOutlet UIScrollView *bgScrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMargin;
@property (weak, nonatomic) IBOutlet UIButton *nextStepBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gzzzVHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gzzzVheight2;
@property (weak, nonatomic) IBOutlet UIView *gzzzView1;
@property (weak, nonatomic) IBOutlet UIView *gzzzView2;
@property (weak, nonatomic) IBOutlet UIView *idNoTpyeView;
@property (weak, nonatomic) IBOutlet UILabel *idNoTypeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *idNoTypeVheight;

@property (nonatomic, strong)ZFPickerView *citizenshipPicker;
@property (nonatomic, strong)ZFPickerView *liveCountryPicker;
@property (nonatomic, strong)ZFPickerView *sexPicker;
@property (nonatomic, strong)ZFDatePickerView *birthDatePicker;
@property (nonatomic, strong)ZFPickerView *idTypePicker;
@property (nonatomic, strong)ZFDatePickerView *idValidDatePicker;
@property (nonatomic, strong)ZFDatePickerView *gzzzValidDatePicker;
@property (nonatomic, strong)ZFPickerView *countryCodePicker;
@property (nonatomic, strong)ZFPickerView *currencyPicker;
@property (nonatomic, strong)ZFPickerView *annualIncomePicker;

@property (weak, nonatomic) IBOutlet UILabel *citizenshipLabel;
@property (weak, nonatomic) IBOutlet UILabel *liveCountryLabel;
@property (weak, nonatomic) IBOutlet UILabel *sexLabel;
@property (weak, nonatomic) IBOutlet UILabel *birthDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *idTypeLabel;
@property (weak, nonatomic) IBOutlet UITextField *idNoTF;
@property (weak, nonatomic) IBOutlet UITextField *idNameTF;
@property (weak, nonatomic) IBOutlet UITextField *gzzzNoTF;

@property (weak, nonatomic) IBOutlet UILabel *gzzzValidDateLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;

@property (weak, nonatomic) IBOutlet UILabel *countryCodeLabel;
@property (weak, nonatomic) IBOutlet UITextField *companyAddreTF;
@property (weak, nonatomic) IBOutlet UITextField *jobTF;
@property (weak, nonatomic) IBOutlet UILabel *currencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *annualIncomeLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailLabel;
@property (weak, nonatomic) IBOutlet UITextField *telLabel;
@property (weak, nonatomic) IBOutlet UITextField *postCodeLabel;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *thirdBgViewHeight;


//代理商号
@property (weak, nonatomic) IBOutlet UIView *agentNumBgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *agentNumBgViewHeight;
@property (weak, nonatomic) IBOutlet UITextField *agentNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *agentNameLabel;

@property (nonatomic, strong) NSArray<NSDictionary *> *idTypeDataArray;
@property (nonatomic, strong) NSArray *currencyDataArray;
@property (nonatomic, strong) NSArray *annualIncomeDataArray;
@property (nonatomic, strong) NSArray *genderArray;
@property (nonatomic, strong) NSString *citizenshipCode;//上送的国籍
@property (nonatomic, strong) NSString *liveCountryCode;//上送的居住国家
/** 国籍、国家 */
@property (nonatomic, strong) NSMutableArray *countryCitizenshipArray;

///  证件有效期
@property (weak, nonatomic) IBOutlet UIView *cerValidBgView;
@property (weak, nonatomic) IBOutlet UILabel *cerValidLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cerValidBgViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *idValidDataLabe;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *companyNameHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *companyAddressHeight;
@property (weak, nonatomic) IBOutlet UITextField *addressTF;
@property (weak, nonatomic) IBOutlet UITextField *companyTF;

@property (weak, nonatomic) IBOutlet UIView *companyView;
@property (weak, nonatomic) IBOutlet UILabel *companyNameLab;
@property (strong, nonatomic) UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *zuihouHeight;
@property (weak, nonatomic) IBOutlet UIView *companyAddressView;
@property (strong, nonatomic) UILabel *companyAddressLabel;

@property (weak, nonatomic) IBOutlet UIView *jiatingdizhiView;
@property (strong, nonatomic) UILabel *jiatingAddressLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *jiatingdizhiHeight;
@property (assign, nonatomic)CGFloat third_H;
@end

@implementation ZFPCPersonInfoViewController
#pragma mark 获取手机区号
- (void)getCountryCode {
    NSDictionary *parameters = @{@"txnType": @"35"};
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            NSArray *countryArr = [requestResult objectForKey:@"list"];
            NSMutableArray *areaArray = [[NSMutableArray alloc] init];
            
            [ZFGlobleManager getGlobleManager].countryInfo = [NSArray yy_modelArrayWithClass:[NUCountryInfo class] json:[requestResult objectForKey:@"list"]];
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
                [areaArray addObject:str];
            }
            
            //把区号保存到本地 防止下次无网络列表空白
            [[ZFGlobleManager getGlobleManager] saveAreaNumArray:areaArray];
            NSString *countryStr = areaArray[0];
            NSString *phoneNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhoneNum"];
            NSString *areaNum = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"area_Num%@", phoneNum]];
            if (areaNum) {
                NSString *code = [[areaNum componentsSeparatedByString:@"+"] lastObject];
                for (NSString *str in areaArray) {//避免改变语言后退出显示没改变
                    if ([str hasSuffix:code]) {
                        countryStr = str;
                        break;
                    }
                }
            }
        }
    } failure:^(NSError *error) {
        //[[MBUtils sharedInstance] dismissMB];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myTitle = NSLocalizedString(@"填写个人资料", nil);
    if ([ZFGlobleManager getGlobleManager].countryInfo == nil || [ZFGlobleManager getGlobleManager].countryInfo.count == 0) {
        [self getCountryCode];
    }
    if ([[ZFGlobleManager getGlobleManager].applyType isEqualToString:@"3"]) {
        self.thirdBgViewHeight.constant = 200.f;
        self.agentNumBgViewHeight.constant = 50.f;
        self.agentNumBgView.hidden = NO;
        _third_H = 200.f;
    }else{
        self.agentNumBgViewHeight.constant = 0.f;
        self.agentNumBgView.hidden = YES;
        self.thirdBgViewHeight.constant = 150.f;
        _third_H = 150.f;
    }
    
    _topMargin.constant = IPhoneXTopHeight;
    _bottomMargin.constant = 20;
    _bgScrollView.backgroundColor = GrayBgColor;
    _bgScrollView.bounces = NO;
    
    _nextStepBtn.backgroundColor = MainThemeColor;
    [_nextStepBtn setTitle:NSLocalizedString(@"下一步", nil) forState:UIControlStateNormal];
    [ZFGlobleManager getGlobleManager].pcSaveImageArray = nil;//清空上次可能缓存的证件图片
    
    _gzzzView1.hidden = _gzzzView2.hidden = YES;
    _gzzzVHeight.constant = _gzzzVheight2.constant = 0;
    _idNoTpyeView.hidden = YES;
    _idNoTypeVheight.constant = 0;
    
    _cerValidBgView.hidden = YES;
//    cerValidLabel
//    cerValidContentLabel
    _cerValidBgViewHeight.constant = 0;
    
    _agentNumLabel.placeholder = NSLocalizedString(@"输入代理商号",nil);
    _agentNameLabel.text = NSLocalizedString(@"代理商号",nil);
    
    _countryCodeLabel.text = [NSString stringWithFormat:@"+%@",[ZFGlobleManager getGlobleManager].areaNum];
    _phoneTF.text = [ZFGlobleManager getGlobleManager].userPhone;
    _phoneTF.userInteractionEnabled = NO;
    [self createPicker];

    _companyTF.delegate = self;
    _companyAddreTF.delegate = self;
    _addressTF.delegate = self;
    _companyTF.tag = 10;
    _companyAddreTF.tag = 20;
    _addressTF.tag = 30;
    
    _companyLabel = [[UILabel alloc] init];
    _companyLabel.frame = _companyTF.frame;
    _companyLabel.font = [UIFont systemFontOfSize:16];
    [_companyView addSubview:_companyLabel];
    _companyLabel.numberOfLines = 0;
    _companyLabel.textAlignment = NSTextAlignmentRight;
    
    _companyAddressLabel = [[UILabel alloc] init];
    _companyAddressLabel.frame = _companyAddreTF.frame;
    _companyAddressLabel.font = [UIFont systemFontOfSize:16];
    [_companyAddressView addSubview:_companyAddressLabel];
    _companyAddressLabel.numberOfLines = 0;
    _companyAddressLabel.textAlignment = NSTextAlignmentRight;
    
    _jiatingAddressLabel = [[UILabel alloc] init];
    _jiatingAddressLabel.frame = _addressTF.frame;
    _jiatingAddressLabel.font = [UIFont systemFontOfSize:16];
    [_jiatingdizhiView addSubview:_jiatingAddressLabel];
    _jiatingAddressLabel.numberOfLines = 0;
    _jiatingAddressLabel.textAlignment = NSTextAlignmentRight;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setFloat:0 forKey:@"a"];
    [userDefaults setFloat:0 forKey:@"b"];
    [userDefaults setFloat:0 forKey:@"c"];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {

    CGRect comRect = [[ZFGlobleManager getGlobleManager] getStringWidthAndHeightWithStr:textField.text withFont:textField.font withWidth:textField.width];
    if (textField.tag == 10) {
        self.companyNameHeight.constant = comRect.size.height+31;
        _companyLabel.frame = CGRectMake(_companyTF.origin.x, (self.companyNameHeight.constant-comRect.size.height)/2, _companyTF.width, comRect.size.height);
        _companyLabel.text = textField.text;
        _companyTF.textColor = [UIColor clearColor];
        _companyLabel.textColor = [UIColor blackColor];
        
        _bgView.frame = CGRectMake(_bgView.origin.x, _bgView.origin.y, _bgView.width, _bgView.height+comRect.size.height-H);
        _bgScrollView.contentSize = _bgView.size;

        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setFloat:comRect.size.height-H forKey:@"a"];
        
        CGFloat b = [[userDefaults objectForKey:@"b"] floatValue];
        _zuihouHeight.constant = 350+b+comRect.size.height-H;
        NSLog(@"%f",comRect.size.height);
    } else if (textField.tag == 20){
        self.companyAddressHeight.constant = comRect.size.height+31;
        _companyAddressLabel.frame = CGRectMake(_companyAddreTF.origin.x, (self.companyAddressHeight.constant-comRect.size.height)/2, _companyTF.width, comRect.size.height);
        _companyAddressLabel.text = textField.text;
        _companyAddreTF.textColor = [UIColor clearColor];
        _companyAddressLabel.textColor = [UIColor blackColor];
        
        _bgView.frame = CGRectMake(_bgView.origin.x, _bgView.origin.y, _bgView.width, _bgView.height+comRect.size.height-H);
        _bgScrollView.contentSize = _bgView.size;
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setFloat:comRect.size.height-H forKey:@"b"];
        
        CGFloat a = [[userDefaults objectForKey:@"a"] floatValue];
        _zuihouHeight.constant = 350+a+comRect.size.height-H;
    }  else if (textField.tag == 30){
        self.jiatingdizhiHeight.constant = comRect.size.height+31;
        _jiatingAddressLabel.frame = CGRectMake(_addressTF.origin.x, (self.jiatingdizhiHeight.constant-comRect.size.height)/2, _addressTF.width, comRect.size.height);
        _jiatingAddressLabel.text = textField.text;
        _addressTF.textColor = [UIColor clearColor];
        _jiatingAddressLabel.textColor = [UIColor blackColor];
        
        _bgView.frame = CGRectMake(_bgView.origin.x, _bgView.origin.y, _bgView.width, _bgView.height+comRect.size.height-H);
        _bgScrollView.contentSize = _bgView.size;
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setFloat:comRect.size.height-H forKey:@"c"];

        _thirdBgViewHeight.constant = _third_H+comRect.size.height-H;
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.tag == 10) {
        _companyLabel.textColor = [UIColor clearColor];
        _companyTF.textColor = [UIColor blackColor];
    } else if (textField.tag == 20) {
        _companyAddressLabel.textColor = [UIColor clearColor];
        _companyAddreTF.textColor = [UIColor blackColor];
    } else if (textField.tag == 30) {
        _jiatingAddressLabel.textColor = [UIColor clearColor];
        _addressTF.textColor = [UIColor blackColor];
    }
    return YES;
}

- (void)createPicker{
    _citizenshipPicker = [[ZFPickerView alloc] init];
    _citizenshipPicker.delegate = self;
    _citizenshipPicker.tag = 101;
    _citizenshipPicker.title = NSLocalizedString(@"请选择国籍", nil);
    _citizenshipPicker.dataArray = self.countryCitizenshipArray;
    [self.view addSubview:_citizenshipPicker];
    
    _liveCountryPicker = [[ZFPickerView alloc] init];
    _liveCountryPicker.delegate = self;
    _liveCountryPicker.tag = 102;
    _liveCountryPicker.title = NSLocalizedString(@"请选择居住国家", nil);
    _liveCountryPicker.dataArray = self.countryCitizenshipArray;
    [self.view addSubview:_liveCountryPicker];
    
    _sexPicker = [[ZFPickerView alloc] init];
    _sexPicker.delegate = self;
    _sexPicker.tag = 103;
    _sexPicker.title = NSLocalizedString(@"请选择性别", nil);
    _sexPicker.dataArray = [self getDataArray:self.genderArray];
    [self.view addSubview:_sexPicker];
    
    _birthDatePicker = [[ZFDatePickerView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _birthDatePicker.delegate = self;
    _birthDatePicker.title = NSLocalizedString(@"请选择出生日期", nil);
    _birthDatePicker.tag = 104;
    [self.view addSubview:_birthDatePicker];
    
    _idTypePicker = [[ZFPickerView alloc] init];
    _idTypePicker.delegate = self;
    _idTypePicker.tag = 105;
    _idTypePicker.title = NSLocalizedString(@"请选择证件类型", nil);
    _idTypePicker.dataArray = [self getDataArray:self.idTypeDataArray];
    [self.view addSubview:_idTypePicker];
    
    _idValidDatePicker = [[ZFDatePickerView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _idValidDatePicker.delegate = self;
    _idValidDatePicker.title = NSLocalizedString(@"请选择证件有效期", nil);
    _idValidDatePicker.tag = 106;
    [self.view addSubview:_idValidDatePicker];
    
    _countryCodePicker = [[ZFPickerView alloc] init];
    _countryCodePicker.delegate = self;
    _countryCodePicker.tag = 107;
    _countryCodePicker.title = NSLocalizedString(@"请选择国家区号", nil);
    _countryCodePicker.dataArray = [ZFGlobleManager getGlobleManager].areaNumArray;
    //[self.view addSubview:_countryCodePicker];
    
    _currencyPicker = [[ZFPickerView alloc] init];
    _currencyPicker.delegate = self;
    _currencyPicker.tag = 108;
    _currencyPicker.title = NSLocalizedString(@"请选择币种", nil);
    _currencyPicker.dataArray = [self getDataArray:self.currencyDataArray];
    [self.view addSubview:_currencyPicker];
    
    _annualIncomePicker = [[ZFPickerView alloc] init];
    _annualIncomePicker.delegate = self;
    _annualIncomePicker.tag = 109;
    _annualIncomePicker.title = NSLocalizedString(@"请选择年收入", nil);
    _annualIncomePicker.dataArray = [self getDataArray:self.annualIncomeDataArray];
    [self.view addSubview:_annualIncomePicker];
    
    _gzzzValidDatePicker = [[ZFDatePickerView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _gzzzValidDatePicker.delegate = self;
    _gzzzValidDatePicker.title = NSLocalizedString(@"请选择工作准证有效期", nil);
    _gzzzValidDatePicker.tag = 110;
    [self.view addSubview:_gzzzValidDatePicker];
}

- (NSArray *)getDataArray:(NSArray *)dataArray {
    NSMutableArray *tempArray = [NSMutableArray array];
    for (NSDictionary *dic in dataArray) {
        [tempArray addObject:dic[kPC_INFO_SHOWTEXT]];
    }
    
    return tempArray;
}

#pragma mark -- 点击事件
- (IBAction)selectContry:(id)sender {
    [self.view endEditing:YES];
    if (self.countryCitizenshipArray.count == 0) {
        for (NUCountryInfo *info in [ZFGlobleManager getGlobleManager].countryInfo) {
//            BOOL enLanguage = [[NetworkEngine getCurrentLanguage] isEqualToString:@"1"];
            NSString *language = [NetworkEngine getCurrentLanguage];
            if ([language isEqualToString:@"1"]) {
                [self.countryCitizenshipArray addObject:info.engDesc];
            } else if ([language isEqualToString:@"2"]) {
                [self.countryCitizenshipArray addObject:info.chnDesc];
            } else if ([language isEqualToString:@"3"]) {
                [self.countryCitizenshipArray addObject:info.fonDesc];
            }
        }
    }
    [_citizenshipPicker show];
}

- (IBAction)selectLiveCountry:(id)sender {
    [self.view endEditing:YES];
    if (self.countryCitizenshipArray.count == 0) {
        for (NUCountryInfo *info in [ZFGlobleManager getGlobleManager].countryInfo) {
//            BOOL enLanguage = [[NetworkEngine getCurrentLanguage] isEqualToString:@"1"];
//            [self.countryCitizenshipArray addObject:enLanguage ?  info.engDesc : info.chnDesc];
            NSString *language = [NetworkEngine getCurrentLanguage];
            if ([language isEqualToString:@"1"]) {
                [self.countryCitizenshipArray addObject:info.engDesc];
            } else if ([language isEqualToString:@"2"]) {
                [self.countryCitizenshipArray addObject:info.chnDesc];
            } else if ([language isEqualToString:@"3"]) {
                [self.countryCitizenshipArray addObject:info.fonDesc];
            }
        }
    }
    [_liveCountryPicker show];
}

- (IBAction)selectSex:(id)sender {
    [self.view endEditing:YES];
    [_sexPicker show];
}

- (IBAction)selectBirthDate:(id)sender {
    [self.view endEditing:YES];
    [_birthDatePicker show];
}

- (IBAction)selectIDType:(id)sender {
    [self.view endEditing:YES];
//    if (!_citizenshipCode.length) {
//        [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"请选择国籍", nil) inView:self.view];
//        return;
//    }
    [_idTypePicker show];
}

- (IBAction)selectIDValidDate:(id)sender {
    [self.view endEditing:YES];
    [_idValidDatePicker show];
}

- (IBAction)selectGzzzValidDate:(id)sender {
    [self.view endEditing:YES];
    [_gzzzValidDatePicker show];
}

- (IBAction)selectCountryCode:(id)sender {
    [self.view endEditing:YES];
    [_countryCodePicker show];
}

- (IBAction)selectCurrency:(id)sender {
    [self.view endEditing:YES];
    [_currencyPicker show];
}

- (IBAction)selectAnnualIncome:(id)sender {
    [self.view endEditing:YES];
    [_annualIncomePicker show];
}

- (IBAction)nextStepAction:(id)sender {
    NSString *citizenship = _citizenshipLabel.text;
    NSString *residenceCountry = _liveCountryLabel.text;
    NSString *gender = _sexLabel.text;
    NSString *birthdate = _birthDateLabel.text;
    NSString *idType = _idTypeLabel.text;
    NSString *idNo = _idNoTF.text;
    NSString *idValidData = _idValidDataLabe.text.length ? _idValidDataLabe.text : @"";
    NSString *cardName = _idNameTF.text;
    NSString *countryCode = _countryCodeLabel.text;
    NSString *phone = _phoneTF.text;
    NSString *address = _addressTF.text;
//    NSString *workPermit = _gzzzNoTF.text;
//    NSString *workPermiteExpiry = _gzzzValidDateLabel.text;
    
    NSString *companyName = _companyTF.text;
    NSString *officeAddress = _companyAddreTF.text;
    NSString *occupation = _jobTF.text;
    NSString *tel = _telLabel.text;
    NSString *incomecurrency = _currencyLabel.text;
    NSString *annualincome = _annualIncomeLabel.text;
    NSString *postCode = _postCodeLabel.text;
    NSString *email = _emailLabel.text;
    NSString *agent = nil;
    if ([[ZFGlobleManager getGlobleManager].applyType isEqualToString:@"3"]) {
        agent = _agentNumLabel.text;
    } else {
        agent = @"";
    }
    if (!citizenship.length || !residenceCountry.length || !gender.length
        ||!birthdate.length || !idType.length || !idNo.length
        || !cardName.length || !countryCode.length || !phone.length || !address.length
        || !companyName.length || !officeAddress.length || !occupation.length || !tel.length
        || !incomecurrency.length || !annualincome.length) {
        [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"请完善必填资料", nil) inView:self.view];
        return;
    }
    
    NSString *uploadIDType = [_idTypeDataArray[[_idTypePicker.dataArray indexOfObject:idType]] objectForKey:kPC_INFO_UPSTRING];
    if (![[WLCardNoFormatter sharedManager] isValidNumbers:_phoneTF.text]) {//手机号格式判断
        [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"手机号格式不正确", nil) inView:self.view];
        return;
    }
    
    NSString *uploadGender = [_genderArray[[_sexPicker.dataArray indexOfObject:gender]] objectForKey:kPC_INFO_UPSTRING];
    NSString *uploadCurrency = @"";
    if (incomecurrency.length) {
        uploadCurrency = [_currencyDataArray[[_currencyPicker.dataArray indexOfObject:incomecurrency]] objectForKey:kPC_INFO_UPSTRING];
    }
    NSString *uploadAnnualIncome = @"";
    if (annualincome.length) {
        uploadAnnualIncome = [_annualIncomeDataArray[[_annualIncomePicker.dataArray indexOfObject:annualincome]] objectForKey:kPC_INFO_UPSTRING];
    }
    
    NSString *name = [TripleDESUtils getEncryptWithString:cardName keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    NSString *idCardType = [TripleDESUtils getEncryptWithString:uploadIDType keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    NSString *certificateno = [TripleDESUtils getEncryptWithString:idNo keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    NSString *phoneNumber = [TripleDESUtils getEncryptWithString:phone keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    NSString *nationality = [TripleDESUtils getEncryptWithString:_citizenshipCode keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    @try {
        [params setValue:_enCardNum forKey:@"cardNum"];
        [params setValue:name forKey:@"name"];
        [params setValue:idCardType forKey:@"idCardType"];
        [params setValue:certificateno forKey:@"certificateno"];
        [params setValue:phoneNumber forKey:@"phoneNumber"];
        [params setValue:nationality forKey:@"nationality"];
        [params setValue:idValidData forKey:@"passPortExpiry"];
        [params setValue:[countryCode stringByReplacingOccurrencesOfString:@"+" withString:@""] forKey:@"realCountryCode"];
        [params setValue:address forKey:@"address"];
        [params setValue:cardName forKey:@"cardName"];
        [params setValue:uploadGender forKey:@"gender"];
        [params setValue:birthdate forKey:@"birthdate"];
//        [params setValue:workPermit forKey:@"workPermit"];
//        [params setValue:workPermiteExpiry forKey:@"workPermiteExpiry"];
        [params setValue:_liveCountryCode forKey:@"residenceCountry"];//居住国家
        [params setValue:companyName forKey:@"companyName"];//非必填
        [params setValue:officeAddress forKey:@"officeAddress"];
        [params setValue:occupation forKey:@"occupation"];
        [params setValue:uploadAnnualIncome forKey:@"annualincome"];
        [params setValue:uploadCurrency forKey:@"incomecurrency"];
        [params setValue:email forKey:@"email"];
        [params setValue:tel forKey:@"tel"];
        [params setValue:postCode forKey:@"postCode"];
        [params setValue:agent forKey:@"agentno"];
    } @catch (NSException *exception) {
        [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"参数错误", nil) inView:self.view];
        return;
    }
    ZFPCAddPicViewController *addPic = [[ZFPCAddPicViewController alloc] initWithParams:params];
    addPic.citizenshipCode = _citizenshipCode;
    [self pushViewController:addPic];
}

#pragma mark -- ZFPickerViewDelegate
- (void)selectZFPickerViewTag:(NSInteger)tag index:(NSInteger)index {
    switch (tag) {
        case 101://国籍
        {
            _citizenshipLabel.text = self.countryCitizenshipArray[index];
            _citizenshipCode = [[ZFGlobleManager getGlobleManager].countryCodeArray[index] stringByReplacingOccurrencesOfString:@"+" withString:@""];
//            _idTypeLabel.text = nil;//切换国籍时清空之前选择的证件类型
//            if ([_citizenshipCode isEqualToString:@"65"]) {
//                _idTypeDataArray = @[@{kPC_INFO_SHOWTEXT: NSLocalizedString(@"身份证", nil),
//                                              kPC_INFO_UPSTRING: @"0"},
//                                            @{kPC_INFO_SHOWTEXT: NSLocalizedString(@"护照", nil),
//                                              kPC_INFO_UPSTRING: @"1"}];
//                _idTypePicker.dataArray = [self getDataArray:_idTypeDataArray];
//            } else {
//                _idTypeDataArray = @[@{kPC_INFO_SHOWTEXT: NSLocalizedString(@"护照", nil),
//                                              kPC_INFO_UPSTRING: @"1"}];
//                _idTypePicker.dataArray = [self getDataArray:_idTypeDataArray];
//            }

            if (([_citizenshipLabel.text isEqualToString:NSLocalizedString(@"马来西亚", nil)] && [_idNoTypeLabel.text isEqualToString:NSLocalizedString(@"*护照号", nil)]) || [_citizenshipLabel.text isEqualToString:NSLocalizedString(@"中国大陆", nil)]) {
                _cerValidBgView.hidden = NO;
                _cerValidBgViewHeight.constant = 50;
            } else {
                _cerValidBgView.hidden = YES;
                _cerValidBgViewHeight.constant = 0;
            }
        }
            break;
        case 102:
        {
            _liveCountryLabel.text = self.countryCitizenshipArray[index];
            _liveCountryCode = [[ZFGlobleManager getGlobleManager].countryCodeArray[index] stringByReplacingOccurrencesOfString:@"+" withString:@""];
            
        }
            break;
        case 103:
            _sexLabel.text = [_genderArray[index] objectForKey:kPC_INFO_SHOWTEXT];
            break;
        case 105://证件类型
        {
            _idTypeLabel.text = [_idTypeDataArray[index] objectForKey:kPC_INFO_SHOWTEXT];
            if (_idNoTypeLabel.text.length) {
                _idNoTpyeView.hidden = NO;
                _idNoTypeVheight.constant = 50;
                _idNoTypeLabel.text = index == 0 ? NSLocalizedString(@"*身份证号", nil) : NSLocalizedString(@"*护照号", nil);
                _idNoTF.placeholder = index == 0 ? NSLocalizedString(@"输入身份证号", nil) : NSLocalizedString(@"输入护照号", nil);
                
                if (([_citizenshipLabel.text isEqualToString:NSLocalizedString(@"马来西亚", nil)] && [_idNoTypeLabel.text isEqualToString:NSLocalizedString(@"*护照号", nil)]) || [_citizenshipLabel.text isEqualToString:NSLocalizedString(@"中国大陆", nil)]) {
                    _cerValidBgView.hidden = NO;
                    _cerValidBgViewHeight.constant = 50;
                } else {
                    _cerValidBgView.hidden = YES;
                    _cerValidBgViewHeight.constant = 0;
                }
            }
        }
            break;
        case 107:
            _countryCodeLabel.text = [ZFGlobleManager getGlobleManager].countryCodeArray[index];
            break;
        case 108:
            _currencyLabel.text = [_currencyDataArray[index] objectForKey:kPC_INFO_SHOWTEXT];
            break;
        case 109:
            _annualIncomeLabel.text = [_annualIncomeDataArray[index] objectForKey:kPC_INFO_SHOWTEXT];
            break;
        default:
            break;
    }
}


#pragma mark - ZFDatePickerViewDelegate
- (void)datePickerViewTag:(NSInteger)tag time:(NSString *)time {
    NSString *currentDate = [DateUtils getCurrentDateWithFormat:@"yyyy-MM-dd"];
    NSInteger intervalDate =  [DateUtils compareBeginTime:currentDate endTime:time];
    if (tag == 104) {
        if (intervalDate < 0) {//出生日期必须<当前日期
            _birthDateLabel.text = time;
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"无效的出生日期", nil) inView:self.view];
            _birthDateLabel.text = nil;
        }
    }
    else if (tag == 106) {
        if (intervalDate > 0) {//选择的日期必须>当前日期
            _idValidDataLabe.text = time;
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"无效的证件有效期", nil) inView:self.view];
            _idValidDataLabe.text = nil;
        }
    }
    else if (tag == 110) {
        if (intervalDate > 0) {//选择的日期必须>当前日期
            _gzzzValidDateLabel.text = time;
        } else {
            [[MBUtils sharedInstance] showMBMomentWithText:NSLocalizedString(@"无效的工作准证有效期", nil) inView:self.view];
            _gzzzValidDateLabel.text = nil;
        }
    }
}

#pragma mark -- Lazy Load
- (NSArray<NSDictionary *> *)idTypeDataArray {
    if (!_idTypeDataArray) {
        _idTypeDataArray = @[@{kPC_INFO_SHOWTEXT: NSLocalizedString(@"身份证", nil),
                               kPC_INFO_UPSTRING: @"0"},
                             @{kPC_INFO_SHOWTEXT: NSLocalizedString(@"护照", nil),
                               kPC_INFO_UPSTRING: @"1"}];
    }

    return _idTypeDataArray;
}

- (NSArray *)currencyDataArray {
    if (!_currencyDataArray) {
        _currencyDataArray = @[@{kPC_INFO_SHOWTEXT: NSLocalizedString(@"人民币", nil),
                                 kPC_INFO_UPSTRING: @"156"},
                               @{kPC_INFO_SHOWTEXT: NSLocalizedString(@"新币", nil),
                                 kPC_INFO_UPSTRING: @"702"},
                               @{kPC_INFO_SHOWTEXT: NSLocalizedString(@"美元", nil),
                                 kPC_INFO_UPSTRING: @"840"},
                               @{kPC_INFO_SHOWTEXT: NSLocalizedString(@"港币", nil),
                                 kPC_INFO_UPSTRING: @"344"},
                               @{kPC_INFO_SHOWTEXT: NSLocalizedString(@"马币", nil),
                                 kPC_INFO_UPSTRING: @"458"}];
    }
    
    return _currencyDataArray;
}

- (NSArray *)annualIncomeDataArray {
    if (!_annualIncomeDataArray) {
        _annualIncomeDataArray = @[@{kPC_INFO_SHOWTEXT: NSLocalizedString(@"20000以下", nil),
                                     kPC_INFO_UPSTRING: @"0"},
                                   @{kPC_INFO_SHOWTEXT: NSLocalizedString(@"20000~100000", nil),
                                     kPC_INFO_UPSTRING: @"1"},
                                   @{kPC_INFO_SHOWTEXT: NSLocalizedString(@"100000~500000", nil),
                                     kPC_INFO_UPSTRING: @"2"},
                                   @{kPC_INFO_SHOWTEXT: NSLocalizedString(@"500000~1000000", nil),
                                     kPC_INFO_UPSTRING: @"3"},
                                   @{kPC_INFO_SHOWTEXT: NSLocalizedString(@"1000000以上", nil),
                                     kPC_INFO_UPSTRING: @"4"}];
        
    }
    
    return _annualIncomeDataArray;
}

- (NSArray *)genderArray {
    if (!_genderArray) {
        _genderArray = @[@{kPC_INFO_SHOWTEXT: NSLocalizedString(@"男", nil),
                           kPC_INFO_UPSTRING: @"0"},
                         @{kPC_INFO_SHOWTEXT: NSLocalizedString(@"女", nil),
                           kPC_INFO_UPSTRING: @"1"}];
    }
    
    return _genderArray;
}

- (NSMutableArray *)countryCitizenshipArray {
    if (!_countryCitizenshipArray) {
        _countryCitizenshipArray = [NSMutableArray arrayWithCapacity:0];
        for (NUCountryInfo *info in [ZFGlobleManager getGlobleManager].countryInfo) {
//            BOOL enLanguage = [[NetworkEngine getCurrentLanguage] isEqualToString:@"1"];
//            [_countryCitizenshipArray addObject:enLanguage ?  info.engDesc : info.chnDesc];
            NSString *language = [NetworkEngine getCurrentLanguage];
            if ([language isEqualToString:@"1"]) {
                [_countryCitizenshipArray addObject:info.engDesc];
            } else if ([language isEqualToString:@"2"]) {
                [_countryCitizenshipArray addObject:info.chnDesc];
            } else if ([language isEqualToString:@"3"]) {
                [_countryCitizenshipArray addObject:info.fonDesc];
            }
        }
    }
    return _countryCitizenshipArray;
}


@end
