//
//  QJHotAndLikeViewController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/17.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJHotAndLikeViewController.h"
#import "QJListCell.h"
#import "QJHenTaiParser.h"
#import "QJListTableView.h"
#import "QJNewInfoViewController.h"
#import "QJLikeSearchBar.h"
//iconfont
#import "TBCityIconFont.h"
#import "UIImage+TBCityIconFont.h"

#import "QJFavoritesSelectController.h"

//详情页
#import "QJSearchController.h"
#import "QJNewSearchViewController.h"

@interface QJHotAndLikeViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, QJFavoritesSelectControllerDelegate, UITextFieldDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate>

@property (nonatomic, strong) QJLikeSearchBar *searchBar;
@property (nonatomic, strong) QJListTableView *likeTableview;
@property (nonatomic, strong) NSMutableArray *likeDatas;
@property (nonatomic, strong) NSMutableArray<QJListItem *> *selectDatas;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, assign) QJFreshStatus status;
@property (nonatomic, assign) BOOL canFreshMore;
@property (nonatomic, assign) NSInteger favcat;
@property (nonatomic, strong) UIRefreshControl *refrshControl;

@property (nonatomic, strong) UIBarButtonItem *bookmarksItem;
@property (nonatomic, strong) UIBarButtonItem *editItem;
@property (nonatomic, strong) UIBarButtonItem *cancelItem;
@property (nonatomic, strong) UIBarButtonItem *doneItem;

@property (nonatomic, strong) NSString *ddact;//记录操作动作

// 搜索框相关
@property (strong, nonatomic) QJNewSearchViewController *searchVC;

@end

@implementation QJHotAndLikeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setContent];
    
    [self showFreshingViewWithTip:nil];
    [self updateLikeResource];
}

#pragma mark -滚动到顶部
- (void)scrollToTop {
    if (self.likeDatas.count) {
        [self.likeTableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)updateLikeResource {
    if (![[QJHenTaiParser parser] checkCookie]) {
        Toast(@"请先前往设置页面进行登录");
        [self stopSomethingCommon];
        return;
    }
    [[QJHenTaiParser parser] updateLikeListInfoWithUrl:[self getLikeUrl] complete:^(QJHenTaiParserStatus status, NSArray<QJListItem *> *listArray) {
        if ([self.refrshControl isRefreshing] || self.pageIndex == 0) {
            [self.likeDatas removeAllObjects];
        }
        if (status == QJHenTaiParserStatusSuccess) {
            //收藏夹按钮设置
            if (nil == self.navigationItem.rightBarButtonItem) {
                self.navigationItem.rightBarButtonItem = self.bookmarksItem;
            }
            //多功能操作按钮实现
            if (listArray.count && nil == self.navigationItem.leftBarButtonItem) {
                self.navigationItem.leftBarButtonItem = self.editItem;
            }
            else if (listArray.count == 0 && nil != self.navigationItem.leftBarButtonItem) {
                self.navigationItem.leftBarButtonItem = nil;
            }
            
            [self.likeDatas addObjectsFromArray:listArray];
            [self.likeTableview reloadData];
        }
        else if (status == QJHenTaiParserStatusParseNoMore) {
            [self.likeTableview reloadData];
        }
        self.status = listArray.count ? QJFreshStatusNone : QJFreshStatusNotMore;
        [self stopSomethingCommon];
    }];
}

- (void)stopSomethingCommon {
    if ([self.refrshControl isRefreshing]) {
        [self.refrshControl endRefreshing];
    }
    if ([self isShowFreshingStatus]) {
        [self hiddenFreshingView];
    }
}

- (NSString *)getLikeUrl {
    NSMutableString *url = [NSMutableString stringWithString:@"favorites.php"];
    //添加收藏夹类型
    NSString *favcatValue = @"all";
    if (self.favcat != -1) {
        favcatValue = [NSString stringWithFormat:@"%ld", self.favcat];
    }
    [url appendFormat:@"?favcat=%@", favcatValue];
    // 添加搜索项
    // 默认做全局搜索
    if (self.searchBar.searchTextF.text.length) {
        [url appendFormat:@"&f_search=%@&sn=on&st=on&sf=on", [self.searchBar.searchTextF.text urlEncode]];
    }
    //添加页码
    if (self.pageIndex > 0) {
        [url appendFormat:@"&page=%ld", self.pageIndex];
    }
    return url;
}

#pragma mark -UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    self.status = QJFreshStatusFreshing;
    self.pageIndex = 0;
    [self updateLikeResource];
    return YES;
}

#pragma mark -QJFavoritesSelectControllerDelegate
- (void)didSelectFavFolderNameWithArr:(NSArray<NSString *> *)array index:(NSInteger)index {
    if (self.ddact.length) {
        //移到别处的操作
        self.ddact = [NSString stringWithFormat:@"fav%ld", index];
        [self didFavOrderAction];
    } else {
        //切换收藏夹
        self.favcat = index;
        self.pageIndex = 0;
        self.navigationItem.title = array.firstObject;
        [self showFreshingViewWithTip:nil];
        [self updateLikeResource];
    }
}

- (void)setContent {
    // 开启大标题功能
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAutomatic;
    
    self.status = QJFreshStatusNone;
    self.favcat = -1;
    self.canFreshMore = YES;
    self.pageIndex = 0;
    self.navigationItem.title = @"All Favorites";
    self.ddact = @"";
    
    [self.view addSubview:self.likeTableview];
    [self.likeTableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.view);
    }];
    
    // 配置搜索控制器
    QJSearchController *searchVC = [[QJSearchController alloc] initWithSearchResultsController:self.searchVC];
    searchVC.delegate = self;
    searchVC.searchResultsUpdater = self;
    searchVC.searchBar.delegate = self;
    searchVC.searchBar.enablesReturnKeyAutomatically = YES;
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
- (void)didPresentSearchController:(UISearchController *)searchController {
    searchController.searchResultsController.view.hidden = NO;
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    searchController.searchResultsController.view.hidden = NO;
}


