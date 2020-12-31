 //
//  ZFAddCardDetailViewController.m
//  newupop
//
//  Created by Jellyfish on 2017/12/20.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFAddCardDetailViewController.h"
#import "UITextField+Format.h"
#import "UITextField+LimitLength.h"
#import "ZFGetMSCodeController.h"
#import "ZFLogOffIDViewController.h"


@interface ZFAddCardDetailViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property(nonatomic, weak) UITableView *tableView;

/** 卡类型 */
@property(nonatomic, assign) BankCardType cardType;
/** 卡号 */
@property(nonatomic, copy) NSString *bankCardNo;

/** 姓名 */
@property(nonatomic, weak) UITextField *nameTF;
/** 证件号码 */
@property(nonatomic, weak) UITextField *idNoTF;
/** 手机号码 */
@property(nonatomic, weak) UITextField *mobileTF;
/** cvn */
@property(nonatomic, weak) UITextField *cvnTF;
/** 有效期 */
@property(nonatomic, weak) UITextField *validTF;
/** 取款密码 */
@property(nonatomic, weak) UITextField *pwdTF;

/** 姓名 */
@property(nonatomic, copy) NSString *name;
/** 证件类型 */
@property(nonatomic, copy) NSString *idType;
/** 已选择的证件类型 */
@property(nonatomic, copy) NSString *selectedIdType;
/** 证件号码 */
@property(nonatomic, copy) NSString *idNo;
/** 手机区号 */
@property(nonatomic, copy) NSString *countryCode;
///显示的手机区号
@property (nonatomic, copy)NSString *bindCountryCode;
/** 手机号码 */
@property(nonatomic, copy) NSString *mobile;
/** cvn */
@property(nonatomic, copy) NSString *cvn;
/** 有效期 */
@property(nonatomic, copy) NSString *valid;
/** 取款密码 */
@property(nonatomic, copy) NSString *pwd;

/** 指引视图 */
@property (nonatomic, weak) UIImageView *tipImageView;
/** 遮罩视图 */
@property (nonatomic, weak) UIView *darkView;

/** 证件类型遮罩 */
@property(nonatomic, weak) UIView *darkViewIdType;
/** 证件类型pickView底部容器视图 */
@property (nonatomic, weak) UIView *contentViewIdType;
/** 证件类型PickerView */
@property (nonatomic, weak) UIPickerView *pickerViewIdType;
/// 证件类型
@property(nonatomic,strong) NSArray *IdTypeArray;
///证件类型
@property(nonatomic, strong)NSDictionary *idTypeDictionary;

/** 手机区号名称遮罩 */
@property(nonatomic, weak) UIView *darkViewCountryCode;
/** 手机区号pickView底部容器视图 */
@property (nonatomic, weak) UIView *contentViewCountryCode;
/** 手机区号PickerView */
@property (nonatomic, weak) UIPickerView *pickerViewCountryCode;
/// 支持的手机号码国家/地区代码
@property(nonatomic,strong) NSMutableArray *areaArray;

/** PickViewType类型 */
@property (nonatomic, assign) PickViewType pickViewType;

@end

@implementation ZFAddCardDetailViewController

- (instancetype)initWithBankCardType:(BankCardType)type  cardNo:(NSString *)cardNo {
    if (self = [super init]) {
        self.cardType = type;
        self.bankCardNo = cardNo;
    }
    return self;
}

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myTitle = NSLocalizedString(@"添加银行卡", nil);
    
    self.areaArray = [ZFGlobleManager getGlobleManager].getAreaNumArray;
    self.IdTypeArray = [NSArray arrayWithObjects:NSLocalizedString(@"身份证", nil),NSLocalizedString(@"回乡证", nil), NSLocalizedString(@"护照", nil), NSLocalizedString(@"其他", nil), nil];
    self.idTypeDictionary = @{
                              NSLocalizedString(@"身份证", nil):@"01",
                              NSLocalizedString(@"回乡证", nil):@"02",
                              NSLocalizedString(@"护照", nil):@"03",
                              NSLocalizedString(@"其他", nil):@"04"
                              };
    
    [self setupTableView];
    [self setupDatePickerViewWithTitle:NSLocalizedString(@"请选择证件类型", nil)];
    [self setupDatePickerViewWithTitle:NSLocalizedString(@"请选择手机区号", nil)];
    
    [self getUserInfo];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

