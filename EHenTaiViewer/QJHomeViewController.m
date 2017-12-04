//
//  QJHomeViewController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/18.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJHomeViewController.h"
#import "QJHenTaiParser.h"
#import "QJListCell.h"
#import "QJEnum.h"
#import "QJListTableView.h"
#import "QJTouchIDViewController.h"
#import "NSString+StringHeight.h"
//详情页
#import "QJNewInfoViewController.h"

@interface QJHomeViewController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
//搜索相关
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *otherStates;
@property (nonatomic, strong) NSArray<NSString *> *classifyArr;
@property (nonatomic, strong) NSDictionary *searchKeyDict;
//列表
@property (nonatomic, strong) QJListTableView *tableView;
@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, assign) float oldOffsetY;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, assign) QJFreshStatus status;
//刷新提示文字
@property (nonatomic, strong) UIRefreshControl *refrshControl;
@property (nonatomic, assign) BOOL isShowThumbImage;//是否呈现启动动画

@end

@implementation QJHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initInfo];
    [self setContent];
    //第一次加载
    [self showFreshingViewWithTip:nil];
    [self updateResource];
}

- (void)readyUpdateResource {
    self.status = QJFreshStatusRefresh;
    self.pageIndex = 0;
    [self updateResource];
}

#pragma mark -更新数据
- (void)updateResource {
    NSString *url = [self makeUrl];
    [[QJHenTaiParser parser] updateListInfoWithUrl:url complete:^(QJHenTaiParserStatus status, NSArray *listArray) {
        
        if (self.status == QJFreshStatusRefresh) {
            [self.datas removeAllObjects];
        }
        self.status = QJFreshStatusNone;
        
        if (status == QJHenTaiParserStatusSuccess) {
            [self.datas addObjectsFromArray:listArray];
            [self.tableView reloadData];
        }
        else if (status == QJHenTaiParserStatusNetworkFail || status == QJHenTaiParserStatusParseFail) {
            self.pageIndex--;
        }
        else if (status == QJHenTaiParserStatusParseNoMore) {
            self.status = QJFreshStatusNotMore;
            self.pageIndex--;
        }
        [self.refrshControl endRefreshing];
        if ([self isShowFreshingStatus]) {
            [self hiddenFreshingView];
        }
    }];
}

//首页接收来自网页设置的影响,不再需要手动修改各个搜索选项
- (NSString *)makeUrl {
    NSString *url = @"";
    if (self.pageIndex) {
        url = [NSString stringWithFormat:@"?page=%ld", self.pageIndex];
    }
    return url;
}

#pragma mark -初始化
- (void)initInfo {
    self.isShowThumbImage = YES;
}

#pragma mark -设置内容
- (void)setContent {
    [self.view addSubview:self.tableView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = [NSObjForKey(@"ExHentaiStatus") boolValue] ? @"exhentai" : @"e-hentai";
}

#pragma mark -tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QJListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QJListCell class])];
    [cell refreshUI:self.datas[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QJNewInfoViewController *vc = [QJNewInfoViewController new];
    vc.hidesBottomBarWhenPushed = YES;
    vc.model = self.datas[indexPath.row];
    vc.preferredContentSize = CGSizeMake(150, 150);
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //预加载
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
        [self updateResource];
    }
}

#pragma mark -getter
- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth(), UISearchBarHeight())];
        _searchBar.searchBarStyle = UISearchBarStyleMinimal;
        _searchBar.showsSearchResultsButton = YES;
        _searchBar.delegate = self;
        _searchBar.placeholder = @"请输入搜索关键词";
        _searchBar.enablesReturnKeyAutomatically = NO;
    }
    return _searchBar;
}

- (QJListTableView *)tableView {
    if (!_tableView) {
        _tableView = [QJListTableView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        //添加刷新模块
        [_tableView addSubview:self.refrshControl];
    }
    return _tableView;
}

- (NSMutableArray *)datas {
    if (!_datas) {
        _datas = [NSMutableArray new];
    }
    return _datas;
}

- (NSMutableArray *)otherStates {
    if (!_otherStates) {
        _otherStates = [NSMutableArray new];
    }
    return _otherStates;
}

- (NSInteger)pageIndex {
    if (!_pageIndex) {
        _pageIndex = 0;
    }
    return _pageIndex;
}

- (NSArray<NSString *> *)classifyArr {
    if (!_classifyArr) {
        _classifyArr = @[@"DOUJINSHI",
                         @"MANGA",
                         @"ARTIST CG",
                         @"GAME CG",
                         @"WESTERN",
                         @"NON-H",
                         @"IMAGE SET",
                         @"COSPLAY",
                         @"ASIAN PORN",
                         @"MISC"];
    }
    return _classifyArr;
}

- (NSDictionary *)searchKeyDict {
    if (nil == _searchKeyDict) {
        _searchKeyDict = @{
                           @"DOUJINSHI":@"&f_doujinshi=",
                           @"MANGA":@"&f_manga=",
                           @"ARTIST CG":@"&f_artistcg=",
                           @"GAME CG":@"&f_gamecg=",
                           @"WESTERN":@"&f_western=",
                           @"NON-H":@"&f_non-h=",
                           @"IMAGE SET":@"&f_imageset=",
                           @"COSPLAY":@"&f_cosplay=",
                           @"ASIAN PORN":@"&f_asianporn=",
                           @"MISC":@"&f_misc="
                           };
    }
    return _searchKeyDict;
}

- (UIRefreshControl *)refrshControl {
    if (nil == _refrshControl) {
        _refrshControl = [UIRefreshControl new];
        [_refrshControl addTarget:self action:@selector(readyUpdateResource) forControlEvents:UIControlEventValueChanged];
    }
    return _refrshControl;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
