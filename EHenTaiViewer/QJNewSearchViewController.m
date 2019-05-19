//
//  QJNewSearchViewController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2019/3/26.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import "QJNewSearchViewController.h"
#import "QJListTableView.h"
#import "QJListCell.h"
#import "QJSearchSiftHeadView.h"
#import "QJSearchSettingViewController.h"
#import "QJHenTaiParser.h"
#import "QJNewInfoViewController.h"
#import "QJSearchController.h"

@interface QJNewSearchViewController ()<UITableViewDelegate, UITableViewDataSource, QJSearchSiftHeadViewDelegate, QJSearchSettingViewControllerDelegate, UISearchBarDelegate>

@property (strong, nonatomic) QJSearchSiftHeadView *headView;
@property (strong, nonatomic) QJListTableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refrshControl;
@property (assign, nonatomic) QJFreshStatus status;
@property (assign, nonatomic) NSInteger pageIndex; // 页面
@property (strong, nonatomic) NSMutableArray<QJListItem *> *datas;
@property (assign, nonatomic) BOOL isFrist;
// 搜索参数
@property (strong, nonatomic) NSArray *normalDatas; // 常规搜索参数key存储

@end

@implementation QJNewSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.type == QJNewSearchViewControllerTypeTag && self.isFrist) {
        self.isFrist = NO;
        self.headView.keys = self.settings;
        [self refreshDatas];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // 防止未请求完就退出,导致下次无法在刷新
    [self stopSomethingCommon];
}

- (void)stopSomethingCommon {
    if ([self.refrshControl isRefreshing]) {
        [self.refrshControl endRefreshing];
    }
    [self hiddenFreshingView];
}

#pragma mark - Init UI
- (void)setupUI {
    self.searchKey = @"";
    self.status = QJFreshStatusNone;
    self.isFrist = YES;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.view);
    }];
}

#pragma mark - Update Datas
// 下拉刷新,重新请求的时候调用
- (void)refreshDatas {
    self.pageIndex = 0;
    [self showFreshingViewWithTip:nil];
    [self updateSearchDatas];
}

- (void)refreshDatasWithoutAnimate {
    self.pageIndex = 0;
    [self updateSearchDatas];
}

- (void)updateSearchDatas {
    if (self.type == QJNewSearchViewControllerTypeSearch || self.type == QJNewSearchViewControllerTypeWatched || self.type == QJNewSearchViewControllerTypeTag) {
        [self updateNormalSearchDatas];
    }
    else if(self.type == QJNewSearchViewControllerTypeFavorites) {
        [self updateFavoritesSearchDatas];
    }
}

// 收藏搜索
- (void)updateFavoritesSearchDatas {
    [[QJHenTaiParser parser] updateLikeListInfoWithUrl:[self getLikeUrl] complete:^(QJHenTaiParserStatus status, NSArray<QJListItem *> *listArray) {
        [self getDatasWithStatus:status listArray:listArray];
    }];
}

- (NSString *)getLikeUrl {
    NSMutableString *url = [NSMutableString stringWithString:@"favorites.php"];
    // 添加搜索项
    // 默认做全局搜索,并且不区分收藏文件夹,否则逻辑就很复杂了
    [url appendFormat:@"?favcat=all&f_search=%@&sn=on&st=on&sf=on", [self.searchKey urlEncode]];
    //添加页码
    if (self.pageIndex > 0) {
        [url appendFormat:@"&page=%ld", self.pageIndex];
    }
    return url;
}

// 普通搜索
- (void)updateNormalSearchDatas {
    NSString *url = [self makeUrl];
    // 开始请求数据
    [[QJHenTaiParser parser] updateListInfoWithUrl:url complete:^(QJHenTaiParserStatus status, NSArray<QJListItem *> *listArray) {
        [self getDatasWithStatus:status listArray:listArray];
    } total:nil];
}

- (NSString *)makeUrl {
    NSMutableString *url = [NSMutableString stringWithString:self.type == QJNewSearchViewControllerTypeWatched ? @"watched?" : @"?"];
    // 先添加筛选项
    NSArray *normalStatus = [QJGlobalInfo getExHentaiSearchSettingArr];
    NSMutableArray *params = [NSMutableArray new];
    for (NSInteger i = 0; i < self.normalDatas.count; i++) {
        NSString *key = self.normalDatas[i];
        BOOL isSelected = [normalStatus[i] boolValue];
        if (i < 10) {
            // 类别
            [params addObject:[NSString stringWithFormat:@"%@=%@", key, isSelected ? @"1" : @"0"]];
        } else {
            // 其他项设置
            if (isSelected) {
                [params addObject:[NSString stringWithFormat:@"%@=on", key]];
                if ([key isEqualToString:@"f_sr"]) {
                    [params addObject:[NSString stringWithFormat:@"f_srdd=%ld", [QJGlobalInfo getExHentaiSmallStar]]];
                }
            }
        }
    }
    [url appendString:[params componentsJoinedByString:@"&"]];
    // 添加搜索项
    // 将高级筛选添加上
    NSMutableString *settingString = [NSMutableString new];
    for (NSString *string in self.settings) {
        NSArray *array = [string componentsSeparatedByString:@"-"];
        [settingString appendFormat:@"%@:\"%@\" ", array.firstObject, array.lastObject];
    }
    [settingString appendString:self.searchKey];
    [url appendFormat:@"&f_search=%@",[settingString urlEncode]];
    //添加页码
    if (self.pageIndex > 0) {
        [url appendFormat:@"&page=%ld", self.pageIndex];
    }
    return url.copy;
}