#pragma mark - 初始化方法
- (void)setupTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.backgroundColor = GrayBgColor;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.tableFooterView = [UIView new];
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

#pragma mark -- UITableViewDataSourece&UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.cardType == BankCardTypeDebit) {
        return 2;
    } else {
        return 3;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 4;
    } else if (section == 2) {
        if (self.cardType == BankCardTypeDebit) {
            return 1;
        } else {
            return 2;
        }
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MYCELL"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // 左边属性
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.textLabel.textColor = ZFAlpColor(0, 0, 0, 0.8);
    
    // 右边属性
    UIFont *rightFont = [UIFont systemFontOfSize:15.0];
    UIColor *rightColor = ZFAlpColor(0, 0, 0, 0.6);
    // 右边编辑框
    UITextField *textField = [UITextField new];
    textField.textAlignment = NSTextAlignmentLeft;
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.textColor = rightColor;
    textField.font = rightFont;
    textField.size = CGSizeMake(SCREEN_WIDTH-140, 44);
    textField.x = 100;
    textField.y = 0;
    textField.delegate = self;
    
    NSString *leftText = @"";
    if (indexPath.section == 0) { // 卡号
        leftText = NSLocalizedString(@"卡号", nil);
        textField.width = SCREEN_WIDTH-130;
        textField.text =self.bankCardNo;
        textField.enabled = NO;
        [cell addSubview:textField];
    } else if (indexPath.section == 1) { // 姓名，证件类型，证件号码，手机号码
        NSArray *array = [NSArray arrayWithObjects:NSLocalizedString(@"姓名", nil), NSLocalizedString(@"证件类型", nil), NSLocalizedString(@"证件号码", nil), NSLocalizedString(@"手机号码", nil), nil];
        leftText = array[indexPath.row];
        
        if (indexPath.row == 0) { // 姓名
            UIButton *detailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [detailBtn setImage:[UIImage imageNamed:@"icon_tips"] forState:UIControlStateNormal];
            [detailBtn setImage:[UIImage imageNamed:@"icon_tips"] forState:UIControlStateHighlighted];
            detailBtn.tag = 0;
            [detailBtn addTarget:self action:@selector(detailBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            detailBtn.frame = CGRectMake(SCREEN_WIDTH-40, 12, 20, 20);
            
            textField.placeholder = NSLocalizedString(@"请输入开户姓名", nil);
            if ([[NSUserDefaults standardUserDefaults] objectForKey:UserName]) { // 二次绑卡
                self.name = [[NSUserDefaults standardUserDefaults] objectForKey:UserName];
                textField.text = self.name;
                if (![[[NSUserDefaults standardUserDefaults] objectForKey:isCanChangeName] isEqualToString:@"0"]) {
                    textField.enabled = NO;
                    [cell addSubview:detailBtn];
                }
            } else { // 首次
                textField.text = self.name;
            }
            textField.keyboardType = UIKeyboardTypeDefault;
            textField.returnKeyType = UIReturnKeyNext;
            self.nameTF = textField;
            [cell addSubview:textField];
        } else if (indexPath.row == 1) { // 证件类型
            UIView *selectView = [[UIView alloc] initWithFrame:CGRectMake(100, 0, SCREEN_WIDTH-120, 44)];
            [cell addSubview:selectView];
            
            UILabel *titleLabel = [[UILabel alloc]
                                   initWithFrame:CGRectMake(CGRectGetMaxX(selectView.frame)-(selectView.width-25+25), 0, selectView.width-30, 44)];
            
            NSString *idType = [[NSUserDefaults standardUserDefaults] objectForKey:IdType];
            if (idType.length) { // 二次绑卡
                NSInteger typeIndex = [idType integerValue]-1;
//                self.idType = [idType isEqualToString:@"01"] ? [self.IdTypeArray firstObject] : [self.IdTypeArray lastObject];
                self.idType = self.IdTypeArray[typeIndex];
                self.selectedIdType = idType;
                titleLabel.text = self.idType;
                if (![[[NSUserDefaults standardUserDefaults] objectForKey:isCanChangeIdType] isEqualToString:@"0"]) {
                    cell.userInteractionEnabled = NO;
                }
            } else {
                titleLabel.text = self.idType ? self.idType : NSLocalizedString(@"请选择证件类型", nil);
                
//                if ([self.idType isEqualToString:NSLocalizedString(@"身份证", nil)] || [self.idType isEqualToString:NSLocalizedString(@"护照", nil)]) {
//                    self.selectedIdType =  [self.idType isEqualToString:NSLocalizedString(@"身份证", nil)] ? @"01" : @"03";
//                }
                self.selectedIdType = [self.idTypeDictionary objectForKey:self.idType];
            }
            
            titleLabel.font = rightFont;
            titleLabel.textColor = rightColor;
            titleLabel.textAlignment = NSTextAlignmentLeft;
            [cell addSubview:titleLabel];
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_fold_grey"]];
            imageView.frame = CGRectMake(CGRectGetMaxX(titleLabel.frame)+10, 12, 20, 20);
            [cell addSubview:imageView];
        } else if (indexPath.row == 2) { // 证件号码
            textField.placeholder = NSLocalizedString(@"请输入有效证件号码", nil);
            if ([[NSUserDefaults standardUserDefaults] objectForKey:UserIdCardNum]) { // 二次绑卡
                self.idNo = [[NSUserDefaults standardUserDefaults] objectForKey:UserIdCardNum];
                textField.text = self.idNo;
                if (![[[NSUserDefaults standardUserDefaults] objectForKey:isCanChangeUserIdCardNum] isEqualToString:@"0"]) {
                    textField.enabled = NO;
                }
            } else { // 首次
                textField.text = self.idNo;
            }
            textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.returnKeyType = UIReturnKeyNext;
            [textField limitTextLength:18];
            self.idNoTF = textField;
            [cell addSubview:textField];
        } else if (indexPath.row == 3) { // 手机号码
            UIView *selectView = [[UIView alloc] initWithFrame:CGRectMake(100, 0, SCREEN_WIDTH-120, 44)];
            [cell addSubview:selectView];
            
            // 区号
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
            if (!self.countryCode) {
                self.countryCode = [NSString stringWithFormat:@"+%@", [ZFGlobleManager getGlobleManager].areaNum];
            }
            self.bindCountryCode = [[self.countryCode componentsSeparatedByString:@"+"] lastObject];
            titleLabel.text = self.countryCode;
            titleLabel.font = rightFont;
            titleLabel.textColor = rightColor;
            titleLabel.textAlignment = NSTextAlignmentCenter;
            [selectView addSubview:titleLabel];
            // 添加手势
            titleLabel.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(countryCodeClicked)];
            [titleLabel addGestureRecognizer:tapGestureRecognizer];
            
            // 倒三角
            UIButton *line = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame)-5, 7, 30, 34)];
            [line setImage:[UIImage imageNamed:@"tel_icon"] forState:UIControlStateNormal];
            [line setImage:[UIImage imageNamed:@"tel_icon"] forState:UIControlStateHighlighted];
            [line addTarget:self action:@selector(countryCodeClicked) forControlEvents:UIControlEventTouchUpInside];
            [selectView addSubview:line];
            
            // 手机号码
            textField.backgroundColor = [UIColor whiteColor];
            textField.frame = CGRectMake(CGRectGetMaxX(line.frame)+4, 0, selectView.width-CGRectGetMaxX(line.frame), 44);
            textField.placeholder = NSLocalizedString(@"请输入手机号", nil);
            textField.text = self.mobile;
            [textField limitTextLength:11];
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            if (self.cardType == BankCardTypeDebit) {
                textField.returnKeyType = UIReturnKeyDone;
            } else {
                textField.returnKeyType = UIReturnKeyNext;
            }
            self.mobileTF = textField;
            [selectView addSubview:textField];
        }
    } else if (indexPath.section == 2) {
        if (self.cardType == BankCardTypeDebit) { // 取款密码
            leftText = @"取款密码";
            
            textField.placeholder = NSLocalizedString(@"请输入银行卡取款密码", nil);
            textField.text = self.pwd;
            [textField limitTextLength:6];
            textField.returnKeyType = UIReturnKeyDone;
            self.pwdTF = textField;
        } else { // CVN，有效期
            NSArray *array = [NSArray arrayWithObjects:NSLocalizedString(@"有效期", nil), @"CVN", nil];
            leftText = array[indexPath.row];
            
            UIButton *detailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [detailBtn setImage:[UIImage imageNamed:@"icon_tips"] forState:UIControlStateNormal];
            [detailBtn setImage:[UIImage imageNamed:@"icon_tips"] forState:UIControlStateHighlighted];
            [detailBtn addTarget:self action:@selector(detailBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            detailBtn.frame = CGRectMake(SCREEN_WIDTH-40, 12, 20, 20);
            [cell addSubview:detailBtn];
            
            if (indexPath.row == 1) {
                detailBtn.tag = 1;
                textField.placeholder = NSLocalizedString(@"卡背面三位数字", nil);
                textField.text = self.cvn;
                [textField limitTextLength:3];
                textField.returnKeyType = UIReturnKeyNext;
                textField.secureTextEntry = YES;
                self.cvnTF = textField;
                
                //cvn右视图 显示或隐藏
                UIButton *cvnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                cvnBtn.frame = CGRectMake(30, 0, 44, 44);
                cvnBtn.tag = 101;
                [cvnBtn setImage:[UIImage imageNamed:@"showpassword_no"] forState:UIControlStateNormal];
                [cvnBtn setImage:[UIImage imageNamed:@"showpassword_yes"] forState:UIControlStateSelected];
                [cvnBtn addTarget:self action:@selector(setupTipView:) forControlEvents:UIControlEventTouchUpInside];
                self.cvnTF.rightViewMode = UITextFieldViewModeAlways;
                self.cvnTF.rightView = cvnBtn;
            } else {
                detailBtn.tag = 2;
                textField.placeholder = @"MM/YY";
                textField.text = self.valid;
                [textField limitTextLength:4];
                textField.returnKeyType = UIReturnKeyDone;
                textField.secureTextEntry = YES;
                self.validTF = textField;
                
                //有效期右视图 显示或隐藏
                UIButton *validBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                validBtn.frame = CGRectMake(30, 0, 44, 44);
                validBtn.tag = 102;
                [validBtn setImage:[UIImage imageNamed:@"showpassword_no"] forState:UIControlStateNormal];
                [validBtn setImage:[UIImage imageNamed:@"showpassword_yes"] forState:UIControlStateSelected];
                [validBtn addTarget:self action:@selector(setupTipView:) forControlEvents:UIControlEventTouchUpInside];
                self.validTF.rightViewMode = UITextFieldViewModeAlways;
                self.validTF.rightView = validBtn;
            }
        }
        [cell addSubview:textField];
    } else { //取款密码
        leftText = @"取款密码";
        
        textField.placeholder = NSLocalizedString(@"请输入银行卡取款密码", nil);
        textField.text = self.pwd;
        [textField limitTextLength:6];
        textField.returnKeyType = UIReturnKeyDone;
        self.pwdTF = textField;
        [cell addSubview:textField];
    }
    
    cell.textLabel.text = leftText;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            self.pickViewType = PickViewTypeIdType;
            [self.pickerViewIdType reloadAllComponents];
            if (!self.idType) { // 避免第一次点击确认没值
                [self pickerView:self.pickerViewIdType didSelectRow:0 inComponent:0];
            }
            self.darkViewIdType.hidden = NO;
            [UIView animateWithDuration:0.5f animations:^{
                self.contentViewIdType.y = SCREEN_HEIGHT-225;
            }];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 45+44+45)];
    bgView.backgroundColor = GrayBgColor;
    
    // 提交按钮
    UIButton *commitBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 45, SCREEN_WIDTH-40, 44)];
    [commitBtn setTitle:NSLocalizedString(@"下一步", nil) forState:UIControlStateNormal];
    [commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [commitBtn setTitleColor:ZFAlpColor(255, 255, 255, 0.7) forState:UIControlStateHighlighted];
    commitBtn.layer.cornerRadius = 5.0f;
    commitBtn.backgroundColor = MainThemeColor;
    [commitBtn addTarget:self action:@selector(commitBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:commitBtn];
    
    if (self.cardType == BankCardTypeDebit) {
        if (section == 1) {
            return bgView;
        }
    } else {
        if (section == 2) {
            return bgView;
        }
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.cardType == BankCardTypeDebit) {
        if (section == 1) {
            return 45*2+44;
        }
    } else {
        if (section == 2) {
            return 45*2+44;
        }
    }
    return 0.00001;
}

#pragma mark - 点击方法
- (void)detailBtnClicked:(UIButton *)sender {
    DLog(@"%zd", sender.tag);
    
    if (sender.tag == 0) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:UserName]) { // 二次绑卡
            [XLAlertController acWithTitle:nil msg:NSLocalizedString(@"为保证资金安全，暂只能绑定当前持卡人的银行卡，如需绑定其他持卡人银行卡，请更换实名信息", nil) confirmBtnTitle:NSLocalizedString(@"更换实名", nil) cancleBtnTitle:NSLocalizedString(@"知道了", nil) confirmAction:^(UIAlertAction *action) {
                ZFLogOffIDViewController *vc = [[ZFLogOffIDViewController alloc] init];
                [self pushViewController:vc];
            }];
        } else { // 首次
            [XLAlertController acWithMessage:NSLocalizedString(@". 中国境内银联卡请填写银行开户预留证件姓名\n\n. 中国境外银联卡请填写银行开户预留英文姓名或银行卡正面姓名", nil) confirmBtnTitle:NSLocalizedString(@"知道了", nil)];
        }
    } else  {
        [self setupTipView:sender];
    }
}


