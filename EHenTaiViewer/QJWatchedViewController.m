//
//  QJWatchedViewController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2019/5/4.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import "QJWatchedViewController.h"
#import "QJListTableView.h"
#import "QJListCell.h"
#import "QJHenTaiParser.h"
#import "QJSearchController.h"
#import "QJNewSearchViewController.h"
#import "QJNewInfoViewController.h"
#import "QJListItem.h"

@interface QJWatchedViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate>

@property (nonatomic, strong) UIButton *pageButton;
@property (nonatomic, strong) UIAlertAction *action1;
@property (nonatomic, assign) QJFreshStatus status;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<QJListItem *> *datas;
@property (assign, nonatomic) NSInteger page;
@property (nonatomic, assign) NSInteger totalPage;
@property (nonatomic, strong) UIRefreshControl *refrshControl;
@property (strong, nonatomic) QJNewSearchViewController *searchVC;

@end

@implementation QJWatchedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 界面初始化
    [self setContent];
    // 刷新数据
    [self showFreshingViewWithTip:nil];
    [self updateDatas];
}

- (void)setContent {
    // 一些数据的初始化
    self.page = 0;
    self.status = QJFreshStatusNone;
    
    self.title = @"关注";
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAutomatic;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:self.pageButton];
    self.navigationItem.rightBarButtonItem = item;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
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

- (void)scrollToTop {
    if (self.datas.count) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
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
            self.page = [alert.textFields.firstObject.text integerValue] - 1;
            NSLog(@"Request page %ld from server.",self.page);
            [self updateDatas];
            
            [self changeRightButtonInfoWithIndex:self.page + 1];
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

- (void)changeRightButtonInfoWithIndex:(NSInteger)index {
    self.pageButton.titleLabel.text = [NSString stringWithFormat:@"%ld", index];
    [self.pageButton setTitle:[NSString stringWithFormat:@"%ld", index] forState:UIControlStateNormal];
}

- (void)textFieldTextChange:(UITextField *)textField {
    NSInteger page = [textField.text integerValue];
    self.action1.enabled = page && page > 0 && page <= self.totalPage;
}

#pragma mark - Update Datas
- (void)readyUpdateResource {
    self.status = QJFreshStatusRefresh;
    self.page = 0;
    [self updateDatas];
}

- (void)updateDatas {
    [[QJHenTaiParser parser] updateWatchedListInfoWithUrl:[NSString stringWithFormat:@"watched?page=%ld", self.page] complete:^(QJHenTaiParserStatus status, NSArray<QJListItem *> *listArray) {
        
        if (self.status == QJFreshStatusRefresh) {
            [self.datas removeAllObjects];
        }
        self.status = QJFreshStatusNone;
        
        if (status == QJHenTaiParserStatusSuccess) {
            [self.datas addObjectsFromArray:listArray];
            [self.tableView reloadData];
        }
        else if (status == QJHenTaiParserStatusNetworkFail || status == QJHenTaiParserStatusParseFail) {
            self.page--;
        }
        else if (status == QJHenTaiParserStatusParseNoMore) {
            self.status = QJFreshStatusNotMore;
            self.page--;
        }
        if ([self.refrshControl isRefreshing]) {
            [self.refrshControl endRefreshing];
        }
        [self hiddenFreshingView];
    } total:^(NSInteger total) {
        self.totalPage = total <= 0 ? 0 : total;
    }];
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //预加载
    CGFloat current = scrollView.contentOffset.y + scrollView.frame.size.height;
    CGFloat total = scrollView.contentSize.height;
    CGFloat ratio = current / total;
    
    CGFloat needRead = 25 * 0.5 + self.page * 25;
    CGFloat totalItem = 25 * (self.page + 1);
    CGFloat newThreshold = needRead / totalItem;
    
    if (self.datas.count && ratio >= newThreshold && self.status == QJFreshStatusNone) {
        self.status = QJFreshStatusMore;
        self.page++;
        NSLog(@"Request page %ld from server.",self.page);
        [self updateDatas];
    }
    
    // 改变右上角显示
    QJListCell *cell = [self.tableView visibleCells].firstObject;
    if (cell) {
        QJListItem *item = self.datas[[self.tableView indexPathForCell:cell].row];
        NSInteger currentPage = item.page;
        [self changeRightButtonInfoWithIndex:currentPage];
    }
}

#pragma mark - TableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QJListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(QJListCell.class) forIndexPath:indexPath];
    [cell refreshUI:self.datas[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QJNewInfoViewController *vc = [QJNewInfoViewController new];
    vc.model = self.datas[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [QJListTableView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.refreshControl = self.refrshControl;
    }
    return _tableView;
}

- (NSMutableArray<QJListItem *> *)datas {
    if (!_datas) {
        _datas = [NSMutableArray new];
    }
    return _datas;
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
        _searchVC.type = QJNewSearchViewControllerTypeWatched;
    }
    return _searchVC;
}

- (UIButton *)pageButton {
    if (!_pageButton) {
        _pageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _pageButton.frame = CGRectMake(0, 0, 45, 15);
        _pageButton.layer.cornerRadius = 5.f;
        _pageButton.backgroundColor = DEFAULT_COLOR;
        [_pageButton setTitle:[NSString stringWithFormat:@"%ld", self.page + 1] forState:UIControlStateNormal];
        _pageButton.titleLabel.text = [NSString stringWithFormat:@"%ld", self.page + 1];
        _pageButton.titleLabel.font = [UIFont systemFontOfSize:12.f];
        [_pageButton addTarget:self action:@selector(jumpPageAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pageButton;
}

@end
