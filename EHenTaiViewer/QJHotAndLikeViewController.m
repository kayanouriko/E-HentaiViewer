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
#import "QJInfoViewController.h"
#import "QJHeadFreshingView.h"
#import "QJEnum.h"
#import "QJScrollHeadView.h"
#import "QJScrollView.h"

#import "QJLoginViewController.h"
#import "QJFavSelectViewController.h"

@interface QJHotAndLikeViewController ()<UITableViewDelegate,UITableViewDataSource,QJHeadFreshingViewDelagate,QJScrollHeadViewDelagate,UIScrollViewDelegate,QJFavSelectViewControllerDelagate>

@property (nonatomic, strong) QJScrollHeadView *scrollHeadView;
@property (nonatomic, strong) QJScrollView *scrollView;
@property (nonatomic, strong) QJListTableView *hotTableView;
@property (nonatomic, strong) QJListTableView *likeTableview;
@property (nonatomic, strong) NSMutableArray *hotDatas;
@property (nonatomic, strong) NSMutableArray *likeDatas;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, strong) QJHeadFreshingView *hotRefreshingView;
@property (nonatomic, strong) QJHeadFreshingView *likeRefreshingView;
@property (nonatomic, assign) QJFreshStatus status;
@property (nonatomic, assign) BOOL canFreshMore;
@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UIView *likeBgView;

@end

@implementation QJHotAndLikeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setContent];
    [self.hotRefreshingView beginReFreshing];
}

- (void)fristRefreshLike {
    if (self.canFreshMore) {
        self.canFreshMore = NO;
        [self.likeRefreshingView beginReFreshing];
    }
}

#pragma mark -QJHeadFreshingViewDelagate
- (void)beginRefreshing {
    if ([self.hotRefreshingView isReFreshing]) {
        [self updateHotResource];
    }
    else if ([self.likeRefreshingView isReFreshing]) {
        [self updateLikeResource];
    }
}

- (void)updateHotResource {
    [[QJHenTaiParser parser] updateHotListInfoComplete:^(QJHenTaiParserStatus status, NSArray<QJListItem *> *listArray) {
        if (self.status == QJFreshStatusRefresh) {
            [self.hotDatas removeAllObjects];
        }
        if (status == QJHenTaiParserStatusSuccess) {
            [self.hotDatas addObjectsFromArray:listArray];
            [self.hotTableView reloadData];
        }
        [self.hotRefreshingView endRefreshing];
    }];
}

- (void)updateLikeResource {
    [[QJHenTaiParser parser] updateLikeListInfoWithUrl:[self getLikeUrl] complete:^(QJHenTaiParserStatus status, NSArray<QJListItem *> *listArray) {
        if (self.status == QJFreshStatusRefresh) {
            [self.likeDatas removeAllObjects];
        }
        if (status == QJHenTaiParserStatusSuccess) {
            [self.likeDatas addObjectsFromArray:listArray];
            [self.likeTableview reloadData];
        }
        [self.likeRefreshingView endRefreshing];
    }];
}

- (NSString *)getLikeUrl {
    if (self.pageIndex == 0) {
        return @"favorites.php";
    }
    return [NSString stringWithFormat:@"favorites.php?page=%ld",self.pageIndex];
}

- (void)setContent {
    self.canFreshMore = YES;
    self.pageIndex = 0;
    self.navigationItem.titleView = self.scrollHeadView;
    [self.view addSubview:self.scrollView];
}

