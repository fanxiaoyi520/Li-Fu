//
//  ZFMyCouponViewController.m
//  newupop
//
//  Created by Jellyfish on 2017/11/6.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFMyCouponViewController.h"
#import "UIScrollView+EmptyDataSet.h"
#import "YYModel.h"
#import "ZFMyCouponCell.h"
#import "YZDisplayViewHeader.h"
#import "ZFUplanModel.h"
#import "ZFUplanWebViewController.h"
#import "ZFTabBarController.h"

@interface ZFMyCouponViewController () <UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, ZFMyCouponCellDelegate>

@property (nonatomic, strong)UITableView *tableView;

/** 使用类型 */
@property(nonatomic, assign) ZFCouponUseType useType;
/** 已使用 */
@property (nonatomic, strong) NSArray<ZFUplanModel *> *notuseArray;
/** 未使用 */
@property (nonatomic, strong) NSArray<ZFUplanModel *> *usedArray;
/** 已过期 */
@property (nonatomic, strong) NSArray<ZFUplanModel *> *expiredArray;

@end

@implementation ZFMyCouponViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = GrayBgColor;
    
    // 初始化数据
    self.notuseArray = [[NSArray alloc] init];
    self.usedArray = [[NSArray alloc] init];
    self.expiredArray = [[NSArray alloc] init];
    
    [self setupTableView];
    
    // 只需要监听自己发出的，不需要监听所有对象发出的通知，否则会导致一个控制器发出，所有控制器都能监听,造成所有控制器请求数据
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadMyCouponData) name:YZDisplayViewClickOrScrollDidFinshNote object:self];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 加载数据
- (void)loadMyCouponData
{
    // 默认选中定位的国家
    if ([self.title isEqualToString:NSLocalizedString(@"未使用", nil)]) {
        if (self.notuseArray.count == 0)
            [self getUseTypeInfo:ZFCouponUseTypeNotUse];
    } else if ([self.title isEqualToString:NSLocalizedString(@"已使用", nil)]) {
        if (self.usedArray.count == 0)
            [self getUseTypeInfo:ZFCouponUseTypeUsed];
    } else {
        if (self.expiredArray.count == 0)
            [self getUseTypeInfo:ZFCouponUseTypeExpired];
    }
}

#pragma mark - 获取uplan信息
- (void)getUseTypeInfo:(ZFCouponUseType)useType
{
    self.useType = useType;
    NSDictionary *parameters = @{
                                 @"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"uplanStatus": [NSString stringWithFormat:@"%zd", useType],
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"txnType": @"66"};
    
    [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    
    [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
        [[MBUtils sharedInstance] dismissMB];
        
        _tableView.emptyDataSetSource = self;
        _tableView.emptyDataSetDelegate = self;
        
        if ([requestResult[@"status"] isEqualToString:@"0"]) {
            if (self.useType == ZFCouponUseTypeNotUse) // 未使用
            {
                self.notuseArray = [NSArray yy_modelArrayWithClass:[ZFUplanModel class] json:requestResult[@"UPlanList"]];
            } else if (self.useType == ZFCouponUseTypeUsed) // 已使用
            {
                self.usedArray = [NSArray yy_modelArrayWithClass:[ZFUplanModel class] json:requestResult[@"UPlanList"]];
            } else
            {
                self.expiredArray = [NSArray yy_modelArrayWithClass:[ZFUplanModel class] json:requestResult[@"UPlanList"]];
            }
            // 刷新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
        } else {
            [XLAlertController acWithMessage:requestResult[@"msg"] confirmBtnTitle:NSLocalizedString(@"好的", nil)];
            return ;
        }
        
    } failure:^(id error) {
        [[MBUtils sharedInstance] dismissMB];
    }];
    
}

- (void)setupTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH-20, SCREEN_HEIGHT-64-50) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 90;
    _tableView.backgroundColor = GrayBgColor;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_tableView];
}

#pragma mark table 代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.useType == ZFCouponUseTypeNotUse) // 未使用
    {
        return self.notuseArray.count;
    } else if (self.useType == ZFCouponUseTypeUsed) // 已使用
    {
        return self.usedArray.count;
    } else // 已过期
    {
        return self.expiredArray.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZFUplanModel *planModel;
    if (self.useType == ZFCouponUseTypeNotUse) // 未使用
    {
        planModel = self.notuseArray[indexPath.section];
    } else if (self.useType == ZFCouponUseTypeUsed) // 已使用
    {
        planModel = self.usedArray[indexPath.section];
    } else // 已过期
    {
        planModel = self.expiredArray[indexPath.section];
    }
    
    ZFMyCouponCell *cell = [ZFMyCouponCell cellWithTableView:tableView];
    cell.useType = self.useType;
    cell.uplanModel = planModel;
    cell.delegate = self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.useType != ZFCouponUseTypeNotUse) {
        DLog(@"不可点击");
        return ;
    }
    DLog(@"++%zd", indexPath.section);
    ZFUplanModel *planModel;
    if (self.useType == ZFCouponUseTypeNotUse) // 未使用
    {
        planModel = self.notuseArray[indexPath.section];
    } else if (self.useType == ZFCouponUseTypeUsed) // 已使用
    {
        planModel = self.usedArray[indexPath.section];
    } else // 已过期
    {
        planModel = self.expiredArray[indexPath.section];
    }
    
    NSLog(@"%zd", indexPath.section);
    DLog(@"%@", planModel.activityUrl);
    
    ZFUplanWebViewController *web = [[ZFUplanWebViewController alloc] initWithActivityUrl:planModel.activityUrl activityID:planModel.activityId myTitle:NSLocalizedString(@"优惠详情", nil)];
    [self pushViewController:web];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (self.useType == ZFCouponUseTypeNotUse)
    {
        if (section == self.notuseArray.count - 1) {
            return 10;
        }
    } else if (self.useType == ZFCouponUseTypeUsed)
    {
        if (section == self.usedArray.count - 1) {
            return 10;
        }
    } else // 澳门
    {
        if (section == self.expiredArray.count - 1) {
            return 10;
        }
    }
    return 0.00001;
}

#pragma mark - WJScrollerMenuDelegate
- (void)didClickuseBtn:(UIButton *)sender
{
    ZFMyCouponCell *cell = (ZFMyCouponCell *)sender.superview;
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    
    ZFUplanModel *planModel;
    if (self.useType == ZFCouponUseTypeNotUse) // 未使用
    {
        planModel = self.notuseArray[indexPath.section];
    } else if (self.useType == ZFCouponUseTypeUsed) // 已使用
    {
        planModel = self.usedArray[indexPath.section];
    } else // 已过期
    {
        planModel = self.expiredArray[indexPath.section];
    }
    
    NSLog(@"%zd", indexPath.section);
    DLog(@"%@", planModel.activityUrl);
    
    ZFUplanWebViewController *web = [[ZFUplanWebViewController alloc] initWithActivityUrl:planModel.activityUrl activityID:planModel.activityId myTitle:NSLocalizedString(@"优惠详情", nil)];
    [self pushViewController:web];
}


#pragma mark -- DZNEmptyDataSetSource
// 设置空白页展示图片
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView{
    return [UIImage imageNamed:@"pic_no_activity"];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView{
    NSString *text = NSLocalizedString(@"暂无优惠券", nil);
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:13.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return -100;
}

// 不影响刷新
- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView{
    return YES;
}


@end