#pragma mark -tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.likeDatas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QJListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QJListCell class])];
    [cell refreshUI:self.likeDatas[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QJListItem *model = self.likeDatas[indexPath.row];
    if (tableView.editing) {
        //如果是编辑状态,这里收集对应的model
        if (![self.selectDatas containsObject:model]) {
            [self.selectDatas addObject:model];
        }
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QJNewInfoViewController *vc = [QJNewInfoViewController new];
    // vc.hidesBottomBarWhenPushed = YES;
    vc.model = model;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.editing) {
        QJListItem *model = self.likeDatas[indexPath.row];
        if ([self.selectDatas containsObject:model]) {
            [self.selectDatas removeObject:model];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

//多选相关
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.likeTableview) {
        //预加载
        CGFloat current = scrollView.contentOffset.y + scrollView.frame.size.height;
        CGFloat total = scrollView.contentSize.height;
        CGFloat ratio = current / total;
        
        CGFloat needRead = 25 * 0.7 + self.pageIndex * 25;
        CGFloat totalItem = 25 * (self.pageIndex + 1);
        CGFloat newThreshold = needRead / totalItem;
        
        if (!self.likeTableview.isEditing && self.status != QJFreshStatusFreshing && self.status != QJFreshStatusNotMore && self.likeDatas.count && ratio >= newThreshold) {
            self.status = QJFreshStatusFreshing;
            self.pageIndex++;
            NSLog(@"Request page %ld from server.",self.pageIndex);
            [self updateLikeResource];
        }
    }
}

#pragma mark -跳转收藏夹
- (void)selectFavFolder {
    QJFavoritesSelectController *vc = [QJFavoritesSelectController new];
    vc.delegate = self;
    vc.likeVCJump = YES;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -多功能操作
- (void)selectPics {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请选择你需要的操作" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"移至别处" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.ddact = @"fav";
        [self changeTableviewSelectMode];
    }];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"取消收藏" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        self.ddact = @"delete";
        [self changeTableviewSelectMode];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        self.ddact = @"";
    }];
    [alertController addAction:otherAction];
    [alertController addAction:deleteAction];
    [alertController addAction:cancelAction];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover) {
        popover.barButtonItem = self.editItem;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)changeTableviewSelectMode {
    if (!self.likeTableview.isEditing) {
        [self.likeTableview setEditing:YES animated:YES];
        self.navigationItem.leftBarButtonItem = self.cancelItem;
        self.navigationItem.rightBarButtonItem = self.doneItem;
        self.searchBar.userInteractionEnabled = NO;
        [self.selectDatas removeAllObjects];
    }
}

- (void)cancelAction {
    if (self.likeTableview.isEditing) {
        [self.likeTableview setEditing:NO animated:YES];
        self.navigationItem.leftBarButtonItem = self.editItem;
        self.navigationItem.rightBarButtonItem = self.bookmarksItem;
        self.searchBar.userInteractionEnabled = YES;
        self.ddact = @"";
    }
}

