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
#import "QJListItem.h"
//详情页
#import "QJSearchController.h"
#import "QJNewInfoViewController.h"
#import "QJNewSearchViewController.h"

@interface QJHomeViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate>

@property (nonatomic, strong) UIButton *pageButton;
@property (nonatomic, strong) UIAlertAction *action1;
//列表
@property (nonatomic, strong) QJListTableView *tableView;
@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, assign) float oldOffsetY;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, assign) NSInteger totalPage;
@property (nonatomic, assign) QJFreshStatus status;
//刷新提示文字
@property (nonatomic, strong) UIRefreshControl *refrshControl;

// 搜索框相关
@property (strong, nonatomic) QJNewSearchViewController *searchVC;

@end

@implementation QJHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (nil != self.title && self.title.length > 0) {
        self.navigationItem.title = self.title;
    } else {
        self.navigationItem.title = [QJGlobalInfo isExHentaiStatus] ? @"ExHentai" : @"E-Hentai";
    }
}

#pragma mark -View Control
- (void)jumpPageAction {
    if (self.totalPage) {
        // 构建弹出框
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"页码跳转" message:[NSString stringWithFormat:@"请输入一个 1 ~ %ld 之间的页码数字", self.totalPage] preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            [textField addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
            textField.textAlignment = NSTextAlignmentCenter;
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.placeholder = @"请输入";
        }];
        self.action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self showFreshingViewWithTip:nil];
            self.status = QJFreshStatusRefresh;
            self.pageIndex = [alert.textFields.firstObject.text integerValue] - 1;
            NSLog(@"Request page %ld from server.",self.pageIndex);
            [self updateResource];
            
            [self changeRightButtonInfoWithIndex:self.pageIndex + 1];
        }];
        self.action1.enabled = NO;
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:self.action1];
        [alert addAction:action2];
        
        [self presentViewController:alert animated:YES completion:nil];

    }
    else {
        Toast(@"跳页功能暂时无法使用");
    }
}

- (void)textFieldTextChange:(UITextField *)textField {
    NSInteger page = [textField.text integerValue];
    self.action1.enabled = page && page > 0 && page <= self.totalPage;
}

- (void)changeRightButtonInfoWithIndex:(NSInteger)index {
    self.pageButton.titleLabel.text = [NSString stringWithFormat:@"%ld", index];
    [self.pageButton setTitle:[NSString stringWithFormat:@"%ld", index] forState:UIControlStateNormal];
}

#pragma mark -滚动到顶部
- (void)scrollToTop {
    if (self.datas.count) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
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
    } total:^(NSInteger total) {
        self.totalPage = total <= 0 ? 0 : total;
    }];
}

//首页接收来自网页设置的影响,不再需要手动修改各个搜索选项
- (NSString *)makeUrl {
    NSMutableString *url = [NSMutableString stringWithString:@""];
    if (nil != self.url && self.url.length > 0) {
        [url appendString:self.url];
    }
    if (self.pageIndex) {
        [url appendFormat:@"?page=%ld", self.pageIndex];
    }
    return url;
}

#pragma mark -设置内容
- (void)setContent {
    // 开启大标题功能
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAutomatic;
    
    self.totalPage = 0;
    
    UIView *logoView = [UIView new];
    logoView.frame = CGRectMake(0, 0, 97.5f, 30.f);
    UIImageView *imageView = [UIImageView new];
    imageView.image = [UIImage imageNamed:@"home_logo"];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    imageView.frame = logoView.frame;
    [logoView addSubview:imageView];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:logoView];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:self.pageButton];
    self.navigationItem.rightBarButtonItem = item;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.view);
    }];
    // 配置搜索控制器
    QJSearchController *searchVC = [[QJSearchController alloc] initWithSearchResultsController:self.searchVC];
    searchVC.delegate = self;
    searchVC.searchResultsUpdater = self;
    searchVC.searchBar.delegate = self;
    self.navigationItem.searchController = searchVC;
    self.navigationItem.hidesSearchBarWhenScrolling = NO;
    self.definesPresentationContext = YES;
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchVC viewsShouldSearchBarSearchButtonClicked:searchBar];
}

// 点击筛选按钮的时候
- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
    [self.searchVC viewsShouldSearchBarBookmarkButtonClicked:searchBar];
}

#pragma mark - 搜索代理
- (void)willPresentSearchController:(UISearchController *)searchController {
    searchController.searchBar.showsBookmarkButton = YES;
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    searchController.searchResultsController.view.hidden = NO;
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    searchController.searchBar.showsBookmarkButton = NO;
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    searchController.searchResultsController.view.hidden = NO;
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
    vc.model = self.datas[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //预加载
    CGFloat current = scrollView.contentOffset.y + scrollView.frame.size.height;
    CGFloat total = scrollView.contentSize.height;
    CGFloat ratio = current / total;
    
    CGFloat needRead = 25 * 0.5 + self.pageIndex * 25;
    CGFloat totalItem = 25 * (self.pageIndex + 1);
    CGFloat newThreshold = needRead / totalItem;
    
    if (self.datas.count && ratio >= newThreshold && self.status == QJFreshStatusNone) {
        self.status = QJFreshStatusMore;
        self.pageIndex++;
        NSLog(@"Request page %ld from server.",self.pageIndex);
        [self updateResource];
    }
    
    // 改变右上角显示
    QJListCell *cell = [self.tableView visibleCells].firstObject;
    if (cell) {
        QJListItem *item = self.datas[[self.tableView indexPathForCell:cell].row];
        NSInteger currentPage = item.page;
        [self changeRightButtonInfoWithIndex:currentPage];
    }
}

#pragma mark -getter
- (UIButton *)pageButton {
    if (!_pageButton) {
        _pageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _pageButton.frame = CGRectMake(0, 0, 45, 15);
        _pageButton.layer.cornerRadius = 5.f;
        _pageButton.backgroundColor = DEFAULT_COLOR;
        [_pageButton setTitle:[NSString stringWithFormat:@"%ld", self.pageIndex + 1] forState:UIControlStateNormal];
        _pageButton.titleLabel.text = [NSString stringWithFormat:@"%ld", self.pageIndex + 1];
        _pageButton.titleLabel.font = [UIFont systemFontOfSize:12.f];
        [_pageButton addTarget:self action:@selector(jumpPageAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pageButton;
}

- (QJListTableView *)tableView {
    if (!_tableView) {
        _tableView = [QJListTableView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        //添加刷新模块
        _tableView.refreshControl = self.refrshControl;
    }
    return _tableView;
}

- (NSMutableArray *)datas {
    if (!_datas) {
        _datas = [NSMutableArray new];
    }
    return _datas;
}

- (NSInteger)pageIndex {
    if (!_pageIndex) {
        _pageIndex = 0;
    }
    return _pageIndex;
}

- (UIRefreshControl *)refrshControl {
    if (nil == _refrshControl) {
        _refrshControl = [UIRefreshControl new];
        [_refrshControl addTarget:self action:@selector(readyUpdateResource) forControlEvents:UIControlEventValueChanged];
    }
    return _refrshControl;
}

- (QJNewSearchViewController *)searchVC {
    if (nil == _searchVC) {
        _searchVC = [QJNewSearchViewController new];
        _searchVC.nav = self.navigationController;
        _searchVC.type = QJNewSearchViewControllerTypeSearch;
    }
    return _searchVC;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
