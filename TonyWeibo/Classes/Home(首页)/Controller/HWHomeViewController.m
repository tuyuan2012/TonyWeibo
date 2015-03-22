//
//  HWHomeViewController.m
//  黑马微博2期
//
//  Created by apple on 14-10-7.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "HWHomeViewController.h"
#import "HWDropdownMenu.h"
#import "HWTitleMenuViewController.h"
#import "HWHttpTool.h"
#import "HWAccountTool.h"
#import "HWTitleButton.h"
#import "UIImageView+WebCache.h"
#import "HWUser.h"
#import "HWStatus.h"
#import "MJExtension.h"
#import "HWLoadMoreFooter.h"
#import "HWStatusCell.h"
#import "HWStatusFrame.h"
#import "MJRefresh.h"

@interface HWHomeViewController () <HWDropdownMenuDelegate>
/**
 *  微博数组（里面放的都是HWStatusFrame模型，一个HWStatusFrame对象就代表一条微博）
 */
@property (nonatomic, strong) NSMutableArray *statusFrames;
@end

@implementation HWHomeViewController

- (NSMutableArray *)statusFrames
{
    if (!_statusFrames) {
        self.statusFrames = [NSMutableArray array];
    }
    return _statusFrames;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = HWColor(211, 211, 211);
//    self.tableView.contentInset = UIEdgeInsetsMake(HWStatusCellMargin, 0, 0, 0);
//    HWLog(@"viewDidLoad---%@", NSStringFromUIEdgeInsets(self.tableView.contentInset));
    
    // 设置导航栏内容
    [self setupNav];
    
    // 获得用户信息（昵称）
    [self setupUserInfo];
    
    // 集成下拉刷新控件
    [self setupDownRefresh];
    
    // 集成上拉刷新控件
    [self setupUpRefresh];
    
    // 获得未读数
//    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(setupUnreadCount) userInfo:nil repeats:YES];
//    // 主线程也会抽时间处理一下timer（不管主线程是否正在其他事件）
//    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    HWLog(@"viewDidAppear---%@", NSStringFromUIEdgeInsets(self.tableView.contentInset));
}

/**
 *  获得未读数
 */
- (void)setupUnreadCount
{
    // 1.拼接请求参数
    HWAccount *account = [HWAccountTool account];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = account.access_token;
    params[@"uid"] = account.uid;
    
    // 2.发送请求
    [HWHttpTool get:@"https://rm.api.weibo.com/2/remind/unread_count.json" params:params success:^(id json) {
        // 设置提醒数字(微博的未读数)
        NSString *status = [json[@"status"] description];
        if ([status isEqualToString:@"0"]) { // 如果是0，得清空数字
            self.tabBarItem.badgeValue = nil;
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        } else { // 非0情况
            self.tabBarItem.badgeValue = status;
            [UIApplication sharedApplication].applicationIconBadgeNumber = status.intValue;
        }
    } failure:^(NSError *error) {
        HWLog(@"请求失败-%@", error);
    }];
}

/**
 *  集成上拉刷新控件
 */
- (void)setupUpRefresh
{
//    [self.tableView addFooterWithCallback:^{
//        HWLog(@"进入上拉刷新状态");
//    }];
    [self.tableView addFooterWithTarget:self action:@selector(loadMoreStatus)];
}

/**
 *  集成下拉刷新控件
 */
- (void)setupDownRefresh
{
    // 1.添加刷新控件
    [self.tableView addHeaderWithTarget:self action:@selector(loadNewStatus)];
    
    // 2.进入刷新状态
    [self.tableView headerBeginRefreshing];
}

/**
 *  将HWStatus模型转为HWStatusFrame模型
 */
- (NSArray *)stausFramesWithStatuses:(NSArray *)statuses
{
    NSMutableArray *frames = [NSMutableArray array];
    for (HWStatus *status in statuses) {
        HWStatusFrame *f = [[HWStatusFrame alloc] init];
        f.status = status;
        [frames addObject:f];
    }
    return frames;
}

/**
 *  UIRefreshControl进入刷新状态：加载最新的数据
 */
