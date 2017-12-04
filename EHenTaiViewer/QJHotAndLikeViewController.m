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

#import "QJLoginViewController.h"
#import "QJFavSelectViewController.h"

@interface QJHotAndLikeViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, QJFavSelectViewControllerDelagate>

@property (nonatomic, strong) QJListTableView *likeTableview;
@property (nonatomic, strong) NSMutableArray *likeDatas;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, assign) QJFreshStatus status;
@property (nonatomic, assign) BOOL canFreshMore;
@property (nonatomic, strong) NSString *favcat;
@property (nonatomic, strong) UIRefreshControl *refrshControl;

@end

@implementation QJHotAndLikeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setContent];
    
    [self showFreshingViewWithTip:nil];
    [self updateLikeResource];
}

- (void)updateLikeResource {
    if (![[QJHenTaiParser parser] checkCookie]) {
        Toast(@"请先前往设置页面进行登录");
        return;
    }
    [[QJHenTaiParser parser] updateLikeListInfoWithUrl:[self getLikeUrl] complete:^(QJHenTaiParserStatus status, NSArray<QJListItem *> *listArray) {
        
        if ([self.refrshControl isRefreshing]) {
            [self.likeDatas removeAllObjects];
        }
        if (status == QJHenTaiParserStatusSuccess) {
            [self.likeDatas addObjectsFromArray:listArray];
            [self.likeTableview reloadData];
        }
        self.status = listArray.count ? QJFreshStatusNone : QJFreshStatusNotMore;
        [self.refrshControl endRefreshing];
        if ([self isShowFreshingStatus]) {
            [self hiddenFreshingView];
        }
    }];
}

- (NSString *)getLikeUrl {
    NSString *url = @"favorites.php";
    if ([self.favcat isEqualToString:@"all"]) {
        if (self.pageIndex == 0) {
            return url;
        } else {
            return [NSString stringWithFormat:@"%@?page=%ld", url, self.pageIndex];
        }
    }
    else {
        url = [NSString stringWithFormat:@"%@?%@",url, self.favcat];
        if (self.pageIndex == 0) {
            return url;
        }
        else {
            return [NSString stringWithFormat:@"%@&page=%ld", url, self.pageIndex];
        }
    }
}

- (void)setContent {
    self.status = QJFreshStatusNone;
    self.favcat = @"all";
    self.canFreshMore = YES;
    self.pageIndex = 0;
    self.navigationItem.title = @"全部收藏";
    
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
    Toast(@"暂时不支持选择收藏夹");
    return;
    QJFavSelectViewController *vc = [QJFavSelectViewController new];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
