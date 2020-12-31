//
//  ZFUplanController.m
//  newupop
//
//  Created by 中付支付 on 2017/11/1.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFUplanController.h"
#import "ZFUplanWebViewController.h"
#import "UIScrollView+EmptyDataSet.h"
#import "ZFUplanModel.h"
#import "ZFUPlanTableViewCell.h"
#import "YYModel.h"
#import "LocationUtils.h"
#import "YZDisplayViewHeader.h"
#import "MJRefresh.h"

#define ShowPageSize 10

@interface ZFUplanController () <UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, strong)UITableView *tableView;
/** 当前国家 */
@property(nonatomic, assign) UPlanCountryType currentCountry;
/** 新加坡 */
@property (nonatomic, strong) NSMutableArray<ZFUplanModel *> *sgArray;
/** 马来西亚 */
@property (nonatomic, strong) NSMutableArray<ZFUplanModel *> *malaArray;
/** 香港 */
@property (nonatomic, strong) NSMutableArray<ZFUplanModel *> *hkArray;
/** 澳门 */
@property (nonatomic, strong) NSMutableArray<ZFUplanModel *> *macaoArray;

/** 新加坡当前页数 */
@property(nonatomic, assign) NSInteger sgCurrentPage;
/** 马来西亚当前页数 */
@property (nonatomic, assign) NSInteger malaCurrentPage;
/** 香港当前页数 */
@property (nonatomic, assign) NSInteger hkCurrentPage;
/** 澳门当前页数 */
@property (nonatomic, assign) NSInteger macaoCurrentPage;

/** bug */
@property(nonatomic, assign) NSInteger index;
@end

@implementation ZFUplanController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = GrayBgColor;
    
    // 初始化数据
    self.sgArray = [[NSMutableArray alloc] init];
    self.malaArray = [[NSMutableArray alloc] init];
    self.hkArray = [[NSMutableArray alloc] init];
    self.macaoArray = [[NSMutableArray alloc] init];
    
    self.sgCurrentPage = 1;
    self.malaCurrentPage = 1;
    self.hkCurrentPage = 1;
    self.macaoCurrentPage = 1;
    
    [self setupTableView];
    
    // 只需要监听自己发出的，不需要监听所有对象发出的通知，否则会导致一个控制器发出，所有控制器都能监听,造成所有控制器请求数据
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadUplanData) name:YZDisplayViewClickOrScrollDidFinshNote object:self];
    self.index = 0;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - 加载数据
- (void)loadUplanData
{
    // 默认选中定位的国家
    NSString *country = [LocationUtils sharedInstance].ISOCountryCode;
    DLog(@"%@", country);
    if ([self.title isEqualToString:NSLocalizedString(@"新加坡", nil)]) {
        if (self.sgArray.count == 0)
            [self getUplanInfoWithCurrentCountryType:UPlanCountryTypeSG country:@"SG" currentPage:self.sgCurrentPage];
    } else if ([self.title isEqualToString:NSLocalizedString(@"马来西亚", nil)]) {
        if (self.malaArray.count == 0)
            [self getUplanInfoWithCurrentCountryType:UPlanCountryTypeMala country:@"MY" currentPage:self.malaCurrentPage];
    } else if ([self.title isEqualToString:NSLocalizedString(@"香港", nil)]) {
        if (self.hkArray.count == 0)
            [self getUplanInfoWithCurrentCountryType:UPlanCountryTypeHK country:@"HK" currentPage:self.hkCurrentPage];
    } else if ([self.title isEqualToString:NSLocalizedString(@"澳门", nil)]) {
        if (self.macaoArray.count == 0)
            [self getUplanInfoWithCurrentCountryType:UPlanCountryTypeMacao country:@"US" currentPage:self.macaoCurrentPage];
    } else {
        if (self.sgArray.count == 0)
            [self getUplanInfoWithCurrentCountryType:UPlanCountryTypeSG country:@"SG" currentPage:self.sgCurrentPage];
    }
}
#pragma mark - 初始化视图
- (void)setupTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64-50-44-2) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 90;
    _tableView.backgroundColor = GrayBgColor;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    [self setRefereshHead];
    [self setupRefresh];
}