- (void)commitBtnClicked {
    [self.view endEditing:YES];
    if (self.cardType == BankCardTypeDebit) {
        if (self.name && self.selectedIdType && self.idNo.length && self.countryCode && self.mobile) {
            if ([self.mobile stringByReplacingOccurrencesOfString:@" " withString:@""].length < 7) {
                [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"手机号码填写有误", nil) inView:self.view];
                return ;
            }
            // 提交
            [self commitBankCardInfo];
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"资料未填写完整", nil) inView:self.view];
            return;
        }
    } else {
        if (self.name && self.selectedIdType && self.idNo.length && self.countryCode && self.mobile && self.cvn && self.valid) {
            if ([self.mobile stringByReplacingOccurrencesOfString:@" " withString:@""].length < 7) {
                [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"手机号码填写有误", nil) inView:self.view];
                return ;
            } else if ([self.cvn stringByReplacingOccurrencesOfString:@" " withString:@""].length < 3) {
                [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"CVN填写有误", nil) inView:self.view];
                return ;
            } else if ([self.valid stringByReplacingOccurrencesOfString:@" " withString:@""].length < 4) {
                [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"有效期填写有误", nil) inView:self.view];
                return ;
            }
            // 提交
             [self commitBankCardInfo];
        } else {
            [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"资料未填写完整", nil) inView:self.view];
            return;
        }
    }
}

