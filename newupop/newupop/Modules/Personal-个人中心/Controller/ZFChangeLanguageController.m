//
//  ZFChangeLanguageController.m
//  newupop
//
//  Created by 中付支付 on 2017/11/2.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFChangeLanguageController.h"
#import "NSBundle+Language.h"
#import "ZFTabBarController.h"

@interface ZFChangeLanguageController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, assign)NSInteger defaultIndex;
@property (nonatomic, assign)NSInteger originIndex;

@end

@implementation ZFChangeLanguageController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myTitle = @"多语言";
    [self createView];
}

- (void)createView{
    NSString *language = [NetworkEngine getCurrentLanguage];
    _defaultIndex = 0;
    if ([language isEqualToString:@"3"]) {//英语
        _defaultIndex = 1;
    } else if ([language isEqualToString:@"1"]) {
        _defaultIndex = 2;
    }
    //记住原来的语言
    _originIndex = _defaultIndex;
    
    [self setupRightBarButtonItemWithTitle:NSLocalizedString(@"完成", nil) action:@selector(completeBtn)];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = GrayBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    [self.view addSubview:_tableView];
}

- (void)completeBtn{
    if (_defaultIndex == _originIndex) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    NSString *language = @"zh-Hans";
    if (_defaultIndex == 1) {
        language = @"zh-Hant";
    } else if (_defaultIndex == 2) {
        language = @"en";
    }
    [NSBundle setLanguage:language];
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:language, nil] forKey:@"AppleLanguages"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CHANGE_LANGUAGE object:nil];
    
    ZFTabBarController *tabVC = [[ZFTabBarController alloc] init];
    tabVC.selectedIndex = 2;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.rootViewController = tabVC;
    UIView *toView;
    UIView *fromView;
    UIViewAnimationOptions option = UIViewAnimationOptionTransitionCrossDissolve;
    [UIView transitionWithView:window
                      duration:1.0f
                       options:option
                    animations:^ {
                        [fromView removeFromSuperview];
                        [window addSubview:toView];
                    }
                    completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 20;
    }
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    NSString *str = @"简体中文";
    if (indexPath.section == 0) {
        str = @"简体中文";
    } else if (indexPath.section == 1) {
        str = @"繁体中文";
    } else if (indexPath.section == 2) {
        str = @"English";
    }
    cell.textLabel.text = str;
    
    if (indexPath.section == _defaultIndex) {
        UIImageView *selectImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-40, 15, 20, 20)];
        selectImage.image = [UIImage imageNamed:@"select_card"];
        [cell addSubview:selectImage];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _defaultIndex = indexPath.section;
    [_tableView reloadData];
}

@end