#pragma mark - 获取uplan信息
- (void)getUplanInfoWithCurrentCountryType:(UPlanCountryType)countryType country:(NSString *)country currentPage:(NSInteger)page
{
    self.currentCountry = countryType;
    self.index += 1;
    NSDictionary *parameters = @{@"countryCode": [ZFGlobleManager getGlobleManager].areaNum,
                                 @"mobile": [ZFGlobleManager getGlobleManager].userPhone,
                                 @"sysareaID": [country uppercaseString],
                                 @"size": [NSString stringWithFormat:@"%zd", ShowPageSize],
                                 @"currentPage": [NSString stringWithFormat:@"%zd", page],
                                 @"sessionID": [ZFGlobleManager getGlobleManager].sessionID,
                                 @"txnType": @"65"};
    
    if (page == 1) {
        [[MBUtils sharedInstance] showMBWithText:NetRequestText inView:self.view];
    }
    
    if (self.index == 1) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [NetworkEngine singlePostWithParmas:parameters success:^(id requestResult) {
                [[MBUtils sharedInstance] dismissMB];
                
                _tableView.emptyDataSetSource = self;
                _tableView.emptyDataSetDelegate = self;
                
                if ([requestResult[@"status"] isEqualToString:@"0"]) {
                    // 临时数组, 刷新出来的数据
                    NSArray *tempArray = [NSArray yy_modelArrayWithClass:[ZFUplanModel class] json:requestResult[@"UPlanList"]];
                    
                    if (self.currentCountry == UPlanCountryTypeSG) // 新加坡
                    {
                        // 添加到显示的数据源中
                        [self.sgArray addObjectsFromArray:tempArray];
                    } else if (self.currentCountry == UPlanCountryTypeMala) // 马来西亚
                    {
                        [self.malaArray addObjectsFromArray:tempArray];
                    } else if (self.currentCountry == UPlanCountryTypeHK) // 香港
                    {
                        [self.hkArray addObjectsFromArray:tempArray];
                    } else // 澳门
                    {
                        [self.macaoArray addObjectsFromArray:tempArray];
                    }
                    
                    // 统一结束刷新
                    [self.tableView.mj_header endRefreshing];
                    [self.tableView.mj_footer endRefreshing];
                    
                    // 如果临时数组的数据不够显示的数据,说明没有数据了
                    if (tempArray.count < ShowPageSize) {
                        // 没有更多的数据了
                        [self.tableView.mj_footer endRefreshingWithNoMoreData];
                    } else {
                        [self.tableView.mj_footer setHidden:NO];
                    }
                    // 刷新UI
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                        self.index = 0;
                    });
                } else {
                    [XLAlertController acWithMessage:requestResult[@"msg"] confirmBtnTitle:NSLocalizedString(@"好的", nil)];
                    return ;
                }
                
            } failure:^(id error) {
                //结束刷新
                [self.tableView.mj_header endRefreshing];
                [self.tableView.mj_footer endRefreshing];
                [[MBUtils sharedInstance] dismissMB];
                // 刷新UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    self.index = 0;
                });
            }];
        });
    }

}

#pragma mark table 代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.currentCountry == UPlanCountryTypeSG) // 新加坡
    {
        return self.sgArray.count;
    } else if (self.currentCountry == UPlanCountryTypeMala) // 马来西亚
    {
        return self.malaArray.count;
    } else if (self.currentCountry == UPlanCountryTypeHK) // 香港
    {
        return self.hkArray.count;
    } else // 澳门
    {
        return self.macaoArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZFUplanModel *planModel;
    if (self.currentCountry == UPlanCountryTypeSG) // 新加坡
    {
        planModel = self.sgArray[indexPath.section];
    } else if (self.currentCountry == UPlanCountryTypeMala) // 马来西亚
    {
        planModel = self.malaArray[indexPath.section];
    } else if (self.currentCountry == UPlanCountryTypeHK) // 香港
    {
        planModel = self.hkArray[indexPath.section];
    } else // 澳门
    {
        planModel = self.macaoArray[indexPath.section];
    }
    
    ZFUPlanTableViewCell *cell = [[ZFUPlanTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"uplanCell"];
    cell.uplanModel = planModel;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZFUplanModel *planModel;
    if (self.currentCountry == UPlanCountryTypeSG) // 新加坡
    {
        planModel = self.sgArray[indexPath.section];
    } else if (self.currentCountry == UPlanCountryTypeMala) // 马来西亚
    {
        planModel = self.malaArray[indexPath.section];
    } else if (self.currentCountry == UPlanCountryTypeHK) // 香港
    {
        planModel = self.hkArray[indexPath.section];
    } else // 澳门
    {
        planModel = self.macaoArray[indexPath.section];
    }
    
    ZFUplanWebViewController *web = [[ZFUplanWebViewController alloc] initWithActivityUrl:planModel.activityUrl activityID:planModel.activityId myTitle:NSLocalizedString(@"优计划详情", nil)];
    [self pushViewController:web];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.00001;
}

#pragma mark -- DZNEmptyDataSetSource
// 设置空白页展示图片
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView{
    return [UIImage imageNamed:@"pic_no_activity"];
}
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView{
    NSString *text = NSLocalizedString(@"暂无优惠活动", nil);
    
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

/** 下拉刷新 */
-(void)setRefereshHead {
    // 头部刷新,设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewStatus方法）
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self refereshData];
    }];
    [header setTitle:NSLocalizedString(@"下拉刷新数据", nil) forState:MJRefreshStateIdle];
    [header setTitle:NSLocalizedString(@"松开立即刷新", nil) forState:MJRefreshStatePulling];
    [header setTitle:NSLocalizedString(@"正在加载", nil) forState:MJRefreshStateRefreshing];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.font = [UIFont systemFontOfSize:13.0];
    [header isAutomaticallyChangeAlpha];
    self.tableView.mj_header = header;