- (void)doneAction {
    if (self.selectDatas.count == 0) {
        Toast(@"至少先选中一项才能进行操作");
        return;
    }
    if ([self.ddact containsString:@"fav"]) {
        //移到别处
        [self moveBookToOther];
    } else {
        //取消收藏
        [self deleteFromFav];
    }
}

- (void)moveBookToOther {
    QJFavoritesSelectController *vc = [QJFavoritesSelectController new];
    vc.delegate = self;
    vc.likeVCJump = NO; // 作用是隐藏全部收藏的选项
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)deleteFromFav {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定从你的收藏夹中移除选中画廊?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self didFavOrderAction];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didFavOrderAction {
    //呈现刷新的提示
    [self showFreshingViewWithTip:nil];
    //执行操作
    NSMutableString *url = [NSMutableString stringWithString:@"favorites.php"];
    //添加收藏夹类型
    if (self.favcat != -1) {
        [url appendFormat:@"?favcat=%ld", self.favcat];
    }
    [[QJHenTaiParser parser] updateMutlitFavoriteWithUrl:url status:self.ddact modifygids:self.selectDatas complete:^(QJHenTaiParserStatus status) {
        [self readyRefreshInfo];
    }];
    //无论成功失败都先退出多选模式
    if (self.likeTableview.isEditing) {
        [self.likeTableview setEditing:NO animated:NO];
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
        self.searchBar.userInteractionEnabled = YES;
        self.ddact = @"";
    }
}

#pragma mark -getter
- (QJListTableView *)likeTableview {
    if (nil == _likeTableview) {
        _likeTableview = [QJListTableView new];
        _likeTableview.delegate = self;
        _likeTableview.dataSource = self;
        _likeTableview.refreshControl = self.refrshControl;
    }
    return _likeTableview;
}

- (NSMutableArray *)likeDatas {
    if (!_likeDatas) {
        _likeDatas = [NSMutableArray new];
    }
    return _likeDatas;
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
        [_refrshControl addTarget:self action:@selector(readyRefreshInfo) forControlEvents:UIControlEventValueChanged];
    }
    return _refrshControl;
}

- (void)readyRefreshInfo {
    self.status = QJFreshStatusFreshing;
    self.pageIndex = 0;
    [self updateLikeResource];
}

- (QJLikeSearchBar *)searchBar {
    if (nil == _searchBar) {
        _searchBar = [[NSBundle mainBundle] loadNibNamed:@"QJLikeSearchBar" owner:nil options:nil][0];
        _searchBar.searchTextF.delegate = self;
    }
    return _searchBar;
}

- (UIBarButtonItem *)bookmarksItem {
    if (nil == _bookmarksItem) {
        _bookmarksItem = [[UIBarButtonItem alloc] initWithImage:[UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e619", 25, [UIColor whiteColor])] style:UIBarButtonItemStylePlain target:self action:@selector(selectFavFolder)];
    }
    return _bookmarksItem;
}

- (UIBarButtonItem *)editItem {
    if (nil == _editItem) {
        _editItem = [[UIBarButtonItem alloc] initWithImage:[UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e606", 25, [UIColor whiteColor])] style:UIBarButtonItemStylePlain target:self action:@selector(selectPics)];
    }
    return _editItem;
}

- (UIBarButtonItem *)cancelItem {
    if (nil == _cancelItem) {
        _cancelItem = [[UIBarButtonItem alloc] initWithImage:[UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e607", 25, [UIColor whiteColor])] style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    }
    return _cancelItem;
}

- (UIBarButtonItem *)doneItem {
    if (nil == _doneItem) {
        _doneItem = [[UIBarButtonItem alloc] initWithImage:[UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e62e", 25, [UIColor whiteColor])] style:UIBarButtonItemStylePlain target:self action:@selector(doneAction)];
    }
    return _doneItem;
}

- (NSMutableArray<QJListItem *> *)selectDatas {
    if (nil == _selectDatas) {
        _selectDatas = [NSMutableArray new];
    }
    return _selectDatas;
}

- (QJNewSearchViewController *)searchVC {
    if (nil == _searchVC) {
        _searchVC = [QJNewSearchViewController new];
        _searchVC.nav = self.navigationController;
        _searchVC.type = QJNewSearchViewControllerTypeFavorites;
    }
    return _searchVC;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
