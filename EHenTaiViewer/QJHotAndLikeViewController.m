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
#import "QJEnum.h"
#import "QJLikeSearchBar.h"
#import "NSString+StringHeight.h"

#import "QJFavoritesSelectController.h"

@interface QJHotAndLikeViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, QJFavoritesSelectControllerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) QJLikeSearchBar *searchBar;
@property (nonatomic, strong) QJListTableView *likeTableview;
@property (nonatomic, strong) NSMutableArray *likeDatas;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, assign) QJFreshStatus status;
@property (nonatomic, assign) BOOL canFreshMore;
@property (nonatomic, assign) NSInteger favcat;
@property (nonatomic, strong) UIRefreshControl *refrshControl;

@property (nonatomic, strong) UIBarButtonItem *bookmarksItem;
@property (nonatomic, strong) UIBarButtonItem *editItem;
@property (nonatomic, strong) UIBarButtonItem *cancelItem;
@property (nonatomic, strong) UIBarButtonItem *doneItem;

@end

@implementation QJHotAndLikeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setContent];
    
    [self showFreshingViewWithTip:nil];
    [self updateLikeResource];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //等布局调整完成后再放xib布局的搜索框
    if (nil == self.likeTableview.tableHeaderView) {
        self.likeTableview.tableHeaderView = self.searchBar;
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
    //添加搜索项
    if (self.searchBar.searchTextF.text.length) {
        [url appendFormat:@"&f_search=%@&f_apply=Search+Favorites", [self.searchBar.searchTextF.text urlEncode]];
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
    self.pageIndex = 0;
    [self updateLikeResource];
    return YES;
}

#pragma mark -QJFavoritesSelectControllerDelegate
- (void)didSelectFavFolderNameWithArr:(NSArray<NSString *> *)array index:(NSInteger)index {
    self.favcat = index;
    self.pageIndex = 0;
    self.navigationItem.title = array.firstObject;
    [self showFreshingViewWithTip:nil];
    [self updateLikeResource];
}

- (void)setContent {
    self.status = QJFreshStatusNone;
    self.favcat = -1;
    self.canFreshMore = YES;
    self.pageIndex = 0;
    self.navigationItem.title = @"All Favorites";
    
    [self.view addSubview:self.likeTableview];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_likeTableview]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_likeTableview)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_likeTableview]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_likeTableview)]];
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
    if (tableView.editing) {
        //如果是编辑状态
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QJNewInfoViewController *vc = [QJNewInfoViewController new];
    vc.hidesBottomBarWhenPushed = YES;
    vc.model = self.likeDatas[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [[QJHenTaiParser parser] updateFavoriteStatus:YES model:self.likeDatas[indexPath.row] index:0 content:@"" complete:^(QJHenTaiParserStatus status) {
        if (status == QJHenTaiParserStatusSuccess) {
            Toast(@"收藏已取消");
            [self.likeDatas removeObject:self.likeDatas[indexPath.row]];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"取消收藏";
}

//多选相关
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete|UITableViewCellEditingStyleInsert;
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
        
        if (self.status != QJFreshStatusFreshing && self.status != QJFreshStatusNotMore && self.likeDatas.count && ratio >= newThreshold) {
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
    if (!self.likeTableview.isEditing) {
        [self.likeTableview setEditing:YES animated:YES];
        self.navigationItem.leftBarButtonItem = self.cancelItem;
        self.navigationItem.rightBarButtonItem = self.doneItem;
    }
}

- (void)cancelAction {
    if (self.likeTableview.isEditing) {
        [self.likeTableview setEditing:NO animated:YES];
        self.navigationItem.leftBarButtonItem = self.editItem;
        self.navigationItem.rightBarButtonItem = self.bookmarksItem;
    }
}

- (void)doneAction {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请选择你需要的操作" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"移至别处" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"The \"Okay/Cancel\" alert action sheet's destructive action occured.");
    }];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"取消收藏" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        NSLog(@"The \"Okay/Cancel\" alert action sheet's destructive action occured.");
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"The \"Okay/Cancel\" alert action sheet's cancel action occured.");
    }];
    
    [alertController addAction:otherAction];
    [alertController addAction:deleteAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark -getter
- (QJListTableView *)likeTableview {
    if (nil == _likeTableview) {
        _likeTableview = [QJListTableView new];
        _likeTableview.delegate = self;
        _likeTableview.dataSource = self;
        [_likeTableview addSubview:self.refrshControl];
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
        _bookmarksItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(selectFavFolder)];
    }
    return _bookmarksItem;
}

- (UIBarButtonItem *)editItem {
    if (nil == _editItem) {
        _editItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(selectPics)];
    }
    return _editItem;
}

- (UIBarButtonItem *)cancelItem {
    if (nil == _cancelItem) {
        _cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];
    }
    return _cancelItem;
}

- (UIBarButtonItem *)doneItem {
    if (nil == _doneItem) {
        _doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction)];
    }
    return _doneItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