- (void)loadNewStatus
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSDictionary *responseObject = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fakeStatus" ofType:@"plist"]];
        // 将 "微博字典"数组 转为 "微博模型"数组
        NSArray *newStatuses = [HWStatus objectArrayWithKeyValuesArray:responseObject[@"statuses"]];
        
        // 将 HWStatus数组 转为 HWStatusFrame数组
        NSArray *newFrames = [self stausFramesWithStatuses:newStatuses];
        
        // 将最新的微博数据，添加到总数组的最前面
        NSRange range = NSMakeRange(0, newFrames.count);
        NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.statusFrames insertObjects:newFrames atIndexes:set];
        
        // 刷新表格
        [self.tableView reloadData];
        
        // 结束刷新
        [self.tableView headerEndRefreshing];
        
        // 显示最新微博的数量
        [self showNewStatusCount:newStatuses.count];
    });
    
    return;
    
    // 1.拼接请求参数
    HWAccount *account = [HWAccountTool account];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = account.access_token;
    
    // 取出最前面的微博（最新的微博，ID最大的微博）
    HWStatusFrame *firstStatusF = [self.statusFrames firstObject];
    if (firstStatusF) {
        // 若指定此参数，则返回ID比since_id大的微博（即比since_id时间晚的微博），默认为0
        params[@"since_id"] = firstStatusF.status.idstr;
    }
    
    // 2.发送请求
    [HWHttpTool get:@"https://api.weibo.com/2/statuses/friends_timeline.json" params:params success:^(id json) {
        // 将 "微博字典"数组 转为 "微博模型"数组
        NSArray *newStatuses = [HWStatus objectArrayWithKeyValuesArray:json[@"statuses"]];
        
        // 将 HWStatus数组 转为 HWStatusFrame数组
        NSArray *newFrames = [self stausFramesWithStatuses:newStatuses];
        
        // 将最新的微博数据，添加到总数组的最前面
        NSRange range = NSMakeRange(0, newFrames.count);
        NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.statusFrames insertObjects:newFrames atIndexes:set];
        
        // 刷新表格
        [self.tableView reloadData];
        
        // 结束刷新
        [self.tableView headerEndRefreshing];
        
        // 显示最新微博的数量
        [self showNewStatusCount:newStatuses.count];
    } failure:^(NSError *error) {
        HWLog(@"请求失败-%@", error);
        
        // 结束刷新刷新
        [self.tableView headerEndRefreshing];
    }];
}

/**
 *  加载更多的微博数据
 */
- (void)loadMoreStatus
{
    // 1.拼接请求参数
    HWAccount *account = [HWAccountTool account];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = account.access_token;
    
    // 取出最后面的微博（最新的微博，ID最大的微博）
    HWStatusFrame *lastStatusF = [self.statusFrames lastObject];
    if (lastStatusF) {
        // 若指定此参数，则返回ID小于或等于max_id的微博，默认为0。
        // id这种数据一般都是比较大的，一般转成整数的话，最好是long long类型
        long long maxId = lastStatusF.status.idstr.longLongValue - 1;
        params[@"max_id"] = @(maxId);
    }
    
    // 2.发送请求
    [HWHttpTool get:@"https://api.weibo.com/2/statuses/friends_timeline.json" params:params success:^(id json) {
        // 将 "微博字典"数组 转为 "微博模型"数组
        NSArray *newStatuses = [HWStatus objectArrayWithKeyValuesArray:json[@"statuses"]];
        
        // 将 HWStatus数组 转为 HWStatusFrame数组
        NSArray *newFrames = [self stausFramesWithStatuses:newStatuses];
        
        // 将更多的微博数据，添加到总数组的最后面
        [self.statusFrames addObjectsFromArray:newFrames];
        
        // 刷新表格
        [self.tableView reloadData];
        
        // 结束刷新(隐藏footer)
        [self.tableView footerEndRefreshing];
    } failure:^(NSError *error) {
        HWLog(@"请求失败-%@", error);
        
        // 结束刷新
        [self.tableView footerEndRefreshing];
    }];
}

/**
 *  显示最新微博的数量
 *
 *  @param count 最新微博的数量
 */