//    [self.tableView.mj_header beginRefreshing];
}
/** 下拉刷新 */
- (void)refereshData{
    if ([self.title isEqualToString:NSLocalizedString(@"新加坡", nil)]) {
        self.sgCurrentPage = 1;
        [self.sgArray removeAllObjects];
        [self getUplanInfoWithCurrentCountryType:UPlanCountryTypeSG country:@"SG" currentPage:self.sgCurrentPage];
    } else if ([self.title isEqualToString:NSLocalizedString(@"马来西亚", nil)]) {
        self.malaCurrentPage = 1;
        [self.malaArray removeAllObjects];
        [self getUplanInfoWithCurrentCountryType:UPlanCountryTypeMala country:@"MY" currentPage:self.malaCurrentPage];
    } else if ([self.title isEqualToString:NSLocalizedString(@"香港", nil)]) {
        self.hkCurrentPage = 1;
        [self.hkArray removeAllObjects];
        [self getUplanInfoWithCurrentCountryType:UPlanCountryTypeHK country:@"HK" currentPage:self.hkCurrentPage];
    } else if ([self.title isEqualToString:NSLocalizedString(@"澳门", nil)]) {
        self.macaoCurrentPage = 1;
        [self.macaoArray removeAllObjects];
        [self getUplanInfoWithCurrentCountryType:UPlanCountryTypeMacao country:@"US" currentPage:self.macaoCurrentPage];
    } else {
        self.sgCurrentPage = 1;
        [self.sgArray removeAllObjects];
        [self getUplanInfoWithCurrentCountryType:UPlanCountryTypeSG country:@"SG" currentPage:self.sgCurrentPage];
    }
}

#pragma mark -- 其他方法
/** 添加刷新控件 */
-(void)setupRefresh {
    // 头部刷新,设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewStatus方法）
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self loadMoreData];
    }];
    [footer setTitle:NSLocalizedString(@"点击或上拉加载更多", nil) forState:MJRefreshStateIdle];
    [footer setTitle:NSLocalizedString(@"正在加载更多数据...", nil) forState:MJRefreshStateRefreshing];
    [footer setTitle:NSLocalizedString(@"没有更多数据", nil) forState:MJRefreshStateNoMoreData];
    footer.stateLabel.font = [UIFont systemFontOfSize:13.0];
    footer.automaticallyHidden = NO;
    self.tableView.mj_footer = footer;
    // 开始隐藏
    [self.tableView.mj_footer setHidden:YES];
}

/** 上拉加载 */
- (void)loadMoreData {
    if ([self.title isEqualToString:NSLocalizedString(@"新加坡", nil)]) {
        [self getUplanInfoWithCurrentCountryType:UPlanCountryTypeSG country:@"SG" currentPage:++self.sgCurrentPage];
    } else if ([self.title isEqualToString:NSLocalizedString(@"马来西亚", nil)]) {
        [self getUplanInfoWithCurrentCountryType:UPlanCountryTypeMala country:@"MY" currentPage:++self.malaCurrentPage];
    } else if ([self.title isEqualToString:NSLocalizedString(@"香港", nil)]) {
        [self getUplanInfoWithCurrentCountryType:UPlanCountryTypeHK country:@"HK" currentPage:++self.hkCurrentPage];
    } else if ([self.title isEqualToString:NSLocalizedString(@"澳门", nil)]) {
        [self getUplanInfoWithCurrentCountryType:UPlanCountryTypeMacao country:@"US" currentPage:++self.macaoCurrentPage];
    } else {
        [self getUplanInfoWithCurrentCountryType:UPlanCountryTypeSG country:@"SG" currentPage:++self.sgCurrentPage];
    }
}

@end