- (void)countryCodeClicked {
    [self.view endEditing:YES];
    self.pickViewType = PickViewTypeCountryCode;
    [self.pickerViewCountryCode reloadAllComponents];
//    if (self.countryCode) { // 没有的话默认选中第一个
//        [self pickerView:self.pickerViewCountryCode didSelectRow:0 inComponent:0];
//    }
    self.darkViewCountryCode.hidden = NO;
    [UIView animateWithDuration:0.5f animations:^{
        self.contentViewCountryCode.y = SCREEN_HEIGHT-225;
    }];
}

- (void)darkViewClicked {
    [UIView animateWithDuration:1.0 animations:^{
        self.darkView.hidden = YES;
        self.tipImageView.hidden = YES;
    }];
}

#pragma mark - 选择器相关
- (void)setupDatePickerViewWithTitle:(NSString *)title {
    // 遮罩
    UIView *darkView = [[UIView alloc] init];
    darkView.alpha = 0.6;
    darkView.backgroundColor = ZFColor(46, 49, 50);
    darkView.frame = ZFSCREEN;
    darkView.hidden = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:darkView];
    
    // 容器视图
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 225)];
    contentView.backgroundColor = [UIColor whiteColor];
    [[UIApplication sharedApplication].keyWindow addSubview:contentView];
    
    // 取消按钮
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];;
    cancelBtn.backgroundColor = [UIColor clearColor];
    [cancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [cancelBtn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [cancelBtn addTarget:self action:@selector(cancelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:cancelBtn];
    
    // 提示文字
    UILabel *tiplabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/4, 0, SCREEN_WIDTH/2, 44)];
    tiplabel.text = title;
    tiplabel.textColor = UIColorFromRGB(0x313131);
    tiplabel.textAlignment = NSTextAlignmentCenter;
    tiplabel.font = [UIFont boldSystemFontOfSize:17.0];
    [contentView addSubview:tiplabel];
    
    // 确定按钮
    UIButton *ctBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-80, 0, 80, 44)];;
    ctBtn.backgroundColor = [UIColor clearColor];
    [ctBtn setTitleColor:MainThemeColor forState:UIControlStateNormal];
    [ctBtn setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
    ctBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [ctBtn addTarget:self action:@selector(ctBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:ctBtn];
    
    // 分割线
    UIView *spliteView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, 1)];
    spliteView.backgroundColor = GrayBgColor;
    [contentView addSubview:spliteView];
    
    // 选择器
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 45, SCREEN_WIDTH, 200)];
    pickerView.backgroundColor = [UIColor whiteColor];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    [contentView addSubview:pickerView];
    
    if ([title isEqualToString:NSLocalizedString(@"请选择证件类型", nil)]) {
        self.pickViewType = PickViewTypeIdType;
        self.darkViewIdType = darkView;
        self.contentViewIdType = contentView;
        self.pickerViewIdType = pickerView;
    } else {
        self.pickViewType = PickViewTypeCountryCode;
        self.darkViewCountryCode = darkView;
        self.contentViewCountryCode = contentView;
        self.pickerViewCountryCode = pickerView;
    }
}