- (void)showNewStatusCount:(NSUInteger)count
{
    // 刷新成功(清空图标数字)
    self.tabBarItem.badgeValue = nil;
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    // 1.创建label
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"timeline_new_status_background"]];
    label.width = [UIScreen mainScreen].bounds.size.width;
    label.height = 35;
    
    // 2.设置其他属性
    if (count == 0) {
        label.text = @"没有新的微博数据，稍后再试";
    } else {
        label.text = [NSString stringWithFormat:@"共有%zd条新的微博数据", count];
    }
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:16];
    
    // 3.添加
    label.y = 64 - label.height;
    // 将label添加到导航控制器的view中，并且是盖在导航栏下边
    [self.navigationController.view insertSubview:label belowSubview:self.navigationController.navigationBar];
    
    // 4.动画
    // 先利用1s的时间，让label往下移动一段距离
    CGFloat duration = 1.0; // 动画的时间
    [UIView animateWithDuration:duration animations:^{
        label.transform = CGAffineTransformMakeTranslation(0, label.height);
    } completion:^(BOOL finished) {
        // 延迟1s后，再利用1s的时间，让label往上移动一段距离（回到一开始的状态）
        CGFloat delay = 1.0; // 延迟1s
        // UIViewAnimationOptionCurveLinear:匀速
        [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveLinear animations:^{
            label.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [label removeFromSuperview];
        }];
    }];
    
    // 如果某个动画执行完毕后，又要回到动画执行前的状态，建议使用transform来做动画
}

/**
 *  获得用户信息（昵称）
 */
- (void)setupUserInfo
{
    // 1.拼接请求参数
    HWAccount *account = [HWAccountTool account];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = account.access_token;
    params[@"uid"] = account.uid;
    
    // 2.发送请求
    [HWHttpTool get:@"https://api.weibo.com/2/users/show.json" params:params success:^(id json) {
        // 标题按钮
        UIButton *titleButton = (UIButton *)self.navigationItem.titleView;
        // 设置名字
        HWUser *user = [HWUser objectWithKeyValues:json];
        [titleButton setTitle:user.name forState:UIControlStateNormal];
        
        // 存储昵称到沙盒中
        account.name = user.name;
        [HWAccountTool saveAccount:account];
    } failure:^(NSError *error) {
        HWLog(@"请求失败-%@", error);
    }];
}

/**
 *  设置导航栏内容
 */
- (void)setupNav
{
    /* 设置导航栏上面的内容 */
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(friendSearch) image:@"navigationbar_friendsearch" highImage:@"navigationbar_friendsearch_highlighted"];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(pop) image:@"navigationbar_pop" highImage:@"navigationbar_pop_highlighted"];
    
    /* 中间的标题按钮 */
    HWTitleButton *titleButton = [[HWTitleButton alloc] init];
    // 设置图片和文字
    NSString *name = [HWAccountTool account].name;
    [titleButton setTitle:name?name:@"首页" forState:UIControlStateNormal];
    // 监听标题点击
    [titleButton addTarget:self action:@selector(titleClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = titleButton;
}

/**
 *  标题点击
 */
- (void)titleClick:(UIButton *)titleButton
{
    // 1.创建下拉菜单
    HWDropdownMenu *menu = [HWDropdownMenu menu];
    menu.delegate = self;
    
    // 2.设置内容
    HWTitleMenuViewController *vc = [[HWTitleMenuViewController alloc] init];
    vc.view.height = 150;
    vc.view.width = 150;
    menu.contentController = vc;
    
    // 3.显示
    [menu showFrom:titleButton];
}

- (void)friendSearch
{
    NSLog(@"friendSearch");
}

- (void)pop
{
    NSLog(@"pop");
}

#pragma mark - HWDropdownMenuDelegate
/**
 *  下拉菜单被销毁了
 */
- (void)dropdownMenuDidDismiss:(HWDropdownMenu *)menu
{
    UIButton *titleButton = (UIButton *)self.navigationItem.titleView;
    // 让箭头向下
    titleButton.selected = NO;
}

/**
 *  下拉菜单显示了
 */
- (void)dropdownMenuDidShow:(HWDropdownMenu *)menu
{
    UIButton *titleButton = (UIButton *)self.navigationItem.titleView;
    // 让箭头向上
    titleButton.selected = YES;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.statusFrames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 获得cell
    HWStatusCell *cell = [HWStatusCell cellWithTableView:tableView];
    
    // 给cell传递模型数据
    cell.statusFrame = self.statusFrames[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HWStatusFrame *frame = self.statusFrames[indexPath.row];
    return frame.cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HWLog(@"didSelectRowAtIndexPath---%d", indexPath.row);
}
@end