#pragma mark -tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.hotTableView) {
        return self.hotDatas.count;
    }
    else {
        return self.likeDatas.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QJListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QJListCell class])];
    if (tableView == self.hotTableView) {
        [cell refreshUI:self.hotDatas[indexPath.row]];
    }
    else {
        [cell refreshUI:self.likeDatas[indexPath.row]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QJInfoViewController *vc = [QJInfoViewController new];
    vc.hidesBottomBarWhenPushed = YES;
    if (tableView == self.hotTableView) {
        vc.item = self.hotDatas[indexPath.row];
    }
    else {
        vc.item = self.likeDatas[indexPath.row];
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView == self.likeTableview ? YES : NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [[QJHenTaiParser parser] updateFavoriteStatus:YES model:self.likeDatas[indexPath.row] index:0 content:@"" complete:^(QJHenTaiParserStatus status) {
        if (status == QJHenTaiParserStatusSuccess) {
            ToastSuccess(nil, @"取消收藏操作成功!");
            [self.likeDatas removeObject:self.likeDatas[indexPath.row]];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"取消收藏";
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.scrollView) {
        self.hotTableView.scrollEnabled = NO;
        self.likeTableview.scrollEnabled = NO;
    }
    /*
    if (scrollView == self.likeTableview) {
        //预加载
        CGFloat current = scrollView.contentOffset.y + scrollView.frame.size.height;
        CGFloat total = scrollView.contentSize.height;
        CGFloat ratio = current / total;
        
        CGFloat needRead = 25 * 0.7 + self.pageIndex * 25;
        CGFloat totalItem = 25 * (self.pageIndex + 1);
        CGFloat newThreshold = needRead / totalItem;
        
        if (self.likeDatas.count && ratio >= newThreshold) {
            self.status = QJFreshStatusMore;
            self.pageIndex++;
            NSLog(@"Request page %ld from server.",self.pageIndex);
            [self updateLikeResource];
        }
    }
     */
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        self.hotTableView.scrollEnabled = YES;
        self.likeTableview.scrollEnabled = YES;
        self.scrollHeadView.selectedIndex = self.scrollView.contentOffset.x / UIScreenWidth();
        if (self.scrollHeadView.selectedIndex) {
            [self fristRefreshLike];
        }
    }
}

#pragma mark -QJScrollHeadViewDelagate
- (void)didSelectedTitleWithIndex:(NSInteger)index {
    [self.scrollView setContentOffset:CGPointMake(UIScreenWidth() * index, 0) animated:YES];
    if (index) {
        [self fristRefreshLike];
    }
}

#pragma mark -跳转收藏夹
- (void)selectFavFolder {
    QJFavSelectViewController *vc = [QJFavSelectViewController new];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark -QJFavSelectViewControllerDelagate
- (void)didSelectFavFolder:(NSInteger)index {
    [self.likeButton setTitle:[NSString stringWithFormat:@"Favorites %ld >",index] forState:UIControlStateNormal];
}

#pragma mark -getter
- (QJScrollView *)scrollView {
    if (nil == _scrollView) {
        _scrollView = [[QJScrollView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth(), UIScreenHeight())];
        _scrollView.contentSize = CGSizeMake(UIScreenWidth() * 2, UIScreenHeight());
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.delegate = self;
        [_scrollView addSubview:self.hotTableView];
        [_scrollView addSubview:self.likeTableview];
        [_scrollView addSubview:self.likeBgView];
    }
    return _scrollView;
}

- (QJScrollHeadView *)scrollHeadView {
    if (!_scrollHeadView) {
        _scrollHeadView = [[NSBundle mainBundle] loadNibNamed:@"QJScrollHeadView" owner:nil options:nil].firstObject;
        _scrollHeadView.frame = CGRectMake(0, 0, UIScreenWidth(), UISearchBarHeight());
        _scrollHeadView.delegate = self;
    }
    return _scrollHeadView;
}

- (QJListTableView *)hotTableView {
    if (nil == _hotTableView) {
        _hotTableView = [QJListTableView new];
        _hotTableView.delegate = self;
        _hotTableView.dataSource = self;
        [_hotTableView addSubview:self.hotRefreshingView];
    }
    return _hotTableView;
}

- (QJListTableView *)likeTableview {
    if (nil == _likeTableview) {
        _likeTableview = [QJListTableView new];
        _likeTableview.frame = CGRectMake(isPad ? UIScreenWidth() + 60 : UIScreenWidth(), 40, isPad ? UIScreenWidth() - 120 : UIScreenWidth(), UIScreenHeight());
        _likeTableview.delegate = self;
        _likeTableview.dataSource = self;
        [_likeTableview addSubview:self.likeRefreshingView];
    }
    return _likeTableview;
}

- (NSMutableArray *)hotDatas {
    if (!_hotDatas) {
        _hotDatas = [NSMutableArray new];
    }
    return _hotDatas;
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

- (QJHeadFreshingView *)hotRefreshingView {
    if (nil == _hotRefreshingView) {
        _hotRefreshingView = [[QJHeadFreshingView alloc] initWithFrame:CGRectMake(0, -kRefreshingViewHeight, isPad ? UIScreenWidth() - 120 : UIScreenWidth(), kRefreshingViewHeight)];
        _hotRefreshingView.delegate = self;
    }
    return _hotRefreshingView;
}

- (QJHeadFreshingView *)likeRefreshingView {
    if (nil == _likeRefreshingView) {
        _likeRefreshingView = [[QJHeadFreshingView alloc] initWithFrame:CGRectMake(0, -kRefreshingViewHeight, isPad ? UIScreenWidth() - 120 : UIScreenWidth(), kRefreshingViewHeight)];
        _likeRefreshingView.delegate = self;
    }
    return _likeRefreshingView;
}

- (UIButton *)likeButton {
    if (nil == _likeButton) {
        _likeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _likeButton.frame = CGRectMake(0, 0, UIScreenWidth(), 40);
        [_likeButton setTitle:@"全部收藏夹 >" forState:UIControlStateNormal];
        [_likeButton addTarget:self action:@selector(selectFavFolder) forControlEvents:UIControlEventTouchUpInside];
    }
    return _likeButton;
}

- (UIView *)likeBgView {
    if (nil == _likeBgView) {
        _likeBgView = [[UIView alloc] initWithFrame:CGRectMake(UIScreenWidth(), UINavigationBarHeight(), UIScreenWidth(),40)];
        _likeBgView.backgroundColor = [UIColor whiteColor];
        [_likeBgView addSubview:self.likeButton];
    }
    return _likeBgView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