#pragma mark -- UIPickerViewDataSource 选择器数据源
// 指定pickerview有几个表盘
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// 指定每个表盘上有几行数据
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (self.pickViewType == PickViewTypeIdType) {
        return self.IdTypeArray.count;
    } else {
        return self.areaArray.count;
    }
}

#pragma mark UIPickerViewDelegate 选择器代理方法
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return SCREEN_WIDTH;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}

// 选中的方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (self.pickViewType == PickViewTypeIdType) {
        self.idType = self.IdTypeArray[row];
//        self.selectedIdType = row == 0 ? @"01" : @"03";
    } else {
        self.countryCode = [NSString stringWithFormat:@"+%@", [[self.areaArray[row] componentsSeparatedByString:@"+"] lastObject]];
    }
    
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    //设置分割线的颜色
    for(UIView *singleLine in pickerView.subviews)
    {
        if (singleLine.frame.size.height < 1)
        {
            singleLine.backgroundColor = ZFAlpColor(0, 0, 0, 0.3);
        }
    }
    //设置文字的属性
    UILabel *genderLabel = [UILabel new];
    genderLabel.textAlignment = NSTextAlignmentCenter;
    if (self.pickViewType == PickViewTypeIdType) {
        genderLabel.text = self.IdTypeArray[row];
    } else {
        genderLabel.text = self.areaArray[row];
    }
    genderLabel.font = [UIFont systemFontOfSize:22.0];
    
    return genderLabel;
}