- (void)getDatasWithStatus:(QJHenTaiParserStatus)status listArray:(NSArray<QJListItem *> *)listArray {
    if ([self.refrshControl isRefreshing]) {
        [self.datas removeAllObjects];
    }
    if (status == QJHenTaiParserStatusSuccess) {
        [self.datas addObjectsFromArray:listArray];
    }
    [self.tableView reloadData];
    self.status = listArray.count ? QJFreshStatusNone : QJFreshStatusNotMore;
    [self stopSomethingCommon];
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat current = scrollView.contentOffset.y + scrollView.frame.size.height;
    CGFloat total = scrollView.contentSize.height;
    CGFloat ratio = current / total;
    
    CGFloat needRead = 25 * 0.7 + self.pageIndex * 25;
    CGFloat totalItem = 25 * (self.pageIndex + 1);
    CGFloat newThreshold = needRead / totalItem;
    
    if (self.datas.count && ratio >= newThreshold && self.status == QJFreshStatusNone) {
        self.status = QJFreshStatusMore;
        self.pageIndex++;
        NSLog(@"Request page %ld from server.",self.pageIndex);
        [self updateSearchDatas];
    }
}

#pragma mark - View Method
- (void)viewsShouldSearchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (self.type == QJNewSearchViewControllerTypeTag) {
        if (searchBar.text.length == 0 && self.settings.count == 0) {
            Toast(@"搜索关键词和高级筛选不能全为空");
            return;
        }
    }
    else if (self.type == QJNewSearchViewControllerTypeFavorites) {
        if (![[QJHenTaiParser parser] checkCookie]) {
            Toast(@"请先前往设置页面进行登录");
            return;
        }
    }
    
    self.searchKey = searchBar.text;
    [self refreshDatas];
}

- (void)viewsShouldSearchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
    QJSearchSettingViewController *vc = [QJSearchSettingViewController new];
    vc.delegate = self;
    vc.settings = self.settings;
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:navVC animated:YES completion:nil];
}

#pragma mark - QJSearchSettingViewControllerDelegate
- (void)settingController:(QJSearchSettingViewController *)settingController changeSiftSettingWithArr:(NSArray *)settings {
    [self.settings removeAllObjects];
    [self.settings addObjectsFromArray:settings];
    self.headView.keys = self.settings;
    [self.tableView reloadData];
}

#pragma mark - QJSearchSiftHeadViewDelegate
- (void)didClickTagActionWithHeadView:(QJSearchSiftHeadView *)headView index:(NSInteger)index {
    // 删除对应的数据
    [self.settings removeObjectAtIndex:index];
    self.headView.keys = self.settings;
    [self.tableView reloadData];
}

#pragma mark - tableview delegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    // 直接不显示
    if (self.type == QJNewSearchViewControllerTypeTag) {
        return 0;
    }
    return self.headView.keys.count ? 40.f : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QJListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(QJListCell.class)];
    [cell refreshUI:self.datas[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QJNewInfoViewController *vc = [QJNewInfoViewController new];
    vc.model = self.datas[indexPath.row];
    if (self.type == QJNewSearchViewControllerTypeTag) {
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [self.nav pushViewController:vc animated:YES];
    }
}

#pragma mark - Getter
- (QJSearchSiftHeadView *)headView {
    if (nil == _headView) {
        _headView = [[QJSearchSiftHeadView alloc] initWithKeys:@[] theDelegate:self];
        _headView.frame = CGRectMake(0, 0, UIScreenWidth(), 40.f);
    }
    return _headView;
}

- (QJListTableView *)tableView {
    if (nil == _tableView) {
        _tableView = [QJListTableView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.refreshControl = self.refrshControl;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    return _tableView;
}

- (NSMutableArray<QJListItem *> *)datas {
    if (nil == _datas) {
        _datas = [NSMutableArray new];
    }
    return _datas;
}

- (NSMutableArray *)settings {
    if (nil == _settings) {
        _settings = [NSMutableArray new];
    }
    return _settings;
}

- (NSArray *)normalDatas {
    if (nil == _normalDatas) {
        _normalDatas = @[@"f_doujinshi",
                         @"f_manga",
                         @"f_artistcg",
                         @"f_gamecg",
                         @"f_western",
                         @"f_non-h",
                         @"f_imageset",
                         @"f_cosplay",
                         @"f_asianporn",
                         @"f_misc",
                         @"f_sname",
                         @"f_stags",
                         @"f_sdesc",
                         @"f_storr",
                         @"f_sto",
                         @"f_sdt1",
                         @"f_sdt2",
                         @"f_sh",
                         @"f_sr",];
    }
    return _normalDatas;
}

- (UIRefreshControl *)refrshControl {
    if (nil == _refrshControl) {
        _refrshControl = [UIRefreshControl new];
        [_refrshControl addTarget:self action:@selector(refreshDatasWithoutAnimate) forControlEvents:UIControlEventValueChanged];
    }
    return _refrshControl;
}

@end
