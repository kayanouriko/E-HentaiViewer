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

#import "QJLoginViewController.h"

@interface QJHotAndLikeViewController ()<UITableViewDelegate,UITableViewDataSource,QJHeadFreshingViewDelagate,QJScrollHeadViewDelagate,UIScrollViewDelegate>

@property (nonatomic, strong) QJScrollHeadView *scrollHeadView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) QJListTableView *hotTableView;
@property (nonatomic, strong) QJListTableView *likeTableview;
@property (nonatomic, strong) NSMutableArray *hotDatas;
@property (nonatomic, strong) NSMutableArray *likeDatas;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, strong) QJHeadFreshingView *hotRefreshingView;
@property (nonatomic, strong) QJHeadFreshingView *likeRefreshingView;
@property (nonatomic, assign) QJFreshStatus status;
@property (nonatomic, assign) BOOL canFreshMore;

@end

@implementation QJHotAndLikeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setContent];
    [self.hotRefreshingView beginReFreshing];
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

#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
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
        self.scrollHeadView.selectedIndex = self.scrollView.contentOffset.x / UIScreenWidth();
    }
}

#pragma mark -QJScrollHeadViewDelagate
- (void)didSelectedTitleWithIndex:(NSInteger)index {
    [self.scrollView setContentOffset:CGPointMake(UIScreenWidth() * index, 0) animated:YES];
}

#pragma mark -getter
- (UIScrollView *)scrollView {
    if (nil == _scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth(), UIScreenHeight())];
        _scrollView.contentSize = CGSizeMake(UIScreenWidth() * 2, UIScreenHeight());
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        [_scrollView addSubview:self.hotTableView];
        [_scrollView addSubview:self.likeTableview];
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
        _likeTableview.frame = CGRectMake(UIScreenWidth() + 60, 0, UIScreenWidth() - 120, UIScreenHeight());
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