// 取消选择时间
- (void)cancelBtnClicked {
    if (self.pickViewType == PickViewTypeIdType) {
        [UIView animateWithDuration:0.3f
                         animations:^{
                             self.contentViewIdType.y = SCREEN_HEIGHT;
                         }
                         completion:^(BOOL finished){
                             self.darkViewIdType.hidden = YES;
                         }];
    } else {
        [UIView animateWithDuration:0.3f
                         animations:^{
                             self.contentViewCountryCode.y = SCREEN_HEIGHT;
                         }
                         completion:^(BOOL finished){
                             self.darkViewCountryCode.hidden = YES;
                         }];
    }
}

// 确定选择
- (void)ctBtnClicked {
    // 选择刷新
    if (self.pickViewType == PickViewTypeIdType) {
        [UIView animateWithDuration:0.3f
                         animations:^{
                             self.contentViewIdType.y = SCREEN_HEIGHT;
                         }
                         completion:^(BOOL finished){
                             self.darkViewIdType.hidden = YES;
                         }];
        
        // 刷新
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
        
    } else {
        [UIView animateWithDuration:0.3f
                         animations:^{
                             self.contentViewCountryCode.y = SCREEN_HEIGHT;
                         }
                         completion:^(BOOL finished){
                             self.darkViewCountryCode.hidden = YES;
                         }];
        // 刷新
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark -- 网络请求
- (void)commitBankCardInfo {
    if (self.cardType == BankCardTypeDebit) {
        self.cvn = @"";
        self.valid = @"";
    } else {
        self.cvn = [TripleDESUtils getEncryptWithString:[self.cvn stringByReplacingOccurrencesOfString:@" " withString:@""] keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
        
        // 后台有效期格式 年月
        NSString *exchange = [NSString stringWithFormat:@"%@%@", [[self.valid stringByReplacingOccurrencesOfString:@" " withString:@""] substringFromIndex:2], [[self.valid stringByReplacingOccurrencesOfString:@" " withString:@""] substringToIndex:2]];
        self.valid = [TripleDESUtils getEncryptWithString:exchange keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    }
    
    // 加密卡号
    NSString *cardNumEncry = [TripleDESUtils getEncryptWithString:[self.bankCardNo stringByReplacingOccurrencesOfString:@" " withString:@""] keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    
    NSString *phoneNo = [TripleDESUtils getEncryptWithString:[self.mobile stringByReplacingOccurrencesOfString:@" " withString:@""] keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    
    NSString *idNumEncry = [TripleDESUtils getEncryptWithString:[self.idNo stringByReplacingOccurrencesOfString:@" " withString:@""] keyString:[ZFGlobleManager getGlobleManager].securityKey ivString:TRIPLEDES_IV_QUICKPAYABROAD];
    
    NSDictionary *parameters = @{@"countryCode" : [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile" : [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID" : [ZFGlobleManager getGlobleManager].sessionID,
                                 @"sysareaid" : @"SG",//[LocationUtils sharedInstance].ISOCountryCode,
                                 @"phoneNo" : phoneNo,
                                 @"cardNum" : cardNumEncry,
                                 @"idCard" : idNumEncry,
                                 @"idType" : self.selectedIdType,
                                 @"cvn2" : self.cvn,
                                 @"expired" : self.valid,
                                 @"name" : [self.name stringByReplacingOccurrencesOfString:@" " withString:@""],
                                 @"bindCountryCode":self.bindCountryCode,
                                 @"txnType" : @"20"};
    [[MBUtils sharedInstance] showMBInView:self.view];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
            [[MBUtils sharedInstance] dismissMB];
            
            if ([[requestResult objectForKey:@"status"] isEqualToString:@"79"]) {//79时不需要验证码 直接调绑卡
                // 验证码界面
                ZFGetMSCodeController *vc = [[ZFGetMSCodeController alloc] initWithParams:parameters];
                vc.phoneNumber = self.mobile;
                vc.orderId = [requestResult objectForKey:@"orderId"];
                vc.status = [requestResult objectForKey:@"status"];
                [self pushViewController:vc];
                return ;
            }
            
            if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) { // 获取验证码成功
                ZFGetMSCodeController *vc = [[ZFGetMSCodeController alloc] initWithParams:parameters];
                vc.phoneNumber = self.mobile;
                vc.orderId = [requestResult objectForKey:@"orderId"];
                [self pushViewController:vc];
            } else {
                [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
                return ;
            }
        } failure:^(NSError *error) {
            
        }];
    });
}

// 获取用户信息
- (void)getUserInfo {
    NSDictionary *parameters = @{@"txnType": @"73",
                                 @"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sessionID":[ZFGlobleManager getGlobleManager].sessionID
                                 };
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
            if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
                
                NSString *idNo = [requestResult objectForKey:@"idNo"];
                NSString *userName = [requestResult objectForKey:@"userName"];
                NSString *idType = [requestResult objectForKey:@"idType"];
                
                if (idNo.length != 0 && userName.length != 0) {
                    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:UserName];
                    [[NSUserDefaults standardUserDefaults] setObject:idNo forKey:UserIdCardNum];
                    [[NSUserDefaults standardUserDefaults] setObject:idType forKey:IdType];
                } else {
                    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:UserName];
                    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:UserIdCardNum];
                    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:IdType];
                }
                
                //是否可输入
                NSString *bindCardNoFlag = [requestResult objectForKey:@"bindCardNoFlag"];
                NSString *bindCardTypeFlag = [requestResult objectForKey:@"bindCardTypeFlag"];
                NSString *bindCardUserNameFlag = [requestResult objectForKey:@"bindCardUserNameFlag"];
                if ([bindCardNoFlag isKindOfClass:[NSNull class]]) {
                    bindCardNoFlag = @"";
                }
                if ([bindCardTypeFlag isKindOfClass:[NSNull class]]) {
                    bindCardTypeFlag = @"";
                }
                if ([bindCardUserNameFlag isKindOfClass:[NSNull class]]) {
                    bindCardUserNameFlag = @"";
                }
                [[NSUserDefaults standardUserDefaults] setObject:bindCardNoFlag forKey:isCanChangeUserIdCardNum];
                [[NSUserDefaults standardUserDefaults] setObject:bindCardTypeFlag forKey:isCanChangeIdType];
                [[NSUserDefaults standardUserDefaults] setObject:bindCardUserNameFlag forKey:isCanChangeName];
                
                // 赋值
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            } else {
                [[MBUtils sharedInstance] showMBMomentWithText:[requestResult objectForKey:@"msg"] inView:self.view];
            }
        } failure:^(NSError *error) {
            
        }];
    });
}

#pragma mark - 其他方法
- (void)setupTipView:(UIButton *)sender {
    [self.tableView endEditing:YES];
    
    if (sender.tag == 101) {//显示或隐藏cvn
        sender.selected = !sender.selected;
        self.cvnTF.secureTextEntry = !sender.selected;
        return;
    }
    
    if (sender.tag == 102) {//显示或隐藏有效期
        sender.selected = !sender.selected;
        self.validTF.secureTextEntry = !sender.selected;
        return;
    }
    // 遮罩
    UIView *darkView = [[UIView alloc] init];
    darkView.alpha = 0.5;
    darkView.hidden = NO;
    darkView.backgroundColor = ZFColor(46, 49, 50);
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    darkView.frame = keyWindow.bounds;
    [keyWindow addSubview:darkView];
    self.darkView = darkView;
    
    UIImageView *tipImageView = [[UIImageView alloc] init];
    tipImageView.image = sender.tag == 1 ? [UIImage imageNamed:@"pic_tips_anquanma_no_word"] : [UIImage imageNamed:@"pic_tips_youxiaoriqi_no_word"];
    tipImageView.width = SCREEN_WIDTH-110;
    tipImageView.height = tipImageView.width*0.6;
    tipImageView.x = 55;
    tipImageView.y = (SCREEN_HEIGHT-tipImageView.height)/2-30;
    tipImageView.hidden = NO;
    [keyWindow addSubview:tipImageView];
    self.tipImageView = tipImageView;
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, tipImageView.width*0.6-50, tipImageView.width, 50)];
    tipLabel.text = sender.tag == 1 ? NSLocalizedString(@"卡背面三位数字", nil) : @"MM/YY";
    tipLabel.textColor = MainFontColor;
    tipLabel.font = [UIFont systemFontOfSize:14.0];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [tipImageView addSubview:tipLabel];
    
    // 添加点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [tap addTarget:self action:@selector(darkViewClicked)];
    [darkView addGestureRecognizer:tap];
}


// 防止复用
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.nameTF) {
        self.name = textField.text;
    } else if (textField == self.idNoTF) {
        self.idNo = textField.text;
    } else if (textField == self.mobileTF) {
        self.mobile = textField.text;
    } else if (textField == self.cvnTF) {
        self.cvn = textField.text;
    } else if (textField == self.validTF) {
        self.valid = textField.text;
    } else if (textField == self.pwdTF) {
        self.pwd = textField.text;
    }
}

// return按钮
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.nameTF) {
        [self.idNoTF becomeFirstResponder];
    } else if (textField == self.idNoTF) {
        [self.mobileTF becomeFirstResponder];
    } else if (textField == self.mobileTF) {
        if (self.cardType == BankCardTypeDebit) {
            [self commitBtnClicked];
        } else {
            [self.cvnTF becomeFirstResponder];
        }
    } else if (textField == self.cvnTF) {
        [self.validTF becomeFirstResponder];
    } else if (textField == self.validTF) {
        [self commitBtnClicked];
    }
//    else if (textField == self.pwdTF) {
//        [self commitBtnClicked];
//    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == self.idNoTF) {//只能输入字符和数字
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:IDNumLimitString] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        return [string isEqualToString:filtered];
    }
    return YES;
}

@end
